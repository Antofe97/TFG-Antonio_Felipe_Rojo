// Sensor CO2
#define PIN_SENSOR 34

// Sensor Proximidad
#include <Simple_HCSR04.h>

#define ECHO_PIN 26 /// the pin at which the sensor echo is connected
#define TRIG_PIN 27 /// the pin at which the sensor trig is connected

Simple_HCSR04 *sensor;

void setup() {
  Serial.begin(115200); //Para hacer debug

  // Sensor proximidad
  sensor = new Simple_HCSR04(ECHO_PIN, TRIG_PIN);
  
}

void loop() {

  // Sensor CO2
  int medicion = analogRead(PIN_SENSOR);
  Serial.print("Medicion:");
  Serial.println(medicion);

  //Sensor Proximidad
  unsigned long distance = sensor->measure()->cm();
  Serial.print("distance: ");
  Serial.print(distance);
  Serial.print("cm\n");
  
  delay(1000);
}
