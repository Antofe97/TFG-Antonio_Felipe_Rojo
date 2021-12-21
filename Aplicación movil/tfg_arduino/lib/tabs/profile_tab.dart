import 'package:flutter/material.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:tfg_arduino/main.dart';
import 'package:tfg_arduino/screens/login_screen.dart';
import 'package:tfg_arduino/utilities/user_secure_storage.dart';
import 'dart:async';
import 'dart:io';
import 'package:mysql1/mysql1.dart';
import 'package:tfg_arduino/utilities/alert_dialogs.dart';

class ProfileTab extends StatefulWidget {
  const ProfileTab({ Key? key }) : super(key: key);

  @override
  _ProfileTabState createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {

  late String _email;
  late String _password;


  final dniController = TextEditingController();
  final nombreController = TextEditingController();
  final apellidosController = TextEditingController();
  final passwordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final repNewPasswordController = TextEditingController();

  late Timer periodic;


  @override
  void initState(){
    super.initState();
    
    userLoged();
    obtenerPerfil();

  }

  Future userLoged() async {
    final email = await UserSecureStorage.getEmail();
    final password = await UserSecureStorage.getPassword();
    _email = email.toString();
    _password = password.toString();
  }

    Future obtenerPerfil() async {

    var settings = ConnectionSettings(
      host: 'tfgarduino.ddns.net', 
      port: 1234,
      user: 'arduino',
      password: 'Arduino.1234',
      db: 'TFG_ARDUINO'
    );

    try{
      var conn = await MySqlConnection.connect(settings);
      var results = await conn.query("SELECT * FROM alumno WHERE dni = ?", [_email]);

      dniController.text = results.first[0];
      nombreController.text = results.first[1];
      apellidosController.text = results.first[2];
        
      

    } on SocketException catch (e){
      print('Error caught: $e');
      //Navigator.pop(context);
      showMyDialog(context, 'No se ha podido conectar', 'Error al conectar con la base de datos. Vuelve a intentarlo mas tarde.');
      
    }

    //return medicion;

  }

  @override
  void dispose(){
    nombreController.dispose();
    apellidosController.dispose();
    dniController.dispose();

    
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: <Widget>[
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
              children: <Widget>[
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Datos alumno', style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold))
                ),
                Padding(padding: const EdgeInsets.symmetric(vertical: 10),  
                child: TextField(
              controller: dniController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'DNI'
              ),
            ),),
                Padding(padding: const EdgeInsets.symmetric(vertical: 10),  
                child: TextField(
              controller: nombreController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Nombre'
              ),
            ),),
                Padding(padding: const EdgeInsets.symmetric(vertical: 10), child: TextField(
              controller: apellidosController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Apellidos'
              )
            ),),
            ElevatedButton(
          onPressed: () { updatePerfil(dniController.text, nombreController.text, apellidosController.text); }, 
          child: const Text('Guardar')
          ),

              ],
            ),
          )),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
              children: <Widget>[
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Cambiar contraseña', style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold))
                ),
                Padding(padding: const EdgeInsets.symmetric(vertical: 10),  
                child: TextField(
              controller: passwordController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Contraseña actual'
              ),
            ),),
                Padding(padding: const EdgeInsets.symmetric(vertical: 10), child: TextField(
              controller: newPasswordController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Contraseña nueva'
              ),
            ),),
            Padding(padding: const EdgeInsets.symmetric(vertical: 10), child: TextField(
              controller: repNewPasswordController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Repetir contraseña nueva'
              ),
            ),),
            ElevatedButton(
          onPressed: () { 
            if(passwordController.text == "" || newPasswordController.text == "" || repNewPasswordController.text == ""){
              showMyDialog(context, 'Rellenar todos los campos', 'Uno o varios campos no han sido completados. Rellena todos los campos y vuelva a intentarlo.');
            } else if(passwordController.text != _password) {
              showMyDialog(context, 'Contraseña actual incorrecta', 'La contraseña actual introducida es incorrecta. Introduce la contraseña actual correcta y vuelve a intentarlo.');
            }
            else if(newPasswordController.text != repNewPasswordController.text){
              showMyDialog(context, 'Las contraseñas no coinciden', 'La contraseña y la confirmación no coinciden.');
            } else{
            updatePassword(newPasswordController.text); 
            }
            }, 
          child: const Text('Guardar')
          ),

              ],
            ),
          )),
          ElevatedButton(
          onPressed: () { _cerrarSesionDialog(); }, 
          child: const Text('Cerrar Sesión')
          ),
          TextButton(onPressed: () {eliminarPerfil();}, child: const Text('Eliminar cuenta', style: TextStyle(color: Colors.red),))
        ],
      ),
    );
    //return ElevatedButton(
    //  onPressed: () { _cerrarSesionDialog(); }, 
    //  child: const Text('Cerrar Sesión')
    //);
  }

  Future<bool> _cerrarSesionDialog() async {
    return (await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        //title: const Text(''),
        content: const Text('¿Seguro que quieres cerrar sesión?'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () => _cerrarSesion(context),
            child: const Text('Sí'),
          ),
        ],
      ),
  )) ?? false;
}
Future updatePerfil(dni, nombre, apellidos) async {
    var settings = ConnectionSettings(
      host: 'tfgarduino.ddns.net', 
      port: 1234,
      user: 'arduino',
      password: 'Arduino.1234',
      db: 'TFG_ARDUINO'
    );

    try{
      var conn = await MySqlConnection.connect(settings);
      await conn.query("UPDATE alumno SET dni = ?, nombre = ?, apellidos = ? WHERE dni = ?", [dni, nombre, apellidos,  _email]);
      await UserSecureStorage.setDNI(dni);

      const snackBar = SnackBar(
        content:  Text('Perfil actualizado correctamente'),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);

    } on SocketException catch (e){
      print('Error caught: $e');
      Navigator.pop(context);
      //showMyDialog(context, 'No se ha podido conectar', 'Error al conectar con la base de datos. Vuelve a intentarlo mas tarde');
      const snackBar =  SnackBar(
        content: Text('No se ha podido actualizar el perfil'),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }

  }

Future updatePassword(newPassword) async {
    var settings = ConnectionSettings(
      host: 'tfgarduino.ddns.net', 
      port: 1234,
      user: 'arduino',
      password: 'Arduino.1234',
      db: 'TFG_ARDUINO'
    );

    try{
      var conn = await MySqlConnection.connect(settings);
      await conn.query("UPDATE alumno SET password = ? WHERE dni = ?", [newPassword, _email]);
      await UserSecureStorage.setPassword(newPassword);

      const snackBar = SnackBar(
        content:  Text('Contraseña actualizada correctamente'),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);

    } on SocketException catch (e){
      print('Error caught: $e');
      Navigator.pop(context);
      //showMyDialog(context, 'No se ha podido conectar', 'Error al conectar con la base de datos. Vuelve a intentarlo mas tarde');
      const snackBar =  SnackBar(
        content: Text('No se ha podido actualizar la contraseña'),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }

  }

  Future eliminarPerfil() async {

    var settings = ConnectionSettings(
      host: 'tfgarduino.ddns.net', 
      port: 1234,
      user: 'arduino',
      password: 'Arduino.1234',
      db: 'TFG_ARDUINO'
    );

    try{
      var conn = await MySqlConnection.connect(settings);

      return (await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        //title: const Text(''),
        content: const Text('¿Seguro que quieres eliminar tu cuenta?'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () async {
              await conn.query("DELETE FROM alumno WHERE dni = ?", [_email]);
              _cerrarSesion(context);
              },
            child: const Text('Sí'),
          ),
        ],
      ),
  )) ?? false;

      
        
      

    } on SocketException catch (e){
      print('Error caught: $e');
      //Navigator.pop(context);
      showMyDialog(context, 'No se ha podido conectar', 'Error al conectar con la base de datos. Vuelve a intentarlo mas tarde');
      
    }

    //return medicion;

  }
}



void _cerrarSesion(context) async {
  await UserSecureStorage.deleteAll();
  Phoenix.rebirth(context);
  /*Navigator.pushReplacement(context,
    MaterialPageRoute<void>(
      builder: (context) {
        return const MyApp();
      },
    ),
  );*/
}