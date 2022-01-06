import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:tfg_arduino/screens/login_screen.dart';
import 'package:tfg_arduino/utilities/custom_color.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
//import 'package:firebase_messaging/firebase_messaging.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(Phoenix(
    child: const MyApp()
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TFG_Arduino',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: MaterialColor(0xFF5967ff, color),
      ),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate
      ],
      supportedLocales: const [
        Locale('en'),
        Locale('es')
      ],
      home: const LoginScreen(),
    );
  }
}
