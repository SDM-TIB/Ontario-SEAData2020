CREATE DATABASE IF NOT EXISTS `drugbank` /*!40100 DEFAULT CHARACTER SET latin1 DEFAULT COLLATE latin1_general_cs */;
USE `drugbank`;
/*!40101 SET NAMES utf8 */;


DROP TABLE IF EXISTS `drug_interactions_main`;
CREATE TABLE `drug_interactions_main` (
	drug_interactions varchar(1000) PRIMARY KEY,
	label text,
	interactionDrug1 text,
	interactionDrug2 text
);
LOCK TABLES `drug_interactions_main` WRITE;
LOAD DATA INFILE '/data/prohde/lslod/tsv/drugbank/drug_interactions_main.tsv' INTO TABLE `drug_interactions_main` FIELDS TERMINATED BY '\t' LINES TERMINATED BY '\n' IGNORE 1 ROWS;
UNLOCK TABLES;

DROP TABLE IF EXISTS `drugs_main`;
CREATE TABLE `drugs_main` (
	drugs varchar(1000) PRIMARY KEY,
	label text,
	predictedWaterSolubility text,
	updateDate text,
	casRegistryNumber text,
	structure text,
	chemicalIupacName text,
	indication text,
	chemicalFormula text,
	keggCompoundId text,
	inchiKey text,
	massSpecFile text,
	predictedLogpHydrophobicity text,
	proteinBinding text,
	pubchemCompoundId text,
	mechanismOfAction text,
	molecularWeightAverage text,
	limsDrugId text,
	pharmgkbId text,
	description text,
	contraindicationInsert text,
	pharmacology text,
	smilesStringCanonical text,
	smilesStringIsomeric text,
	creationDate text,
	primaryAccessionNo text,
	biotransformation text,
	genericName text,
	molecularWeightMono text,
	rxlistLink text,
	pubchemSubstanceId text,
	state text,
	interactionInsert text,
	predictedLogs text,
	inchiIdentifier text,
	fdaLabelFiles text,
	keggDrugId text,
	experimentalLogpHydrophobicity text,
	synthesisReference text,
	dpdDrugIdNumber text,
	experimentalWaterSolubility text,
	msdsFiles text,
	halfLife text,
	pdbHomologyId text,
	meltingPoint text,
	absorption text,
	pdrhealthLink text,
	patientInformationInsert text,
	experimentalCaco2Permeability text,
	toxicity text,
	reference text,
	swissprotId text,
	genbankId text,
	swissprotName text,
	pdbExperimentalId text,
	pkaIsoelectricPoint text,
	chemicalStructure text,
	swissprotPage text,
	hetId text,
	experimentalLogs text,
	chebiId text
);
CREATE INDEX drugs_main_keggcompoundid ON drugs_main(keggCompoundId(1000));
CREATE INDEX drugs_main_pubchemcompoundid ON drugs_main(pubchemCompoundId(1000));
CREATE INDEX drugs_main_limsdrugid ON drugs_main(limsDrugId(1000));
CREATE INDEX drugs_main_primaryaccessionno ON drugs_main(primaryAccessionNo(1000));
CREATE INDEX drugs_main_genericname ON drugs_main(genericName(1000));
CREATE INDEX drugs_main_pubchemsubstanceid ON drugs_main(pubchemSubstanceId(1000));
CREATE INDEX drugs_main_pharmgkbid ON drugs_main(pharmgkbId(1000));
CREATE INDEX drugs_main_keggdrugid ON drugs_main(keggDrugId(1000));
CREATE INDEX drugs_main_dpddrugidnumber ON drugs_main(dpdDrugIdNumber(1000));
CREATE INDEX drugs_main_casregistrynumber ON drugs_main(casRegistryNumber(1000));
CREATE INDEX drugs_main_chemicalformula ON drugs_main(chemicalFormula(1000));
LOCK TABLES `drugs_main` WRITE;
LOAD DATA INFILE '/data/prohde/lslod/tsv/drugbank/drugs_main.tsv' INTO TABLE `drugs_main` FIELDS TERMINATED BY '\t' LINES TERMINATED BY '\n' IGNORE 1 ROWS;
UNLOCK TABLES;

DROP TABLE IF EXISTS `enzymes_main`;
CREATE TABLE `enzymes_main` (
	enzymes varchar(1000) PRIMARY KEY,
	label text,
	geneName text,
	name text,
	proteinSequence text,
	swissprotId text,
	swissprotPage text
);
LOCK TABLES `enzymes_main` WRITE;
LOAD DATA INFILE '/data/prohde/lslod/tsv/drugbank/enzymes_main.tsv' INTO TABLE `enzymes_main` FIELDS TERMINATED BY '\t' LINES TERMINATED BY '\n' IGNORE 1 ROWS;
UNLOCK TABLES;

DROP TABLE IF EXISTS `references_main`;
CREATE TABLE `references_main` (
	`references` varchar(1000) PRIMARY KEY,
	label text,
	sameAs text,
	page text
);
LOCK TABLES `references_main` WRITE;
LOAD DATA INFILE '/data/prohde/lslod/tsv/drugbank/references_main.tsv' INTO TABLE `references_main` FIELDS TERMINATED BY '\t' LINES TERMINATED BY '\n' IGNORE 1 ROWS;
UNLOCK TABLES;

DROP TABLE IF EXISTS `targets_main`;
CREATE TABLE `targets_main` (
	targets varchar(1000) PRIMARY KEY,
	label text,
	bio2rdfSymbol text,
	chromosomeLocation text,
	essentiality text,
	genatlasId text,
	genbankIdGene text,
	genbankIdGenePage text,
	genbankIdProtein text,
	genbankIdProteinPage text,
	geneName text,
	geneSequence text,
	genecardId text,
	generalFunction text,
	hgncId text,
	hgncIdPage text,
	hprdId text,
	locus text,
	molecularWeight text,
	name text,
	numberOfResidues text,
	pathway text,
	pdbId text,
	pdbIdPage text,
	proteinSequence text,
	reaction text,
	`signal` text,
	specificFunction text,
	swissprotId text,
	swissprotName text,
	swissprotPage text,
	theoreticalPi text
);
LOCK TABLES `targets_main` WRITE;
LOAD DATA INFILE '/data/prohde/lslod/tsv/drugbank/targets_main.tsv' INTO TABLE `targets_main` FIELDS TERMINATED BY '\t' LINES TERMINATED BY '\n' IGNORE 1 ROWS;
UNLOCK TABLES;

DROP TABLE IF EXISTS `drug_interactions_text`;
CREATE TABLE `drug_interactions_text` (
	drug_interactions varchar(128),
	text varchar(2944),
	CONSTRAINT pk_drug_interactions_text PRIMARY KEY(drug_interactions,text),
	CONSTRAINT fk_drug_interactions_text FOREIGN KEY(drug_interactions) REFERENCES `drug_interactions_main`(drug_interactions)
);
LOCK TABLES `drug_interactions_text` WRITE;
LOAD DATA INFILE '/data/prohde/lslod/tsv/drugbank/drug_interactions_text.tsv' INTO TABLE `drug_interactions_text` FIELDS TERMINATED BY '\t' LINES TERMINATED BY '\n' IGNORE 1 ROWS;
UNLOCK TABLES;

DROP TABLE IF EXISTS `drugs_affectedOrganism`;
CREATE TABLE `drugs_affectedOrganism` (
	drugs varchar(128),
	affectedOrganism varchar(2944),
	CONSTRAINT pk_drugs_affectedOrganism PRIMARY KEY(drugs,affectedOrganism),
	CONSTRAINT fk_drugs_affectedOrganism FOREIGN KEY(drugs) REFERENCES `drugs_main`(drugs)
);
LOCK TABLES `drugs_affectedOrganism` WRITE;
LOAD DATA INFILE '/data/prohde/lslod/tsv/drugbank/drugs_affectedOrganism.tsv' INTO TABLE `drugs_affectedOrganism` FIELDS TERMINATED BY '\t' LINES TERMINATED BY '\n' IGNORE 1 ROWS;
UNLOCK TABLES;

DROP TABLE IF EXISTS `drugs_ahfsCode`;
CREATE TABLE `drugs_ahfsCode` (
	drugs varchar(128),
	ahfsCode varchar(2944),
	CONSTRAINT pk_drugs_ahfsCode PRIMARY KEY(drugs,ahfsCode),
	CONSTRAINT fk_drugs_ahfsCode FOREIGN KEY(drugs) REFERENCES `drugs_main`(drugs)
);
LOCK TABLES `drugs_ahfsCode` WRITE;
LOAD DATA INFILE '/data/prohde/lslod/tsv/drugbank/drugs_ahfsCode.tsv' INTO TABLE `drugs_ahfsCode` FIELDS TERMINATED BY '\t' LINES TERMINATED BY '\n' IGNORE 1 ROWS;
UNLOCK TABLES;

DROP TABLE IF EXISTS `drugs_atcCode`;
CREATE TABLE `drugs_atcCode` (
	drugs varchar(128),
	atcCode varchar(2944),
	CONSTRAINT pk_drugs_atcCode PRIMARY KEY(drugs,atcCode),
	CONSTRAINT fk_drugs_atcCode FOREIGN KEY(drugs) REFERENCES `drugs_main`(drugs)
);
LOCK TABLES `drugs_atcCode` WRITE;
LOAD DATA INFILE '/data/prohde/lslod/tsv/drugbank/drugs_atcCode.tsv' INTO TABLE `drugs_atcCode` FIELDS TERMINATED BY '\t' LINES TERMINATED BY '\n' IGNORE 1 ROWS;
UNLOCK TABLES;

DROP TABLE IF EXISTS `drugs_brandMixture`;
CREATE TABLE `drugs_brandMixture` (
	drugs varchar(128),
	brandMixture varchar(2944),
	CONSTRAINT pk_drugs_brandMixture PRIMARY KEY(drugs,brandMixture),
	CONSTRAINT fk_drugs_brandMixture FOREIGN KEY(drugs) REFERENCES `drugs_main`(drugs)
);
LOCK TABLES `drugs_brandMixture` WRITE;
LOAD DATA INFILE '/data/prohde/lslod/tsv/drugbank/drugs_brandMixture.tsv' INTO TABLE `drugs_brandMixture` FIELDS TERMINATED BY '\t' LINES TERMINATED BY '\n' IGNORE 1 ROWS;
UNLOCK TABLES;

DROP TABLE IF EXISTS `drugs_brandName`;
CREATE TABLE `drugs_brandName` (
	drugs varchar(128),
	brandName varchar(2944),
	CONSTRAINT pk_drugs_brandName PRIMARY KEY(drugs,brandName),
	CONSTRAINT fk_drugs_brandName FOREIGN KEY(drugs) REFERENCES `drugs_main`(drugs)
);
LOCK TABLES `drugs_brandName` WRITE;
LOAD DATA INFILE '/data/prohde/lslod/tsv/drugbank/drugs_brandName.tsv' INTO TABLE `drugs_brandName` FIELDS TERMINATED BY '\t' LINES TERMINATED BY '\n' IGNORE 1 ROWS;
UNLOCK TABLES;

DROP TABLE IF EXISTS `drugs_brandedDrug`;
CREATE TABLE `drugs_brandedDrug` (
	drugs varchar(128),
	brandedDrug varchar(2944),
	CONSTRAINT pk_drugs_brandedDrug PRIMARY KEY(drugs,brandedDrug),
	CONSTRAINT fk_drugs_brandedDrug FOREIGN KEY(drugs) REFERENCES `drugs_main`(drugs)
);
LOCK TABLES `drugs_brandedDrug` WRITE;
LOAD DATA INFILE '/data/prohde/lslod/tsv/drugbank/drugs_brandedDrug.tsv' INTO TABLE `drugs_brandedDrug` FIELDS TERMINATED BY '\t' LINES TERMINATED BY '\n' IGNORE 1 ROWS;
UNLOCK TABLES;
CREATE INDEX brandeddrug ON drugs_brandedDrug(brandedDrug(1000));

DROP TABLE IF EXISTS `drugs_dosageForm`;
CREATE TABLE `drugs_dosageForm` (
	drugs varchar(128),
	dosageForm varchar(2944),
	CONSTRAINT pk_drugs_dosageForm PRIMARY KEY(drugs,dosageForm),
	CONSTRAINT fk_drugs_dosageForm FOREIGN KEY(drugs) REFERENCES `drugs_main`(drugs)
);
LOCK TABLES `drugs_dosageForm` WRITE;
LOAD DATA INFILE '/data/prohde/lslod/tsv/drugbank/drugs_dosageForm.tsv' INTO TABLE `drugs_dosageForm` FIELDS TERMINATED BY '\t' LINES TERMINATED BY '\n' IGNORE 1 ROWS;
UNLOCK TABLES;

DROP TABLE IF EXISTS `drugs_drugCategory`;
CREATE TABLE `drugs_drugCategory` (
	drugs varchar(128),
	drugCategory varchar(2944),
	CONSTRAINT pk_drugs_drugCategory PRIMARY KEY(drugs,drugCategory),
	CONSTRAINT fk_drugs_drugCategory FOREIGN KEY(drugs) REFERENCES `drugs_main`(drugs)
);
LOCK TABLES `drugs_drugCategory` WRITE;
LOAD DATA INFILE '/data/prohde/lslod/tsv/drugbank/drugs_drugCategory.tsv' INTO TABLE `drugs_drugCategory` FIELDS TERMINATED BY '\t' LINES TERMINATED BY '\n' IGNORE 1 ROWS;
UNLOCK TABLES;

DROP TABLE IF EXISTS `drugs_drugType`;
CREATE TABLE `drugs_drugType` (
	drugs varchar(128),
	drugType varchar(2944),
	CONSTRAINT pk_drugs_drugType PRIMARY KEY(drugs,drugType),
	CONSTRAINT fk_drugs_drugType FOREIGN KEY(drugs) REFERENCES `drugs_main`(drugs)
);
LOCK TABLES `drugs_drugType` WRITE;
LOAD DATA INFILE '/data/prohde/lslod/tsv/drugbank/drugs_drugType.tsv' INTO TABLE `drugs_drugType` FIELDS TERMINATED BY '\t' LINES TERMINATED BY '\n' IGNORE 1 ROWS;
UNLOCK TABLES;

DROP TABLE IF EXISTS `drugs_enzyme`;
CREATE TABLE `drugs_enzyme` (
	drugs varchar(128),
	enzyme varchar(2944),
	CONSTRAINT pk_drugs_enzyme PRIMARY KEY(drugs,enzyme),
	CONSTRAINT fk_drugs_enzyme FOREIGN KEY(drugs) REFERENCES `drugs_main`(drugs)
);
LOCK TABLES `drugs_enzyme` WRITE;
LOAD DATA INFILE '/data/prohde/lslod/tsv/drugbank/drugs_enzyme.tsv' INTO TABLE `drugs_enzyme` FIELDS TERMINATED BY '\t' LINES TERMINATED BY '\n' IGNORE 1 ROWS;
UNLOCK TABLES;

DROP TABLE IF EXISTS `drugs_foodInteraction`;
CREATE TABLE `drugs_foodInteraction` (
	drugs varchar(128),
	foodInteraction varchar(2944),
	CONSTRAINT pk_drugs_foodInteraction PRIMARY KEY(drugs,foodInteraction),
	CONSTRAINT fk_drugs_foodInteraction FOREIGN KEY(drugs) REFERENCES `drugs_main`(drugs)
);
LOCK TABLES `drugs_foodInteraction` WRITE;
LOAD DATA INFILE '/data/prohde/lslod/tsv/drugbank/drugs_foodInteraction.tsv' INTO TABLE `drugs_foodInteraction` FIELDS TERMINATED BY '\t' LINES TERMINATED BY '\n' IGNORE 1 ROWS;
UNLOCK TABLES;

DROP TABLE IF EXISTS `drugs_page`;
CREATE TABLE `drugs_page` (
	drugs varchar(128),
	page varchar(2944),
	CONSTRAINT pk_drugs_page PRIMARY KEY(drugs,page),
	CONSTRAINT fk_drugs_page FOREIGN KEY(drugs) REFERENCES `drugs_main`(drugs)
);
LOCK TABLES `drugs_page` WRITE;
LOAD DATA INFILE '/data/prohde/lslod/tsv/drugbank/drugs_page.tsv' INTO TABLE `drugs_page` FIELDS TERMINATED BY '\t' LINES TERMINATED BY '\n' IGNORE 1 ROWS;
UNLOCK TABLES;

DROP TABLE IF EXISTS `drugs_possibleDiseaseTarget`;
CREATE TABLE `drugs_possibleDiseaseTarget` (
	drugs varchar(128),
	possibleDiseaseTarget varchar(2944),
	CONSTRAINT pk_drugs_possibleDiseaseTarget PRIMARY KEY(drugs,possibleDiseaseTarget),
	CONSTRAINT fk_drugs_possibleDiseaseTarget FOREIGN KEY(drugs) REFERENCES `drugs_main`(drugs)
);
LOCK TABLES `drugs_possibleDiseaseTarget` WRITE;
LOAD DATA INFILE '/data/prohde/lslod/tsv/drugbank/drugs_possibleDiseaseTarget.tsv' INTO TABLE `drugs_possibleDiseaseTarget` FIELDS TERMINATED BY '\t' LINES TERMINATED BY '\n' IGNORE 1 ROWS;
UNLOCK TABLES;
CREATE INDEX drugs_possibleDiseaseTarget ON drugs_possibleDiseaseTarget(possibleDiseaseTarget(1000));
CREATE INDEX drugs_possibleDiseaseTarget_drugs ON drugs_possibleDiseaseTarget(drugs);

DROP TABLE IF EXISTS `drugs_sameAs`;
CREATE TABLE `drugs_sameAs` (
	drugs varchar(128),
	sameAs varchar(2944),
	CONSTRAINT pk_drugs_sameAs PRIMARY KEY(drugs,sameAs),
	CONSTRAINT fk_drugs_sameAs FOREIGN KEY(drugs) REFERENCES `drugs_main`(drugs)
);
LOCK TABLES `drugs_sameAs` WRITE;
LOAD DATA INFILE '/data/prohde/lslod/tsv/drugbank/drugs_sameAs.tsv' INTO TABLE `drugs_sameAs` FIELDS TERMINATED BY '\t' LINES TERMINATED BY '\n' IGNORE 1 ROWS;
UNLOCK TABLES;
CREATE INDEX drugs_sameAs ON `drugs_sameAs`(sameAs(1000));

DROP TABLE IF EXISTS `drugs_secondaryAccessionNumber`;
CREATE TABLE `drugs_secondaryAccessionNumber` (
	drugs varchar(128),
	secondaryAccessionNumber varchar(2944),
	CONSTRAINT pk_drugs_secondaryAccessionNumber PRIMARY KEY(drugs,secondaryAccessionNumber),
	CONSTRAINT fk_drugs_secondaryAccessionNumber FOREIGN KEY(drugs) REFERENCES `drugs_main`(drugs)
);
LOCK TABLES `drugs_secondaryAccessionNumber` WRITE;
LOAD DATA INFILE '/data/prohde/lslod/tsv/drugbank/drugs_secondaryAccessionNumber.tsv' INTO TABLE `drugs_secondaryAccessionNumber` FIELDS TERMINATED BY '\t' LINES TERMINATED BY '\n' IGNORE 1 ROWS;
UNLOCK TABLES;

DROP TABLE IF EXISTS `drugs_synonym`;
CREATE TABLE `drugs_synonym` (
	drugs varchar(128),
	synonym varchar(2944),
	CONSTRAINT pk_drugs_synonym PRIMARY KEY(drugs,synonym),
	CONSTRAINT fk_drugs_synonym FOREIGN KEY(drugs) REFERENCES `drugs_main`(drugs)
);
LOCK TABLES `drugs_synonym` WRITE;
LOAD DATA INFILE '/data/prohde/lslod/tsv/drugbank/drugs_synonym.tsv' INTO TABLE `drugs_synonym` FIELDS TERMINATED BY '\t' LINES TERMINATED BY '\n' IGNORE 1 ROWS;
UNLOCK TABLES;

DROP TABLE IF EXISTS `drugs_target`;
CREATE TABLE `drugs_target` (
	drugs varchar(128),
	target varchar(2944),
	CONSTRAINT pk_drugs_target PRIMARY KEY(drugs,target),
	CONSTRAINT fk_drugs_target FOREIGN KEY(drugs) REFERENCES `drugs_main`(drugs)
);
LOCK TABLES `drugs_target` WRITE;
LOAD DATA INFILE '/data/prohde/lslod/tsv/drugbank/drugs_target.tsv' INTO TABLE `drugs_target` FIELDS TERMINATED BY '\t' LINES TERMINATED BY '\n' IGNORE 1 ROWS;
UNLOCK TABLES;

DROP TABLE IF EXISTS `targets_cellularLocation`;
CREATE TABLE `targets_cellularLocation` (
	targets varchar(128),
	cellularLocation varchar(2944),
	CONSTRAINT pk_targets_cellularLocation PRIMARY KEY(targets,cellularLocation),
	CONSTRAINT fk_targets_cellularLocation FOREIGN KEY(targets) REFERENCES `targets_main`(targets)
);
LOCK TABLES `targets_cellularLocation` WRITE;
LOAD DATA INFILE '/data/prohde/lslod/tsv/drugbank/targets_cellularLocation.tsv' INTO TABLE `targets_cellularLocation` FIELDS TERMINATED BY '\t' LINES TERMINATED BY '\n' IGNORE 1 ROWS;
UNLOCK TABLES;

DROP TABLE IF EXISTS `targets_drugReference`;
CREATE TABLE `targets_drugReference` (
	targets varchar(128),
	drugReference varchar(2944),
	CONSTRAINT pk_targets_drugReference PRIMARY KEY(targets,drugReference),
	CONSTRAINT fk_targets_drugReference FOREIGN KEY(targets) REFERENCES `targets_main`(targets)
);
LOCK TABLES `targets_drugReference` WRITE;
LOAD DATA INFILE '/data/prohde/lslod/tsv/drugbank/targets_drugReference.tsv' INTO TABLE `targets_drugReference` FIELDS TERMINATED BY '\t' LINES TERMINATED BY '\n' IGNORE 1 ROWS;
UNLOCK TABLES;

DROP TABLE IF EXISTS `targets_generalReference`;
CREATE TABLE `targets_generalReference` (
	targets varchar(128),
	generalReference varchar(2944),
	CONSTRAINT pk_targets_generalReference PRIMARY KEY(targets,generalReference),
	CONSTRAINT fk_targets_generalReference FOREIGN KEY(targets) REFERENCES `targets_main`(targets)
);
LOCK TABLES `targets_generalReference` WRITE;
LOAD DATA INFILE '/data/prohde/lslod/tsv/drugbank/targets_generalReference.tsv' INTO TABLE `targets_generalReference` FIELDS TERMINATED BY '\t' LINES TERMINATED BY '\n' IGNORE 1 ROWS;
UNLOCK TABLES;

DROP TABLE IF EXISTS `targets_goClassificationComponent`;
CREATE TABLE `targets_goClassificationComponent` (
	targets varchar(128),
	goClassificationComponent varchar(2944),
	CONSTRAINT pk_targets_goClassificationComponent PRIMARY KEY(targets,goClassificationComponent),
	CONSTRAINT fk_targets_goClassificationComponent FOREIGN KEY(targets) REFERENCES `targets_main`(targets)
);
LOCK TABLES `targets_goClassificationComponent` WRITE;
LOAD DATA INFILE '/data/prohde/lslod/tsv/drugbank/targets_goClassificationComponent.tsv' INTO TABLE `targets_goClassificationComponent` FIELDS TERMINATED BY '\t' LINES TERMINATED BY '\n' IGNORE 1 ROWS;
UNLOCK TABLES;

DROP TABLE IF EXISTS `targets_goClassificationFunction`;
CREATE TABLE `targets_goClassificationFunction` (
	targets varchar(128),
	goClassificationFunction varchar(2944),
	CONSTRAINT pk_targets_goClassificationFunction PRIMARY KEY(targets,goClassificationFunction),
	CONSTRAINT fk_targets_goClassificationFunction FOREIGN KEY(targets) REFERENCES `targets_main`(targets)
);
LOCK TABLES `targets_goClassificationFunction` WRITE;
LOAD DATA INFILE '/data/prohde/lslod/tsv/drugbank/targets_goClassificationFunction.tsv' INTO TABLE `targets_goClassificationFunction` FIELDS TERMINATED BY '\t' LINES TERMINATED BY '\n' IGNORE 1 ROWS;
UNLOCK TABLES;

DROP TABLE IF EXISTS `targets_goClassificationProcess`;
CREATE TABLE `targets_goClassificationProcess` (
	targets varchar(128),
	goClassificationProcess varchar(2944),
	CONSTRAINT pk_targets_goClassificationProcess PRIMARY KEY(targets,goClassificationProcess),
	CONSTRAINT fk_targets_goClassificationProcess FOREIGN KEY(targets) REFERENCES `targets_main`(targets)
);
LOCK TABLES `targets_goClassificationProcess` WRITE;
LOAD DATA INFILE '/data/prohde/lslod/tsv/drugbank/targets_goClassificationProcess.tsv' INTO TABLE `targets_goClassificationProcess` FIELDS TERMINATED BY '\t' LINES TERMINATED BY '\n' IGNORE 1 ROWS;
UNLOCK TABLES;

DROP TABLE IF EXISTS `targets_pfamDomainFunction`;
CREATE TABLE `targets_pfamDomainFunction` (
	targets varchar(128),
	pfamDomainFunction varchar(2944),
	CONSTRAINT pk_targets_pfamDomainFunction PRIMARY KEY(targets,pfamDomainFunction),
	CONSTRAINT fk_targets_pfamDomainFunction FOREIGN KEY(targets) REFERENCES `targets_main`(targets)
);
LOCK TABLES `targets_pfamDomainFunction` WRITE;
LOAD DATA INFILE '/data/prohde/lslod/tsv/drugbank/targets_pfamDomainFunction.tsv' INTO TABLE `targets_pfamDomainFunction` FIELDS TERMINATED BY '\t' LINES TERMINATED BY '\n' IGNORE 1 ROWS;
UNLOCK TABLES;

DROP TABLE IF EXISTS `targets_pfamDomainFunctionPage`;
CREATE TABLE `targets_pfamDomainFunctionPage` (
	targets varchar(128),
	pfamDomainFunctionPage varchar(2944),
	CONSTRAINT pk_targets_pfamDomainFunctionPage PRIMARY KEY(targets,pfamDomainFunctionPage),
	CONSTRAINT fk_targets_pfamDomainFunctionPage FOREIGN KEY(targets) REFERENCES `targets_main`(targets)
);
LOCK TABLES `targets_pfamDomainFunctionPage` WRITE;
LOAD DATA INFILE '/data/prohde/lslod/tsv/drugbank/targets_pfamDomainFunctionPage.tsv' INTO TABLE `targets_pfamDomainFunctionPage` FIELDS TERMINATED BY '\t' LINES TERMINATED BY '\n' IGNORE 1 ROWS;
UNLOCK TABLES;

DROP TABLE IF EXISTS `targets_sameAs`;
CREATE TABLE `targets_sameAs` (
	targets varchar(128),
	sameAs varchar(2944),
	CONSTRAINT pk_targets_sameAs PRIMARY KEY(targets,sameAs),
	CONSTRAINT fk_targets_sameAs FOREIGN KEY(targets) REFERENCES `targets_main`(targets)
);
LOCK TABLES `targets_sameAs` WRITE;
LOAD DATA INFILE '/data/prohde/lslod/tsv/drugbank/targets_sameAs.tsv' INTO TABLE `targets_sameAs` FIELDS TERMINATED BY '\t' LINES TERMINATED BY '\n' IGNORE 1 ROWS;
UNLOCK TABLES;

DROP TABLE IF EXISTS `targets_synonym`;
CREATE TABLE `targets_synonym` (
	targets varchar(128),
	synonym varchar(2944),
	CONSTRAINT pk_targets_synonym PRIMARY KEY(targets,synonym),
	CONSTRAINT fk_targets_synonym FOREIGN KEY(targets) REFERENCES `targets_main`(targets)
);
LOCK TABLES `targets_synonym` WRITE;
LOAD DATA INFILE '/data/prohde/lslod/tsv/drugbank/targets_synonym.tsv' INTO TABLE `targets_synonym` FIELDS TERMINATED BY '\t' LINES TERMINATED BY '\n' IGNORE 1 ROWS;
UNLOCK TABLES;

DROP TABLE IF EXISTS `targets_transmembraneRegions`;
CREATE TABLE `targets_transmembraneRegions` (
	targets varchar(128),
	transmembraneRegions varchar(2944),
	CONSTRAINT pk_targets_transmembraneRegions PRIMARY KEY(targets,transmembraneRegions),
	CONSTRAINT fk_targets_transmembraneRegions FOREIGN KEY(targets) REFERENCES `targets_main`(targets)
);
LOCK TABLES `targets_transmembraneRegions` WRITE;
LOAD DATA INFILE '/data/prohde/lslod/tsv/drugbank/targets_transmembraneRegions.tsv' INTO TABLE `targets_transmembraneRegions` FIELDS TERMINATED BY '\t' LINES TERMINATED BY '\n' IGNORE 1 ROWS;
UNLOCK TABLES;