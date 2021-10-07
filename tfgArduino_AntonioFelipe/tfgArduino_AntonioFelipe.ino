// Sensor CO2
#define PIN_SENSOR 34

void setup() {
  Serial.begin(115200);
}

void loop() {
  int medicion = analogRead(PIN_SENSOR);
  Serial.print("Medicion:");
  Serial.println(medicion);
  delay(1000);
}
