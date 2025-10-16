# %%
from os import path
from sqlalchemy import create_engine, text
import pandas as pd

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
lifecycle_query = read_query('life_cycle_parameterized.sql')
reference_dates_query = read_query('reference_dates.sql')

# %%
app_engine = create_engine(f"sqlite:///{DATA_DIR}/database_loyalty_system.db")
analytical_engine = create_engine(f"sqlite:///{DATA_DIR}/database_analytical.db")

# %%
reference_dates = pd.read_sql(reference_dates_query, con=app_engine)

for date in reference_dates['DtRef'].to_list()[:-1]:
    df_lifecycle = pd.read_sql(lifecycle_query.format(date=date), con=app_engine)

    with analytical_engine.begin() as connection:
        connection.execute(text(f"DELETE FROM clients_lifecycle WHERE DtRef = '{date}'"))
        df_lifecycle.to_sql('clients_lifecycle', con=connection, index=False, if_exists='append')