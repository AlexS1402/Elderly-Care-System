import time
import random

def simulate_sensor_data():
    # Simulating heart rate and accelerometer data
    return random.randint(60, 100), (random.uniform(-1, 1), random.uniform(-1, 1), random.uniform(-1, 1))

def detect_fall(acceleration):
    x, y, z = acceleration
    # A simple threshold-based algorithm for demonstration
    if abs(x) > 0.5 or abs(y) > 0.5 or abs(z) > 0.5:
        return True
    return False

def main():
    while True:
        heart_rate, acceleration = simulate_sensor_data()
        if detect_fall(acceleration):
            print(f"Fall detected with heart rate: {heart_rate} and acceleration: {acceleration}")
            # Here you would send data to the cloud
            sent = True
            break
        time.sleep(1)  # check every second

if __name__ == "__main__":
    main()
