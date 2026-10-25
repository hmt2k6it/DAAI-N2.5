import os
import urllib.parse
from pathlib import Path
from dotenv import load_dotenv
from sqlalchemy import create_engine
import pyodbc

def load_env():
    # Tim file .env tu nhieu vi tri tuong doi
    current_dir = Path(__file__).resolve().parent if "__file__" in globals() else Path.cwd()
    for env_candidate in [current_dir / ".env", current_dir / "DataWarehouse" / "ETL" / ".env", Path(".env")]:
        if env_candidate.exists():
            load_dotenv(env_candidate, override=True)
            return
    load_dotenv(override=True)

def get_connection_string(database=None):
    load_env()
    server = os.getenv("DB_SERVER", "localhost")
    db = database or os.getenv("DB_NAME", "datawarehouse")
    driver = os.getenv("DB_DRIVER", "ODBC Driver 18 for SQL Server")
    trusted = os.getenv("DB_TRUSTED_CONNECTION", "yes")
    trust_cert = os.getenv("DB_TRUST_SERVER_CERTIFICATE", "yes")
    user = os.getenv("DB_USER")
    password = os.getenv("DB_PASSWORD")

    parts = [
        f"DRIVER={{{driver}}}",
        f"SERVER={server}",
        f"DATABASE={db}",
        f"TrustServerCertificate={trust_cert}"
    ]
    if user and password:
        parts.append(f"UID={user}")
        parts.append(f"PWD={password}")
    else:
        parts.append(f"Trusted_Connection={trusted}")

    return ";".join(parts) + ";"

def get_engine(database=None):
    """Tao SQLAlchemy Engine toi uu voi fast_executemany cho Microsoft SQL Server"""
    conn_str = get_connection_string(database=database)
    params = urllib.parse.quote_plus(conn_str)
    return create_engine(f"mssql+pyodbc:///?odbc_connect={params}", fast_executemany=True)

def get_raw_connection(database=None):
    """Tao pyodbc Connection truc tiep voi autocommit"""
    return pyodbc.connect(get_connection_string(database=database), autocommit=True)

if __name__ == "__main__":
    conn = get_raw_connection("master")
    cur = conn.cursor()
    cur.execute("SELECT @@VERSION")
    print("Ket noi SQL Server thanh cong:")
    print(cur.fetchone()[0])
    conn.close()
