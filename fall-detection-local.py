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
import logging

# Set up basic configuration for logging
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')

# Load the trained machine learning model for fall detection
model_path = '/home/albxii/ecs/ecs_rf_model.pkl'
model = joblib.load(model_path)

def connect_to_databases(config):
    try:
        sqlite_conn = sqlite3.connect(config['sqlite_db'])
        logging.info("Connected to SQLite DB successfully.")
        mysql_conn = mysql.connector.connect(**config['mysql'])
        logging.info("Connected to MySQL DB successfully.")
        return sqlite_conn, mysql_conn
    except Error as e:
        logging.error(f"Database connection error: {e}")
    return None, None

def insert_sensor_data(conn, profile_id, timestamp, sensor_type, value):
    try:
        sql = ''' INSERT INTO sensordata(ProfileID, Timestamp, SensorType, Value)
                  VALUES(?,?,?,?) '''
        cur = conn.cursor()
        cur.execute(sql, (profile_id, timestamp, sensor_type, value))
        conn.commit()
    except Error as e:
        logging.error(f"Failed to insert sensor data: {e}")

def insert_alert_log(conn, profile_id, alert_type, timestamp, resolved=0):
    try:
        sql = ''' INSERT INTO alertlogs(ProfileID, AlertType, AlertTimestamp, Resolved)
                  VALUES(?,?,?,?) ''' if isinstance(conn, sqlite3.Connection) else \
               ''' INSERT INTO alertlogs(ProfileID, AlertType, AlertTimestamp, Resolved)
                  VALUES(%s, %s, %s, %s) '''
        cur = conn.cursor()
        cur.execute(sql, (profile_id, alert_type, timestamp, resolved))
        conn.commit()
    except Error as e:
        logging.error(f"Failed to insert alert log: {e}")

def simulate_sensor_data():
    return (random.randint(60, 100),
            (random.uniform(-2, 2), random.uniform(-2, 2), random.uniform(-2, 2)),
            (random.uniform(-200, 200), random.uniform(-200, 200), random.uniform(-200, 200)))

def detect_fall(acceleration, gyroscope, thresholds):
    if max(abs(np.array(acceleration))) > thresholds['acc'] or \
       max(abs(np.array(gyroscope))) > thresholds['gyro']:
        return True
    return False

def main():
    db_config = {
        'sqlite_db': '/home/albxii/ecs/elderlycaresystemlocaldb.db',
        'mysql': {
            'host': 'elderlycaresystemclouddb.mysql.database.azure.com',
            'user': 'root_admin',
            'passwd': '1A2a4=33NTG.',
            'database': 'elderlycareclouddb'
        }
    }
    thresholds = {'acc': 1.0, 'gyro': 150}

    sqlite_conn, mysql_conn = connect_to_databases(db_config)
    profile_id = 1
    try:
        while True:
            if os.path.exists('stop.txt'):
                logging.info("Stop file detected. Exiting program...")
                os.remove('stop.txt')
                break
            data = simulate_sensor_data()
            timestamp = datetime.datetime.now().strftime('%Y-%m-%d %H:%M:%S')
            insert_sensor_data(sqlite_conn, profile_id, timestamp, 'Heart Rate', data[0])
            insert_sensor_data(sqlite_conn, profile_id, timestamp, 'Accelerometer', np.mean(data[1]))
            insert_sensor_data(sqlite_conn, profile_id, timestamp, 'Gyroscope', np.mean(data[2]))
            
            if detect_fall(data[1], data[2], thresholds):
                alert_message = f"Fall detected with heart rate: {data[0]}, acceleration: {data[1]}, gyroscope: {data[2]}"
                logging.info(alert_message)
                insert_alert_log(sqlite_conn, profile_id, 'Fall Detected', timestamp)
                insert_alert_log(mysql_conn, profile_id, 'Fall Detected', timestamp)
            else:
                logging.info(f"No fall detected at {timestamp}")
            time.sleep(1)
    except KeyboardInterrupt:
        logging.info("Program terminated by user.")
    finally:
        if sqlite_conn:
            sqlite_conn.close()
        if mysql_conn:
            mysql_conn.close()
        logging.info("Database connections closed.")

if __name__ == "__main__":
    main()
