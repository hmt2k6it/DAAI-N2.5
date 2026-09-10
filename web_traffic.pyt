import pandas as pd

df_web_traffic_raw = pd.read_csv('student_data/web_traffic.csv')
df_web_traffic_silver = df_web_traffic_raw.copy()
df_web_traffic_silver = df_web_traffic_silver.drop_duplicates()
str_cols = df_web_traffic_silver.select_dtypes(include=['object']).columns
for col in str_cols:
    df_web_traffic_silver[col] = df_web_traffic_silver[col].astype(str).str.strip()
if 'timestamp' in df_web_traffic_silver.columns:
    df_web_traffic_silver['timestamp'] = pd.to_datetime(df_web_traffic_silver['timestamp'], errors='coerce')

df_web_traffic_silver.to_csv('student_data/silver_web_traffic.csv', index=False)
try:
    display(df_web_traffic_silver.head())
except NameError:
    print(df_web_traffic_silver.head())