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
    conn = None
    try:
        if config['type'] == 'sqlite':
            conn = sqlite3.connect(config['path'])
        elif config['type'] == 'mysql':
            conn = mysql.connector.connect(
                host=config['host'],
                user=config['user'],
                passwd=config['passwd'],
                database=config['database']
            )
    except Error as e:
        logging.error(f"Database connection error: {e}")
        if conn:
            conn.close()
        return None
    return conn

def execute_db_query(cursor, query, data=None, fetch=False):
    """Executes a database query safely."""
    try:
        cursor.execute(query, data or ())
        return cursor.fetchall() if fetch else None
    except Error as e:
        logging.error(f"Database query error: {e}")
        return None
    finally:
        cursor.close()  # Ensure the cursor is closed after operation

def insert_sensor_data(conn, profile_id, timestamp, sensor_type, value):
    """Inserts sensor data into the database."""
    placeholder = '?' if isinstance(conn, sqlite3.Connection) else '%s'
    table_name = 'sensordata' if isinstance(conn, sqlite3.Connection) else 'sensordatahistory'
    sql = f'''INSERT INTO {table_name}(ProfileID, Timestamp, SensorType, Value)
              VALUES({placeholder}, {placeholder}, {placeholder}, {placeholder})'''
    try:
        cursor = conn.cursor()  # Manually creating a cursor
        cursor.execute(sql, (profile_id, timestamp, sensor_type, value))
        conn.commit()
    finally:
        cursor.close()  # Ensuring the cursor is closed after operations

def insert_alert_log(conn, profile_id, alert_type, timestamp, resolved=0):
    """Inserts an alert log into the database."""
    placeholder = '?' if isinstance(conn, sqlite3.Connection) else '%s'
    sql = f'''INSERT INTO alertlogs(ProfileID, AlertType, AlertTimestamp, Resolved)
              VALUES({placeholder}, {placeholder}, {placeholder}, {placeholder})'''
    cursor = conn.cursor()
    execute_db_query(cursor, sql, (profile_id, alert_type, timestamp, resolved))
    conn.commit()


def fetch_and_send_medication_reminders(mysql_conn, profile_id):
    logging.info("Starting to fetch medication reminders.")
    now = datetime.datetime.now()
    current_time = now.strftime('%H:%M:%S')

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
            # Convert timedelta to time and compare with current time
            if (datetime.datetime.min + scheduled_time).time().strftime('%H:%M:%S') == current_time:
                send_medication_reminder(profile_id, medication_name, scheduled_time)
    logging.info("Completed fetching medication reminders.")

def send_medication_reminder(profile_id, medication_name, scheduled_time):
    """Simulated function to send medication reminder to wearable device."""
    logging.info(f"Reminder sent for {medication_name} at {scheduled_time} to profile {profile_id}")

def simulate_sensor_data():
    """Generates simulated sensor data."""
    heart_rate = random.randint(60, 100)
    accelerometer = np.random.uniform(-2, 2, 3)
    gyroscope = np.random.uniform(-200, 200, 3)
    return heart_rate, accelerometer, gyroscope

def detect_fall(accelerometer, gyroscope):
    """Determines whether a fall has occurred based on sensor data and a machine learning model."""
    # Initial threshold check to see if further analysis is required
    if np.max(np.abs(accelerometer)) > THRESHOLDS['acc'] or np.max(np.abs(gyroscope)) > THRESHOLDS['gyro']:
        # Prepare the data as a DataFrame with the same structure used in model training
        features = pd.DataFrame([[
            accelerometer[0], accelerometer[1], accelerometer[2], 
            gyroscope[0], gyroscope[1], gyroscope[2]
        ]], columns=['xAcc', 'yAcc', 'zAcc', 'xGyro', 'yGyro', 'zGyro'])

        # Predict using the trained model
        prediction = model.predict(features)
        if prediction[0] == 'Fall Detected':
            return True
    return False

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
