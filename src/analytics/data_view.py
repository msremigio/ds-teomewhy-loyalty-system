# %%
from os import path
from sqlalchemy import create_engine
import pandas as pd
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

dau_query = read_query('dau.sql')
mau_query = read_query('mau.sql')
mau_28days_query = read_query('mau_28days.sql')

# %%
engine = create_engine(f"sqlite:///{DATA_DIR}/database_loyalty_system.db")

dau = pd.read_sql(dau_query, con=engine)
mau = pd.read_sql(mau_query, con=engine)
mau_28days = pd.read_sql(mau_28days_query, con=engine)

# %%
fig, (ax1, ax2, ax3) = plt.subplots(3, 1, figsize=(20,15))

ax1.plot(dau["DtDay"], dau["DAU"])
ax1.set_title('DAU')
ax1.set_ylabel('Distinct Users')
ax1.set_xticks(ax1.get_xticks()[::50])

ax2.plot(mau["DtMonth"], mau["MAU"])
ax2.set_title('MAU')
ax2.set_ylabel('Distinct Users')
ax2.set_xticks(ax2.get_xticks()[::2])

ax3.plot(mau_28days["DtRef"], mau_28days["MAU28Days"])
ax3.set_title('MAU (28 days)')
ax3.set_ylabel('Distinct Users')
ax3.set_xticks(ax3.get_xticks()[::50])

plt.savefig("active_users_analytics.png")


# %%
