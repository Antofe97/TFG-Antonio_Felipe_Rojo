import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:io';
import 'package:mysql1/mysql1.dart';

import 'package:tfg_arduino/utilities/alert_dialogs.dart';
import 'package:tfg_arduino/utilities/user_secure_storage.dart';

class ArduinoTab extends StatefulWidget {
  const ArduinoTab({ Key? key }) : super(key: key);

  @override
  _ArduinoTabState createState() => _ArduinoTabState();
}

class _ArduinoTabState extends State<ArduinoTab> {

  int medicion = 0;
  late String _email;

  late Timer periodic;

  final co2LowController = TextEditingController();
  final co2HighController = TextEditingController();
  final distanciaController = TextEditingController();

  Timer _debounce = Timer(Duration(milliseconds: 1000), () { });
  int _debounceTime = 1000;

  @override
  void initState(){
    super.initState();
    const seconds = Duration(seconds: 3);
    periodic = Timer.periodic(seconds, (Timer t) => setState((){obtenerEstado();}));
    userLoged();
    obtenerConfiguracion();

    co2LowController.addListener(_onConfigurationChanged);
    co2HighController.addListener(_onConfigurationChanged);
    distanciaController.addListener(_onConfigurationChanged);
  }

  @override
  void dispose(){
    periodic.cancel();
    co2LowController.removeListener(_onConfigurationChanged);
    co2LowController.dispose();
    co2HighController.removeListener(_onConfigurationChanged);
    co2HighController.dispose();
    distanciaController.removeListener(_onConfigurationChanged);
    distanciaController.dispose();

    
    super.dispose();
  }

  _onConfigurationChanged(){
    if (_debounce.isActive) {_debounce.cancel();}
    _debounce = Timer(Duration(milliseconds: _debounceTime), () {
      if (co2LowController.text != "" && co2HighController.text != "" && distanciaController.text != "") {
        updateConfiguracion(co2LowController.text, co2HighController.text, distanciaController.text);
      }
    });
  }

  Future userLoged() async {
    final email = await UserSecureStorage.getEmail();
    _email = email.toString();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: <Widget>[
          Card(
            child: Column(
              children: <Widget>[
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(padding: EdgeInsets.fromLTRB(20, 10, 10, 5), child: Text('Estado', style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold)))
                ),
                Padding(padding: EdgeInsets.symmetric(vertical: 10),
                 child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Column(
                      children: <Widget>[
                      const Text('Cantidad CO2:'),
                      Text(medicion.toString(), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),)
                      ],
                    ),
                    Container(
                      width: 1,
                      height: 45,
                      color: Colors.grey,
                    ),
                    Column(
                      children: <Widget>[
                      const Text('Distancia:'),
                      Text(medicion.toString(), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),)
                      ],
                    )
                  ],
                )
                )
              ],
            )
            
          ),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
              children: <Widget>[
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Configuración', style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold))
                ),
                Padding(padding: const EdgeInsets.symmetric(vertical: 10),  
                child: TextField(
              controller: co2LowController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'CO2 Medio'
              ),
            ),),
                Padding(padding: const EdgeInsets.symmetric(vertical: 10), child: TextField(
              controller: co2HighController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'CO2 Máximo'
              )
            ),),
                Padding(padding: const EdgeInsets.symmetric(vertical: 10), child: TextField(
              controller: distanciaController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Distancia'
              )
            ),)
              ],
            ),
          ))
        ],
      ),
    );
  }

  Future obtenerEstado() async {

    var settings = ConnectionSettings(
      host: 'tfgarduino.ddns.net', 
      port: 1234,
      user: 'arduino',
      password: 'Arduino.1234',
      db: 'TFG_ARDUINO'
    );

    try{
      var conn = await MySqlConnection.connect(settings);
      var check = await conn.query("SELECT * FROM conectado WHERE alumno = ?", [_email]);
      if(check.isNotEmpty){
        var results = await conn.query("SELECT * FROM medicion WHERE alumno = ? ORDER BY fecha DESC LIMIT 1", [_email]);
        medicion = results.first[0];
        
      }

    } on SocketException catch (e){
      print('Error caught: $e');
      //Navigator.pop(context);
      showMyDialog(context, 'No se ha podido conectar', 'Error al conectar con la base de datos. Vuelve a intentarlo mas tarde');
      
    }

    //return medicion;

  }

  Future obtenerConfiguracion() async {
    var settings = ConnectionSettings(
      host: 'tfgarduino.ddns.net', 
      port: 1234,
      user: 'arduino',
      password: 'Arduino.1234',
      db: 'TFG_ARDUINO'
    );

    try{
      var conn = await MySqlConnection.connect(settings);
      var configuracion = await conn.query("SELECT * FROM configuracion WHERE alumno = ?", [_email]);
      
      co2LowController.text = configuracion.first[0].toString();
      co2HighController.text = configuracion.first[1].toString();
      distanciaController.text = configuracion.first[2].toString();

    } on SocketException catch (e){
      print('Error caught: $e');
      Navigator.pop(context);
      showMyDialog(context, 'No se ha podido conectar', 'Error al conectar con la base de datos. Vuelve a intentarlo mas tarde');
      
    }

  }

  Future updateConfiguracion(co2Low, co2High, distancia) async {
    var settings = ConnectionSettings(
      host: 'tfgarduino.ddns.net', 
      port: 1234,
      user: 'arduino',
      password: 'Arduino.1234',
      db: 'TFG_ARDUINO'
    );

    try{
      var conn = await MySqlConnection.connect(settings);
      await conn.query("UPDATE configuracion SET co2Low = ?, co2Max = ?, distancia = ? WHERE alumno = ?", [co2Low, co2High, distancia, _email]);
      
      const snackBar = SnackBar(
        content:  Text('Configuración guardada correctamente'),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);

    } on SocketException catch (e){
      print('Error caught: $e');
      Navigator.pop(context);
      //showMyDialog(context, 'No se ha podido conectar', 'Error al conectar con la base de datos. Vuelve a intentarlo mas tarde');
      const snackBar =  SnackBar(
        content: Text('No se ha podido guardar la configuración'),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }

  }

}