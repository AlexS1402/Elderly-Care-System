# Elderly Care System

## Overview

The Elderly Care System is designed to provide caregivers with a dashboard to monitor the health and well-being of elderly patients. It includes features such as patient data management, medication schedules, alert logs, and user management. The system consists of a frontend built with Flutter and a backend using Node.js with a MySQL database hosted on Azure.

## Table of Contents

1. [Prerequisites](#prerequisites)
2. [Setup](#setup)
    1. [Frontend Setup](#frontend-setup)
    2. [Backend Setup](#backend-setup)
    3. [Fall Detection Algorithm Setup](#fall-detection-algorithm-setup)
    4. [Device Setup](#device-setup)
3. [Testing](#testing)
4. [Running the Application](#running-the-application)
5. [Deployment](#deployment)
6. [Contact](#contact)

## Prerequisites

- Node.js (v14 or later)
- MySQL Server
- Flutter SDK
- Firebase CLI (for deployment)
- Git
- Python (v3.7 or later)
- Raspberry Pi 4 Model B
- Required Python packages (`numpy`, `pandas`, `joblib`, `mysql-connector-python`, `python-dotenv`, `twilio`, `bcrypt`, `smtplib`)

## Setup

### Frontend Setup

1. **Clone the repository:**

    ```sh
    git clone <repository-url>
    cd <repository-name>/frontend
    ```

2. **Install Flutter dependencies:**

    ```sh
    flutter pub get
    ```

3. **Configure Firebase:**

    - Ensure you have a Firebase project set up.
    - Add `google-services.json` (for Android) and `GoogleService-Info.plist` (for iOS) to the appropriate directories.
    - Update `index.html` with Firebase configurations in the `/web` directory.

4. **Configure environment variables:**

    Create a `.env` file in the frontend directory with the following content:

    ```env
    BASE_URL=http://localhost:3000/api
    ```

5. **Run the frontend application:**

    ```sh
    flutter run
    ```

### Backend Setup

1. **Navigate to the backend directory:**

    ```sh
    cd ../backend
    ```

2. **Install Node.js dependencies:**

    ```sh
    npm install
    ```

3. **Configure environment variables:**

    Create a `.env` file in the backend directory with the following content:

    ```env
    PORT=3000
    DB_HOST=<your-database-host>
    DB_USER=<your-database-username>
    DB_PASS=<your-database-password>
    DB_NAME=<your-database-name>
    JWT_SECRET=<your-jwt-secret>
    ```

4. **Set up the MySQL database:**

    - Ensure your MySQL server is running.
    - Run the SQL scripts provided in the `/backend/sql` directory to set up the database schema.

5. **Run the backend server:**

    ```sh
    npm start
    ```

### Fall Detection Algorithm Setup

1. **Navigate to the fall detection directory:**

    ```sh
    cd ../fall-detection
    ```

2. **Install Python dependencies:**

    ```sh
    pip install -r requirements.txt
    ```

3. **Configure environment variables:**

    Create a `.env` file in the fall detection directory with the following content:

    ```env
    EMAIL_ADDRESS=your_email@gmail.com
    EMAIL_PASSWORD=your_generated_app_password
    SMTP_SERVER=smtp.gmail.com
    SMTP_PORT=587
    TWILIO_ACCOUNT_SID=your_twilio_account_sid
    TWILIO_AUTH_TOKEN=your_twilio_auth_token
    TWILIO_PHONE_NUMBER=your_twilio_phone_number
    MYSQL_HOST=elderlycaresystemclouddb.mysql.database.azure.com
    MYSQL_USER=root_admin
    MYSQL_PASSWORD=1A2a4=33NTG.
    MYSQL_DATABASE=elderlycareclouddb
    SQLITE_DB_PATH=/home/albxii/ecs/elderlycaresystemlocaldb.db
    ```

4. **Set up the MySQL and SQLite databases:**

    - Ensure your MySQL server is running and the database schema is set up.
    - Create the SQLite database using the provided SQL scripts.

5. **Run the fall detection algorithm:**

    ```sh
    python fall_detection_local.py
    ```

### Device Setup

1. **Hardware Components:**
    - ESP32 Board
    - Adafruit LSM6DSOX Accelerometer and Gyroscope
    - Waveshare 1.54 inch e-Paper Display with module
    - Vibration Motor
    - Tactile Switch Button
    - Prototype board and wires for connections

2. **Wiring Layout:**
    - **ESP32 Connections:**
        - Accelerometer (I2C): SDA (GPIO 21), SCL (GPIO 22)
        - e-Paper Display: DIN (GPIO 23), CLK (GPIO 18), CS (GPIO 5), DC (GPIO 15), RST (GPIO 2), BUSY (GPIO 4)
        - Vibration Motor: Control Pin (GPIO 19)
        - Button: GPIO 12 (with internal pull-up)

3. **Component Assembly:**
    - Connect the accelerometer, e-paper display, vibration motor, and button to the ESP32 using the specified GPIO pins.
    - Use the prototype board to manage power and ground connections, ensuring a clean layout.

4. **Testing the Device:**
    - Use the provided testing code to verify each component's functionality.
    - Ensure all connections are secure and the device powers on correctly.

5. **Screenshots:**
    - Refer to the "wearable_device" directory for device screenshots.

## Testing

### Unit Testing

1. **Frontend Unit Tests:**

    ```sh
    flutter test
    ```

2. **Backend Unit Tests:**

    ```sh
    npm test
    ```

3. **Fall Detection Unit Tests:**

    Create unit test files in the `fall-detection/tests` directory and run the tests:

    ```sh
    python -m unittest discover -s fall-detection/tests
    ```

### Integration Testing

1. **Use Postman to create integration test scripts for API endpoints.**
2. **Run integration tests using Newman:**

    ```sh
    newman run <your-collection-file.json>
    ```

3. **Integration Tests for Fall Detection:**

    Ensure the fall detection algorithm is correctly integrated with the databases and alert systems.

### System Testing

1. **Set up Selenium or Cypress for automated system testing.**
2. **Execute test scripts to verify end-to-end functionality.**

3. **System Tests for Fall Detection:**

    Simulate sensor data and ensure the entire system (from data input to alert generation) functions correctly.

### Security Testing

1. **Use OWASP ZAP or Burp Suite to perform security scans and penetration tests.**

### Load and Performance Testing

1. **Use JMeter or Gatling to simulate concurrent users and measure performance.**

## Running the Application

1. **Start the backend server:**

    ```sh
    cd backend
    npm start
    ```

2. **Run the frontend application:**

    ```sh
    cd frontend
    flutter run
    ```

3. **Run the fall detection algorithm:**

    ```sh
    cd fall-detection
    python fall_detection_local.py
    ```

## Deployment

### Frontend Deployment

1. **Build the frontend application:**

    ```sh
    flutter build web
    ```

2. **Deploy to Firebase Hosting:**

    ```sh
    firebase deploy --only hosting
    ```

### Backend Deployment

1. **Deploy the backend server to a hosting service (e.g., Heroku, AWS, Azure).**
2. **Ensure the backend server is connected to the MySQL database.**

### Fall Detection Algorithm Deployment

1. **Deploy the fall detection algorithm on a Raspberry Pi or similar device.**
2. **Ensure the device has access to the necessary environment variables and database connections.**

## Contact

For any queries or issues, please contact:

- **Name:** Alex
- **Email:** alex@example.com

