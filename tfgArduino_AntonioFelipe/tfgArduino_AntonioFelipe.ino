#include <HTTPClient.h>

#include <TimeLib.h>
unsigned long previousTime;
unsigned long actualTime;
unsigned long heatTime;

//LED RGB
#include <Adafruit_NeoPixel.h>
#define PIN 15
#define NUM 1

Adafruit_NeoPixel pixels = Adafruit_NeoPixel(NUM,PIN, NEO_GRB + NEO_KHZ800);
//
////////////////
//////
#include <DNSServer.h>
#include <WiFi.h>
#include <WiFiAP.h>
#include <ESPmDNS.h>
// Set these to your desired credentials.
const char *ss = "Arduino";
const char *pass = "arduino";

//////
#include "FS.h" //Para usar File
#include "ArduinoJson.h"

///// BASE DE DATOS
#include <MySQL_Connection.h>
#include <MySQL_Cursor.h>

//byte mac_addr[] = { 0xDE, 0xAD, 0xBE, 0xEF, 0xFE, 0xED };

IPAddress server_addr;  // IP of the MySQL *server* here
char hostname_DB[] = "tfgarduino.ddns.net";
char user[] = "arduino";              // Usuario MySQL
char passwordDB[] = "Arduino.1234";        // Contraseña MySQL

/// BASE DE DATOS
WiFiClient client;  // Use this for WiFi instead of EthernetClient
MySQL_Connection conn((Client *)&client);
  
// Import required libraries
#include "WiFi.h"
#include "ESPAsyncWebServer.h"
#include "SPIFFS.h"

// Create AsyncWebServer object on port 80
AsyncWebServer server(80);
DNSServer dnsServer;

int conf_distance;
int conf_co2_mid;
int conf_co2_max;
String conf_dni;
String conf_ssid;
String tokenApp;
boolean semaforo =true;
//boolean semaforoDB;
//boolean hasWifiParams = false;

int loops;

TaskHandle_t TaskCheckConnections;

String lectura(const String& var){
  DynamicJsonDocument doc = readConFile();

  if(var == "SSID"){
    if(WiFi.SSID() != ""){
      //hasWifiParams = true;
      return "Conectado actualmente a: " + WiFi.SSID();
    }
    else{
      return "El dispositivo no está conectado a ninguna red WiFi";
    }
  }
  
  if(var == "CO2_MAX"){
    const char* value = doc["co2_max"];
    return value;
  }
  if(var == "CO2_MID"){
    const char* value = doc["co2_mid"];
    return value;
  }
  if(var == "DISTANCE"){
    const char* value = doc["distance"];
    return value;
  }
  String dni = doc["dni"];
  
  String alu_password = doc["alu_password"];
  if(var == "SESION"){
    Serial.println("DNI: " +dni+" , PASSWORD: " + alu_password);
    if(dni != ""){
      if(conn.connected() != 0){
        if(comprobarSesion(dni, alu_password)) {
          Serial.println("SESION CORRECTA");
          return "Sesión iniciada como: " + dni;
        } else{
          Serial.println("SESION INCORRECTA");
          return "";
        }
      } else {
        return "Sesión iniciada como: " + dni;
      }
    }
  }
  
  return String();
}

//Comprueba que el DNI y contraseña son correctos
boolean comprobarSesion(String dni, String password){
  String sentencia = "SELECT * FROM TFG_ARDUINO.alumno WHERE dni = '" + dni + "' AND password = '" + password +"';";
  int str_len = sentencia.length() + 1; //Length (with one extra character for the null terminator)
  char INSERT_SQL[str_len];
  sentencia.toCharArray(INSERT_SQL, str_len);

  Serial.println("MENSAJE DESDE comprobarSesion");
  // Iniciar instancia MySQL
  MySQL_Cursor *cur_mem = new MySQL_Cursor(&conn);
  // Ejecutar consulta SQL
  cur_mem->execute(INSERT_SQL);
  // Recorrer filas
  column_names *cols = cur_mem->get_columns();
  row_values *row = NULL;
  do {
    row = cur_mem->get_next_row();
    if (row != NULL) {
        tokenApp = row->values[4];
        delete cur_mem;
        return true;
    }
  } while (row != NULL);
  
  delete cur_mem; //Eliminar cursor para liberar memoria
  return false;
}

//Modificar conexión Wi-Fi
String modifyWifi(String ssid, String password){
    //Obtener JSON de configuración almacenado
    DynamicJsonDocument doc = readConFile();
    doc["ssid"] = ssid;
    doc["password"] = password;

    WiFi.disconnect(true);
    //Actualizar parámetros de conexión y guardar JSON
    writeConFile(doc);
    //Volver a conectar Wi-Fi
    connectWifi();
    return String();
}

//Modificar límites CO2 y distancia
String modifyLimits(String co2_mid, String co2_max, String distance){
    //Obtener JSON de configuración almacenado
    DynamicJsonDocument doc = readConFile();
    doc["co2_max"] = co2_max;
    doc["co2_mid"] = co2_mid;
    doc["distance"] = distance;
    
    conf_distance = distance.toInt();
    conf_co2_max = co2_max.toInt();
    conf_co2_mid = co2_mid.toInt();

    //Actualizar JSON y almacenar
    writeConFile(doc);
    return String();
}

//Comprueba inicio de sesión, actualiza JSON y modifica el AP y DNS
String iniciarSesion(String dni, String password){
  if(comprobarSesion(dni, password)){
    DynamicJsonDocument doc = readConFile();
    doc["dni"] = dni;
    doc["alu_password"] = password;
    doc["token_app"] = tokenApp;

    //updateAlumnoDB(dni, nombre, apellidos, password, conf_dni);
    conf_dni = dni;
    
    writeConFile(doc);

    createAccessPoint();
    startDNS();
  }
    return String();
}

//Actualiza JSON y modifica el AP y el DNS
String cerrarSesion(){
    DynamicJsonDocument doc = readConFile();
    doc["dni"] = "";
    doc["alu_password"] = "";

    conf_dni = "";
    
    writeConFile(doc);

    createAccessPoint();
    startDNS();
    
    return String();
}

////////////////

// Pantalla OLED
#include <SPI.h>
#include <Wire.h>
#include <Adafruit_GFX.h>
#include <Adafruit_SSD1306.h>

#define SCREEN_WIDTH 128 // Ancho en pixeles pantalla
#define SCREEN_HEIGHT 64 // Altura en pixeles pantalla

// Declaration for SSD1306 display connected using software SPI (default case):
#define OLED_MOSI  23
#define OLED_CLK   18
#define OLED_DC    16
#define OLED_CS    17
#define OLED_RESET 5
Adafruit_SSD1306 display(SCREEN_WIDTH, SCREEN_HEIGHT,
  OLED_MOSI, OLED_CLK, OLED_DC, OLED_RESET, OLED_CS);

// Logo UCLM
const unsigned char logoUCLM [] PROGMEM = {
  0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 
  0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 
  0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 
  0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 
  0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xfe, 0x7f, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 
  0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xfc, 0x3f, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 
  0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xf8, 0x1f, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 
  0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xf0, 0x0f, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 
  0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xe0, 0x07, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 
  0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xc0, 0x03, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 
  0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0x80, 0x01, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 
  0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0x01, 0x80, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 
  0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xfe, 0x0f, 0xf0, 0x7f, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 
  0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xfc, 0x3f, 0xfc, 0x3f, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 
  0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xf8, 0x78, 0x1e, 0x1f, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 
  0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xf1, 0xe0, 0x07, 0x8f, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 
  0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xe3, 0xc0, 0x03, 0xc7, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 
  0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xc7, 0x00, 0x00, 0xe3, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 
  0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0x8e, 0x00, 0x00, 0x71, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 
  0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0x0c, 0x00, 0x00, 0x38, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 
  0xff, 0xff, 0xff, 0xff, 0xff, 0xfe, 0x18, 0x07, 0xe0, 0x18, 0x7f, 0xff, 0xff, 0xff, 0xff, 0xff, 
  0xff, 0xff, 0xff, 0xff, 0xff, 0xfc, 0x38, 0x3f, 0xfc, 0x1c, 0x3f, 0xff, 0xff, 0xff, 0xff, 0xff, 
  0xff, 0xff, 0xff, 0xff, 0xff, 0xf8, 0x70, 0x7c, 0x3e, 0x0e, 0x1f, 0xff, 0xff, 0xff, 0xff, 0xff, 
  0xff, 0xff, 0xff, 0xff, 0xff, 0xf0, 0x60, 0xe0, 0x07, 0x06, 0x0f, 0xff, 0xff, 0xff, 0xff, 0xff, 
  0xff, 0xff, 0xff, 0xff, 0xff, 0xe0, 0xe1, 0xc0, 0x03, 0x87, 0x07, 0xff, 0xff, 0xff, 0xff, 0xff, 
  0xff, 0xff, 0xff, 0xff, 0xff, 0xc0, 0xc3, 0x80, 0x01, 0xc3, 0x03, 0xff, 0xff, 0xff, 0xff, 0xff, 
  0xff, 0xff, 0xff, 0xff, 0xff, 0x80, 0xc7, 0x00, 0x00, 0xe3, 0x01, 0xff, 0xff, 0xff, 0xff, 0xff, 
  0xff, 0xff, 0xff, 0xff, 0xff, 0x01, 0xce, 0x07, 0xe0, 0x73, 0x80, 0xff, 0xff, 0xff, 0xff, 0xff, 
  0xff, 0xff, 0xff, 0xff, 0xfe, 0x01, 0x8c, 0x1f, 0xf8, 0x31, 0x80, 0x7f, 0xff, 0xff, 0xff, 0xff, 
  0xff, 0xff, 0xff, 0xff, 0xfc, 0x01, 0x8c, 0x3c, 0x3c, 0x31, 0x80, 0x3f, 0xff, 0xff, 0xff, 0xff, 
  0xff, 0xff, 0xff, 0xff, 0xf8, 0x01, 0x8c, 0x70, 0x0e, 0x31, 0x80, 0x1f, 0xff, 0xff, 0xff, 0xff, 
  0xff, 0xff, 0xff, 0xff, 0xf0, 0x01, 0x8c, 0x60, 0x06, 0x39, 0x80, 0x0f, 0xff, 0xff, 0xff, 0xff, 
  0xff, 0xff, 0xff, 0xff, 0xf0, 0x01, 0x9c, 0x60, 0x07, 0x39, 0x80, 0x0f, 0xff, 0xff, 0xff, 0xff, 
  0xff, 0xff, 0xff, 0xff, 0xf8, 0x01, 0x9c, 0xe0, 0x03, 0x19, 0x80, 0x1f, 0xff, 0xff, 0xff, 0xff, 
  0xff, 0xff, 0xff, 0xff, 0xfc, 0x01, 0x9c, 0xc0, 0x03, 0x19, 0x80, 0x3f, 0xff, 0xff, 0xff, 0xff, 
  0xff, 0xff, 0xff, 0xff, 0xfe, 0x01, 0x9c, 0xc0, 0x03, 0x19, 0x80, 0x7f, 0xff, 0xff, 0xff, 0xff, 
  0xff, 0xff, 0xff, 0xff, 0xff, 0x01, 0x9c, 0xe0, 0x07, 0x19, 0x80, 0xff, 0xff, 0xff, 0xff, 0xff, 
  0xff, 0xff, 0xff, 0xff, 0xff, 0x81, 0x9c, 0x60, 0x06, 0x19, 0x81, 0xff, 0xff, 0xff, 0xff, 0xff, 
  0xff, 0xff, 0xff, 0xff, 0xff, 0xc1, 0x9c, 0x70, 0x0e, 0x19, 0x83, 0xff, 0xff, 0xff, 0xff, 0xff, 
  0xff, 0xff, 0xff, 0xff, 0xff, 0xe1, 0x9c, 0x30, 0x0e, 0x19, 0x87, 0xff, 0xff, 0xff, 0xff, 0xff, 
  0xff, 0xff, 0xff, 0xff, 0xff, 0xf1, 0x9c, 0x38, 0x1c, 0x19, 0x8f, 0xff, 0xff, 0xff, 0xff, 0xff, 
  0xff, 0xff, 0xff, 0xff, 0xff, 0xf9, 0x9c, 0x70, 0x0e, 0x19, 0x9f, 0xff, 0xff, 0xff, 0xff, 0xff, 
  0xff, 0xff, 0xff, 0xff, 0xff, 0xfd, 0x9c, 0xe0, 0x07, 0x19, 0xbf, 0xff, 0xff, 0xff, 0xff, 0xff, 
  0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0x9c, 0xc0, 0x03, 0x19, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 
  0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0x9c, 0xc0, 0x03, 0x19, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 
  0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0x9c, 0xc0, 0x03, 0x19, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 
  0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xdc, 0xc0, 0x03, 0x1b, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 
  0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xfc, 0xc0, 0x03, 0x1f, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 
  0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xfc, 0xc0, 0x03, 0x1f, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 
  0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xfc, 0xc0, 0x03, 0x1f, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 
  0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xfc, 0xc0, 0x03, 0x3f, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 
  0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xfe, 0xc0, 0x03, 0x7f, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 
  0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xc0, 0x03, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 
  0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xc0, 0x03, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 
  0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xc0, 0x03, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 
  0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xe0, 0x07, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 
  0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xf0, 0x0f, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 
  0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xf8, 0x1f, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 
  0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xfc, 0x3f, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 
  0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xfe, 0x7f, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 
  0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 
  0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 
  0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 
  0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff
};

// Icono Base de Datos
const unsigned char database_icon [] PROGMEM = {
  0x3f, 0x00, 0x7f, 0x80, 0x7f, 0x80, 0x3f, 0x00, 0x40, 0x80, 0x7f, 0x80, 0x3f, 0x00, 0x40, 0x80, 
  0x7f, 0x80, 0x3f, 0x00
};

// Sensor CO2
#define PIN_SENSOR 34

// Sensor Proximidad
#include <Simple_HCSR04.h>

#define ECHO_PIN 26 /// the pin at which the sensor echo is connected
#define TRIG_PIN 27 /// the pin at which the sensor trig is connected

Simple_HCSR04 *sensor;

////// Captive Portal
#include <AsyncTCP.h>

class CaptiveRequestHandler : public AsyncWebHandler {
public:
  CaptiveRequestHandler() {}
  virtual ~CaptiveRequestHandler() {}

  bool canHandle(AsyncWebServerRequest *request){
    //request->addInterestingHeader("ANY");
    return true;
  }

  void handleRequest(AsyncWebServerRequest *request) {
    request->send(SPIFFS, "/index.html","text/html", false); 
  }
};

/////

void setup() {
  Serial.begin(115200); //Para hacer debug

  ///////PANTALLA
  if(!display.begin(SSD1306_SWITCHCAPVCC)) {
    Serial.println(F("SSD1306 allocation failed"));
    for(;;); // Don't proceed, loop forever
  }

  display.clearDisplay();
  display.display();
  //delay(2000);
  
  display.clearDisplay();

  display.drawBitmap(0, 0, logoUCLM, 128, 64, WHITE); // display.drawBitmap(x position, y position, bitmap data, bitmap width, bitmap height, color)
  display.display();
  delay(2000); // Pause for 2 seconds

  
  ////////
  ////////////////////////

  // Inicializar SPIFFS
  if(!SPIFFS.begin(true)){
    Serial.println("Error al montar el sistema de ficheros SPIFFS");
    return;
  }
  
  createAccessPoint();
  
  // Connect to Wi-Fi
  //const char* ssid = doc["ssid"];
  //const char* password = doc["password"];
  
  //connectWifi();

  //connectDB();
  
  startDNS();
  
  
  // Print ESP32 Local IP Address
  Serial.println(WiFi.localIP());

  setupServer();

  DynamicJsonDocument doc = readConFile();
  conf_distance = doc["distance"];
  conf_co2_mid = doc["co2_mid"];
  conf_co2_max = doc["co2_max"];
  String cambio = doc["dni"];
  conf_dni = cambio;
  String cambio2 = doc["token_app"];
  tokenApp = cambio2;
  String cambio3 = doc["ssid"];
  conf_ssid = cambio3;
  ///////////////
  //////// Asignación del metodo checkConnections() al Core 0
  xTaskCreatePinnedToCore(
      checkConnections, /* Function to implement the task */
      "TaskCheckConnections", /* Name of the task */
      10000,  /* Stack size in words */
      NULL,  /* Task input parameter */
      0,  /* Priority of the task */
      &TaskCheckConnections,  /* Task handle. */
      0); /* Core where the task should run */

  ////////
  
  // Sensor proximidad
  sensor = new Simple_HCSR04(ECHO_PIN, TRIG_PIN);

  display.clearDisplay();
  display.display();

  //Inicialización tiempo de calentamiento MQ135
  heatTime = millis();
  //Inicialización contador de tiempo para las notificaciones
  previousTime = millis() - 300000;
  
  pixels.begin();
}

void loop() {
  
  dnsServer.processNextRequest();
  // Lectura CO2
  int medicionCO2 = analogRead(PIN_SENSOR);
  Serial.print("Medicion CO2:");
  Serial.println(medicionCO2);

  //Lectura Distancia
  unsigned long medicionDistancia = sensor->measure()->cm();
  Serial.print("distance: ");
  Serial.print(medicionDistancia);
  Serial.print("cm\n");

  String mensaje;
  if (medicionDistancia < conf_distance)
  {
    mensaje = "Demasiado\ncerca";
  }
  //else
  //{
  //  mensaje = "Distancia\ncorrecta";
  //}
  if (medicionCO2 < conf_co2_mid){
    
    mensaje = "Calidad \naire correcta";
    pixels.setPixelColor(0, pixels.Color(0,255,0));
    pixels.show();
  }
  if (medicionCO2 > conf_co2_mid && medicionCO2 < conf_co2_max){
    
    mensaje = "Aire\ncargandose";
    pixels.setPixelColor(0, pixels.Color(255,255,0));
    pixels.show();
  }
  if (medicionCO2 > conf_co2_max){
    if(tokenApp != ""){
      actualTime = millis();
      if(actualTime - previousTime > 300000){ //Solo envia notificación si han pasado 5 minutos desde la anterior
        enviarNotificacion(medicionCO2);
        previousTime = actualTime;
      }
    }
    mensaje = "Alta\nconcentracion CO2";
    pixels.setPixelColor(0, pixels.Color(255,0,0));
    pixels.show();
  }
  //inicializar pantalla
  display.setTextSize(1);
  display.setTextColor(SSD1306_WHITE);
  display.setCursor(0,0);

  display.clearDisplay();

  display.println(mensaje);
  display.setCursor(0,16);
  display.println("Medicion CO2 (ppm):");

  // Barras señal wifi
  long rssi = WiFi.RSSI();
  Serial.print("rssi:");
  Serial.println(rssi);
  Serial.println("");
  int bars;
  //display.fillRect(80,13,3,3,WHITE);
  //display.fillRect(105,10,3,6,WHITE);
  //display.fillRect(110,7,3,9,WHITE);
  //display.fillRect(115,4,3,12,WHITE);
  if (rssi >= -55) {
    bars = 5;
  } else if (rssi <= -55 & rssi >= -65) {
    bars = 4;
  } else if (rssi <= -65 & rssi >= -70) {
    bars = 3;
  } else if (rssi <= -70 & rssi >= -78) {
    bars = 2;
  } else if (rssi <= -78 & rssi >= -82) {
    bars = 1;
  } else {
    bars = 0;
  }

  if(WiFi.status() != WL_CONNECTED){
    display.setCursor(60,0);
    display.println(WiFi.softAPIP());
  } else{
  for (int b = 0; b <= bars; b++) {
    //display.fillRect(59 + (b*5),33 - (b*5),3,b*5,WHITE);
    //display.fillRect(59 + (b*5),33 - (b*3),3,b*4,WHITE);
    display.fillRect(95 + (b * 5), 10 - (b * 2), 3, b * 2, WHITE);
  }
  }
  if(conn.connected() == 1){
      display.drawBitmap(85, 0, database_icon, 10, 10, WHITE); // display.drawBitmap(x position, y position, bitmap data, bitmap width, bitmap height, color)
  }
  //else{
  //  Serial.println("Desconectado de la DB. Intentando conectar...");
  //  connectDB();
  //}

  display.setTextColor(WHITE);
  display.setTextSize(1);

  display.setTextSize(2);             // Draw 2X-scale text
  display.setTextColor(SSD1306_WHITE);
  display.setCursor(0, 25);
  display.print(medicionCO2);
  
  display.setCursor(0,40);
  display.setTextSize(1); 
  display.println("Distancia (cm):");
  display.setCursor(0,50);
  display.setTextSize(2);
  display.print(medicionDistancia);

  display.display();

  loops = 0;
  
  do{
    if(semaforo){
      Serial.println("Bloqueo (LOOP)");
      semaforo = false;
      if(conn.connected() != 0){
        heatTime = millis();
        if(heatTime > 120000){ //Solo inserta medición despues de 2 minutos desde el encendido
          if(conf_dni != ""){
            insertMedicionDB(medicionCO2, medicionDistancia, conf_dni);
            checkConfiguracionDB();
          }
        }
      }
      Serial.println("Libero (LOOP)");
      semaforo = true;
    }
    else{
      if(loops == 10){
        Serial.println("SALGO");
        break;
      }
      loops = loops + 1;
      Serial.println(loops);
      Serial.println("Me espero (LOOP)");
      delay(100);
    }
  }while(!semaforo);
  
  delay(5000); //Actualización cada 5 segundos
}

void enviarNotificacion(int medicionCO2){
  Serial.print("Envia notificación. Token: ");
  Serial.println(tokenApp);
  HTTPClient http;

  http.begin("https://fcm.googleapis.com/fcm/send");
  http.addHeader("Content-Type", "application/json");
  http.addHeader("Authorization", "key=AAAASOggT80:APA91bEaHXHSX73eAPIsqwxWAHE9cWh8bvW18i7OoL-Uyci-7HV0ZpkolfBZU4Mt_Xe-mM21vK-rB7HHPeV-edaAcnTQKKoxWT2WZQ9w67pzx89ot68T0jt5sqCZ01gUlSb4sBICFv0n");

  int httpResponseCode = http.POST("{\"notification\": { \"title\": \"Medición CO2: " + (String) medicionCO2 + "\", \"body\": \"Alta concentración de CO2.\" }, \"to\": \"" + (String) tokenApp +"\"}");
}

void checkConfiguracionDB(){
  String sentencia = "SELECT * FROM TFG_ARDUINO.configuracion WHERE alumno = '" + conf_dni + "';";
  int str_len = sentencia.length() + 1; //Length (with one extra character for the null terminator)
  char INSERT_SQL[str_len];
  sentencia.toCharArray(INSERT_SQL, str_len);
  
  // Initiate the query class instance
  MySQL_Cursor *cur_mem = new MySQL_Cursor(&conn);
  // Execute the query
  cur_mem->execute(INSERT_SQL);

  Serial.println("MENSAJE DESDE checkConfiguracionDB");

  // Fetch the columns and print them
  column_names *cols = cur_mem->get_columns();
  // Read the rows and print them
  row_values *row = NULL;
  int co2_mid;
  int co2_max;
  int distancia;
  do {
    row = cur_mem->get_next_row();
    if (row != NULL) {
        co2_mid = (int)row->values[0];
        co2_max = (int)row->values[1];
        distancia = (int)row->values[2];
        if(conf_co2_mid != co2_mid || conf_co2_max != co2_max || conf_distance != distancia){
          modifyLimits(row->values[0], row->values[1], row->values[2]);
        }
    }
  } while (row != NULL);
  
  delete cur_mem; //Eliminar cursor para liberar memoria
}
void connectDB(){
  /// BASE DE DATOS
  int err = WiFi.hostByName(hostname_DB, server_addr);
  if(err == 1){
    Serial.println("Obteniendo IP del servidor...");
    Serial.print("Dirección IP: ");
    Serial.println(server_addr);
  } else {
    Serial.print("Error al obtener IP del servidor. Código de error: ");
    Serial.println(err);
  }
  Serial.println("Conectando DB...");
    if (conn.connect(server_addr, 1234, user, passwordDB)) {
      delay(1000);
    }
    else
      Serial.println("No se ha podido conectar DB.");
    //conn.close();
  ///
}
void createAccessPoint(){
  // Set these to your desired credentials.
  DynamicJsonDocument doc = readConFile();
  String dni = doc["dni"];
  String ssidap = "Arduino_" + dni;
  const char *ssidAP = ssidap.c_str();
  //const char *passwordAP = "abcd1234";
  WiFi.softAP(ssidAP);
  IPAddress myIP = WiFi.softAPIP();
  Serial.print("Dirección IP Punto de Acceso: ");
  Serial.println(myIP);
}
DynamicJsonDocument readConFile(){
  //Lectura fichero JSON
  File file = SPIFFS.open("/configuracion.json","r");
  
  DynamicJsonDocument doc(1024);                         //Memory pool
  DeserializationError error = deserializeJson(doc, file); //Parse message
  if(error){
    Serial.print(F("deserializeJson() failed: "));
    Serial.println(error.f_str());
    return doc;
  }
  file.close();
  return doc;
}
void writeConFile(DynamicJsonDocument doc){
  File file = SPIFFS.open("/configuracion.json", "w+");
  serializeJson(doc, file);
  file.close();
}
void connectWifi(){
  DynamicJsonDocument doc = readConFile();
  const char* ssid = doc["ssid"];
  const char* password = doc["password"];
  Serial.print("SSID: ");
  Serial.print(ssid);
  Serial.print(", PASSWORD: ");
  Serial.println(password);
  WiFi.begin(ssid, password);
  int intento = 0;
  while (WiFi.status() != WL_CONNECTED) {
    if (intento == 10){
      break;
    }
    delay(1000);
    Serial.println("Conectando WiFi..");
    intento++;
  }
}
void startDNS(){
  //Serial.println("Starting DNS Server");
  //dnsServer.start(53, "*", WiFi.softAPIP());
  DynamicJsonDocument doc = readConFile();
  String dni = doc["dni"];
  String hostname = "arduino_" + dni;
  Serial.print("HOSTNAME: ");
  Serial.println(hostname);
  //DNS
  if(!MDNS.begin(hostname.c_str())) {
     Serial.println("Error al iniciar mDNS");
     return;
  }
}

String scanWiFi(){
  //WiFi.mode(WIFI_STA);
  //WiFi.disconnect();
    //delay(100);
  Serial.println("Iniciando escaneo WiFi...");
  // WiFi.scanNetworks will return the number of networks found
    int n = WiFi.scanNetworks();
    String redes = "[";
    Serial.println("Escaneo finalizado.");
    if (n == 0) {
        Serial.println("No se han encontrado redes.");
    } else {
        Serial.print(n);
        Serial.println(" redes encontradas");
        for (int i = 0; i < n; ++i) {
          if(!(WiFi.SSID(i) == "")){
            if (!(i == 0)){
               redes = redes + ",";
            }
            redes = redes + '"' + WiFi.SSID(i) + '"';
            
          }
          
            // Print SSID and RSSI for each network found
            //Serial.print(i + 1);
            //Serial.print(": ");
            //Serial.print(WiFi.SSID(i));
            //Serial.print(" (");
            //Serial.print(WiFi.RSSI(i));
            //Serial.print(")");
            //Serial.println((WiFi.encryptionType(i) == WIFI_AUTH_OPEN)?" ":"*");
            //delay(10);
        }
        redes = redes + "]";
    }
    Serial.print("JSON completo:");
    Serial.println(redes);

    return redes;
    // Wait a bit before scanning again
    //delay(5000);
}
void setupServer(){
  // Route for root / web page
  server.on("/", HTTP_GET, [](AsyncWebServerRequest *request){
    request->send(SPIFFS, "/index.html", String(), false, lectura);
  });
  
  // Route to load style.css file
  server.on("/style.css", HTTP_GET, [](AsyncWebServerRequest *request){
    request->send(SPIFFS, "/style.css", "text/css");
  });

  server.on("/modifyWifi", HTTP_GET, [](AsyncWebServerRequest *request){
    String ssid;
    String password;
    if (request->hasParam("ssid")){
      ssid = request->getParam("ssid")->value();
    }
    else{
      ssid = "No se ha introducido SSID";
      Serial.println("No se ha introducido SSID");
    }
    if (request->hasParam("password")){
      password = request->getParam("password")->value();
    }
    else{
      password = "No se ha introducido contraseña";
    }

    //if(semaforo){
      //semaforo = false;
      do{
        if(semaforo){
          Serial.println("Bloqueo (/modifyWifi)");
          semaforo = false;
          
          modifyWifi(ssid, password);
          
          Serial.println("Libero (/modifiyWifi)");
          semaforo = true;
        }
        else{
          Serial.println("Me espero (/modifyWifi)");
          delay(100);
        }
      }while(!semaforo);
      //modifyWifi(ssid, password);
      //semaforo = true;
    //}
    request->redirect("http://arduino_" + conf_dni + "/");
    //request->send(SPIFFS, "/index.html", String(), false, lectura);
  });
  server.on("/modifyLimits", HTTP_GET, [](AsyncWebServerRequest *request){
    String co2_max;
    String co2_mid;
    String distance;
    if (request->hasParam("co2_max")){
      co2_max = request->getParam("co2_max")->value();
    }
    else{
      co2_max = "No se ha introducido CO2_MAX";
    }
    if (request->hasParam("co2_mid")){
      co2_mid = request->getParam("co2_mid")->value();
    }
    else{
      co2_mid = "No se ha introducido CO2_MID";
    }
    if (request->hasParam("distance")){
      distance = request->getParam("distance")->value();
    }
    else{
      distance = "No se ha introducido distancia";
    }
    modifyLimits(co2_mid, co2_max, distance);
    updateConfiguracionDB(co2_mid, co2_max, distance, conf_dni);
    request->redirect("http://arduino_" + conf_dni + "/");
    //request->send(SPIFFS, "/index.html", String(), false, lectura);
  });
  server.on("/iniciarSesion", HTTP_GET, [](AsyncWebServerRequest *request){
    String dni;
    String password;
    
    if (request->hasParam("dni")){
      dni = request->getParam("dni")->value();
    }
    if (request->hasParam("alu_password")){
      password = request->getParam("alu_password")->value();
    }
    
    //if(semaforo){
      //semaforo = false;
      do{
        if(semaforo){
          Serial.println("Bloqueo (/iniciarSesion)");
          semaforo = false;
          
          iniciarSesion(dni, password);
          
          Serial.println("Libero (/iniciarSesion)");
          semaforo = true;
        }
        else{
          Serial.println("Me espero (/iniciarSesion)");
          delay(100);
        }
      }while(!semaforo);
      //iniciarSesion(dni, password);
      //semaforo = true;
    //}
    delay(2000);
    request->redirect("http://arduino_" + conf_dni + "/");
    //request->send(SPIFFS, "/index.html", String(), false, lectura);
  });

  server.on("/cerrarSesion", HTTP_GET, [](AsyncWebServerRequest *request){

    //if(semaforo){
      //semaforo = false;
      do{
        if(semaforo){
          Serial.println("Bloqueo (/cerrarSesion)");
          semaforo = false;
          
          cerrarSesion();
          
          Serial.println("Libero (/cerrarSesion)");
          semaforo = true;
        }
        else{
          Serial.println("Me espero (/cerrarSesion)");
          delay(100);
        }
      }while(!semaforo);
      //cerrarSesion();
      //semaforo = true;
    //}
    delay(2000);
    request->redirect("http://arduino_" + conf_dni + "/");
    //request->send(SPIFFS, "/index.html", String(), false, lectura);
  });
  
  server.on("/scanWiFi", HTTP_GET, [](AsyncWebServerRequest *request){
    String redes = scanWiFi();
    request->send(200, "application/json", redes);
  });

  server.addHandler(new CaptiveRequestHandler()).setFilter(ON_AP_FILTER);//only when requested from AP
  // Start server
  server.begin();
}

void insertMedicionDB(int medicionCO2, int distancia, String alumno){
  
  String sentencia = "INSERT INTO TFG_ARDUINO.medicion (co2, fecha, alumno) VALUES ('" + (String) medicionCO2 + "', now(), '" + alumno + "');";
  int str_len = sentencia.length() + 1; //Length (with one extra character for the null terminator)
  char INSERT_SQL[str_len];
  sentencia.toCharArray(INSERT_SQL, str_len);

  Serial.println("MENSAJE DESDE insertMedicionDB");
  // Initiate the query class instance
  MySQL_Cursor *cur_mem = new MySQL_Cursor(&conn);
  // Execute the query
  cur_mem->execute(INSERT_SQL);

  sentencia = "INSERT INTO TFG_ARDUINO.conectado (fecha, alumno, co2, distancia) VALUES (now(), '" + alumno + "', '" + (String) medicionCO2 + "', '" + (String) distancia + "');";
  str_len = sentencia.length() + 1; //Length (with one extra character for the null terminator)
  INSERT_SQL[str_len];
  sentencia.toCharArray(INSERT_SQL, str_len);

  Serial.println("MENSAJE DESDE insertConectado");
  
  cur_mem->execute(INSERT_SQL);

  
  // Note: since there are no results, we do not need to read any data
  // Deleting the cursor also frees up memory used
  delete cur_mem;

}

void updateConfiguracionDB(String co2Low , String co2Max, String distancia, String alumno){
  
  String sentencia = "UPDATE TFG_ARDUINO.configuracion SET co2Low = '" + co2Low + "', co2Max = '" + co2Max + "', distancia = '" + distancia + "'  WHERE alumno = '" + alumno + "'";
  int str_len = sentencia.length() + 1; //Length (with one extra character for the null terminator)
  char INSERT_SQL[str_len];
  sentencia.toCharArray(INSERT_SQL, str_len);

  Serial.println("MENSAJE DESDE updateConfiguracionDB");
  
  // Initiate the query class instance
  MySQL_Cursor *cur_mem = new MySQL_Cursor(&conn);
  // Execute the query
  cur_mem->execute(INSERT_SQL);
  // Note: since there are no results, we do not need to read any data
  // Deleting the cursor also frees up memory used
  delete cur_mem;

}

void updateAlumnoDB(String dni, String nombre, String apellidos, String password, String conf_dni){
  String sentencia = "UPDATE TFG_ARDUINO.alumno SET dni = '" + dni + "', nombre = '" + nombre + "', apellidos = '" + apellidos + "', password = '" + password + "' WHERE dni = '" + conf_dni + "'";
  int str_len = sentencia.length() + 1; //Length (with one extra character for the null terminator)
  char UPDATE_SQL[str_len];
  sentencia.toCharArray(UPDATE_SQL, str_len);

  Serial.println("MENSAJE DESDE updateAlumnoDB");
  
  // Initiate the query class instance
  MySQL_Cursor *cur_mem = new MySQL_Cursor(&conn);
  // Execute the query
  cur_mem->execute(UPDATE_SQL);
  // Note: since there are no results, we do not need to read any data
  // Deleting the cursor also frees up memory used
  delete cur_mem;
}

void checkConnections( void * parameter){
  for(;;){
    boolean finalizado = false;
    do{
      if(conf_ssid != ""){
      if(semaforo){
        Serial.println("Bloqueo (CONNECTIONS)");
        semaforo = false;
        if (WiFi.status() != WL_CONNECTED) {
        Serial.println("Desconectado de la red WiFi. Intentando conectar...");
        connectWifi();
        }
        //Comprueba si esta conectado a la base de datos.
        if(conn.connected() == 0 && WiFi.status() == WL_CONNECTED){
          Serial.println("Desconectado de la DB. Intentando conectar...");
          connectDB();    
        }
        Serial.println("Libero (CONNECTIONS)");
        semaforo = true;
        finalizado = true;
      }
      else{
        Serial.println("Me espero (CONNECTIONS)");
        delay(100);}
    }
    }while(!semaforo && finalizado);
    delay(5000);
  }
}
