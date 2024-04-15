import numpy as np
import pandas as pd
import time
import random
import joblib
import os

# Load the trained Random Forest model
model = joblib.load('ecs_rf_model.pkl')

def simulate_sensor_data():
    # Simulating more realistic heart rate, accelerometer, and gyroscope data
    return (random.randint(60, 100),  # Heart rate
            (random.uniform(-0.5, 0.5), random.uniform(-0.5, 0.5), random.uniform(-0.5, 0.5)),  # Accelerometer data
            (random.uniform(-50, 50), random.uniform(-50, 50), random.uniform(-50, 50)))  # Gyroscope data

def detect_fall(acceleration, gyroscope, acc_threshold=1.0, gyro_threshold=150, duration_threshold=3):
    # Tracking stability or low movement post-initial detection
    global stable_count, unstable_count
    if max(abs(np.array(acceleration))) > acc_threshold or max(abs(np.array(gyroscope))) > gyro_threshold:
        unstable_count += 1
        stable_count = 0  # Reset stable count if movement is detected
        if unstable_count >= duration_threshold:
            unstable_count = 0  # Reset after reporting a fall
            return True
    else:
        if unstable_count > 0:  # Check for stability after initial detection
            stable_count += 1
            if stable_count >= duration_threshold:  # Confirming low movement post potential fall
                unstable_count = 0
                stable_count = 0
                return True
    return False

def main():
    global stable_count, unstable_count
    stable_count = 0
    unstable_count = 0
    try:
        while True:
            if os.path.exists('stop.txt'):
                print("Stop file detected. Exiting program...")
                if os.path.exists('stop.txt'):
                    os.remove('stop.txt')  # Clean up stop file on exit
                break
            heart_rate, acceleration, gyroscope = simulate_sensor_data()
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
            time.sleep(1)  # Simulate sensor data every second
    except KeyboardInterrupt:
        print("Program terminated by user.")

if __name__ == "__main__":
    main()
