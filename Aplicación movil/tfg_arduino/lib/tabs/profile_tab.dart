import 'package:flutter/material.dart';
import 'package:tfg_arduino/main.dart';
import 'package:tfg_arduino/utilities/user_secure_storage.dart';

class ProfileTab extends StatefulWidget {
  const ProfileTab({ Key? key }) : super(key: key);

  @override
  _ProfileTabState createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () { _cerrarSesionDialog(); }, 
      child: const Text('Cerrar Sesión')
    );
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
}



void _cerrarSesion(context) async {
  await UserSecureStorage.deleteAll();
  Navigator.pushReplacement(context,
    MaterialPageRoute<void>(
      builder: (context) {
        return const MyApp();
      },
    ),
  );
}