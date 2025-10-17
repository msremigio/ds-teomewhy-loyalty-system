# %%
from os import path
from sqlalchemy import create_engine
import pandas as pd
import matplotlib.pyplot as plt
from sklearn.preprocessing import MinMaxScaler
from sklearn.cluster import KMeans
import seaborn as sns

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

# %%
df_rfv = pd.read_sql(rfv_query, con=app_engine,)

df_rfv = df_rfv[['ClientId', 'Recency', 'Frequency', 'Value']]

# %%
plt.scatter('Frequency', 'Value', data=df_rfv)
plt.title("Frequency x Value")
plt.xlabel('Frequency')
plt.ylabel('Value')
plt.show()

# %%
df_rfv = df_rfv[df_rfv['Value'] < 4000]
df_rfv.reset_index(drop=True, inplace=True)

# %%
plt.scatter('Frequency', 'Value', data=df_rfv)
plt.title("Frequency x Value")
plt.xlabel('Frequency')
plt.ylabel('Value')
plt.show()

# %%
min_max_scaler = MinMaxScaler()
normalized_fv = min_max_scaler.fit_transform(df_rfv[['Frequency', 'Value']])

# %%
kmeans_cluster = KMeans(n_clusters=5, max_iter=1000, random_state=1995)
kmeans_cluster.fit(normalized_fv)

# %%
df_rfv['FrequencyValueCluster'] = kmeans_cluster.labels_

centroids = min_max_scaler.inverse_transform(kmeans_cluster.cluster_centers_)

centroid_x = centroids[:,0]
centroid_y = centroids[:,1]

# %%
plt.scatter('Frequency', 'Value', data=df_rfv)
plt.title("Frequency x Value")
plt.xlabel('Frequency')
plt.ylabel('Value')
plt.legend()
plt.show()

# %%
fig,ax = plt.subplots(figsize=(15,10))
sns.scatterplot(data=df_rfv,
                x='Frequency', y='Value',
                ax=ax,
                hue='FrequencyValueCluster', 
                style='FrequencyValueCluster', 
                palette='deep')
sns.scatterplot(x=centroid_x, y=centroid_y, 
                ax=ax, 
                hue=df_rfv['FrequencyValueCluster'].sort_values().unique(), 
                marker='+',
                s=500,
                palette='deep', 
                legend=False)
ax.set_title('Cluster Groups')
sns.move_legend(ax, 'upper left', bbox_to_anchor=(1,1), ncol=1, title='Cluster', frameon=True)
plt.savefig('frequency_value_clusters.png')