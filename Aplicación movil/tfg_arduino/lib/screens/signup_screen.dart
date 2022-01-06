import 'package:flutter/material.dart';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:tfg_arduino/components/custom_text_field.dart';
import 'package:tfg_arduino/utilities/alert_dialogs.dart';
import 'package:tfg_arduino/utilities/user_secure_storage.dart';
import 'package:mysql1/mysql1.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class SignUpScreen extends StatelessWidget {
  SignUpScreen({ Key? key }) : super(key: key);

  final dniController = TextEditingController();
  final nombreController = TextEditingController();
  final apellidosController = TextEditingController();
  final passwordController = TextEditingController();
  final passwordConfirmationController = TextEditingController();

  RegExp nifRegExp = RegExp(r'([0-9]{8}[TRWAGMYFPDXBNJZSQVHLCKE])$');
  //RegExp nieRegExp = RegExp(r'([XYZ][0-9]{7}[TRWAGMYFPDXBNJZSQVHLCKE])$');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF35424a)),
      ),
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: const SystemUiOverlayStyle(statusBarColor: Colors.transparent, statusBarIconBrightness: Brightness.dark),
        child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 45.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            
            const Padding(padding: EdgeInsets.only(top: 10, bottom: 40), child: Text('Crear Cuenta', style: TextStyle(color: Color(0xFF35424a), fontSize: 36.0, fontFamily: 'Quicksand', fontWeight: FontWeight.bold))),
            
            CustomTextField(obscureText: false,hintText: 'Introducir DNI', labelText: 'DNI', prefixedIcon: Icon(Icons.credit_card, color: Color(0xFF5967ff)), controlador: dniController,),
          

            const Padding(padding: EdgeInsets.symmetric(vertical:10)),
            CustomTextField(obscureText: false, labelText: 'Nombre', hintText: 'Introducir Nombre', controlador: nombreController, prefixedIcon: Icon(Icons.person, color: Color(0xFF5967ff)),),
            
            const Padding(padding: EdgeInsets.symmetric(vertical:10)),
            CustomTextField(obscureText: false, labelText: 'Apellidos', hintText: 'Introducir Apellidos', controlador: apellidosController, prefixedIcon: Icon(Icons.person, color: Color(0xFF5967ff))),

            const Padding(padding: EdgeInsets.symmetric(vertical:10)),
            Container(width: 150, height: 1, color: Color(0xFF5967ff),),

            const Padding(padding: EdgeInsets.symmetric(vertical:10)),
            CustomTextField(obscureText: true, labelText: 'Contraseña', hintText: 'Introducir Contraseña', controlador: passwordController, prefixedIcon: Icon(Icons.lock, color: Color(0xFF5967ff),)),

            const Padding(padding: EdgeInsets.symmetric(vertical:10)),
            CustomTextField(obscureText: true, labelText: 'Confirmar Contraseña', hintText: 'Vuelve a introducir la contraseña', controlador: passwordConfirmationController, prefixedIcon: Icon(Icons.lock, color: Color(0xFF5967ff)),),
           
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
                    Radius.circular(18.0),
                    ),
                  ),
                ),
              ),
              onPressed: () { 
                print("NIF");
                print(dniController.text);
                  print(nifRegExp.hasMatch(dniController.text));
                  //print("NIE");
                  //print(nieRegExp.hasMatch(dniController.text));
                if(dniController.text == "" || nombreController.text == "" || apellidosController.text == "" || passwordController.text == "" || passwordConfirmationController.text == ""){
                  showMyDialog(context, 'Rellenar todos los campos', 'Uno o varios campos no han sido completados. Rellena todos los campos y vuelva a intentarlo.');
                } else if(!nifRegExp.hasMatch(dniController.text)){ //|| !nieRegExp.hasMatch(dniController.text)){
                  
                  showMyDialog(context, 'Formato DNI incorrecto', 'Introduce un formato de DNI correcto.');
                } else if(passwordController.text != passwordConfirmationController.text){
                  showMyDialog(context, 'Las contraseñas no coinciden', 'La contraseña y la confirmación no coinciden.');
                } else{
                  crearCuenta(context);
                }
                }, 
              child: const Padding(padding: EdgeInsets.symmetric(horizontal: 80, vertical:17), child: Text('Crear Cuenta', style: TextStyle(fontSize: 17, color: Colors.white, fontFamily: 'Quicksand', fontWeight: FontWeight.bold)))
            ),
            const Padding(padding: EdgeInsets.symmetric(vertical:10)),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
              const Text('¿Ya tienes una cuenta?', style: TextStyle(fontSize: 16, color: Color(0xFFabb5be), fontFamily: 'Quicksand'),),
              const Padding(padding: EdgeInsets.symmetric(horizontal:2)),
              
              TextButton(onPressed: () { 
                Navigator.pop(context);
              }, child: const Text('Inicia Sesión', style: TextStyle(fontSize: 17,color: Color(0xFF5967ff), fontFamily: 'Quicksand', fontWeight: FontWeight.bold),))
            ],)
            
            
            
          ],
        )
        
      ),

    )
    );
  }

  Future crearCuenta(context) async{
    
    showLoadingDialog(context, "Creando cuenta...");

    var settings = ConnectionSettings(
      host: 'tfgarduino.ddns.net', 
      port: 1234,
      user: 'arduino',
      password: 'Arduino.1234',
      db: 'TFG_ARDUINO'
    );

    String? tokenApp;

    FirebaseMessaging messaging = FirebaseMessaging.instance;

    messaging.getToken().then((value){
      tokenApp = value;
    });

    /*FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      // Parse the message received
        print("NOTIFICACION");
        print(message.notification?.title);
        print(message.notification?.body);
    });^*/

    try{
      var conn = await MySqlConnection.connect(settings);
    
      await conn.query('INSERT INTO TFG_ARDUINO.alumno (dni, nombre, apellidos, password, token_app) VALUES (?,?,?,?,?);', [dniController.text, nombreController.text, apellidosController.text, passwordController.text, tokenApp]);
      await conn.query('INSERT INTO TFG_ARDUINO.configuracion (co2Low, co2Max, distancia, alumno) VALUES (?,?,?,?);', [600, 1400, 140, dniController.text]);

      var cuenta = await conn.query('SELECT * FROM alumno WHERE dni = ?;', [dniController.text]);

      if (cuenta.isNotEmpty){
        Navigator.pop(context);
        await conn.close();
        await UserSecureStorage.setLoginParameters(dniController.text, passwordController.text);
        
        Phoenix.rebirth(context);
      }
      else{
        Navigator.pop(context);
        await conn.close();
        showMyDialog(context, 'No se ha creado la cuenta', 'El DNI introducido o la contraseña son incorrectas. Vuelve a intentarlo.');
      }
      
      
    } on SocketException catch (e){
      print('Error caught: $e');
      Navigator.pop(context);
      showMyDialog(context, 'No se ha podido conectar', 'Error al conectar con la base de datos. Vuelve a intentarlo mas tarde.');
      
    }
  }
}