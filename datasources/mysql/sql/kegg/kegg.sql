CREATE DATABASE IF NOT EXISTS `kegg` /*!40100 DEFAULT CHARACTER SET latin1 DEFAULT COLLATE latin1_general_cs */;
USE `kegg`;
/*!40101 SET NAMES utf8 */;


DROP TABLE IF EXISTS `Compound_main`;
CREATE TABLE `Compound_main` (
	Compound varchar(1000) PRIMARY KEY,
	label text,
	sameAs text,
	identifier text,
	title text,
	formula text,
	mass text,
	url text,
	urlImage text
);
LOCK TABLES `Compound_main` WRITE;
LOAD DATA INFILE '/data/prohde/lslod/tsv/kegg/Compound_main.tsv' INTO TABLE `Compound_main` FIELDS TERMINATED BY '\t' LINES TERMINATED BY '\n' IGNORE 1 ROWS;
UNLOCK TABLES;

DROP TABLE IF EXISTS `Drug_main`;
CREATE TABLE `Drug_main` (
	Drug varchar(1000) PRIMARY KEY,
	label text,
	sameAs text,
	identifier text,
	title text,
	formula text,
	mass text,
	url text,
	urlImage text
);
LOCK TABLES `Drug_main` WRITE;
LOAD DATA INFILE '/data/prohde/lslod/tsv/kegg/Drug_main.tsv' INTO TABLE `Drug_main` FIELDS TERMINATED BY '\t' LINES TERMINATED BY '\n' IGNORE 1 ROWS;
UNLOCK TABLES;

DROP TABLE IF EXISTS `Enzyme_main`;
CREATE TABLE `Enzyme_main` (
	Enzyme varchar(1000) PRIMARY KEY,
	label text,
	comment text,
	identifier text,
	title text,
	url text,
	systematicName text
);
LOCK TABLES `Enzyme_main` WRITE;
LOAD DATA INFILE '/data/prohde/lslod/tsv/kegg/Enzyme_main.tsv' INTO TABLE `Enzyme_main` FIELDS TERMINATED BY '\t' LINES TERMINATED BY '\n' IGNORE 1 ROWS;
UNLOCK TABLES;

DROP TABLE IF EXISTS `Reaction_main`;
CREATE TABLE `Reaction_main` (
	Reaction varchar(1000) PRIMARY KEY,
	label text,
	comment text,
	sameAs text,
	identifier text,
	title text,
	url text,
	urlImage text,
	equation text
);
LOCK TABLES `Reaction_main` WRITE;
LOAD DATA INFILE '/data/prohde/lslod/tsv/kegg/Reaction_main.tsv' INTO TABLE `Reaction_main` FIELDS TERMINATED BY '\t' LINES TERMINATED BY '\n' IGNORE 1 ROWS;
UNLOCK TABLES;

DROP TABLE IF EXISTS `Compound_synonym`;
CREATE TABLE `Compound_synonym` (
	Compound varchar(128),
	synonym varchar(2944),
	CONSTRAINT pk_Compound_synonym PRIMARY KEY(Compound,synonym),
	CONSTRAINT fk_Compound_synonym FOREIGN KEY(Compound) REFERENCES `Compound_main`(Compound)
);
LOCK TABLES `Compound_synonym` WRITE;
LOAD DATA INFILE '/data/prohde/lslod/tsv/kegg/Compound_synonym.tsv' INTO TABLE `Compound_synonym` FIELDS TERMINATED BY '\t' LINES TERMINATED BY '\n' IGNORE 1 ROWS;
UNLOCK TABLES;

DROP TABLE IF EXISTS `Compound_xRef`;
CREATE TABLE `Compound_xRef` (
	Compound varchar(128),
	xRef varchar(2944),
	CONSTRAINT pk_Compound_xRef PRIMARY KEY(Compound,xRef),
	CONSTRAINT fk_Compound_xRef FOREIGN KEY(Compound) REFERENCES `Compound_main`(Compound)
);
LOCK TABLES `Compound_xRef` WRITE;
LOAD DATA INFILE '/data/prohde/lslod/tsv/kegg/Compound_xRef.tsv' INTO TABLE `Compound_xRef` FIELDS TERMINATED BY '\t' LINES TERMINATED BY '\n' IGNORE 1 ROWS;
UNLOCK TABLES;

DROP TABLE IF EXISTS `Drug_synonym`;
CREATE TABLE `Drug_synonym` (
	Drug varchar(128),
	synonym varchar(2944),
	CONSTRAINT pk_Drug_synonym PRIMARY KEY(Drug,synonym),
	CONSTRAINT fk_Drug_synonym FOREIGN KEY(Drug) REFERENCES `Drug_main`(Drug)
);
LOCK TABLES `Drug_synonym` WRITE;
LOAD DATA INFILE '/data/prohde/lslod/tsv/kegg/Drug_synonym.tsv' INTO TABLE `Drug_synonym` FIELDS TERMINATED BY '\t' LINES TERMINATED BY '\n' IGNORE 1 ROWS;
UNLOCK TABLES;

DROP TABLE IF EXISTS `Drug_xRef`;
CREATE TABLE `Drug_xRef` (
	Drug varchar(128),
	xRef varchar(2944),
	CONSTRAINT pk_Drug_xRef PRIMARY KEY(Drug,xRef),
	CONSTRAINT fk_Drug_xRef FOREIGN KEY(Drug) REFERENCES `Drug_main`(Drug)
);
LOCK TABLES `Drug_xRef` WRITE;
LOAD DATA INFILE '/data/prohde/lslod/tsv/kegg/Drug_xRef.tsv' INTO TABLE `Drug_xRef` FIELDS TERMINATED BY '\t' LINES TERMINATED BY '\n' IGNORE 1 ROWS;
UNLOCK TABLES;

DROP TABLE IF EXISTS `Enzyme_isA`;
CREATE TABLE `Enzyme_isA` (
	Enzyme varchar(128),
	isA varchar(2944),
	CONSTRAINT pk_Enzyme_isA PRIMARY KEY(Enzyme,isA),
	CONSTRAINT fk_Enzyme_isA FOREIGN KEY(Enzyme) REFERENCES `Enzyme_main`(Enzyme)
);
LOCK TABLES `Enzyme_isA` WRITE;
LOAD DATA INFILE '/data/prohde/lslod/tsv/kegg/Enzyme_isA.tsv' INTO TABLE `Enzyme_isA` FIELDS TERMINATED BY '\t' LINES TERMINATED BY '\n' IGNORE 1 ROWS;
UNLOCK TABLES;

DROP TABLE IF EXISTS `Enzyme_synonym`;
CREATE TABLE `Enzyme_synonym` (
	Enzyme varchar(128),
	synonym varchar(2944),
	CONSTRAINT pk_Enzyme_synonym PRIMARY KEY(Enzyme,synonym),
	CONSTRAINT fk_Enzyme_synonym FOREIGN KEY(Enzyme) REFERENCES `Enzyme_main`(Enzyme)
);
LOCK TABLES `Enzyme_synonym` WRITE;
LOAD DATA INFILE '/data/prohde/lslod/tsv/kegg/Enzyme_synonym.tsv' INTO TABLE `Enzyme_synonym` FIELDS TERMINATED BY '\t' LINES TERMINATED BY '\n' IGNORE 1 ROWS;
UNLOCK TABLES;

DROP TABLE IF EXISTS `Enzyme_xCofactor`;
CREATE TABLE `Enzyme_xCofactor` (
	Enzyme varchar(128),
	xCofactor varchar(2944),
	CONSTRAINT pk_Enzyme_xCofactor PRIMARY KEY(Enzyme,xCofactor),
	CONSTRAINT fk_Enzyme_xCofactor FOREIGN KEY(Enzyme) REFERENCES `Enzyme_main`(Enzyme)
);
LOCK TABLES `Enzyme_xCofactor` WRITE;
LOAD DATA INFILE '/data/prohde/lslod/tsv/kegg/Enzyme_xCofactor.tsv' INTO TABLE `Enzyme_xCofactor` FIELDS TERMINATED BY '\t' LINES TERMINATED BY '\n' IGNORE 1 ROWS;
UNLOCK TABLES;

DROP TABLE IF EXISTS `Enzyme_xGene`;
CREATE TABLE `Enzyme_xGene` (
	Enzyme varchar(128),
	xGene varchar(2944),
	CONSTRAINT pk_Enzyme_xGene PRIMARY KEY(Enzyme,xGene),
	CONSTRAINT fk_Enzyme_xGene FOREIGN KEY(Enzyme) REFERENCES `Enzyme_main`(Enzyme)
);
LOCK TABLES `Enzyme_xGene` WRITE;
LOAD DATA INFILE '/data/prohde/lslod/tsv/kegg/Enzyme_xGene.tsv' INTO TABLE `Enzyme_xGene` FIELDS TERMINATED BY '\t' LINES TERMINATED BY '\n' IGNORE 1 ROWS;
UNLOCK TABLES;

DROP TABLE IF EXISTS `Enzyme_xProduct`;
CREATE TABLE `Enzyme_xProduct` (
	Enzyme varchar(128),
	xProduct varchar(2944),
	CONSTRAINT pk_Enzyme_xProduct PRIMARY KEY(Enzyme,xProduct),
	CONSTRAINT fk_Enzyme_xProduct FOREIGN KEY(Enzyme) REFERENCES `Enzyme_main`(Enzyme)
);
LOCK TABLES `Enzyme_xProduct` WRITE;
LOAD DATA INFILE '/data/prohde/lslod/tsv/kegg/Enzyme_xProduct.tsv' INTO TABLE `Enzyme_xProduct` FIELDS TERMINATED BY '\t' LINES TERMINATED BY '\n' IGNORE 1 ROWS;
UNLOCK TABLES;

DROP TABLE IF EXISTS `Enzyme_xSubstrate`;
CREATE TABLE `Enzyme_xSubstrate` (
	Enzyme varchar(128),
	xSubstrate varchar(2944),
	CONSTRAINT pk_Enzyme_xSubstrate PRIMARY KEY(Enzyme,xSubstrate),
	CONSTRAINT fk_Enzyme_xSubstrate FOREIGN KEY(Enzyme) REFERENCES `Enzyme_main`(Enzyme)
);
LOCK TABLES `Enzyme_xSubstrate` WRITE;
LOAD DATA INFILE '/data/prohde/lslod/tsv/kegg/Enzyme_xSubstrate.tsv' INTO TABLE `Enzyme_xSubstrate` FIELDS TERMINATED BY '\t' LINES TERMINATED BY '\n' IGNORE 1 ROWS;
UNLOCK TABLES;

DROP TABLE IF EXISTS `Reaction_xEnzyme`;
CREATE TABLE `Reaction_xEnzyme` (
	Reaction varchar(128),
	xEnzyme varchar(2944),
	CONSTRAINT pk_Reaction_xEnzyme PRIMARY KEY(Reaction,xEnzyme),
	CONSTRAINT fk_Reaction_xEnzyme FOREIGN KEY(Reaction) REFERENCES `Reaction_main`(Reaction)
);
LOCK TABLES `Reaction_xEnzyme` WRITE;
LOAD DATA INFILE '/data/prohde/lslod/tsv/kegg/Reaction_xEnzyme.tsv' INTO TABLE `Reaction_xEnzyme` FIELDS TERMINATED BY '\t' LINES TERMINATED BY '\n' IGNORE 1 ROWS;
UNLOCK TABLES;

DROP TABLE IF EXISTS `Reaction_xPathway`;
CREATE TABLE `Reaction_xPathway` (
	Reaction varchar(128),
	xPathway varchar(2944),
	CONSTRAINT pk_Reaction_xPathway PRIMARY KEY(Reaction,xPathway),
	CONSTRAINT fk_Reaction_xPathway FOREIGN KEY(Reaction) REFERENCES `Reaction_main`(Reaction)
);
LOCK TABLES `Reaction_xPathway` WRITE;
LOAD DATA INFILE '/data/prohde/lslod/tsv/kegg/Reaction_xPathway.tsv' INTO TABLE `Reaction_xPathway` FIELDS TERMINATED BY '\t' LINES TERMINATED BY '\n' IGNORE 1 ROWS;
UNLOCK TABLES;

DROP TABLE IF EXISTS `Reaction_xProduct`;
CREATE TABLE `Reaction_xProduct` (
	Reaction varchar(128),
	xProduct varchar(2944),
	CONSTRAINT pk_Reaction_xProduct PRIMARY KEY(Reaction,xProduct),
	CONSTRAINT fk_Reaction_xProduct FOREIGN KEY(Reaction) REFERENCES `Reaction_main`(Reaction)
);
LOCK TABLES `Reaction_xProduct` WRITE;
LOAD DATA INFILE '/data/prohde/lslod/tsv/kegg/Reaction_xProduct.tsv' INTO TABLE `Reaction_xProduct` FIELDS TERMINATED BY '\t' LINES TERMINATED BY '\n' IGNORE 1 ROWS;
UNLOCK TABLES;

DROP TABLE IF EXISTS `Reaction_xSubstrate`;
CREATE TABLE `Reaction_xSubstrate` (
	Reaction varchar(128),
	xSubstrate varchar(2944),
	CONSTRAINT pk_Reaction_xSubstrate PRIMARY KEY(Reaction,xSubstrate),
	CONSTRAINT fk_Reaction_xSubstrate FOREIGN KEY(Reaction) REFERENCES `Reaction_main`(Reaction)
);
LOCK TABLES `Reaction_xSubstrate` WRITE;
LOAD DATA INFILE '/data/prohde/lslod/tsv/kegg/Reaction_xSubstrate.tsv' INTO TABLE `Reaction_xSubstrate` FIELDS TERMINATED BY '\t' LINES TERMINATED BY '\n' IGNORE 1 ROWS;
UNLOCK TABLES;