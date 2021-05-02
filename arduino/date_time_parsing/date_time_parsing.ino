#include "EEPROM.h"
#include "RTClib.h"
#include "Wire.h"

const byte _bus_address = 01; // self             // i2c address  // i2c
const byte _start_key   = 01; // start time key   // i2c data key // timer & i2c
const byte _stop_key    = 02; // stop time key    // i2c data key // timer & i2c
const byte _start_at    = 10; // start time       // address      // eeprom
const byte _stop_at     = 20; // stop time        // address      // eeprom
RTC_DS1307 rtc;                                   // objects

struct TimeElement {
  byte key;
  byte address;
  byte hour;
  byte minute;
  byte second;
  TimeElement() {}
  TimeElement(byte _address, byte _key) : address(_address) , key(_key) {
    read();
  }
  void from(byte *_time) {
    if (_time[0] == key)
      hour = _time[1],
      minute = _time[2],
      second = _time[3],
      println(),
      save();
  }
  void from(DateTime _time) {
    hour = _time.hour();
    minute = _time.minute();
    second = _time.second();
  }
  bool isCrossed(TimeElement &after) {
    char _currentTime[7];
    char _afterTime[7];
    sprintf(_currentTime, "%.2d%.2d%.2d", hour, minute, second);
    sprintf(_afterTime, "%.2d%.2d%.2d", after.hour, after.minute, after.second);
    return String(_currentTime) >= String(_afterTime);
  }
  void print() {
    char _time[9];
    sprintf(_time, "%.2d:%.2d:%.2d", hour, minute, second);
    Serial.print(_time);
  }
  void println() {
    print();
    Serial.println();
  }
  void read() {
    EEPROM.get(address + 0, hour);
    EEPROM.get(address + 1, minute);
    EEPROM.get(address + 2, second);
  }
  void save() {
    EEPROM.put(address + 0, hour);
    EEPROM.put(address + 1, minute);
    EEPROM.put(address + 2, second);
  }
}
startAt(_start_at, _start_key), stopAt(_stop_at, _stop_key), newTime;
void setup () {
  Serial.begin(115200);
  Wire.begin(_bus_address);
  Wire.onReceive(on_receive);
  if (! rtc.begin()) {
    Serial.println("Couldn't find RTC");
    Serial.flush();
    abort();
  }
  pinMode(13, OUTPUT);
}
void loop () {
  newTime.from(rtc.now());
  newTime.print();
  Serial.print('\t');
  startAt.print();
  Serial.print('\t');
  stopAt.println();
  digitalWrite(13, newTime.isCrossed(startAt) && !newTime.isCrossed(stopAt));
  delay(1000);
}
//i2c
void on_receive(int howMany) {
  if (Wire.available()) {
    byte buff[howMany];
    Wire.readBytes(buff, howMany);
    startAt.from(buff);
    stopAt.from(buff);
    for(auto c : buff) Serial.print(c);
  }
}
