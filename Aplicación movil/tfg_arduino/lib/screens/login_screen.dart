import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mysql1/mysql1.dart';
import 'package:tfg_arduino/screens/main_screen.dart';
import 'package:tfg_arduino/utilities/user_secure_storage.dart';


class LoginScreen extends StatefulWidget {
  const LoginScreen({ Key? key }) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  final dniController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    userLoged();
  }

  Future userLoged() async {
    final email = await UserSecureStorage.getEmail();
    final password = await UserSecureStorage.getPassword();
    if(email != null && password != null){
      connectDB(context, email, password);
    }
  }

  @override
  void dispose(){
    dniController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TFG Arduino')
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 35.0, vertical: 50),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Text('Iniciar Sesión', style: TextStyle(fontSize: 35.0, fontFamily: 'OpenSans')),
            const Padding(padding: EdgeInsets.only(top:15)),
            TextField(
              controller: dniController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Usuario'
              ),
            ),
            const Padding(padding: EdgeInsets.only(top:20)),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Contraseña'
              )
            ),
            const Padding(padding: EdgeInsets.only(top:20)),
            ElevatedButton(onPressed: () {connectDB(context, dniController.text, passwordController.text);}, child: const Text('Iniciar Sesión'))
            
          ],
        )
        
      ),
    );
  }
}

Future connectDB(context, dni, password) async{
  
  _showLoadingDialog(context);

  var settings = ConnectionSettings(
    host: 'tfgarduino.ddns.net', 
    port: 1234,
    user: 'antonio',
    password: 'password',
    db: 'TFG_ARDUINO'
  );


  try{
    var conn = await MySqlConnection.connect(settings);
  
    var results = await conn.query('SELECT * FROM alumno WHERE dni = ? AND password = ?', [dni, password]);

    if (results.isNotEmpty){
      Navigator.pop(context);
      await conn.close();
      await UserSecureStorage.setLoginParameters(dni, password);
      print('GUARDADOS PARAMETROS DE INICIO DE SESION');
      _logInApp(context);
    }
    else{
      Navigator.pop(context);
      await conn.close();
      _showDialog(context, 'No se ha podido iniciar sesión', 'El DNI introducido o la contraseña son incorrectas. Vuelve a intentarlo.');
    }
    /*for (var row in results) {
      print('DNI: ${row[0]}, Nombre: ${row[1]}, Apellidos: ${row[2]}, Contraseña: ${row[3]}');
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            // Retrieve the text the user has entered by using the
            // TextEditingController.
            content: Text('DNI: ${row[0]}, Nombre: ${row[1]}, Apellidos: ${row[2]}, Contraseña: ${row[3]}'),
          );
        },
      );
    }*/
    
    
  } on SocketException catch (e){
    print('Error caught: $e');
    Navigator.pop(context);
    _showDialog(context, 'No se ha podido conectar', 'Error al conectar con la base de datos. Vuelve a intentarlo mas tarde');
    
  }
}

void _logInApp(context) {
  Navigator.pushReplacement(context,
    MaterialPageRoute<void>(
      builder: (context) {
        return const MainScreen();
      },
    ),
  );
}

Future<void> _showDialog(context, title, text) async {
  return showDialog<void>(
    context: context,
    barrierDismissible: false, // user must tap button!
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(title),
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              Text(text),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: const Text('Cerrar'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}

Future<void> _showLoadingDialog(context) async {
  return showDialog<void>(
    context: context,
    barrierDismissible: false, // user must tap button!
    builder: (BuildContext context) {
      return AlertDialog(
        content: Row(
        children: [
          const CircularProgressIndicator(),
          Container(margin: const EdgeInsets.only(left: 20),child: const Text("Iniciando Sesión..." )),
        ],),
        
      );
    },
  );
}