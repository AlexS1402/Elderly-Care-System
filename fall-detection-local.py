import numpy as np
import pandas as pd
import time
import random
import joblib

# Load the trained Random Forest model
model = joblib.load('ecs_rf_model.pkl')

def simulate_sensor_data():
    # Simulating heart rate, accelerometer, and gyroscope data
    return (random.randint(60, 100),  # Heart rate
            (random.uniform(-2, 2), random.uniform(-2, 2), random.uniform(-2, 2)),  # Acceleration data
            (random.uniform(-250, 250), random.uniform(-250, 250), random.uniform(-250, 250)))  # Gyroscope data

def detect_fall(acceleration, gyroscope):
    # Simple threshold-based fall detection logic
    acc_threshold = 0.7
    gyro_threshold = 100  # Adjust the threshold based on empirical observation if needed
    if max(abs(np.array(acceleration))) > acc_threshold or max(abs(np.array(gyroscope))) > gyro_threshold:
        return True
    return False

def main():
    while True:
        heart_rate, acceleration, gyroscope = simulate_sensor_data()
        if detect_fall(acceleration, gyroscope):
            # Create a DataFrame for prediction to include feature names
            feature_names = ['xAcc', 'yAcc', 'zAcc', 'xGyro', 'yGyro', 'zGyro']
            features = pd.DataFrame([list(acceleration) + list(gyroscope)], columns=feature_names)
            prediction = model.predict(features)
            if prediction[0] == 'Fall Detected':
                print(f"Fall detected with heart rate: {heart_rate}, acceleration: {acceleration}, gyroscope: {gyroscope}")
                # Here, you might send data to the cloud or alert caregivers
                break
        time.sleep(1)  # Delay to simulate sensor reading frequency

if __name__ == "__main__":
    main()