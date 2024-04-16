import sqlite3
import mysql.connector
from mysql.connector import Error
import datetime

def connect_to_sqlite(db_file):
    try:
        conn = sqlite3.connect(db_file)
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
        return conn
    except Error as e:
        print(f"MySQL Error: {e}")
    return None

def log_alert_in_local_db(sqlite_conn, profile_id, alert_type, resolved):
    cursor = sqlite_conn.cursor()
    cursor.execute("""
        INSERT INTO alertlogs (ProfileID, AlertType, AlertTimestamp, Resolved)
        VALUES (?, ?, ?, ?)
        """, (profile_id, alert_type, datetime.datetime.now(), resolved))
    sqlite_conn.commit()

def log_alert_in_cloud_db(mysql_conn, profile_id, alert_type, resolved):
    cursor = mysql_conn.cursor()
    cursor.execute("""
        INSERT INTO alertlogs (ProfileID, AlertType, AlertTimestamp, Resolved)
        VALUES (%s, %s, %s, %s)
        """, (profile_id, alert_type, datetime.datetime.now(), resolved))
    mysql_conn.commit()

def send_alert_to_device(alert_message):
    # Placeholder for alert sending logic to wearable device
    print(f"Send this alert to device: {alert_message}")

def send_medication_reminder(profile_id, medication_name, scheduled_time):
    # Placeholder for reminder sending logic to wearable device
    print(f"Reminder: It's time for {profile_id} to take their medication {medication_name} at {scheduled_time}")

def fetch_and_send_medication_reminders(mysql_conn, profile_id):
    cursor = mysql_conn.cursor()
    cursor.execute("""
        SELECT m.MedicationName, s.ScheduledTime FROM medicationschedules s
        JOIN patientmedications m ON s.PatientMedicationID = m.PatientMedicationID
        WHERE m.ProfileID = %s AND DATE(s.ScheduledTime) = CURDATE()
        """, (profile_id,))
    for (medication_name, scheduled_time) in cursor.fetchall():
        send_medication_reminder(profile_id, medication_name, scheduled_time)

def main():
    sqlite_conn = connect_to_sqlite('local.db')
    mysql_conn = connect_to_mysql('elderlycaresystemclouddb.mysql.database.azure.com', 'root_admin', '1A2a4=33NTG.', 'elderlycareclouddb')
    profile_id = 1  # Example profile ID

    # Simulate a fall detection
    fall_detected = True  # This would be set by your fall detection logic
    if fall_detected:
        log_alert_in_local_db(sqlite_conn, profile_id, 'Fall', 0)
        log_alert_in_cloud_db(mysql_conn, profile_id, 'Fall', 0)
        send_alert_to_device("Fall detected! Immediate assistance required.")

    # Check for and send medication reminders
    fetch_and_send_medication_reminders(mysql_conn, profile_id)

    # Close database connections
    sqlite_conn.close()
    mysql_conn.close()

if __name__ == "__main__":
    main()
