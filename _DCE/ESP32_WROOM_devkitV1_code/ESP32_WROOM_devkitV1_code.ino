#include <SPI.h>   
#include <MFRC522.h>
#include <OOCSI.h>
#include <Adafruit_NeoPixel.h>

// Fill in tag UID's (you can copy + paste the UID's when you scan an unknown one from serial monitor)
#define UID1   "04 D3 E2 5A BB 2A 81"
#define UID2   "04 91 A5 E9 22 02 89"
#define UID3   "04 53 E3 5A BB 2A 81"
#define UID4   "04 6C EE 5D BB 2A 81"

// Fill in team channel for receiving
#define teamChannel "DCE2025/yourteamhere"

// OOCSI Connection Details
const char* ssid = "wifiname";
const char* password = "wifipassword";
const char* OOCSIName = "DCE2025/yourteamhere/esp##";
const char* hostserver = "hello.OOCSI.net";

// Create OOCSI instance
OOCSI oocsi = OOCSI();
   
// RFID module pins
#define SS_PIN  21  
#define RST_PIN 22  
MFRC522 mfrc522(SS_PIN, RST_PIN);
  
// WS2812B LED strip setup
#define LED_PIN    4     // Pin connected to the data input of the WS2812B LED strip
#define NUM_LEDS   10    // Number of LEDs in the strip
Adafruit_NeoPixel strip = Adafruit_NeoPixel(NUM_LEDS, LED_PIN, NEO_GRB + NEO_KHZ800);

// Timing Variables
unsigned long lastTagTime = 0;
const unsigned long timeout = 150;  // timeout before sending 0
int lastSentNumber = 0; // Stores the last sent number

void setup() {
  Serial.begin(115200);
  SPI.begin();
  mfrc522.PCD_Init();
  strip.begin();  // Initialize the LED strip
  strip.show();   // Initialize all LEDs to off
    
  // output OOCSI activity on the built-in LED
  pinMode(LED_BUILTIN, OUTPUT);
  oocsi.setActivityLEDPin(LED_BUILTIN);
    
  // Setup OOCSI connection
  oocsi.setActivityLEDPin(LED_BUILTIN);  // Show activity on LED
  oocsi.connect(OOCSIName, hostserver, ssid, password);         
  oocsi.subscribe(teamChannel);
}

void loop() {
  oocsi.keepAlive(); // Maintain OOCSI connection
    
  // Check if a new card is present
  if (mfrc522.PICC_IsNewCardPresent() && mfrc522.PICC_ReadCardSerial()) {
    lastTagTime = millis(); // Update detection time
    
    // Read UID and format it
    String content = "";
    for (byte i = 0; i < mfrc522.uid.size; i++) {
      content += (mfrc522.uid.uidByte[i] < 0x10 ? " 0" : " ");
      content += String(mfrc522.uid.uidByte[i], HEX);
    }
    content.toUpperCase();

    // Check against known Unique Identifiers
    if (content.substring(1) == UID1) { // Replace with first tag UID
      sendNumber(1);
    } else if (content.substring(1) == UID2) { // Replace with second tag UID
      sendNumber(2);
    } else if (content.substring(1) == UID3) {  // Replace with third tag UID
      sendNumber(3);
    } else if (content.substring(1) == UID4) {  // Replace with third tag UID
      sendNumber(4);
    } else {
      Serial.println("Unknown tag detected! Copy this UID:");
      Serial.println(content);
    }
  }

// If no tag has been detected for `timeout` milliseconds, send 0
if (millis() - lastTagTime > timeout && lastSentNumber != 0) {
  sendNumber(0);
}

// Check for gyro data from OOCSI and update LEDs
oocsi.check();
  updateLEDs();
}

void sendNumber(int number) {
  if (lastSentNumber != number) {  // Only send if number changes
    Serial.print("Message: ");
    Serial.println(number);
        
    // Send to OOCSI
    oocsi.newMessage(teamChannel);
    oocsi.addInt("tag", number);
    oocsi.sendMessage();

    lastSentNumber = number;
  }
}

void updateLEDs() {
  // Get the gyro value from OOCSI
  int phone = oocsi.getInt("phone_value", 0);  // Default to 0 if 'gyro' is not found
    
  // Constrain the gyro value to the range of the number of LEDs
  phone = constrain(phone, 0, NUM_LEDS);
  
  // Set all LEDs to off first
  for (int i = 0; i < NUM_LEDS; i++) {
    strip.setPixelColor(i, strip.Color(0, 0, 0));  // Off
  }

  // Adjust LED colors based on the last sent tag number
  switch (lastSentNumber) {
    case 1:
      // Red for tag 1
      for (int i = 0; i < phone; i++) {
        strip.setPixelColor(i, strip.Color(100, 0, 0)); // Red
      }
    break;
    case 2:
      // Green for tag 2
      for (int i = 0; i < phone; i++) {
        strip.setPixelColor(i, strip.Color(0, 100, 0)); // Green
      }
    break;
    case 3:
      // Blue for tag 3 (if you prefer a different color)
      for (int i = 0; i < phone; i++) {
        strip.setPixelColor(i, strip.Color(0, 0, 100)); // Blue
      }
    break;
    case 4:
      // White for tag 4 (if you prefer a different color)
      for (int i = 0; i < NUM_LEDS; i++) {
        strip.setPixelColor(i, strip.Color(100, 100, 100)); // white
      }
    break;
    default:
      // Turn off all LEDs for unknown tag values
      for (int i = 0; i < NUM_LEDS; i++) {
        strip.setPixelColor(i, strip.Color(0, 0, 0));  // Off
      }
    break;
  }
  
  // Show the updated LED strip
  strip.show();
}
    