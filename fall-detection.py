import os
from dotenv import load_dotenv
import tkinter as tk
from tkinter import ttk, messagebox, scrolledtext
import sqlite3
import mysql.connector
from mysql.connector import Error
import datetime
import numpy as np
import pandas as pd
import time
import joblib
import logging
import bcrypt
import threading
import smtplib
from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText
from twilio.rest import Client
import paho.mqtt.client as mqtt
import json

# Load environment variables from .env file
load_dotenv()

# Configure logging
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')

# Constants and Configurations
MODEL_PATH = '/home/albxii/ecs/ecs_rf_model.pkl'
DB_CONFIGS = {
    'sqlite': {
        'type': 'sqlite',
        'path': os.getenv('SQLITE_DB_PATH')
    },
    'mysql': {
        'type': 'mysql',
        'host': os.getenv('MYSQL_HOST'),
        'user': os.getenv('MYSQL_USER'),
        'passwd': os.getenv('MYSQL_PASSWORD'),
        'database': os.getenv('MYSQL_DATABASE')
    }
}
THRESHOLDS = {'acc': 1.0, 'gyro': 150}

# Email and Twilio configuration
EMAIL_ADDRESS = os.getenv('EMAIL_ADDRESS')
EMAIL_PASSWORD = os.getenv('EMAIL_PASSWORD')
SMTP_SERVER = os.getenv('SMTP_SERVER')
SMTP_PORT = int(os.getenv('SMTP_PORT'))
TWILIO_ACCOUNT_SID = os.getenv('TWILIO_ACCOUNT_SID')
TWILIO_AUTH_TOKEN = os.getenv('TWILIO_AUTH_TOKEN')
TWILIO_PHONE_NUMBER = os.getenv('TWILIO_PHONE_NUMBER')

# MQTT Configuration
mqtt_server = "localhost"
data_topic = "esp32/data"
alert_topic = "esp32/alert"
med_reminder_topic = "esp32/medReminder"
control_topic = "esp32/control"
check_status_topic = "esp32/checkStatus"
status_topic = "esp32/status"

# Load the machine learning model
model = joblib.load(MODEL_PATH)

# Global variables to store user and patient info
current_user = None
current_patient = None
fall_detection_thread = None
stop_event = threading.Event()
device_status_checked = False
sensor_data_transmitted = False

# Function to connect to the database
def connect_to_database(config):
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

# Function to execute database queries
def execute_db_query(cursor, query, data=None, fetch=False):
    try:
        cursor.execute(query, data or ())
        return cursor.fetchall() if fetch else None
    except Error as e:
        logging.error(f"Database query error: {e}")
        return None

def insert_sensor_data(conn, profile_id, timestamp, sensor_type, value):
    placeholder = '?' if isinstance(conn, sqlite3.Connection) else '%s'
    table_name = 'sensordata' if isinstance(conn, sqlite3.Connection) else 'sensordatahistory'
    sql = f'''INSERT INTO {table_name}(ProfileID, Timestamp, SensorType, Value)
              VALUES({placeholder}, {placeholder}, {placeholder}, {placeholder})'''
    cursor = conn.cursor()
    execute_db_query(cursor, sql, (profile_id, timestamp, sensor_type, value))
    conn.commit()
    cursor.close()

def insert_alert_log(conn, profile_id, alert_type, timestamp, resolved=0):
    placeholder = '?' if isinstance(conn, sqlite3.Connection) else '%s'
    sql = f'''INSERT INTO alertlogs(ProfileID, AlertType, AlertTimestamp, Resolved)
              VALUES({placeholder}, {placeholder}, {placeholder}, {placeholder})'''
    cursor = conn.cursor()
    execute_db_query(cursor, sql, (profile_id, alert_type, timestamp, resolved))
    conn.commit()
    cursor.close()

def fetch_and_log_medication_schedules(mysql_conn, profile_id):
    query = """
        SELECT m.MedicationName, s.ScheduledTime 
        FROM medicationschedules s
        JOIN patientmedications m ON s.PatientMedicationID = m.PatientMedicationID
        WHERE m.ProfileID = %s AND CURDATE() BETWEEN m.StartDate AND m.EndDate
    """
    cursor = mysql_conn.cursor()
    results = execute_db_query(cursor, query, (profile_id,), fetch=True)
    cursor.close()
    if results:
        for medication_name, scheduled_time in results:
            scheduled_time_str = (datetime.datetime.min + scheduled_time).time().strftime('%H:%M:%S')
            logging.info(f"{medication_name} at {scheduled_time_str}")
    else:
        logging.info(f"No medication schedules found for patient {profile_id}.")

def fetch_and_send_medication_reminders(mysql_conn, profile_id):
    now = datetime.datetime.now()
    current_time = now.strftime('%H:%M:%S')
    query = """
        SELECT m.MedicationName, s.ScheduledTime 
        FROM medicationschedules s
        JOIN patientmedications m ON s.PatientMedicationID = m.PatientMedicationID
        WHERE m.ProfileID = %s AND CURDATE() BETWEEN m.StartDate AND m.EndDate
    """
    cursor = mysql_conn.cursor()
    results = execute_db_query(cursor, query, (profile_id,), fetch=True)
    cursor.close()
    if results:
        for medication_name, scheduled_time in results:
            scheduled_time_str = (datetime.datetime.min + scheduled_time).time().strftime('%H:%M:%S')
            if scheduled_time_str == current_time:
                logging.info(f"Reminder: Take {medication_name} at {scheduled_time_str}")
                send_medication_reminder_to_device(medication_name, scheduled_time_str)

def detect_fall(accelerometer, gyroscope):
    if np.max(np.abs(accelerometer)) > THRESHOLDS['acc'] or np.max(np.abs(gyroscope)) > THRESHOLDS['gyro']:
        features = pd.DataFrame([[
            accelerometer[0], accelerometer[1], accelerometer[2], 
            gyroscope[0], gyroscope[1], gyroscope[2]
        ]], columns=['xAcc', 'yAcc', 'zAcc', 'xGyro', 'yGyro', 'zGyro'])
        prediction = model.predict(features)
        if prediction[0] == 'Fall Detected':
            return True
    return False

def get_emergency_contact(mysql_conn, profile_id):
    query = """
        SELECT pp.EmergencyContact, pp.FirstName, pp.LastName, pp.Address, u.Email 
        FROM patientprofiles pp 
        JOIN users u ON pp.UserId = u.UserID 
        WHERE pp.ProfileID = %s
    """
    cursor = mysql_conn.cursor()
    result = execute_db_query(cursor, query, (profile_id,), fetch=True)
    cursor.close()
    if result:
        return result[0]
    return None, None, None, None, None

def send_alerts(profile_id, alert_message, mysql_conn):
    emergency_contact_phone, first_name, last_name, address, emergency_contact_email = get_emergency_contact(mysql_conn, profile_id)
    if emergency_contact_phone and emergency_contact_email:
        alert_message = f"Fall detected for {first_name} {last_name} at {address}. {alert_message}"
        send_email_alert("Fall Detected Alert", alert_message, emergency_contact_email)
        send_sms_alert(alert_message, emergency_contact_phone)
    else:
        logging.info(f"Emergency contact details not found for profile {profile_id}")

def send_email_alert(subject, body, to_address):
    msg = MIMEMultipart()
    msg['From'] = EMAIL_ADDRESS
    msg['To'] = to_address
    msg['Subject'] = subject
    msg.attach(MIMEText(body, 'plain'))
    try:
        server = smtplib.SMTP(SMTP_SERVER, SMTP_PORT)
        server.starttls()
        server.login(EMAIL_ADDRESS, EMAIL_PASSWORD)
        text = msg.as_string()
        server.sendmail(EMAIL_ADDRESS, to_address, text)
        server.quit()
        logging.info(f"Email sent to {to_address}")
    except Exception as e:
        logging.info(f"Failed to send email: {e}")

def send_sms_alert(body, to_phone_number):
    client = Client(TWILIO_ACCOUNT_SID, TWILIO_AUTH_TOKEN)
    try:
        message = client.messages.create(
            body=body,
            from_=TWILIO_PHONE_NUMBER,
            to=to_phone_number
        )
        logging.info(f"SMS sent to {to_phone_number}: {message.sid}")
    except Exception as e:
        logging.info(f"Failed to send SMS: {e}")

def send_medication_reminder_to_device(medication_name, scheduled_time):
    reminder_message = f"Reminder: Take {medication_name} at {scheduled_time}"
    client.publish(med_reminder_topic, reminder_message)

def check_device_connection():
    global device_status_checked
    device_status_checked = False
    client.publish(check_status_topic, "check")
    time.sleep(5)  # Wait for the device to respond
    if not device_status_checked:
        log_message("No Wearable Device Found...")
    else:
        log_message("Device Connected.")

# MQTT Callbacks
def on_connect(client, userdata, flags, rc):
    print("Connected with result code " + str(rc))
    client.subscribe(data_topic)
    client.subscribe(status_topic)

def on_message(client, userdata, msg):
    global device_status_checked, sensor_data_transmitted
    print(f"Message received on topic {msg.topic}: {msg.payload.decode()}")
    if msg.topic == data_topic:
        data = json.loads(msg.payload.decode())
        heart_rate = data['heartRate']
        accel_data = np.array(data['accel'])
        gyro_data = np.array(data['gyro'])
        timestamp = datetime.datetime.now().strftime('%Y-%m-%d %H:%M:%S')
        if current_patient is not None:
            profile_id = current_patient['ProfileID']
            with connect_to_database(DB_CONFIGS['mysql']) as mysql_conn:
                insert_sensor_data(mysql_conn, profile_id, timestamp, 'Heart Rate', heart_rate)
                insert_sensor_data(mysql_conn, profile_id, timestamp, 'Accelerometer', np.mean(accel_data))
                insert_sensor_data(mysql_conn, profile_id, timestamp, 'Gyroscope', np.mean(gyro_data))
                if detect_fall(accel_data, gyro_data):
                    alert_message = f"Fall detected at {timestamp}"
                    logging.info(alert_message)
                    insert_alert_log(mysql_conn, profile_id, 'Fall Detected', timestamp)
                    send_alerts(profile_id, alert_message, mysql_conn)
                    client.publish(alert_topic, "Fall detected!")
            if not sensor_data_transmitted:
                log_message("Sensor Data is being transmitted...")
                sensor_data_transmitted = True
    elif msg.topic == status_topic:
        if msg.payload.decode() == "connected":
            device_status_checked = True

# MQTT Client Setup
client = mqtt.Client()
client.on_connect = on_connect
client.on_message = on_message

client.connect(mqtt_server, 1883, 60)
client.loop_start()

def start_system():
    global fall_detection_thread, stop_event, sensor_data_transmitted
    stop_event.clear()
    sensor_data_transmitted = False
    check_device_connection()  # Check device connection first
    if device_status_checked:
        client.publish(control_topic, "start")  # Send start message to ESP32
        log_message("Starting...")
        fall_detection_thread = threading.Thread(target=run_system)
        fall_detection_thread.start()
        check_thread_status()
    else:
        log_message("Unable to start system without connected wearable device.")

def run_system():
    if current_patient is not None:
        profile_id = current_patient['ProfileID']
        with connect_to_database(DB_CONFIGS['sqlite']) as sqlite_conn, \
             connect_to_database(DB_CONFIGS['mysql']) as mysql_conn:
            if sqlite_conn is None or mysql_conn is None:
                logging.info("Failed to connect to databases.")
                return

            fetch_and_log_medication_schedules(mysql_conn, profile_id)

            try:
                while not stop_event.is_set():
                    fetch_and_send_medication_reminders(mysql_conn, profile_id)
                    time.sleep(1)
            except KeyboardInterrupt:
                logging.info("Program terminated by user.")
            finally:
                logging.info("Database connections will be automatically closed.")
    else:
        logging.info("No current patient selected, cannot start system.")

def stop_system():
    global stop_event
    stop_event.set()
    client.publish(control_topic, "stop")  # Send stop message to ESP32
    log_message("Stopped.")

def check_thread_status():
    if fall_detection_thread.is_alive():
        root.after(100, check_thread_status)
    else:
        start_button.config(state=tk.NORMAL)
        stop_button.config(state=tk.NORMAL)

def log_message(message):
    console_output.insert(tk.END, message + "\n")
    console_output.see(tk.END)
    logging.info(message)

def login_user():
    global current_user, current_patient
    username = username_entry.get()
    password = password_entry.get()
    with connect_to_database(DB_CONFIGS['mysql']) as mysql_conn:
        query = "SELECT UserID, PasswordHash FROM users WHERE Username = %s"
        cursor = mysql_conn.cursor()
        result = execute_db_query(cursor, query, (username,), fetch=True)
        cursor.close()
        if result and bcrypt.checkpw(password.encode('utf-8'), result[0][1].encode('utf-8')):
            current_user = {'UserID': result[0][0], 'Username': username}
            fetch_patients()
        else:
            messagebox.showerror("Login Failed", "Invalid username or password")

def fetch_patients():
    with connect_to_database(DB_CONFIGS['mysql']) as mysql_conn:
        query = "SELECT ProfileID, FirstName, LastName FROM patientprofiles WHERE UserID = %s"
        cursor = mysql_conn.cursor()
        results = execute_db_query(cursor, query, (current_user['UserID'],), fetch=True)
        cursor.close()
        if results:
            for result in results:
                patients_listbox.insert(tk.END, f"{result[1]} {result[2]}")
            patient_selection_frame.pack()
        else:
            messagebox.showerror("No Patients Found", "No patients found for this user")

def select_patient(event):
    global current_patient
    selection = event.widget.curselection()
    if selection:
        index = selection[0]
        patient_name = event.widget.get(index)
        first_name, last_name = patient_name.split()
        with connect_to_database(DB_CONFIGS['mysql']) as mysql_conn:
            query = "SELECT * FROM patientprofiles WHERE FirstName = %s AND LastName = %s AND UserID = %s"
            cursor = mysql_conn.cursor()
            result = execute_db_query(cursor, query, (first_name, last_name, current_user['UserID']), fetch=True)
            cursor.close()
            if result:
                current_patient = {
                    'ProfileID': result[0][0],
                    'FirstName': result[0][2],
                    'LastName': result[0][3],
                    'EmergencyContact': result[0][7],
                    'Address': result[0][6]
                }
                patient_name_label.config(text=f"Patient: {current_patient['FirstName']} {current_patient['LastName']}")
                login_frame.pack_forget()
                patient_selection_frame.pack_forget()
                main_frame.pack()
                log_message("Welcome to the Elderly Care System, please press 'Start' to begin tracking.")

def logout_user():
    global current_user, current_patient
    current_user = None
    current_patient = None
    main_frame.pack_forget()
    login_frame.pack()

# GUI setup
root = tk.Tk()
root.title("Elderly Care System")

# Login Frame
login_frame = tk.Frame(root)
login_frame.pack()
tk.Label(login_frame, text="Username:").grid(row=0, column=0)
username_entry = tk.Entry(login_frame)
username_entry.grid(row=0, column=1)
tk.Label(login_frame, text="Password:").grid(row=1, column=0)
password_entry = tk.Entry(login_frame, show='*')
password_entry.grid(row=1, column=1)
login_button = tk.Button(login_frame, text="Login", command=login_user)
login_button.grid(row=2, columnspan=2)

# Patient Selection Frame
patient_selection_frame = tk.Frame(root)
tk.Label(patient_selection_frame, text="Select a Patient:").pack()
patients_listbox = tk.Listbox(patient_selection_frame)
patients_listbox.pack()
patients_listbox.bind('<<ListboxSelect>>', select_patient)

# Main Frame
main_frame = tk.Frame(root)
tk.Label(main_frame, text="Elderly Care System", font=("Arial", 24)).pack()
patient_name_label = tk.Label(main_frame, text="", font=("Arial", 18))
patient_name_label.pack()

# Console output
console_output = scrolledtext.ScrolledText(main_frame, width=80, height=20)
console_output.pack()

# Start and Stop buttons
buttons_frame = tk.Frame(main_frame)
buttons_frame.pack(pady=10)
start_button = tk.Button(buttons_frame, text="Start", command=start_system)
start_button.grid(row=0, column=0, padx=5)
stop_button = tk.Button(buttons_frame, text="Stop", command=stop_system)
stop_button.grid(row=0, column=1, padx=5)
change_login_button = tk.Button(buttons_frame, text="Change Login Details", command=logout_user)
change_login_button.grid(row=0, column=2, padx=5)

root.mainloop()
