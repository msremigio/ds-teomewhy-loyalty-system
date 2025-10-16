# %%
from os import path
from sqlalchemy import create_engine
import pandas as pd
from sklearn.cluster import KMeans
import matplotlib.pyplot as plt

# %%
CURRENT_DIR = path.dirname(__file__)
SRC_DIR = path.dirname(CURRENT_DIR)
BASE_DIR = path.dirname(SRC_DIR)
DATA_DIR = path.join(BASE_DIR, 'data')

# %%
def read_query(query_file: str) -> str:
    with open(path.join(CURRENT_DIR, query_file), 'r') as open_file:
        query = open_file.read()

    return query

# %%
rfv_query = read_query('recency_frequency_value.sql')

# %%
app_engine = create_engine(f"sqlite:///{DATA_DIR}/database_loyalty_system.db")