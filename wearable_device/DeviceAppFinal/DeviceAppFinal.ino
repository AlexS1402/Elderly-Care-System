#include <WiFi.h>
#include <PubSubClient.h>
#include <Wire.h>
#include <Adafruit_LSM6DSOX.h>
#include <BLEDevice.h>
#include <BLEUtils.h>
#include <BLEScan.h>
#include <BLEAdvertisedDevice.h>
#include <SPI.h>
#include <GxEPD2_BW.h>
#include <Adafruit_GFX.h>
#include <Fonts/FreeMonoBold9pt7b.h>
#include <Fonts/FreeMono9pt7b.h>
#include <esp_task_wdt.h> // Include the watchdog timer library
#include <esp_sleep.h> // Include the sleep mode library

// Replace with your SSID, password and mqtt_server ip-address.
const char* ssid = "";
const char* password = "";
const char* mqtt_server = "";

WiFiClient espClient;
PubSubClient client(espClient);

const char* dataTopic = "esp32/data";
const char* alertTopic = "esp32/alert";
const char* medReminderTopic = "esp32/medReminder";
const char* controlTopic = "esp32/control";
const char* statusTopic = "esp32/status";
const char* checkStatusTopic = "esp32/checkStatus";

// Create the sensor object
Adafruit_LSM6DSOX lsm6dsox;

// Vibration motor pin
const int motorPin = 19;
// Button pin
const int buttonPin = 12;

// BLE scan and heart rate monitor connection
BLEScan* pBLEScan;
BLEAdvertisedDevice* myDevice;
BLEClient* pClient = nullptr;

int heartRate = 0;
bool heartRateReceived = false;
bool deviceStarted = false;

// E-Paper display
GxEPD2_BW<GxEPD2_154_D67, GxEPD2_154_D67::HEIGHT> display(GxEPD2_154_D67(/*CS=*/ 5, /*DC=*/ 15, /*RST=*/ 2, /*BUSY=*/ 4));

// Medication reminder
String lastMedReminder = "";

// Watchdog timer timeout in seconds
#define WATCHDOG_TIMEOUT 30

// Button debounce variables
unsigned long lastDebounceTime = 0;
unsigned long debounceDelay = 50;
bool buttonState = HIGH;
bool lastButtonState = HIGH;

class MyAdvertisedDeviceCallbacks: public BLEAdvertisedDeviceCallbacks {
    void onResult(BLEAdvertisedDevice advertisedDevice) {
        Serial.printf("Advertised Device: Name: %s, Address: %s, Service UUID: %s, RSSI: %d\n", 
                      advertisedDevice.getName().c_str(),
                      advertisedDevice.getAddress().toString().c_str(),
                      advertisedDevice.haveServiceUUID() ? advertisedDevice.getServiceUUID().toString().c_str() : "N/A",
                      advertisedDevice.getRSSI());

        // Check if the advertised device is a heart rate monitor (UUID: 0x180D)
        if (advertisedDevice.haveServiceUUID() && advertisedDevice.isAdvertisingService(BLEUUID((uint16_t)0x180D))) {
            Serial.println("Found a heart rate monitor!");
            myDevice = new BLEAdvertisedDevice(advertisedDevice);
            BLEDevice::getScan()->stop();
        }
    }
};

void displayMessage(String line1, String line2, String line3 = "", String line4 = "") {
  display.setFullWindow();
  display.firstPage();
  do {
    display.fillScreen(GxEPD_WHITE);
    display.setTextColor(GxEPD_BLACK);
    display.setFont(&FreeMonoBold9pt7b);
    display.setCursor(0, 20);
    display.print(line1);
    display.setFont(&FreeMono9pt7b); // Use smaller font for other lines
    display.setCursor(0, 40);
    display.print(line2);
    display.setCursor(0, 60);
    display.print(line3);
    display.setCursor(0, 80);
    display.print(line4);
  } while (display.nextPage());
  display.display();
}

void handleError(String errorMessage) {
  Serial.println("Error: " + errorMessage);
  displayMessage("Error", errorMessage);
  delay(5000); // Show error message for 5 seconds
}

void connectToHeartRateMonitor() {
  if (myDevice == nullptr) {
    handleError("No heart rate monitor found");
    return;
  }

  Serial.print("Connecting to ");
  Serial.println(myDevice->getAddress().toString().c_str());

  pClient = BLEDevice::createClient();
  if (!pClient->connect(myDevice)) {
    handleError("Failed to connect to heart rate monitor");
    return;
  }
  Serial.println("Connected to heart rate monitor");

  // Obtain the heart rate measurement characteristic
  BLERemoteService* pRemoteService = pClient->getService(BLEUUID((uint16_t)0x180D));
  if (pRemoteService == nullptr) {
    handleError("Failed to find heart rate service");
    return;
  }
  BLERemoteCharacteristic* pRemoteCharacteristic = pRemoteService->getCharacteristic(BLEUUID((uint16_t)0x2A37));
  if (pRemoteCharacteristic == nullptr) {
    handleError("Failed to find heart rate characteristic");
    return;
  }

  // Subscribe to the heart rate measurement notifications
  pRemoteCharacteristic->registerForNotify([](BLERemoteCharacteristic* pBLERemoteCharacteristic, uint8_t* pData, size_t length, bool isNotify) {
    Serial.print("Heart Rate: ");
    Serial.println(pData[1]);  // Heart rate value is in the second byte
    heartRate = pData[1];
    heartRateReceived = true;
  });

  displayMessage("ElderlyCareSystem", "Connected!", "Now Transmitting Data...");
}

void setup_wifi() {
  delay(10);
  Serial.println();
  Serial.print("Connecting to ");
  Serial.println(ssid);

  WiFi.begin(ssid, password);

  displayMessage("ElderlyCareSystem", "Connecting to WiFi...");

  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }

  Serial.println("");
  Serial.println("WiFi connected");
  Serial.println("IP address: ");
  Serial.println(WiFi.localIP());

  displayMessage("ElderlyCareSystem", "Connected!");
  delay(30000); // Show the message for 30 seconds
  displayMessage("ElderlyCareSystem", "Now Transmitting Data...");
}

void callback(char* topic, byte* payload, unsigned int length) {
  Serial.print("Message arrived [");
  Serial.print(topic);
  Serial.print("] ");
  for (int i = 0; i < length; i++) {
    Serial.print((char)payload[i]);
  }
  Serial.println();

  if (String(topic) == alertTopic) {
    // Handle alert messages
    Serial.println("Alert received");

    // Vibrate motor on high setting for alert
    analogWrite(motorPin, 255); // High setting
    delay(500);
    analogWrite(motorPin, 0);

    displayMessage("ElderlyCareSystem", "ALERT DETECTED");
    delay(30000); // Display the alert message for 30 seconds
    displayMessage("ElderlyCareSystem", "Connected, now transmitting.", "", lastMedReminder);
  } else if (String(topic) == medReminderTopic) {
    // Handle medication reminder messages
    Serial.println("Medication reminder received");

    // Vibrate motor on low setting for medication reminder
    analogWrite(motorPin, 128); // Low setting
    delay(500);
    analogWrite(motorPin, 0);
    delay(500);
    analogWrite(motorPin, 128); // Low setting
    delay(500);
    analogWrite(motorPin, 0);

    // Parse medication reminder
    String medReminder = "";
    for (unsigned int i = 0; i < length; i++) {
      medReminder += (char)payload[i];
    }
    lastMedReminder = medReminder; // Store the last medication reminder

    displayMessage("ElderlyCareSystem", "Medication Reminder", medReminder);
    delay(60000); // Display the medication reminder for 1 minute
    displayMessage("ElderlyCareSystem", "Connected, now transmitting.", "", lastMedReminder);
  } else if (String(topic) == controlTopic) {
    String command = "";
    for (unsigned int i = 0; i < length; i++) {
      command += (char)payload[i];
    }
    if (command == "start") {
      Serial.println("Start command received");
      // Start the device
      deviceStarted = true;
      start_device();
    } else if (command == "stop") {
      Serial.println("Stop command received");
      // Stop the device
      deviceStarted = false;
      stop_device();
    }
  } else if (String(topic) == checkStatusTopic) {
    Serial.println("Check status command received");
    client.publish(statusTopic, "connected");
  }
}

void reconnect() {
  while (!client.connected()) {
    Serial.print("Attempting MQTT connection...");
    if (client.connect("ESP32Client")) {
      Serial.println("connected");
      client.subscribe(alertTopic);
      client.subscribe(medReminderTopic);
      client.subscribe(controlTopic); // Subscribe to control topic for start/stop commands
      client.subscribe(checkStatusTopic); // Subscribe to check status topic
    } else {
      Serial.print("failed, rc=");
      Serial.print(client.state());
      Serial.println(" try again in 5 seconds");
      delay(5000);
    }
  }
}

void start_device() {
  Serial.println("Starting device...");

  // Initialize I2C communication for accelerometer
  Wire.begin(21, 22); // SDA on GPIO 21, SCL on GPIO 22

  Serial.println("Initializing LSM6DSOX sensor...");
  // Try to initialize the sensor
  if (!lsm6dsox.begin_I2C()) {
    handleError("Failed to find LSM6DSOX chip");
    return;
  }
  Serial.println("LSM6DSOX Found!");

  // Initialize BLE
  BLEDevice::init("");
  pBLEScan = BLEDevice::getScan(); // Create new scan
  pBLEScan->setAdvertisedDeviceCallbacks(new MyAdvertisedDeviceCallbacks());
  pBLEScan->setActiveScan(true); // Active scan uses more power, but get results faster
  pBLEScan->start(60, false); // Scan for 60 seconds

  // Initialize motor pin
  pinMode(motorPin, OUTPUT);

  displayMessage("ElderlyCareSystem", "Welcome!", "Connecting to Heart Rate Monitor...");
}

void stop_device() {
  Serial.println("Stopping device...");

  // Disconnect BLE heart rate monitor
  if (pClient != nullptr && pClient->isConnected()) {
    pClient->disconnect();
    pClient = nullptr;
  }

  // Stop I2C communication for accelerometer
  Wire.end();

  // Reset motor pin
  digitalWrite(motorPin, LOW);

  displayMessage("ElderlyCareSystem", "Now leaving...");
  delay(5000); // Display the leaving message for 5 seconds
  display.setFullWindow();
  display.firstPage();
  do {
    display.fillScreen(GxEPD_WHITE);
  } while (display.nextPage());
  display.display(); // Clear the display
}

void enterDeepSleep() {
  display.setFullWindow();
  display.firstPage();
  do {
    display.fillScreen(GxEPD_WHITE);
  } while (display.nextPage());
  display.display(); // Clear the display

  esp_sleep_enable_ext0_wakeup(GPIO_NUM_12, 0); // Wake up on button press (active low)
  esp_deep_sleep_start(); // Enter deep sleep mode
}

void setup() {
  Serial.begin(115200);
  setup_wifi();
  client.setServer(mqtt_server, 1883);
  client.setCallback(callback);

  // Initialize display
  display.init(115200);
  display.setRotation(1);

  // Initialize watchdog timer
  esp_task_wdt_init(WATCHDOG_TIMEOUT, true); // Enable panic so ESP32 restarts
  esp_task_wdt_add(NULL); // Add current thread to watchdog

  // Initialize button pin with built-in pull-up resistor
  pinMode(buttonPin, INPUT_PULLUP);

  // Subscribe to control topic immediately to receive start command
  reconnect();
}

void loop() {
  esp_task_wdt_reset(); // Reset watchdog timer

  // Check button state for debounce
  int reading = digitalRead(buttonPin);

  if (reading != lastButtonState) {
    lastDebounceTime = millis();
  }

  if ((millis() - lastDebounceTime) > debounceDelay) {
    if (reading == LOW && buttonState == HIGH) {
      // Button press detected
      buttonState = LOW;
      Serial.println("Button press detected, entering deep sleep.");
      enterDeepSleep();
    } else if (reading == HIGH && buttonState == LOW) {
      // Button release detected
      buttonState = HIGH;
    }
  }

  lastButtonState = reading;

  if (!client.connected()) {
    reconnect();
  }
  client.loop();

  if (deviceStarted) {
    // Check if BLE device found and connect to it
    if (myDevice != nullptr) {
      connectToHeartRateMonitor();
      myDevice = nullptr; // Reset the device pointer to avoid reconnecting in the loop
    }

    // Read accelerometer and gyroscope data
    sensors_event_t accel, gyro, temp;
    lsm6dsox.getEvent(&accel, &gyro, &temp);

    // Publish accelerometer, gyroscope, and heart rate data
    if (heartRateReceived) {
      heartRateReceived = false; // Reset the flag
      char dataStr[256];
      snprintf(dataStr, sizeof(dataStr), "{\"heartRate\":%d,\"accel\":[%.2f,%.2f,%.2f],\"gyro\":[%.2f,%.2f,%.2f]}",
               heartRate, accel.acceleration.x, accel.acceleration.y, accel.acceleration.z,
               gyro.gyro.x, gyro.gyro.y, gyro.gyro.z);
      client.publish(dataTopic, dataStr);
    }

    delay(1000); // Wait for a second before reading again
  }
}
