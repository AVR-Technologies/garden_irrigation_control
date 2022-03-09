#include "ArduinoJson.h"
#include "BluetoothSerial.h"
#include "Wire.h"
//i2c address
const byte _bus_address = 01; // slave
//i2c data key
const byte _start_key   = 01; // start time key     // timer
const byte _stop_key    = 02; // stop time key      // timer
const byte _clock_key   = 03; // new clock key      // rtc
//obejcts
BluetoothSerial SerialBT;
StaticJsonDocument<200> doc;
//time handler object
struct TimeElement {          // for esp32 size: 12 // with key 16
  int key;
  int hour;
  int minute;
  int second;
  TimeElement(int _key) : key(_key) {}
  void from(const char *_time) {
    sscanf(_time, "%d:%d:%d", &hour, &minute, &second);
  }
  void print() {
    char _time[9];
    sprintf(_time, "%.2d:%.2d:%.2d", (byte)hour, (byte)minute, (byte)second);
    Serial.print(_time);
  }
  void send() {
    byte _buff[4];
    _buff[0] = (byte)key;
    _buff[1] = (byte)hour;
    _buff[2] = (byte)minute;
    _buff[3] = (byte)second;
    Wire.beginTransmission(_bus_address);
    Wire.write(_buff, 4);
    Wire.endTransmission();
    print();
  }
}  startAt(_start_key),  stopAt(_stop_key);
/*
  struct Clock{
  int year;
  int month;
  int day;
  int hour;
  int minute;
  int second;
  void from(const char* _buff){
    sscanf(_buff, "%d-%d-%d %d:%d:%d", &year, &month, &day, &hour, &minute, &second);
    Serial.print("time: ");
  }
  void print(){
    char _buff[18];
    sprintf(_buff, "%d/%d/%d %d:%d:%d", year, month, day, hour, minute, second);
    Serial.println(_buff);
  }
  void send() {
    byte _buff[7];
    _buff[0] = _clock_key;
    _buff[1] = (byte)year;
    _buff[2] = (byte)month;
    _buff[3] = (byte)day;
    _buff[4] = (byte)hour;
    _buff[5] = (byte)minute;
    _buff[6] = (byte)second;
    Wire.beginTransmission(_bus_address);
    Wire.write(_buff, 7);
    Wire.endTransmission();
    print();
  }
  } newClock;
*/
void setup() {
  Serial.begin(115200);
  SerialBT.begin("ESP32test"); //Bluetooth device name
  Wire.begin(); // join i2c bus (address optional for master)
  Serial.println(F("boot complete"));
}
void loop() {
  if (SerialBT.available()) {
    String data = SerialBT.readString();
    doc.clear();
    deserializeJson(doc, data);
    //    if(doc["data"] == 0){ //sync time
    //      newClock.from(doc["time"]);
    //      newClock.send();
    //    }
    //    else
    if (doc["data"] == 1) { //timer settings
      startAt.from(doc["start"]);
      stopAt.from(doc["stop"]);
      startAt.send();
      stopAt.send();
    }
  }
}
