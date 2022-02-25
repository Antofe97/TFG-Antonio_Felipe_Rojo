import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:io';
import 'package:mysql1/mysql1.dart';

import 'package:tfg_arduino/utilities/alert_dialogs.dart';
import 'package:tfg_arduino/utilities/user_secure_storage.dart';
import 'package:tfg_arduino/utilities/custom_text_field.dart';

class ArduinoTab extends StatefulWidget {
  const ArduinoTab({Key? key}) : super(key: key);

  @override
  _ArduinoTabState createState() => _ArduinoTabState();
}

class _ArduinoTabState extends State<ArduinoTab> {
  int medicionEstado = 0;
  int distanciaEstado = 0;
  late String _email;

  late Timer periodic;

  final co2LowController = TextEditingController();
  final co2HighController = TextEditingController();
  final distanciaController = TextEditingController();

  Timer _debounce = Timer(Duration(milliseconds: 1000), () {});
  int _debounceTime = 1000;

  IconData? iconoEstadoCO2;
  Color? co2Color;
  String textoEstadoCO2 = "";

  IconData? iconoEstadoDistancia;
  Color? distanciaColor;
  String textoEstadoDistancia = "";

  late int co2Low;
  late int co2High;
  late int distancia;

  late Future _future;

  @override
  void initState() {
    super.initState();

    userLoged();
    _future = obtenerConfiguracion();

    const seconds = Duration(seconds: 3);
    periodic = Timer.periodic(
        seconds,
        (Timer t) => setState(() {
              _future = obtenerEstado();
            }));

    /*co2LowController.addListener(_onConfigurationChanged);
    co2HighController.addListener(_onConfigurationChanged);
    distanciaController.addListener(_onConfigurationChanged);*/
  }

  @override
  void dispose() {
    periodic.cancel();
    //co2LowController.removeListener(_onConfigurationChanged);
    co2LowController.dispose();
    //co2HighController.removeListener(_onConfigurationChanged);
    co2HighController.dispose();
    //distanciaController.removeListener(_onConfigurationChanged);
    distanciaController.dispose();

    super.dispose();
  }

  /*_onConfigurationChanged(){
    if (_debounce.isActive) {_debounce.cancel();}
    _debounce = Timer(Duration(milliseconds: _debounceTime), () {
      if (co2LowController.text != "" && co2HighController.text != "" && distanciaController.text != "") {
        updateConfiguracion(co2LowController.text, co2HighController.text, distanciaController.text);
      }
    });
  }*/

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
                  child: Padding(
                      padding: EdgeInsets.fromLTRB(20, 10, 10, 5),
                      child: Text('Estado',
                          style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Quicksand')))),
              buildFutureBuilder(),
            ],
          )),
          Card(
              child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: <Widget>[
                const Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Configuración',
                        style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Quicksand'))),
                Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: CustomTextField(
                      obscureText: false,
                      labelText: 'CO2 Medio',
                      controlador: co2LowController,
                    )),
                Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: CustomTextField(
                      obscureText: false,
                      labelText: 'CO2 Máximo',
                      controlador: co2HighController,
                    )),
                Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: CustomTextField(
                      obscureText: false,
                      labelText: 'Distancia',
                      controlador: distanciaController,
                    )),
                ElevatedButton(
                  onPressed: () {
                    updateConfiguracion(co2LowController.text,
                        co2HighController.text, distanciaController.text);
                  },
                  child: const Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 40, vertical: 10),
                      child: Text('Guardar',
                          style: TextStyle(
                              fontSize: 17,
                              color: Colors.white,
                              fontFamily: 'Quicksand',
                              fontWeight: FontWeight.bold))),
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(
                      const Color(0xFF5967ff),
                    ),
                    elevation: MaterialStateProperty.all(6),
                    shape: MaterialStateProperty.all(
                      const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(15.0),
                        ),
                      ),
                    ),
                  ),
                ),
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
        db: 'TFG_ARDUINO');

    try {
      var conn = await MySqlConnection.connect(settings);
      var check = await conn
          .query("SELECT * FROM conectado WHERE alumno = ?", [_email]);
      if (check.isNotEmpty) {
        //var results = await conn.query("SELECT * FROM medicion WHERE alumno = ? ORDER BY fecha DESC LIMIT 1", [_email]);
        medicionEstado = check.first[2];
        distanciaEstado = check.first[3];
        if (medicionEstado >= co2High) {
          iconoEstadoCO2 = Icons.dangerous_rounded;
          co2Color = Colors.red;
          textoEstadoCO2 = "Alta concentración de CO2";
        } else if (medicionEstado >= co2Low) {
          iconoEstadoCO2 = Icons.warning_rounded;
          co2Color = Colors.yellow;
          textoEstadoCO2 = "El aire se está cargando";
        } else {
          iconoEstadoCO2 = Icons.thumb_up_rounded;
          co2Color = Colors.green;
          textoEstadoCO2 = "Calidad del aire correcta";
        }
        if (distanciaEstado >= distancia) {
          iconoEstadoDistancia = Icons.thumb_up_alt_rounded;
          distanciaColor = Colors.green;
          textoEstadoDistancia = "Distancia correcta";
        } else {
          iconoEstadoDistancia = Icons.dangerous_rounded;
          distanciaColor = Colors.red;
          textoEstadoDistancia = "Demasiado cerca";
        }
        return check;
      }

      return false;
    } on SocketException catch (e) {
      print('Error caught: $e');
      //Navigator.pop(context);
      showMyDialog(context, 'No se ha podido conectar',
          'Error al conectar con la base de datos. Vuelve a intentarlo mas tarde');
    }

    //return medicion;
  }

  Future obtenerConfiguracion() async {
    var settings = ConnectionSettings(
        host: 'tfgarduino.ddns.net',
        port: 1234,
        user: 'arduino',
        password: 'Arduino.1234',
        db: 'TFG_ARDUINO');

    try {
      var conn = await MySqlConnection.connect(settings);
      var configuracion = await conn
          .query("SELECT * FROM configuracion WHERE alumno = ?", [_email]);

      co2LowController.text = configuracion.first[0].toString();
      co2HighController.text = configuracion.first[1].toString();
      distanciaController.text = configuracion.first[2].toString();

      co2Low = configuracion.first[0];
      co2High = configuracion.first[1];
      distancia = configuracion.first[2];
    } on SocketException catch (e) {
      print('Error caught: $e');
      Navigator.pop(context);
      showMyDialog(context, 'No se ha podido conectar',
          'Error al conectar con la base de datos. Vuelve a intentarlo mas tarde');
    }
  }

  Future updateConfiguracion(
      co2LowUpdate, co2HighUpdate, distanciaUpdate) async {
    var settings = ConnectionSettings(
        host: 'tfgarduino.ddns.net',
        port: 1234,
        user: 'arduino',
        password: 'Arduino.1234',
        db: 'TFG_ARDUINO');

    try {
      var conn = await MySqlConnection.connect(settings);
      await conn.query(
          "UPDATE configuracion SET co2Low = ?, co2Max = ?, distancia = ? WHERE alumno = ?",
          [co2LowUpdate, co2HighUpdate, distanciaUpdate, _email]);

      co2Low = int.parse(co2LowUpdate);
      co2High = int.parse(co2HighUpdate);
      distancia = int.parse(distanciaUpdate);

      const snackBar = SnackBar(
        content: Text('Configuración guardada correctamente'),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    } on SocketException catch (e) {
      print('Error caught: $e');
      Navigator.pop(context);
      //showMyDialog(context, 'No se ha podido conectar', 'Error al conectar con la base de datos. Vuelve a intentarlo mas tarde');
      const snackBar = SnackBar(
        content: Text('No se ha podido guardar la configuración'),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  FutureBuilder buildFutureBuilder() {
    // EL _future = userLoged();,  TAMBIEN SE PUEDE PONER AQUI
    return FutureBuilder(
      builder: (context, AsyncSnapshot snapshot) {
        // Devuelve el widget correspondiente aquí según el estado de la instantánea
        if (snapshot.hasData) {
          if (snapshot.data == false){
            return const Center(
              child: Padding(
            padding: EdgeInsets.symmetric(vertical: 70),
            child: Text("Arduino desconectada", style: TextStyle(color: Color(0xFFabb5be), fontSize: 16,fontFamily: 'Quicksand', fontWeight: FontWeight.w700),),
          ));
          } else{return buildEstado(context);}
        } else {
          return const Center(
              child: Padding(
            padding: EdgeInsets.symmetric(vertical: 62),
            child: CircularProgressIndicator(),
          ));
        }
      },
      future: _future,
    );
  }

  buildEstado(BuildContext context) {
    return Padding(
        padding: EdgeInsets.symmetric(vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Column(
              children: <Widget>[
                const Text('Cantidad CO2:',
                    style: TextStyle(
                        fontFamily: 'Quicksand',
                        fontSize: 20,
                        fontWeight: FontWeight.w400)),
                Text(
                  medicionEstado.toString(),
                  style: const TextStyle(
                      fontSize: 40, fontWeight: FontWeight.bold),
                ),
                Icon(
                  iconoEstadoCO2,
                  color: co2Color,
                  size: 50,
                ),
                Text(
                  textoEstadoCO2,
                  style: TextStyle(
                      fontFamily: 'Quicksand',
                      color: co2Color,
                      fontWeight: FontWeight.bold),
                )
              ],
            ),
            Container(
              width: 1,
              height: 80,
              color: Colors.grey,
            ),
            Column(
              children: <Widget>[
                const Text('Distancia:',
                    style: TextStyle(
                        fontFamily: 'Quicksand',
                        fontSize: 20,
                        fontWeight: FontWeight.w400)),
                Text(
                  distanciaEstado.toString(),
                  style: const TextStyle(
                      fontSize: 40, fontWeight: FontWeight.bold),
                ),
                Icon(
                  iconoEstadoDistancia,
                  color: distanciaColor,
                  size: 50,
                ),
                Text(
                  textoEstadoDistancia,
                  style: TextStyle(
                      fontFamily: 'Quicksand',
                      color: distanciaColor,
                      fontWeight: FontWeight.bold),
                )
              ],
            )
          ],
        ));
  }
}
