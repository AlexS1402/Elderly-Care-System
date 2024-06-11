# Elderly Care System

## Overview

The Elderly Care System is designed to provide caregivers with a dashboard to monitor the health and well-being of elderly patients. It includes features such as patient data management, medication schedules, alert logs, and user management. The system consists of a frontend built with Flutter and a backend using Node.js with a MySQL database hosted on Azure.

## Table of Contents

1. [Prerequisites](#prerequisites)
2. [Setup](#setup)
    1. [Frontend Setup](#frontend-setup)
    2. [Backend Setup](#backend-setup)
    3. [ECSI/Fall Detection Algorithm Setup](#ecsi/fall-detection-algorithm-setup)
    4. [Device Setup](#device-setup)
    5. [MQTT Server Setup](#mqtt-server-setup)
    6. [Local SQL Server Setup on Raspberry Pi](#local-sql-server-setup-on-raspberry-pi)
3. [Running the Application](#running-the-application)
4. [Database Structure](#database-structure)
5. [Contact](#contact)
6. [Demonstration Video](#demonstration-video)

## Prerequisites

- Node.js (v14 or later)
- MySQL Server
- Flutter SDK
- Firebase CLI (for deployment)
- Git
- Python (v3.7 or later)
- Raspberry Pi 4 Model B
- Required Python packages (`numpy`, `pandas`, `joblib`, `mysql-connector-python`, `python-dotenv`, `twilio`, `bcrypt`, `smtplib`)
- Twilio account for sending SMS alerts
- Email address and password for the SMTP server
- Mosquitto MQTT Broker for device communication (if not using alternative methods)

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

### ECSI/Fall Detection Algorithm Setup

1. **Navigate to the fall detection directory:**

    ```sh
    cd ../ecsi
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
    SMTP_SERVER=<your-smtp-server>
    SMTP_PORT=<your-SMTP-port>
    TWILIO_ACCOUNT_SID=your_twilio_account_sid
    TWILIO_AUTH_TOKEN=your_twilio_auth_token
    TWILIO_PHONE_NUMBER=your_twilio_phone_number
    MYSQL_HOST=<your-database-host>
    MYSQL_USER=<your-database-username>
    MYSQL_PASSWORD=<your-database-password>
    MYSQL_DATABASE=<your-database-name>
    SQLITE_DB_PATH=<your-local-datbase-path>
    ```

4. **Set up the MySQL and SQLite databases:**

    - Ensure your MySQL server is running and the database schema is set up.
    - Create the SQLite database using the provided SQL scripts.

5. **Run the fall detection algorithm:**

    ```sh
    python ecsi.py
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

### MQTT Server Setup

**Note**: The MQTT server is required for the wearable device to communicate with the fall detection algorithm.

1. **Install Mosquitto MQTT Broker on Raspberry Pi:**

    ```sh
    sudo apt update
    sudo apt install mosquitto mosquitto-clients
    sudo systemctl enable mosquitto
    sudo systemctl start mosquitto
    ```

2. **Configure Mosquitto (optional):**

    - Edit the Mosquitto configuration file if you need custom settings:

    ```sh
    sudo nano /etc/mosquitto/mosquitto.conf
    ```

    - Restart Mosquitto service after making changes:

    ```sh
    sudo systemctl restart mosquitto
    ```

3. **Connect the Wearable Device to the MQTT Server:**
    - Ensure the MQTT server's IP address and WiFi credentials are correctly set in the device source code:

    ```cpp
    const char* ssid = "Your_SSID";
    const char* password = "Your_PASSWORD";
    const char* mqtt_server = "Your_Raspberry_Pi_IP";
    ```

    - Upload the updated code to the ESP32 device.

### Local SQL Server Setup on Raspberry Pi

1. **Install SQLite on Raspberry Pi:**

    ```sh
    sudo apt update
    sudo apt install sqlite3
    ```

2. **Create and Set Up SQLite Database:**

    ```sh
    sqlite3 elderlycaresystemlocaldb.db
    ```

3. **Create Tables in SQLite Database:**

    ```sql
    CREATE TABLE patientprofiles (
        ProfileID INTEGER PRIMARY KEY,
        UserID INTEGER,
        FirstName TEXT,
        LastName TEXT,
        DOB DATE,
        Gender TEXT,
        Address TEXT,
        EmergencyContact TEXT
    );

    CREATE TABLE patientmedications (
        PatientMedicationID INTEGER PRIMARY KEY,
        ProfileID INTEGER,
        MedicationName TEXT,
        Dosage TEXT,
        StartDate DATE,
        EndDate DATE,
        FrequencyPerDay INTEGER
    );

    CREATE TABLE medicationschedules (
        ScheduleID INTEGER PRIMARY KEY,
        PatientMedicationID INTEGER,
        ScheduledTime TIME
    );

    CREATE TABLE users (
        UserID INTEGER PRIMARY KEY,
        Username TEXT,
        PasswordHash TEXT,
        UserRole TEXT
    );

    CREATE TABLE sensordata (
        DataHistoryID INTEGER PRIMARY KEY,
        ProfileID INTEGER,
        Timestamp DATETIME,
        SensorType TEXT,
        Value REAL
    );

    CREATE TABLE alertlogs (
        AlertID INTEGER PRIMARY KEY,
        ProfileID INTEGER,
        AlertType TEXT,
        AlertTimestamp DATETIME,
        Resolved BOOLEAN
    );
    ```

4. **Verify the SQLite Database Setup:**

    - List tables to ensure they are created correctly:

    ```sh
    sqlite3 elderlycaresystemlocaldb.db
    .tables
    ```

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
    cd ecsi
    python ecsi.py
    ```

## Database Structure

### MySQL Database Structure (Cloud)

- **patientprofiles:**
    - `address` - VARCHAR(255)
    - `DOB` - DATE
    - `EmergencyContact` - VARCHAR(255)
    - `FirstName` - VARCHAR(255)
    - `LastName` - VARCHAR(255)
    - `Gender` - ENUM('Male','Female','Other')
    - `ProfileID` - INT
    - `UserId` - INT

- **patientmedications:**
    - `Dosage` - VARCHAR(255)
    - `EndDate` - DATE
    - `FrequencyPerDay` - INT
    - `MedicationName` - VARCHAR(255)
    - `PatientMedicationID` - INT
    - `StartDate` - DATE

- **medicationschedules:**
    - `PatientMedicationID` - INT
    - `ScheduledTime` - TIME
    - `ScheduleID` - INT

- **users:**
    - `Email` - VARCHAR(255)
    - `PasswordHash` - VARCHAR(255)
    - `UserID` - INT
    - `Username` - VARCHAR(255)
    - `UserRole` - ENUM('Admin','Caregiver','Patient')

- **sensordatahistory:**
    - `DataHistoryID` - INT
    - `ProfileID` - INT
    - `SensorType` - VARCHAR(255)
    - `Timestamp` - DATETIME
    - `Value` - DOUBLE

- **alertlogs:**
    - `AlertID` - INT
    - `AlertTimestamp` - DATETIME
    - `AlertType` - VARCHAR(255)
    - `ProfileID` - INT
    - `Resolved` - TINYINT(1)

### SQLite Database Structure (Local)

- **patientprofiles:**
    - `ProfileID` - INTEGER PRIMARY KEY
    - `UserID` - INTEGER
    - `FirstName` - TEXT
    - `LastName` - TEXT
    - `DOB` - DATE
    - `Gender` - TEXT
    - `Address` - TEXT
    - `EmergencyContact` - TEXT

- **patientmedications:**
    - `PatientMedicationID` - INTEGER PRIMARY KEY
    - `ProfileID` - INTEGER
    - `MedicationName` - TEXT
    - `Dosage` - TEXT
    - `StartDate` - DATE
    - `EndDate` - DATE
    - `FrequencyPerDay` - INTEGER

- **medicationschedules:**
    - `ScheduleID` - INTEGER PRIMARY KEY
    - `PatientMedicationID` - INTEGER
    - `ScheduledTime` - TIME

- **users:**
    - `UserID` - INTEGER PRIMARY KEY
    - `Username` - TEXT
    - `PasswordHash` - TEXT
    - `UserRole` - TEXT

- **sensordata:**
    - `DataHistoryID` - INTEGER PRIMARY KEY
    - `ProfileID` - INTEGER
    - `Timestamp` - DATETIME
    - `SensorType` - TEXT
    - `Value` - REAL

- **alertlogs:**
    - `AlertID` - INTEGER PRIMARY KEY
    - `ProfileID` - INTEGER
    - `AlertType` - TEXT
    - `AlertTimestamp` - DATETIME
    - `Resolved` - BOOLEAN

## Contact

For any queries or issues, please contact:

- **Name:** Alex Saunders
- **Personal Email:**  alexander.saunders14@yahoo.co.uk
- **University Email:** asaunde4@stu.chi.ac.uk

## Demonstration Video

This is a link to a demonstration video of how the system functions:
https://youtu.be/Me-EucbhGCo
