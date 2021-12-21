import 'dart:io';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:mysql1/mysql1.dart';
import 'package:tfg_arduino/components/custom_text_field.dart';
import 'package:tfg_arduino/screens/main_screen.dart';
import 'package:tfg_arduino/screens/signup_screen.dart';
import 'package:tfg_arduino/utilities/user_secure_storage.dart';
import 'package:tfg_arduino/utilities/alert_dialogs.dart';

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
      dniController.text = email.toString();
      passwordController.text = password.toString();
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
      //appBar: AppBar(
        //title: const Text('TFG Arduino')
      //),
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle(statusBarColor: Colors.transparent),
      child: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF5967ff),
                Color(0xFF5374ff),
                Color(0xFF5180ff),
                Color(0xFF538bff),
                Color(0xFF5995ff),
              ],
            ),
          ),
        //color: const Color(0xff5a9bef),
        child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 45.0, vertical: 50),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Padding(padding: EdgeInsets.symmetric(vertical: 40), child: Text('Iniciar Sesión', style: TextStyle(color: Colors.white, fontSize: 35.0, fontFamily: 'OpenSans'))),
            /*const Align(
              alignment: Alignment.centerLeft,
              child: Padding(padding: EdgeInsets.only(left: 5, bottom: 5),child: Text('DNI', style: TextStyle(color: Colors.white, fontSize: 16))),
            ),
            const CustomTextField(obscureText: false, hintText: 'Introduce tu DNI', prefixedIcon: Icon(Icons.person, color: Colors.white,),),*/
            
            TextField(
              controller: dniController,
              cursorColor: Colors.white,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                filled: true,
                fillColor: Color(0xFF5967ff),//Color(0xFF5180ff),
                hintText: 'Introducir DNI',
                prefixIcon: Icon(Icons.person, color: Colors.white),
                enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.transparent), borderRadius: BorderRadius.all(Radius.circular(12))),
                //border: OutlineInputBorder(borderSide: BorderSide(color: Colors.red), borderRadius: BorderRadius.all(Radius.circular(12))),
                labelText: 'DNI',
                focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white, width: 2), borderRadius: BorderRadius.all(Radius.circular(12))),
                labelStyle: TextStyle(color: Colors.white, fontSize: 18),
                hintStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.w300),
                
                //border: InputBorder.none,

              ),
            ),
            /*const Align(
              alignment: Alignment.centerLeft,
              child: Padding(padding: EdgeInsets.only(left: 5, bottom: 5, top: 10),child: Text('Contraseña', style: TextStyle(fontSize: 15))),
            ),*/

            const Padding(padding: EdgeInsets.symmetric(vertical:20)),
            TextField(
              controller: passwordController,
              cursorColor: Colors.white,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                filled: true,
                fillColor: Color(0xFF5967ff),//Color(0xFF5180ff),
                hintText: 'Introducir contraseña',
                prefixIcon: Icon(Icons.lock, color: Colors.white),
                enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.transparent), borderRadius: BorderRadius.all(Radius.circular(12))),
                //border: OutlineInputBorder(borderSide: BorderSide(color: Colors.red), borderRadius: BorderRadius.all(Radius.circular(12))),
                labelText: 'Contraseña',
                focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white, width: 2), borderRadius: BorderRadius.all(Radius.circular(12))),
                labelStyle: TextStyle(color: Colors.white, fontSize: 18),
                hintStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.w300)
                //border: InputBorder.none,

              ),
            ),
            /*TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Contraseña'
              )
            ),*/
            const Padding(padding: EdgeInsets.symmetric(vertical:20)),
            ElevatedButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(
                Colors.white,
                ),
                elevation: MaterialStateProperty.all(6),
                shape: MaterialStateProperty.all(
                  const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(
                    Radius.circular(18.0),
                    ),
                  ),
                ),
              ),
              onPressed: () {connectDB(context, dniController.text, passwordController.text);}, 
              child: const Padding(padding: EdgeInsets.symmetric(horizontal: 80, vertical:10), child: Text('Iniciar Sesión', style: TextStyle(fontSize: 16, color: Colors.blue, fontWeight: FontWeight.w400)))
            ),
            const Padding(padding: EdgeInsets.symmetric(vertical:10)),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
              const Text('¿No tienes una cuenta?', style: TextStyle(color: Colors.white),),
              const Padding(padding: EdgeInsets.symmetric(horizontal:2)),
              
              TextButton(onPressed: () { 
                Navigator.push(context, MaterialPageRoute(builder: (context) => SignUpScreen(),),);
              }, child: const Text('Crear Cuenta', style: TextStyle(fontSize: 17,color: Colors.white, fontWeight: FontWeight.bold),))
            ],)
            
            
            
          ],
        )
        
      ),
        )
    )
    );
  }
}

Future connectDB(context, dni, password) async{
  
  showLoadingDialog(context, "Iniciando Sesión...");

  var settings = ConnectionSettings(
    host: 'tfgarduino.ddns.net', 
    port: 1234,
    user: 'arduino',
    password: 'Arduino.1234',
    db: 'TFG_ARDUINO'
  );


  try{
    var conn = await MySqlConnection.connect(settings);
  
    var results = await conn.query('SELECT * FROM alumno WHERE dni = ? AND password = ?', [dni, password]);

    if (results.isNotEmpty){
      Navigator.pop(context);
      await conn.close();
      await UserSecureStorage.setLoginParameters(dni, password);
      _logInApp(context);
    }
    else{
      Navigator.pop(context);
      await conn.close();
      showMyDialog(context, 'No se ha podido iniciar sesión', 'El DNI introducido o la contraseña son incorrectas. Vuelve a intentarlo.');
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
    showMyDialog(context, 'No se ha podido conectar', 'Error al conectar con la base de datos. Vuelve a intentarlo mas tarde.');
    
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



