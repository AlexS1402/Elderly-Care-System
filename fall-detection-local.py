import sqlite3
import numpy as np
import pandas as pd
import time
import random
import joblib
import os

# Load the trained Random Forest model
model = joblib.load('/home/albxii/ecs/ecs_rf_model.pkl')

# Database functions
def connect_to_db(db_file):
    try:
        conn = sqlite3.connect(db_file)
        return conn
    except sqlite3.Error as e:
        print(f"Error connecting to database: {e}")
    return None

def insert_sensor_data(conn, profile_id, timestamp, sensor_type, value):
    sql = ''' INSERT INTO sensordata(ProfileID, Timestamp, SensorType, Value)
              VALUES(?,?,?,?) '''
    cur = conn.cursor()
    cur.execute(sql, (profile_id, timestamp, sensor_type, value))
    conn.commit()

def simulate_sensor_data():
    return (random.randint(60, 100), 
            (random.uniform(-0.5, 0.5), random.uniform(-0.5, 0.5), random.uniform(-0.5, 0.5)), 
            (random.uniform(-50, 50), random.uniform(-50, 50), random.uniform(-50, 50)))

def detect_fall(acceleration, gyroscope, acc_threshold=1.0, gyro_threshold=150, duration_threshold=3):
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
    database = '/home/albxii/ecs/elderlycaresystemlocaldb.db'  # Ensure this is the correct path to your database
    conn = connect_to_db(database)
    profile_id = 1  # Assuming you know this beforehand
    global stable_count, unstable_count
    stable_count = 0
    unstable_count = 0
    try:
        while True:
            if os.path.exists('stop.txt'):
                print("Stop file detected. Exiting program...")
                if os.path.exists('stop.txt'):
                    os.remove('stop.txt')
                break
            heart_rate, acceleration, gyroscope = simulate_sensor_data()
            timestamp = time.strftime('%Y-%m-%d %H:%M:%S')
            # Log each sensor data
            insert_sensor_data(conn, profile_id, timestamp, 'Heart Rate', heart_rate)
            insert_sensor_data(conn, profile_id, timestamp, 'Accelerometer', np.mean(acceleration))
            insert_sensor_data(conn, profile_id, timestamp, 'Gyroscope', np.mean(gyroscope))
            
            if detect_fall(acceleration, gyroscope):
                feature_names = ['xAcc', 'yAcc', 'zAcc', 'xGyro', 'yGyro', 'zGyro']
                features = pd.DataFrame([list(acceleration) + list(gyroscope)], columns=feature_names)
                prediction = model.predict(features)
                if prediction[0] == 'Fall Detected':
                    print(f"Fall detected with heart rate: {heart_rate}, acceleration: {acceleration}, gyroscope: {gyroscope}")
                    # Here, you might send data to the cloud or alert caregivers
                else:
                    print(f"Fall Not Detected with heart rate: {heart_rate}, Acceleration: {acceleration}, Gyroscope: {gyroscope}")
            else:
                print(f"Fall Not Detected with heart rate: {heart_rate}, Acceleration: {acceleration}, Gyroscope: {gyroscope}")
            time.sleep(1)
    except KeyboardInterrupt:
        print("Program terminated by user.")

if __name__ == "__main__":
    main()
