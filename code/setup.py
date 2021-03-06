#!/usr/bin/env python3

from distutils.core import setup
from setuptools import find_packages

setup(name='ontario',
      version='1.0',
      description='Ontario - Ontology-based architecture for semantic data lakes',
      author='Kemele M. Endris',
      author_email='endris@l3s.de',
      url='https://github.com/SDM-TIB/Ontario',
      scripts=['scripts/runExperiment.py', 'run_query.py', 'scripts/runOntarioExp.sh', 'scripts/run_dief_experiment.py'],
      packages=find_packages(exclude=['docs']),
      install_requires=["ply",
                        'hdfs',
                        'pyspark',
                        'pymongo',
                        'pydrill',
                        'mysql-connector-python==8.0.11',
                        'neo4j-driver',
                        'rdflib',
                        'networkx'],
      include_package_data=True,
      license='GNU/GPL v2'
      )
