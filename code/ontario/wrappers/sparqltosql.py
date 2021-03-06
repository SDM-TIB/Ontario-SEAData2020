__author__ = 'Kemele M. Endris and Philipp D. Rohde'

from ontario.sparql.parser.services import Filter, Expression, Argument, unaryFunctor, binaryFunctor
from ontario.model.rml_model import TripleMapType, SubjectMap
from ontario.model.rdfmt_model import DataSourceType
from ontario.sparql.parser import queryParser as qp
from .utilities import *
import logging
import hashlib

logger = logging.getLogger(__name__)
logger.setLevel(logging.INFO)
handler = logging.FileHandler('ontario-sparql2sql.log')
handler.setLevel(logging.INFO)
formatter = logging.Formatter('%(asctime)s - %(name)s - %(levelname)s - %(message)s')
handler.setFormatter(formatter)
logger.addHandler(handler)


class SPARQL2SQL(object):

    def __init__(self, sparql, mapping, datasource, rdfmts, star):
        self.mapping = mapping
        self.sparql = qp.parse(sparql)
        self.datasource = datasource
        self.rdfmts = rdfmts
        self.star = star
        self.prefixes = getPrefs(self.sparql.prefs)

    def translate(self):
        # TODO: include templates like http://example.org/{start}_{end} (2019-05-27)
        query_filters = [f for f in self.sparql.body.triples[0].triples if isinstance(f, Filter)]

        starpreds = list(self.star['predicates'].keys())
        star_preds = [p for p in starpreds if '?' not in p]

        if 'http://www.w3.org/1999/02/22-rdf-syntax-ns#type' in star_preds:
            star_preds.remove('http://www.w3.org/1999/02/22-rdf-syntax-ns#type')

        mapping_preds = {tm: triplemap for tm, triplemap in self.mapping.items() for p in star_preds if p in triplemap.predicate_object_map}

        # TODO: maybe this is only necessary because of the drugbank:Offer class
        #  which is in the RDF-MT file but not in the mappings (2019-06-12)
        # find the rdfmts that really can be answered by the source
        rdfmts = []
        capabilities = {}
        for rdfmt in self.star['rdfmts']:
            found = False
            for tm, triplemap in mapping_preds.items():
                if rdfmt in triplemap.subject_map.rdf_types:
                    found = True
            if found:
                rdfmts.append(rdfmt)
                capabilities.setdefault(rdfmt, self.star['datasources'][self.datasource.ID][rdfmt])

        query = None
        projvartocols = None
        coltotemplates = None
        database_name = None
        if len(rdfmts) == 1:
            query, projvartocols, coltotemplates, database_name = self.translate_single_query(mapping_preds, star_preds, rdfmts, self.star['triples'], query_filters)
        elif len(rdfmts) > 1:
            # TODO: deal with more than two RDF-MTs (2019-06-12)
            if len(rdfmts) > 2:
                logger.warn("More than two RDF-MTs - you will miss some results with the current implementation")

            preds1 = set(capabilities[rdfmts[0]])
            preds2 = set(capabilities[rdfmts[1]])
            intersection = preds1.intersection(preds2)

            if intersection == set():
                # empty intersection
                # translate both queries and join them
                # print("JOIN")
                query, projvartocols, coltotemplates, database_name = self.join_queries(preds1, preds2, rdfmts, query_filters)

                # print(query)
            elif intersection == preds1 and len(preds1) == len(preds2):
                # full union
                # translate both queries and union them
                # print("UNION")
                query, projvartocols, coltotemplates, database_name = self.union_queries(preds1, preds2, rdfmts, query_filters)
            else:
                # union of the intersection
                # translate the rest without intersection
                # join everything in the end
                # TODO: this needs to be implemented (2019-06-12)
                # print("JOINS AND UNIONS")
                a = 1

        return query, projvartocols, coltotemplates, database_name

    def join_queries(self, preds1, preds2, rdfmts, query_filters):
        mapping_preds1 = {tm: triplemap for tm, triplemap in self.mapping.items() for p in preds1 if
                          p in triplemap.predicate_object_map}
        mapping_preds2 = {tm: triplemap for tm, triplemap in self.mapping.items() for p in preds2 if
                          p in triplemap.predicate_object_map}

        triples1 = []
        triples2 = []
        for triple in self.star['triples']:
            if rdfmts[0] in triple.rdfmts:
                triples1.append(triple)
            if rdfmts[1] in triple.rdfmts:
                triples2.append(triple)

        vars1 = set(self.get_so_variables(triples1))
        vars2 = set(self.get_so_variables(triples2))
        join_vars = vars1.intersection(vars2)
        proj_vars = self.sparql.args.copy()
        for j in join_vars:
            self.sparql.args.append(Argument(j, False))  # project join variables

        q1, p1, c1, d1 = self.translate_single_query(mapping_preds1, preds1, [rdfmts[0]], triples1, query_filters)
        q2, p2, c2, d2 = self.translate_single_query(mapping_preds2, preds2, [rdfmts[1]], triples2, query_filters)

        # TODO: joins on multiple variables? (2019-06-12)
        j = join_vars.pop()
        join_cond = 'A.`' + j[1:] + '` = B.`' + j[1:] + '`'

        if self.sparql.distinct:
            query = "SELECT DISTINCT"
        else:
            query = "SELECT"

        projections = []
        for pv in proj_vars:
            if pv.name[1:] == j[1:]:
                projections.append('A.`' + pv.name[1:] + '`')
            else:
                projections.append('`' + pv.name[1:] + '`')
        projections = ", ".join(projections)

        query = query + " " + projections + " FROM\n(" + q1 + ") AS A \nJOIN (" + q2 + ") AS B \nON " + join_cond
        database_name = d1

        return query, None, None, database_name

    def union_queries(self, preds1, preds2, rdfmts, query_filters):
        mapping_preds1 = {tm: triplemap for tm, triplemap in self.mapping.items() for p in preds1 if
                          p in triplemap.predicate_object_map}
        mapping_preds2 = {tm: triplemap for tm, triplemap in self.mapping.items() for p in preds2 if
                          p in triplemap.predicate_object_map}

        q1, p1, c1, d1 = self.translate_single_query(mapping_preds1, preds1, [rdfmts[0]], self.star['triples'], query_filters)
        q2, p2, c2, d2 = self.translate_single_query(mapping_preds2, preds2, [rdfmts[1]], self.star['triples'], query_filters)

        query = "(" + q1 + ") UNION (" + q2 + ")"
        database_name = d1

        return query, None, None, database_name

    def translate_single_query(self, mapping_preds, star_preds, rdfmts, star_triples, query_filters):
        touninon = {}
        completematch = {}
        for tm, triplemap in mapping_preds.items():
            for rdfmt in triplemap.subject_map.rdf_types:
                if rdfmt in rdfmts and len(set(star_preds).intersection(list(triplemap.predicate_object_map.keys()))) == len(set(star_preds)):
                    completematch[rdfmt] = {}
                    completematch[rdfmt][tm] = triplemap.predicate_object_map

                if rdfmt in rdfmts and len(set(star_preds).intersection(list(triplemap.predicate_object_map.keys()))) > 0:
                    touninon.setdefault(rdfmt, {})[tm] = triplemap.predicate_object_map

        if len(completematch) > 0:
            if len(completematch) == 1:
                query, projvartocols, coltotemplates, database_name = self.make_join(touninon[list(touninon.keys())[0]], star_triples, query_filters)
                return query, projvartocols, coltotemplates, database_name
            else:
                return self.make_union(completematch, query_filters)
        elif len(touninon) > 1:
            return self.make_union(touninon, query_filters)
        elif len(touninon) == 1:
            query, projvartocols, coltotemplates, database_name = self.make_join(touninon[list(touninon.keys())[0]], star_triples, query_filters)
            return query, projvartocols, coltotemplates, database_name

    def make_join(self, mapping_preds, star_triples, query_filters):
        tables, subjects, tm_tablealias, database_name = self.get_table_names(mapping_preds)
        # print(tables)
        coltotemplates, projections, projvartocol, objectfilters, constfilters = self.get_predicate_column_map(mapping_preds, subjects, tm_tablealias, star_triples, query_filters)

        constfilters = list(set(constfilters))
        constfilters.extend(objectfilters)
        if len(mapping_preds) > 0:
            fromclauses = []
            for k, v in tables.items():
                fromclauses.append(v + ' ' + k)
            fromcaluse = "\n FROM " + ", ".join(list(set(fromclauses)))
            distinct = ""
            if self.sparql.distinct:
                distinct = "DISTINCT "
            projections = " SELECT  " + distinct + ", ".join(sorted(list(set(projections.values()))))
            if len(objectfilters) > 0:
                whereclause = "\n WHERE " + "\n\t AND ".join(constfilters)
            else:
                whereclause = ""

            sqlquery = projections + " " + fromcaluse + " " + whereclause

            return sqlquery, projvartocol, coltotemplates, database_name
        else:
            return None, None, coltotemplates, database_name

    def make_union(self, tounions, query_filters, subjectunions=False):
        coltotemplates = {}
        projvartocols = {}
        database_names = {}
        unions = []
        rdfmts = list(tounions.keys())
        rdfmts = list(reversed(sorted(rdfmts)))

        for rdfmt in rdfmts:
            mappingpreds = tounions[rdfmt]
            if subjectunions:
                for tm, submaps in mappingpreds.items():
                    un, projvartocols, coltotemplates, database_name = self.make_join({tm: submaps}, query_filters)
                    if un is not None and len(un) > 0:
                        unions.append(un)
                        if isinstance(database_name, str):
                            database_names = database_name
                        else:
                            database_names.update(database_name)
            else:
                un, projvartocols, coltotemplates, database_name = self.make_join(mappingpreds, query_filters)
                if un is not None and len(un) > 0:
                    unions.append(un)
                    if isinstance(database_name, str):
                        database_names = database_name
                    else:
                        database_names.update(database_name)

        # query = " UNION ".join(unions)
        # print(query)
        return unions, projvartocols, coltotemplates, database_names

    def get_table_names(self, mapping_preds):
        tm_tablealias = {}
        subjects = {}
        tables = {}
        i = 0
        database_name = ""

        for tm, predicate_object_map in mapping_preds.items():
            tablealias = 'Ontario_' + str(i)
            tm_tablealias[tablealias] = tm
            triplemap = self.mapping[tm]

            subjects[tm] = triplemap.subject_map.subject

            logicalsource = triplemap.logical_source
            data_source = logicalsource.data_source

            if self.datasource.dstype == DataSourceType.MYSQL:
                database_name = data_source.name
                if '/' in database_name:
                    database_name = database_name.split('/')[-1]
                tablename = logicalsource.table_name
                tables[tablealias] = tablename
            else:
                if isinstance(database_name, str):
                    database_name = {}
                tablename = data_source.name
                if self.datasource.dstype == DataSourceType.LOCAL_TSV or \
                        self.datasource.dstype == DataSourceType.SPARK_TSV or \
                        self.datasource.dstype == DataSourceType.HADOOP_TSV:
                    fileext = self.datasource.url + ('/' if self.datasource.url[-1] != '/' else "") + \
                              tablename + ('.tsv' if '.tsv' not in data_source.name else "")
                    # fileext = '/media/kemele/DataHD/LSLOD-flatfile/tsv/' + tablename
                elif self.datasource.dstype == DataSourceType.LOCAL_CSV or \
                        self.datasource.dstype == DataSourceType.SPARK_CSV or \
                        self.datasource.dstype == DataSourceType.HADOOP_CSV:
                    fileext = self.datasource.url + ('/' if self.datasource.url[-1] != '/' else "") + \
                              tablename + ('.csv' if '.csv' not in data_source.name else "")
                    # fileext = '/media/kemele/DataHD/LSLOD-flatfile/csv/' + tablename
                elif self.datasource.dstype == DataSourceType.LOCAL_JSON or \
                        self.datasource.dstype == DataSourceType.SPARK_JSON or \
                        self.datasource.dstype == DataSourceType.HADOOP_JSON:
                    fileext = self.datasource.url + ('/' if self.datasource.url[-1] != '/' else "") + \
                              tablename + ('.json' if '.json' not in data_source.name else "")
                    # fileext = '/media/kemele/DataHD/LSLOD-flatfile/json/' + tablename
                elif self.datasource.dstype == DataSourceType.LOCAL_XML or \
                        self.datasource.dstype == DataSourceType.SPARK_XML or \
                        self.datasource.dstype == DataSourceType.HADOOP_XML:
                    fileext = self.datasource.url + ('/' if self.datasource.url[-1] != '/' else "") + \
                              tablename + ('.xml' if '.xml' not in data_source.name else "")
                    # fileext = '/media/kemele/DataHD/LSLOD-flatfile/xml/' + tablename

                else:
                    fileext = ''

                database_name[fileext] = str(hashlib.md5(str(tablename).encode()).hexdigest())
                tables[tablealias] = database_name[fileext]

            i += 1

        return tables, subjects, tm_tablealias, database_name

    def get_predicate_column_map(self, mapping_preds, subjects, tm_tablealias, star_triples, query_filters):
        coltotemplates = {}
        projections = {}
        projvartocol = {}
        objectfilters = []
        constfilters = []
        i = 0
        for tm, predicate_object_map in mapping_preds.items():
            star_variables = set(self.get_so_variables(star_triples))
            var_pred_map = {}
            tablealias = 'Ontario_' + str(i)
            if isinstance(predicate_object_map, SubjectMap):
                self.subjectMap(star_triples, predicate_object_map, tablealias, var_pred_map, coltotemplates, projections, projvartocol, objectfilters)
            else:
                self.predicate_object_map(predicate_object_map, star_variables, tablealias, var_pred_map, coltotemplates, projections, projvartocol, objectfilters)

            self.filter_clauses(query_filters, constfilters, tm, predicate_object_map, var_pred_map, coltotemplates, tablealias)

            self.get_cond_sql(predicate_object_map, var_pred_map, constfilters, tablealias)
            i += 1

        self.subject_cond(star_triples, subjects, tm_tablealias, constfilters, coltotemplates, projections, projvartocol, objectfilters)
        self.join_condition(subjects, tm_tablealias, constfilters, objectfilters)

        return coltotemplates, projections, projvartocol, objectfilters, constfilters

    def subjectMap(self, star_triples, predicate_object_map, tablealias, var_pred_map, coltotemplates, projections, projvartocol, objectfilters):
        subjvar = star_triples[0].subject.name
        var = subjvar
        var_pred_map[subjvar] = 'http://www.w3.org/1999/02/22-rdf-syntax-ns#type'
        if predicate_object_map.subject.resource_type == TripleMapType.TEMPLATE:
            coltotemplates[subjvar[1:]] = predicate_object_map.subject.value
            splits = predicate_object_map.subject.value.split('{')
            column = []
            for sp in splits[1:]:
                column.append(sp[:sp.find('}')])
            if len(column) == 1:
                column = column[0]
        elif predicate_object_map.subject.resource_type == TripleMapType.REFERENCE:
            column = predicate_object_map.subject.value
        else:
            column = []
        if isinstance(column, list):
            j = 0
            for col in column:
                self.projection(projections, tablealias, col, var, projvartocol, coltotemplates, objectfilters, j)
                j += 1
        else:
            self.projection(projections, tablealias, column, var, projvartocol, coltotemplates, objectfilters)

    def projection(self, projections, tablealias, col, var, projvartocol, coltotemplates, objectfilters, j=None):
        """
        Projects subjects/objects and semantifies them according to the mappings
        :param projections: list of projections from the query
        :param tablealias: alias of the attribute's table
        :param col: column of the table to be accessed
        :param var: variable from the SPARQL query that translates to the attribute
        :param projvartocol: list of projected variables
        :param coltotemplates: mappings
        :param objectfilters: filters in the WHERE clause
        :param j: (optional) number of the table
        """
        column = '`' + col + '`'
        if var in [c.name for c in self.sparql.args]:
            if var[1:] in coltotemplates.keys():
                prefix = coltotemplates[var[1:]].replace('{' + col + '}', '')
                projstr = 'CONCAT("' + prefix + '", ' + tablealias + "." + column + ')'
            else:
                projstr = tablealias + "." + column

            if j is None:
                projections[var[1:]] = projstr + " AS `" + var[1:] + '`'
            else:
                projections[var[1:] + '_Ontario_' + str(j)] = projstr + " AS `" + var[1:] + '_Ontario_' + str(j) + '`'
            projvartocol[var[1:]] = col
        objectfilters.append(tablealias + '.' + column + " is not null ")
        if self.datasource.dstype == DataSourceType.MYSQL:
            objectfilters.append(tablealias + '.' + column + " <> '' ")

    def subject_cond(self, star_triples, subjects, tm_tablealias, constfilters, coltotemplates, projections, projvartocol, objectfilters):
        invalidsubj = False
        subj = star_triples[0].subject.name if not star_triples[0].subject.constant else None
        if subj is not None:
            filtersadded = []
            for tm, subject in subjects.items():
                subjcol = subject.value
                tablealias = [v for v in tm_tablealias if tm_tablealias[v] == tm][0]
                splits = subjcol.split('{')
                coltotemplates[subj[1:]] = subjcol
                column = []
                for sp in splits[1:]:
                    column.append(sp[:sp.find('}')])

                if len(column) > 1:
                    j = 0
                    for col in column:
                        self.projection(projections, tablealias, col, subj, projvartocol, coltotemplates, objectfilters, j)
                        j += 1
                elif len(column) == 1:
                    col = column[0]
                    self.projection(projections, tablealias, col, subj, projvartocol, coltotemplates, objectfilters)
        else:
            subj = star_triples[0].subject.name
            for tm, subject in subjects.items():
                subjcol = subject.value
                tablealias = [v for v in tm_tablealias if tm_tablealias[v] == tm][0]
                splits = subjcol.split('{')
                column = []
                for sp in splits[1:]:
                    column.append(sp[:sp.find('}')])

                if len(splits[0]) > 0 and splits[0] not in subj:
                    invalidsubj = True
                    break
                var = subj.replace(splits[0], '').replace('}', '')

                if '<' in var and '>' in var:
                    var = var[1:-1]
                var = "'" + var + "'"
                # if isinstance(column, list):
                j = 0
                for col in column:
                    vcolumn = "`" + col + '`'
                    constfilters.append(tablealias + "." + vcolumn + " = " + var)
                    j += 1
        if invalidsubj:
            mapping_preds = []

    def predicate_object_map(self, predicate_object_map, star_variables, tablealias, var_pred_map, coltotemplates, projections, projvartocol, objectfilters):
        var_pred_map.update({var: pred for pred, var in self.star['predicates'].items() if pred in predicate_object_map})
        column = []
        for var in star_variables:
            if var not in var_pred_map:
                continue
            p = var_pred_map[var]
            pmap, omap = predicate_object_map[p]
            if omap.objectt.resource_type == TripleMapType.TEMPLATE:
                coltotemplates[var[1:]] = omap.objectt.value
                splits = omap.objectt.value.split('{')
                column = []
                for sp in splits[1:]:
                    column.append(sp[:sp.find('}')])
                if len(column) == 1:
                    column = column[0]
            elif omap.objectt.resource_type == TripleMapType.REFERENCE:
                column = omap.objectt.value
            else:
                column = []
            if isinstance(column, list):
                j = 0
                for col in column:
                    self.projection(projections, tablealias, col, var, projvartocol, coltotemplates, objectfilters, j)
                    j += 1
            else:
                self.projection(projections, tablealias, column, var, projvartocol, coltotemplates, objectfilters)

    def filter_clauses(self, query_filters, constfilters, tm, predicate_object_map, var_pred_map, coltotemplates, tablealias):
        for f in query_filters:
            fil = self.get_obj_filter(f, var_pred_map, self.mapping[tm].subject_map.subject, predicate_object_map, coltotemplates, tablealias)
            if fil is not None and len(fil) > 0:
                constfilters.append(fil)

    def get_cond_sql(self, predicate_object_map, var_pred_map, constfilters, tablealias):
        for var, p in var_pred_map.items():

            if '?' not in var:
                pmap, omap = predicate_object_map[p]

                if omap.objectt.resource_type == TripleMapType.TEMPLATE:
                    # omap.objectt.value
                    splits = omap.objectt.value.split('{')
                    column = []
                    for sp in splits[1:]:
                        column.append(sp[:sp.find('}')])

                    var = var.replace(splits[0], '').replace('}', '')
                    if '<' in var and '>' in var:
                        var = var[1:-1]
                    var = "'" + var + "'"
                elif omap.objectt.resource_type == TripleMapType.REFERENCE:
                    column = omap.objectt.value
                    if "'" not in var and '"' not in var:
                        var = "'" + var + "'"
                    if '"' in var:
                        var = "'" + var[1:-1] + "'"
                else:
                    column = []
                if isinstance(column, list):
                    j = 0
                    for col in column:
                        vcolumn = "`" + col + '`'
                        constfilters.append(tablealias + "." + vcolumn + " = " + var)
                        j += 1
                else:
                    column = "`" + column + '`'
                    constfilters.append(tablealias + "." + column + " = " + var)

    def join_condition(self, subjects, tm_tablealias, constfilters, objectfilters):
        if len(subjects) > 1:
            aliases = list(tm_tablealias.keys())
            raliases = aliases.copy()
            raliases.reverse()
            compared = []
            for a1 in aliases:
                for a2 in aliases:
                    if a1 + a2 in compared:
                        continue
                    if a1 == a2:
                        continue
                    compared.append(a1 + a2)
                    compared.append(a2 + a1)
                    subj1 = subjects[tm_tablealias[a1]].value
                    subj2 = subjects[tm_tablealias[a2]].value
                    column1 = None
                    column2 = None
                    splits = subj1.split('{')
                    for sp in splits:
                        if '}' in sp:
                            column1 = sp[:sp.find('}')]
                            break
                    splits = subj2.split('{')
                    for sp in splits:
                        if '}' in sp:
                            column2 = sp[:sp.find('}')]
                            break
                    column1 = '`' + column1 + '`'
                    column2 = '`' + column2 + '`'
                    if column1 == column2:
                        constfilters.append(a1 + '.' + column1 + "=" + a2 + "." + column2)
                        if a1 + '.' + column1 + " is not null " in objectfilters:
                            objectfilters.remove(a1 + '.' + column1 + " is not null ")
                        if a2 + '.' + column2 + " is not null " in objectfilters:
                            objectfilters.remove(a2 + '.' + column2 + " is not null ")

    def get_so_variables(self, triples):
        tvars = []
        for t in triples:
            if not t.subject.constant:
                tvars.append(t.subject.name)
            if not t.theobject.constant:
                tvars.append(t.theobject.name)

        return tvars

    def getsqlfil(self, l, r, op, var_pred_map, subjmap, predicate_object_map, coltotemplates, tablealias):
        if r is not None and '?' in r.name:
            var = r.name
            val = l.name
        else:
            var = l.name
            val = r.name
        # print(val)
        if '(' in var and ')' in var:
            var = var[var.find('(') + 1:var.find(')')]

        if len(var_pred_map) == 0 or var == self.star['triples'][0].subject.name:
            subjcol = subjmap.value
            splits = subjcol.split('{')
            coltotemplates[var[1:]] = subjcol
            column = []
            for sp in splits[1:]:
                column.append(sp[:sp.find('}')])

            if len(column) > 1:
                objfilters = []
                for col in column:
                    vcolumn = "`" + col + '`'

                    if '<' in val and '>' in val:
                        val = val.replace('<', '').replace('>', '')
                    if '"' not in val and "'" not in val:
                        val = "'" + val + "'"

                    if op == 'REGEX':
                        val = "LOWER('%" + val[1:-1] + "%')"
                        objectfilter = 'LOWER(' + tablealias + '.' + vcolumn + ") LIKE " + val
                    else:
                        objectfilter = tablealias + '.' + vcolumn + op + val
                    objfilters.append(objectfilter)

                return " AND ".join(objfilters)
            elif len(column) == 1:
                column = "`" + column[0] + '`'

                if '<' in val and '>' in val:
                    val = val.replace('<', '').replace('>', '').replace(splits[0], '')

                if '"' not in val and "'" not in val:
                    val = "'" + val + "'"

                if op == 'REGEX':
                    val = "LOWER('%" + val[1:-1] + "%')"
                    objectfilter = 'LOWER(' + tablealias + '.' + column + ") LIKE " + val
                else:
                    objectfilter = tablealias + '.' + column + op + val

                return objectfilter
        if var not in var_pred_map:
            return None

        p = var_pred_map[var]
        pmap, omap = predicate_object_map[p]
        if omap.objectt.resource_type == TripleMapType.TEMPLATE:
            coltotemplates[var[1:]] = omap.objectt.value
            splits = omap.objectt.value.split('{')
            column = []
            for sp in splits[1:]:
                column.append(sp[:sp.find('}')])
            val = val.replace(splits[0], "")

            if len(column) == 1:
                column = column[0]

        elif omap.objectt.resource_type == TripleMapType.REFERENCE:
            column = omap.objectt.value
        else:
            column = []
        if isinstance(column, list):
            if len(column) > 0:
                column = column[0]
        column = "`" + column + '`'

        if '<' in val and '>' in val:
            val = val.replace('<', '').replace('>', '')
        if '"' not in val and "'" not in val:
            val = "'" + val + "'"

        if op == 'REGEX':
            val = "LOWER('%" + val[1:-1] + "%')"
            objectfilter = 'LOWER(' + tablealias + '.' + column + ") LIKE " + val
        else:
            objectfilter = tablealias + '.' + column + op + val

        return objectfilter

    def get_Expression_value(self, exp, var_pred_map, subjmap, predicate_object_map, coltotemplates, tablealias):
        left = exp.left
        right = exp.right
        op = exp.op

        if op in unaryFunctor:
            if isinstance(left, Expression) and isinstance(left.left, Argument):
                left = left.left
                fil = self.getsqlfil(left, right, op, var_pred_map, subjmap, predicate_object_map, coltotemplates, tablealias)
                return fil

        elif op in binaryFunctor:
            if op == 'REGEX' and right.desc is not False:
                if isinstance(left, Expression):
                    if 'xsd:string' in left.op:
                        left = left.left
                        fil = self.getsqlfil(left, right, op, var_pred_map, subjmap, predicate_object_map, coltotemplates, tablealias)
                        return fil
                    # else:
                    #     left = self.get_Expression_value(left, var_pred_map, subjmap,predicate_object_map, coltotemplates, tablealias)
                    #     right = self.get_Expression_value(right, var_pred_map, subjmap, predicate_object_map, coltotemplates,tablealias)
                else:
                    fil = self.getsqlfil(left, right, op, var_pred_map, subjmap, predicate_object_map,
                                         coltotemplates, tablealias)
                    return fil
                # return op + "(" + str(left) + "," + right.name + "," + right.desc + ")"
            else:
                return op + "(" + str(left) + "," + str(right) + ")"

        elif right is None:
            return op + str(left)

        else:
            if isinstance(left, Argument) and isinstance(right, Argument):
                fil = self.getsqlfil(left, right, op, var_pred_map, subjmap, predicate_object_map, coltotemplates, tablealias)
                return fil
            if isinstance(left, Expression) and isinstance(right, Expression):
                leftexp = self.get_Expression_value(left, var_pred_map, subjmap, predicate_object_map, coltotemplates, tablealias)
                rightexp = self.get_Expression_value(right, var_pred_map, subjmap, predicate_object_map, coltotemplates, tablealias)
                if op == '||' or op == '|':
                    if leftexp is None or rightexp is None:
                        return None
                    return '(' + leftexp + ' OR ' + rightexp + ')'
                else:
                    if leftexp is None or rightexp is None:
                        return None
                    return '(' + leftexp + ' AND ' + rightexp + ')'
            # print(op, type(left), left, type(right), right)
            return "(" + str(exp.left) + " " + exp.op + " " + str(exp.right)

    def get_obj_filter(self, f, var_pred_map, subjmap, predicate_object_map, coltotemplates, tablealias):
        return self.get_Expression_value(f.expr, var_pred_map, subjmap, predicate_object_map, coltotemplates, tablealias)
