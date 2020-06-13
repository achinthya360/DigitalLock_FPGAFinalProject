#include <SevSeg.h>

#include <SevSeg.h>

SevSeg sevseg; //Instantiate a seven segment object
char str[5] = "dPEN";
char str2[5]= "shDT";
void setup() {
  byte numDigits = 4;

byte digitPins[] = {2, 3, 4, 5};

byte segmentPins[] = {6, 7, 8, 9, 10, 11, 12, 13};

sevseg.begin(COMMON_CATHODE, numDigits, digitPins, segmentPins);

sevseg.setBrightness(90);
  sevseg.setBrightness(90);
  sevseg.blank();

  Serial.begin(9600);
}

void loop(){
  int lock = digitalRead(14);
  if(lock){
    sevseg.setChars(str2);
  }
  else{
    sevseg.setChars(str);
  }
  sevseg.refreshDisplay();
  
}
