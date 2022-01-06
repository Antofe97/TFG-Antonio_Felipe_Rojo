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
import 'package:firebase_messaging/firebase_messaging.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({ Key? key }) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  final dniController = TextEditingController();
  final passwordController = TextEditingController();

  bool visible = true;
  Color colorToggle = Colors.grey;

  String? tokenApp;

  @override
  void initState() {
    super.initState();
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    messaging.getToken().then((value){
      tokenApp = value;
    });

    userLoged();

    
  }

  Future userLoged() async {
    final email = await UserSecureStorage.getEmail();
    final password = await UserSecureStorage.getPassword();

    

    if(email != null && password != null){
      dniController.text = email.toString();
      passwordController.text = password.toString();
      connectDB(context, email, password, tokenApp);
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
        value: const SystemUiOverlayStyle(statusBarColor: Colors.transparent, statusBarIconBrightness: Brightness.dark, systemStatusBarContrastEnforced: true, systemNavigationBarColor: Color(0xFF5967ff), ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 45.0, vertical: 50),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Image(image: AssetImage('assets/images/LogoUCLM.svg.png'), height: 130,),
            const Padding(padding: EdgeInsets.only(top: 10), child: Text('TFG ARDUINO', style: TextStyle(color: Color(0xFFabb5be), fontSize: 16,fontFamily: 'Quicksand', fontWeight: FontWeight.w700))),
            const Padding(padding: EdgeInsets.symmetric(vertical: 40), child: Text('Iniciar Sesión', style: TextStyle(color: Color(0xFF35424a), fontSize: 36.0, fontFamily: 'Quicksand', fontWeight: FontWeight.bold))),
            /*const Align(
              alignment: Alignment.centerLeft,
              child: Padding(padding: EdgeInsets.only(left: 5, bottom: 5),child: Text('DNI', style: TextStyle(color: Colors.white, fontSize: 16))),
            ),
            const CustomTextField(obscureText: false, hintText: 'Introduce tu DNI', prefixedIcon: Icon(Icons.person, color: Colors.white,),),*/
            
            TextField(
              controller: dniController,
              cursorColor: const Color(0xFF5967ff),
              style: const TextStyle(color: Color(0xFF5967ff)),
              decoration: const InputDecoration(
                filled: true,
                //fillColor: Color(0xFF5967ff),//Color(0xFF5180ff),
                hintText: 'Introducir DNI',
                prefixIcon: Icon(Icons.person, color: Color(0xFF5967ff)),
                enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Color(0xFF5967ff)), borderRadius: BorderRadius.all(Radius.circular(12))),
                //border: OutlineInputBorder(borderSide: BorderSide(color: Colors.red), borderRadius: BorderRadius.all(Radius.circular(12))),
                labelText: 'DNI',
                focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Color(0xFF5967ff), width: 2), borderRadius: BorderRadius.all(Radius.circular(12))),
                labelStyle: TextStyle(color: Color(0xFF5967ff), fontFamily: 'Quicksand', fontSize: 18, fontWeight: FontWeight.w600),
                hintStyle: TextStyle(color: Color(0xFF5967ff), fontFamily: 'Quicksand', fontWeight: FontWeight.w500),
                
                //border: InputBorder.none,

              ),
            ),
            /*const Align(
              alignment: Alignment.centerLeft,
              child: Padding(padding: EdgeInsets.only(left: 5, bottom: 5, top: 10),child: Text('Contraseña', style: TextStyle(fontSize: 15))),
            ),*/
            const Padding(padding: EdgeInsets.symmetric(vertical:17)),
            TextField(
              controller: passwordController,
              cursorColor: const Color(0xFF5967ff),
              style: const TextStyle(color: Color(0xFF5967ff)),
              obscureText: visible,
              decoration: InputDecoration(
                filled: true,
                //fillColor: Color(0xFF5967ff),//Color(0xFF5180ff),
                hintText: 'Introducir contraseña',
                prefixIcon: Icon(Icons.lock, color: Color(0xFF5967ff)),
                enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Color(0xFF5967ff)), borderRadius: BorderRadius.all(Radius.circular(12))),
                //border: OutlineInputBorder(borderSide: BorderSide(color: Colors.red), borderRadius: BorderRadius.all(Radius.circular(12))),
                labelText: 'Contraseña',
                focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Color(0xFF5967ff), width: 2), borderRadius: BorderRadius.all(Radius.circular(12))),
                labelStyle: TextStyle(color: Color(0xFF5967ff), fontFamily: 'Quicksand', fontSize: 18, fontWeight: FontWeight.w600),
                hintStyle: TextStyle(color: Color(0xFF5967ff), fontFamily: 'Quicksand', fontWeight: FontWeight.w500),
                //border: InputBorder.none,
                suffixIcon: IconButton(icon: visible ? Icon(Icons.visibility) : Icon(Icons.visibility_off), color: Color(0xFF5967ff), onPressed: () { setState((){visible = !visible;});},)
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
                const Color(0xFF5967ff),
                ),
                elevation: MaterialStateProperty.all(6),
                shape: MaterialStateProperty.all(
                  const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(
                    Radius.circular(12.0),
                    ),
                  ),
                ),
              ),
              onPressed: () {connectDB(context, dniController.text, passwordController.text, tokenApp);}, 
              child: const Padding(padding: EdgeInsets.symmetric(horizontal: 80, vertical:17), child: Text('Iniciar Sesión', style: TextStyle(fontSize: 17, color: Colors.white, fontFamily: 'Quicksand', fontWeight: FontWeight.bold)))
            ),
            const Padding(padding: EdgeInsets.symmetric(vertical:10)),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
              const Text('¿No tienes una cuenta?', style: TextStyle(fontSize: 16, color: Color(0xFFabb5be), fontFamily: 'Quicksand'),),
              const Padding(padding: EdgeInsets.symmetric(horizontal:2)),
              
              TextButton(onPressed: () { 
                Navigator.push(context, MaterialPageRoute(builder: (context) => SignUpScreen(),),);
              }, child: const Text('Crear Cuenta', style: TextStyle(fontSize: 17,color: Color(0xFF5967ff), fontFamily: 'Quicksand', fontWeight: FontWeight.bold),))
            ],)
            
            
            
          ],
        )
        
      ),
    )
    );
  }
}

Future connectDB(context, dni, password, tokenApp) async{
  
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

      await conn.query('UPDATE alumno SET token_app = ? WHERE dni = ?', [tokenApp, dni]);

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



