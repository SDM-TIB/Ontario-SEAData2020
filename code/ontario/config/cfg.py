
__author__ = 'Philipp D. Rohde'

"""This module serves as a global configuration for Ontario."""

import json
from .PlanType import PlanType


def __load_indexes():
    """Get a dictionary containing the RDB indexes."""
    index_file = open('/data/configuration/indexes.json')
    json_str = index_file.read()
    return json.loads(json_str)


planType = PlanType.SOURCE_SPECIFIC_HEURISTICS  # default plan type
indexes = __load_indexes()   # load indexes from RDB
config = None
query = None
alpha = 1
beta = 0
