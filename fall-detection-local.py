import sqlite3
import mysql.connector
from mysql.connector import Error
import datetime
import numpy as np
import pandas as pd
import time
import random
import joblib
import os

# Load the trained machine learning model for fall detection
model = joblib.load('/home/albxii/ecs/ecs_rf_model.pkl')

def connect_to_databases(sqlite_db, mysql_host, mysql_user, mysql_password, mysql_db):
    """ Establish connections to both SQLite and MySQL databases """
    try:
        sqlite_conn = sqlite3.connect(sqlite_db)
        print("Connected to SQLite DB successfully.")
        mysql_conn = mysql.connector.connect(
            host=mysql_host, user=mysql_user, passwd=mysql_password, database=mysql_db
        )
        print("Connected to MySQL DB successfully.")
        return sqlite_conn, mysql_conn
    except Exception as e:
        print(f"Database connection error: {e}")
    return None, None

def insert_sensor_data(conn, profile_id, timestamp, sensor_type, value):
    """ Insert sensor data into the database """
    try:
        sql = ''' INSERT INTO sensordata(ProfileID, Timestamp, SensorType, Value)
                  VALUES(?,?,?,?) '''
        cur = conn.cursor()
        cur.execute(sql, (profile_id, timestamp, sensor_type, value))
        conn.commit()
    except Error as e:
        print(f"Failed to insert sensor data: {e}")

def insert_alert_log(conn, profile_id, alert_type, timestamp, resolved=0):
    """ Insert an alert log into the database """
    try:
        if isinstance(conn, sqlite3.Connection):
            sql = ''' INSERT INTO alertlogs(ProfileID, AlertType, AlertTimestamp, Resolved)
                      VALUES(?,?,?,?) '''
        else:
            sql = ''' INSERT INTO alertlogs(ProfileID, AlertType, AlertTimestamp, Resolved)
                      VALUES(%s, %s, %s, %s) '''
        cur = conn.cursor()
        cur.execute(sql, (profile_id, alert_type, timestamp, resolved))
        conn.commit()
    except Error as e:
        print(f"Failed to insert alert log: {e}")

def send_alert_to_device(message):
    """ Placeholder for sending alert to a wearable device """
    print(f"Sending alert to device: {message}")

def simulate_sensor_data():
    """ Generate simulated sensor data for heart rate, acceleration, and gyroscope """
    return (random.randint(60, 100),
            (random.uniform(-2, 2), random.uniform(-2, 2), random.uniform(-2, 2)),
            (random.uniform(-200, 200), random.uniform(-200, 200), random.uniform(-200, 200)))

def detect_fall(acceleration, gyroscope, acc_threshold=1.0, gyro_threshold=150, duration_threshold=3):
    """ Determine whether a fall has occurred based on sensor data """
    global stable_count, unstable_count
    if max(abs(np.array(acceleration))) > acc_threshold or max(abs(np.array(gyroscope))) > gyro_threshold:
        unstable_count += 1
        stable_count = 0
        if unstable_count >= duration_threshold:
            unstable_count = 0
            return True
    else:
        if unstable_count > 0:
            stable_count += 1
            if stable_count >= duration_threshold:
                unstable_count = 0
                stable_count = 0
                return True
    return False

def main():
    """ Main function to run the fall detection system """
    global stable_count, unstable_count
    stable_count, unstable_count = 0, 0
    sqlite_conn, mysql_conn = connect_to_databases('/home/albxii/ecs/elderlycaresystemlocaldb.db',
                                                   'elderlycaresystemclouddb.mysql.database.azure.com', 'root_admin', '1A2a4=33NTG.', 'elderlycareclouddb')
    profile_id = 1
    try:
        while True:
            if os.path.exists('stop.txt'):
                print("Stop file detected. Exiting program...")
                os.remove('stop.txt')
                break
            heart_rate, acceleration, gyroscope = simulate_sensor_data()
            timestamp = time.strftime('%Y-%m-%d %H:%M:%S')
            insert_sensor_data(sqlite_conn, profile_id, timestamp, 'Heart Rate', heart_rate)
            insert_sensor_data(sqlite_conn, profile_id, timestamp, 'Accelerometer', np.mean(acceleration))
            insert_sensor_data(sqlite_conn, profile_id, timestamp, 'Gyroscope', np.mean(gyroscope))
            
            if detect_fall(acceleration, gyroscope):
                alert_message = f"Fall detected with heart rate: {heart_rate}, acceleration: {acceleration}, gyroscope: {gyroscope}"
                print(alert_message)
                insert_alert_log(sqlite_conn, profile_id, 'Fall Detected', timestamp)
                insert_alert_log(mysql_conn, profile_id, 'Fall Detected', timestamp)
                send_alert_to_device(alert_message)
            else:
                print(f"No fall detected at {timestamp}")
            time.sleep(1)
    except KeyboardInterrupt:
        print("Program terminated by user.")
    finally:
        if sqlite_conn:
            sqlite_conn.close()
        if mysql_conn:
            mysql_conn.close()
        print("Database connections closed.")

if __name__ == "__main__":
    main()
