import sqlite3
import mysql.connector
from mysql.connector import Error
import datetime
import numpy as np
import time
import random
import joblib
import os
import logging

# Configure logging
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')

# Constants and Configurations
MODEL_PATH = '/home/albxii/ecs/ecs_rf_model.pkl'
DB_CONFIGS = {
    'sqlite': {
        'type': 'sqlite',
        'path': '/home/albxii/ecs/elderlycaresystemlocaldb.db'
    },
    'mysql': {
        'type': 'mysql',
        'host': 'elderlycaresystemclouddb.mysql.database.azure.com',
        'user': 'root_admin',
        'passwd': '1A2a4=33NTG.',
        'database': 'elderlycareclouddb'
    }
}
THRESHOLDS = {'acc': 1.0, 'gyro': 150}

# Load the machine learning model
model = joblib.load(MODEL_PATH)

def connect_to_database(config):
    """Establishes database connection based on the type specified in the config."""
    try:
        if config['type'] == 'sqlite':
            return sqlite3.connect(config['path'])
        elif config['type'] == 'mysql':
            return mysql.connector.connect(
                host=config['host'],
                user=config['user'],
                passwd=config['passwd'],
                database=config['database']
            )
    except Error as e:
        logging.error(f"Database connection error: {e}")
        return None

def execute_db_query(cursor, query, data=None, fetch=False):
    """Executes a database query safely."""
    try:
        cursor.execute(query, data or ())
        if fetch:
            return cursor.fetchall()
    except Error as e:
        logging.error(f"Database query error: {e}")
        return None

def insert_sensor_data(conn, profile_id, timestamp, sensor_type, value):
    """Inserts sensor data into the database."""
    placeholder = '?' if isinstance(conn, sqlite3.Connection) else '%s'
    table_name = 'sensordata' if isinstance(conn, sqlite3.Connection) else 'sensordatahistory'
    sql = f'''INSERT INTO {table_name}(ProfileID, Timestamp, SensorType, Value)
              VALUES({placeholder}, {placeholder}, {placeholder}, {placeholder})'''
    cursor = conn.cursor()
    execute_db_query(cursor, sql, (profile_id, timestamp, sensor_type, value))
    conn.commit()
    cursor.close()

def insert_alert_log(conn, profile_id, alert_type, timestamp, resolved=0):
    """Inserts an alert log into the database."""
    placeholder = '?' if isinstance(conn, sqlite3.Connection) else '%s'
    sql = f'''INSERT INTO alertlogs(ProfileID, AlertType, AlertTimestamp, Resolved)
              VALUES({placeholder}, {placeholder}, {placeholder}, {placeholder})'''
    cursor = conn.cursor()
    execute_db_query(cursor, sql, (profile_id, alert_type, timestamp, resolved))
    conn.commit()
    cursor.close()

def fetch_and_send_medication_reminders(mysql_conn, profile_id):
    query = """
        SELECT m.MedicationName, s.ScheduledTime FROM medicationschedules s
        JOIN patientmedications m ON s.PatientMedicationID = m.PatientMedicationID
        WHERE m.ProfileID = %s AND DATE(s.ScheduledTime) = CURDATE()
    """
    cursor = mysql_conn.cursor()
    results = execute_db_query(cursor, query, (profile_id,), fetch=True)
    cursor.close()
    if results:
        for (medication_name, scheduled_time) in results:
            send_medication_reminder(profile_id, medication_name, scheduled_time)

def send_medication_reminder(profile_id, medication_name, scheduled_time):
    """Simulated function to send medication reminders."""
    logging.info(f"Reminder sent for {medication_name} at {scheduled_time} to profile {profile_id}")

def simulate_sensor_data():
    """Generates simulated sensor data."""
    heart_rate = random.randint(60, 100)
    accelerometer = np.random.uniform(-2, 2, 3)
    gyroscope = np.random.uniform(-200, 200, 3)
    return heart_rate, accelerometer, gyroscope

def detect_fall(acceleration, gyroscope):
    """Determines whether a fall has occurred based on sensor data."""
    return np.max(np.abs(acceleration)) > THRESHOLDS['acc'] or np.max(np.abs(gyroscope)) > THRESHOLDS['gyro']

def main():
    profile_id = 1
    with connect_to_database(DB_CONFIGS['sqlite']) as sqlite_conn, \
         connect_to_database(DB_CONFIGS['mysql']) as mysql_conn:
        if sqlite_conn is None or mysql_conn is None:
            logging.error("Failed to connect to databases.")
            return

        try:
            while not os.path.exists('stop.txt'):
                timestamp = datetime.datetime.now().strftime('%Y-%m-%d %H:%M:%S')
                heart_rate, accelerometer, gyroscope = simulate_sensor_data()
                insert_sensor_data(sqlite_conn, profile_id, timestamp, 'Heart Rate', heart_rate)
                insert_sensor_data(mysql_conn, profile_id, timestamp, 'Heart Rate', heart_rate)
                insert_sensor_data(sqlite_conn, profile_id, timestamp, 'Accelerometer', np.mean(accelerometer))
                insert_sensor_data(mysql_conn, profile_id, timestamp, 'Accelerometer', np.mean(accelerometer))
                insert_sensor_data(sqlite_conn, profile_id, timestamp, 'Gyroscope', np.mean(gyroscope))
                insert_sensor_data(mysql_conn, profile_id, timestamp, 'Gyroscope', np.mean(gyroscope))

                fetch_and_send_medication_reminders(mysql_conn, profile_id)

                if detect_fall(accelerometer, gyroscope):
                    alert_message = f"Fall detected at {timestamp}"
                    logging.info(alert_message)
                    insert_alert_log(sqlite_conn, profile_id, 'Fall Detected', timestamp)
                    insert_alert_log(mysql_conn, profile_id, 'Fall Detected', timestamp)
                    send_alert_to_device(alert_message)
                else:
                    logging.info(f"No fall detected at {timestamp}")

                time.sleep(1)
        except KeyboardInterrupt:
            logging.info("Program terminated by user.")
        finally:
            logging.info("Database connections will be automatically closed.")

def send_alert_to_device(message):
    """Sends an alert to a wearable device. Placeholder for actual device communication logic."""
    logging.info(f"Sending alert to device: {message}")

if __name__ == "__main__":
    main()
