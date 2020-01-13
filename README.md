# Ontario-SEAData2020

This repository contains all source files and data used for the experiment presented in "Optimizing Federated Queries Based on the Data Lake Physical
Design" at SEA Data 2020.

## Requirements
In order to run the experiment the following software is needed.
* Python 3 (incl. numpy, pandas, and matplotlib)
* Jupyter Notebook with R kernel
* Docker (incl. docker-compose)

## Preparation
Before running the experiment, the data sources must be initialized and the Docker image of the engine needs to be build.
To do so, perform the following setps.

1. extract the data files from the archive (recommanded to use 7-zip ``cd datasources/tsv; 7z x tsv.zip.001; cd ../..``)
2. start the Docker containers: ``docker-compose -f datasources/mysql/docker-compose.yml up -d``
3. while waiting for the containers to finish loading the data build the Docker image ``docker build ./code -t prohde/ontario:sea2020``

## Running the Experiment
Once the data is loaded, the experiment can be performed by executing ``./experiment.sh``.
If the data sources are not running on the same host or your internal IP address of the Docker host is different, change ``172.17.0.1`` in the file ``./configurations/semdl-lslod.json`` accordingly.

## Analysis
First, prepare the data for R and generate the bar chart for the query execution time by typing:

``python3 analysis.py``

Second, to calculate the diefficiency open ``dief.ipynp`` in Jupyter Notebook and run it.
