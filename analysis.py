
__author__ = 'Philipp D. Rohde'

import matplotlib.pyplot as plt
import numpy as np
import pandas as pd
import collections
plt.style.use('ggplot')

ROOT_DIR = './'
ROOT_DIR_RES = ROOT_DIR + 'results/'

# defining the query names in an ordered manner
qnames = collections.OrderedDict()
qnames['Q1'] = 'Q1'
qnames['Q2'] = 'Q2'
qnames['Q3'] = 'Q3'
qnames['Q4'] = 'Q4'
qnames['Q5'] = 'Q5'

mins = {"Q1": 0, "Q2": 0, "Q3": 0, "Q4": 0, "Q5": 0}
minvals = {"Q1": 500, "Q2": 500, "Q3": 500, "Q4": 500, "Q5": 500}

def load_data(path, approach, qnames, mins, minvals):
    """
    Loads the result data from the given path.
    :param path: the path to the engine's result folder.
    :param approach: name of the approach the data belongs to
    :return: the best result per query (metrics, traces)
    """
    rr = {}

    def mapval(row):
        row['totaltime'] = pd.to_numeric(row['totaltime'])
        row['comp'] = pd.to_numeric(row['comp'])
        rr[row['test']] = row['totaltime']
        return row

    for i in range(1, 6):
        res = pd.read_csv(path + '/exec_res_' + str(i) + '/results.csv', sep='\t', header=None,
                          names=['test', 'decompositionTime', 'planningTime', 'tfft', 'totaltime',
                                 'moreResults', 'comp'])
        res.apply(mapval, axis=1)

        for k, r in rr.items():
            if k not in minvals:
                minvals[k] = r
                mins[k] = i
            elif r < minvals[k]:
                minvals[k] = r
                mins[k] = i

    metrics = pd.DataFrame()
    for k, v in mins.items():
        if v == 0:
            res['test'] = qnames[k]
            res['tfft'] = np.nan
            res['totaltime'] = np.nan
            res['comp'] = np.nan
        else:
            res = pd.read_csv(path + '/exec_res_' + str(v) + '/results.csv', sep='\t', header=None,
                              names=['test', 'decompositionTime', 'planningTime', 'tfft', 'totaltime',
                                     'moreResults', 'comp'])
            res = res[res['test'] == k]
            res['test'] = qnames[k]
        res.reset_index(drop=True, inplace=True)
        metrics.reset_index(drop=True, inplace=True)
        metrics = pd.concat([metrics, res])
        metrics.reset_index(drop=True, inplace=True)
        metrics.drop_duplicates(inplace=True)

    metrics['approach'] = approach
    metrics = metrics[['test', 'approach', 'tfft', 'totaltime', 'comp']]

    traces = pd.DataFrame()
    for k, v in mins.items():
        if v == 0:
            continue
        res = pd.read_csv(path + '/exec_res_' + str(v) + '/traces.csv', header=None,  names=['test', 'answer', 'time'])
        res = res[res['test'] == k]
        res['test'] = qnames[k]
        res.reset_index(drop=True, inplace=True)
        if len(res[res['time'] > 300.0]) > 0:
            res = res[res['time'] <= 300.0]
            row = metrics[metrics['test'] == k]
            metrics.loc[row.index, 'totaltime'] = 300.0
            metrics.loc[row.index, 'comp'] = res.iloc[-1]['answer']

        traces.reset_index(drop=True, inplace=True)
        traces = pd.concat([traces, res], sort=False)
        traces.reset_index(drop=True, inplace=True)
        traces.drop_duplicates(inplace=True)
        traces['approach'] = approach

    return metrics, traces


def plot_data(metrics, columns, name):
    approaches = metrics['approach'].unique()
    plotdata = None
    for a in approaches:
        fx = metrics[metrics['approach'] == a][['test', 'totaltime']]
        fx.columns = ['test', a]
        if plotdata is None:
            plotdata = fx
        else:
            plotdata = pd.merge(fx, plotdata, on='test')

    plotdata = plotdata[columns]
    color = ["#20639B", "#5DD39E", "#121212", "#D5717F", "#AA14E1", "#E12C14", "#E18314", "#EBEE11", "#41947F", "#FFFFAB"]
    ploto = plotdata.plot(kind='bar', x='test', logy=True, color=color, width=.77, align='center')
    ploto.set_ylabel('Execution Time [s]')
    ploto.set_xlabel('Query')
    plt.figure(figsize=(35, 4))
    ploto.legend(fontsize='small', loc='lower center', bbox_to_anchor=(.5, -.37), frameon=False,
                 ncol=4, handleheight=1., labelspacing=0.09)

    fig = ploto.get_figure()
    fig.savefig(ROOT_DIR_RES + "analysis/" + name + ".png", dpi=300, bbox_inches='tight')


if __name__ == '__main__':
    from time import time
    start = time()

    # Physical-Design-Unaware QEP
    metrics_woidx_nodelay, traces_woidx_nodelay = load_data(ROOT_DIR_RES + 'woidx_nodelay', 'no delay', qnames, mins, minvals)
    metrics_woidx_gamma1, traces_woidx_gamma1 = load_data(ROOT_DIR_RES + 'woidx_gamma1', 'gamma 1', qnames, mins, minvals)
    metrics_woidx_gamma2, traces_woidx_gamma2 = load_data(ROOT_DIR_RES + 'woidx_gamma2', 'gamma 2', qnames, mins, minvals)
    metrics_woidx_gamma3, traces_woidx_gamma3 = load_data(ROOT_DIR_RES + 'woidx_gamma3', 'gamma 3', qnames, mins, minvals)

    # Physical-Design-Aware QEP
    metrics_idx_nodelay, traces_idx_nodelay = load_data(ROOT_DIR_RES + 'nodelay', 'no delay', qnames, mins, minvals)
    metrics_idx_gamma1, traces_idx_gamma1 = load_data(ROOT_DIR_RES + 'gamma1', 'gamma 1', qnames, mins, minvals)
    metrics_idx_gamma2, traces_idx_gamma2 = load_data(ROOT_DIR_RES + 'gamma2', 'gamma 2', qnames, mins, minvals)
    metrics_idx_gamma3, traces_idx_gamma3 = load_data(ROOT_DIR_RES + 'gamma3', 'gamma 3', qnames, mins, minvals)

    # joining the metrics
    metrics_woidx = pd.concat([metrics_woidx_nodelay,
                         metrics_woidx_gamma1,
                         metrics_woidx_gamma2,
                         metrics_woidx_gamma3], sort=False)
    metrics_idx = pd.concat([metrics_idx_nodelay,
                         metrics_idx_gamma1,
                         metrics_idx_gamma2,
                         metrics_idx_gamma3], sort=False)

    # joining the traces
    traces_woidx = pd.concat([traces_woidx_nodelay,
                        traces_woidx_gamma1,
                        traces_woidx_gamma2,
                        traces_woidx_gamma3], sort=False)
    traces_idx = pd.concat([traces_idx_nodelay,
                        traces_idx_gamma1,
                        traces_idx_gamma2,
                        traces_idx_gamma3], sort=False)

    columns = ['test', 'no delay', 'gamma 1', 'gamma 2', 'gamma 3']
    plot_data(metrics_woidx, columns, 'exec_time_woidx')
    plot_data(metrics_idx, columns, 'exec_time_idx')

    metrics_woidx.to_csv(ROOT_DIR_RES + "analysis/metrics_woidx.csv", index=False)
    traces_woidx.to_csv(ROOT_DIR_RES + "analysis/traces_woidx.csv", index=False)

    metrics_idx.to_csv(ROOT_DIR_RES + "analysis/metrics_idx.csv", index=False)
    traces_idx.to_csv(ROOT_DIR_RES + "analysis/traces_idx.csv", index=False)

    duration = time() - start
    print("analysis takes", round(duration, 4), "seconds")
