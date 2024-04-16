import sqlite3
import mysql.connector
from mysql.connector import Error

def connect_to_sqlite(db_file):
    try:
        conn = sqlite3.connect(db_file)
        print("Connected to SQLite DB successfully.")
        return conn
    except sqlite3.Error as e:
        print(f"SQLite error: {e}")
    return None

def connect_to_mysql(host_name, user_name, user_password, db_name):
    try:
        conn = mysql.connector.connect(
            host=host_name,
            user=user_name,
            passwd=user_password,
            database=db_name
        )
        print("Connected to MySQL DB successfully.")
        return conn
    except Error as e:
        print(f"MySQL Error: {e}")
    return None

def transfer_data(sqlite_conn, mysql_conn):
    sqlite_cursor = sqlite_conn.cursor()
    sqlite_cursor.execute("SELECT ProfileID, Timestamp, SensorType, Value FROM sensordata")
    rows = sqlite_cursor.fetchall()

    mysql_cursor = mysql_conn.cursor()
    for row in rows:
        try:
            mysql_cursor.execute("""
                INSERT INTO sensordatahistory (ProfileID, Timestamp, SensorType, Value)
                VALUES (%s, %s, %s, %s)
                """, row)
            mysql_conn.commit()
            print(f"Data transferred for ProfileID: {row[0]}")
        except mysql.connector.Error as e:
            print(f"Failed to insert data for ProfileID {row[0]}: {e}")

def main():
    sqlite_conn = connect_to_sqlite('/home/albxii/ecs/elderlycaresystemlocaldb.db')
    mysql_conn = connect_to_mysql('elderlycaresystemclouddb.mysql.database.azure.com', 'root_admin', '1A2a4=33NTG.', 'elderlycareclouddb')
    
    if sqlite_conn and mysql_conn:
        print("Starting data transfer...")
        transfer_data(sqlite_conn, mysql_conn)
        sqlite_conn.close()
        mysql_conn.close()
        print("Data transfer complete and connections closed.")
    else:
        print("Failed to connect to one or more databases.")

if __name__ == "__main__":
    main()
