import pandas as pd

df_tf_raw = pd.read_json('student_data/tf.json')
df_tf_silver = df_tf_raw.copy()

df_tf_silver = df_tf_silver.drop_duplicates()

str_cols = df_tf_silver.select_dtypes(include=['object']).columns
for col in str_cols:
    df_tf_silver[col] = df_tf_silver[col].apply(lambda x: x.strip() if isinstance(x, str) else x)
df_tf_silver.to_csv('student_data/silver_tf.csv', index=False)

try:
    display(df_tf_silver.head())
except NameError:
    print(df_tf_silver.head())