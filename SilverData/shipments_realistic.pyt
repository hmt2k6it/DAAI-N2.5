import pandas as pd

df_shipments_raw = pd.read_csv('student_data/shipments_realistic.csv')
df_shipments_silver = df_shipments_raw.copy()
df_shipments_silver = df_shipments_silver.drop_duplicates()
str_cols = df_shipments_silver.select_dtypes(include=['object']).columns
for col in str_cols:
    df_shipments_silver[col] = df_shipments_silver[col].astype(str).str.strip()

date_cols = ['ship_date', 'delivery_date'] 
for col in date_cols:
    if col in df_shipments_silver.columns:
        df_shipments_silver[col] = pd.to_datetime(df_shipments_silver[col], errors='coerce')

if 'ship_date' in df_shipments_silver.columns and 'delivery_date' in df_shipments_silver.columns:
    valid_dates = df_shipments_silver['delivery_date'] >= df_shipments_silver['ship_date']
  
    df_shipments_silver = df_shipments_silver[valid_dates | df_shipments_silver['delivery_date'].isna()]

df_shipments_silver.to_csv('student_data/silver_shipments_realistic.csv', index=False)

try:
    display(df_shipments_silver.head())
except NameError:
    print(df_shipments_silver.head())