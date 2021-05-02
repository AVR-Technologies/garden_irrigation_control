#include "EEPROM.h"
#include "RTClib.h"
#include "Wire.h"
//i2c address
#define _bus_address 0x01   // self
//i2c data key
#define _start_key 0x02     // start time key // timer
#define _stop_key 0x03      // stop time key  // timer
#define _clock_key 0x04     // new clock key  // rtc
//eeprom address
#define _start_at 100       // start time
#define _stop_at  110       // stop time
#define _clock_at 120       // new clock time
#define _clock_update_at 130    // clock update variable
//objects
RTC_DS1307 rtc;
DateTime now;
void(* reset) (void) = 0;//declare reset function at address 0
char buf2[] = "YYYY/MM/DD-hh:mm:ss";
//time handler object
struct TimeElement {  // size 6bytes
  int hour;
  int minute;
  int second;
  void from(DateTime _time) {
    hour = _time.hour();
    minute = _time.minute();
    second = _time.second();
  }
  void from(byte *_time) {
    hour = _time[1];
    minute = _time[2];
    second = _time[3];
    print();
  }
  void print() {
    char _time[9];
    sprintf(_time, "%.2d:%.2d:%2d", hour, minute, second);
    Serial.print(_time);
  }
  bool isCrossed(TimeElement &after) {
    char _currentTime[7];
    char _afterTime[7];
    sprintf(_currentTime, "%.2d%.2d%.2d", hour, minute, second);
    sprintf(_afterTime, "%.2d%.2d%.2d", after.hour, after.minute, after.second);
    return String(_currentTime) >= String(_afterTime);
  }
} startAt, stopAt, newTime;
struct Clock{         // size 6bytes
  byte year;
  byte month;
  byte day;
  byte hour;
  byte minute;
  byte second;
  Clock(){
    EEPROM.get(_clock_at + 0, year);
    EEPROM.get(_clock_at + 1, month);
    EEPROM.get(_clock_at + 2, day);
    EEPROM.get(_clock_at + 3, hour);
    EEPROM.get(_clock_at + 4, minute);
    EEPROM.get(_clock_at + 5, second);
  }
  void from(byte* _time) {
    year = _time[1];
    month = _time[2];
    day = _time[3];
    hour = _time[4];
    minute = _time[5];
    second = 0;
    save();
    reset();
  }
  void print(){
    char _buff[18];
    sprintf(_buff, "%d/%d/%d %d:%d:%d", year, month, day, hour, minute, second);
    Serial.println(_buff);
  }
  void save(){
    EEPROM.put(_clock_update_at, 1);//tell new clock time available
    EEPROM.put(_clock_at + 0, year);
    EEPROM.put(_clock_at + 1, month);
    EEPROM.put(_clock_at + 2, day);
    EEPROM.put(_clock_at + 3, hour);
    EEPROM.put(_clock_at + 4, minute);
    EEPROM.put(_clock_at + 5, second);
  }
  void sync(){
    if( EEPROM.read(_clock_update_at) == 1){
      
//      rtc.adjust(DateTime(year, month, day, hour, minute, second));
      Serial.print("sync done");
      EEPROM.put(_clock_update_at, 0);
    }else rtc.begin();
  }
} newClock;
void setup () {
  Serial.begin(115200);  
  newClock.sync();
  rtc.begin();
//  Wire.begin(_bus_address);
//  Wire.onReceive(on_receive);
  Serial.print("hello");
//  if (! rtc.begin()) {
//    Serial.println("Couldn't find RTC");
//    Serial.flush();
//    abort();
//  }
//  if (! rtc.begin()) {
//      Serial.println("Couldn't find RTC");
//      Serial.flush();
//      abort();
//  }
  read_time();
  pinMode(13, OUTPUT);
}
void loop () {
  DateTime now = rtc.now();
  Serial.println(now.toString(buf2));
//  Serial.print('\t');
//  newTime.from(rtc.now());
//  newTime.print();
//  Serial.print('\t');
//  startAt.print();
//  Serial.print('\t');
//  stopAt.print();
//  Serial.println();
//  digitalWrite(13, newTime.isCrossed(startAt) && !newTime.isCrossed(stopAt));
  delay(1000);
}
//eeprom
void read_time() {
  EEPROM.get(_start_at, startAt);
  EEPROM.get(_stop_at,  stopAt);
}
//i2c
void on_receive(int howMany) {
  if(Wire.available()){
    byte buff[howMany];
    Wire.readBytes(buff, howMany);
    if(buff[0] == _start_key) startAt.from(buff), EEPROM.put(_start_at, startAt);
    else if(buff[0] == _stop_key) stopAt.from(buff), EEPROM.put(_stop_at, stopAt);
    else if(buff[0] == _clock_key) newClock.from(buff);
  }
}
//rtc
//void sync_clock(){
//  rtc.adjust(DateTime(17, 2, 3, 5, 7, 14));
//}
