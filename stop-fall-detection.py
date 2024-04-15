import time
import os

def create_stop_file():
    with open('stop.txt', 'w') as f:
        f.write('stop')  # Write a simple command to the file

if __name__ == "__main__":
    input("Press Enter to stop the fall detection program...")
    create_stop_file()
    # Wait a bit to ensure the fall detection program has time to shut down
    time.sleep(5)
    if os.path.exists('stop.txt'):
        os.remove('stop.txt')  # Clean up the stop file after ensuring the program has stopped
    print("Fall detection program has been stopped and the stop file has been cleaned up.")
