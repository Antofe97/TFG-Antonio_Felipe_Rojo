import 'package:flutter/material.dart';
import 'package:mysql1/mysql1.dart';
import 'package:tfg_arduino/tabs/arduino_tab.dart';
import 'package:tfg_arduino/tabs/profile_tab.dart';
import 'package:tfg_arduino/tabs/statistics_tab.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({ Key? key }) : super(key: key);

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {

  int _selectedIndex = 0;


  static const TextStyle optionStyle = TextStyle(fontSize: 30, fontWeight: FontWeight.bold);
  

  static const List<Widget> _widgetOptions = <Widget>[
    StatisticsTab(),
    ArduinoTab(),
    ProfileTab()
  ];

  static const List<Color> _colorOptions = [Color(0xFF5967ff), Color(0xFF5967ff), Color(0xFF5967ff)];
  static const List<Text> _titles = [Text('Estadísticas', style: TextStyle(fontFamily: 'QuickSand', fontWeight: FontWeight.bold)), Text('Arduino', style: TextStyle(fontFamily: 'QuickSand', fontWeight: FontWeight.bold)), Text('Perfil', style: TextStyle(fontFamily: 'QuickSand', fontWeight: FontWeight.bold))];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void dispose(){
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: _titles.elementAt(_selectedIndex),
          backgroundColor: _colorOptions.elementAt(_selectedIndex),
        ),
        body: Center(
          child: _widgetOptions.elementAt(_selectedIndex),
          ),
          bottomNavigationBar: BottomNavigationBar(
            type: BottomNavigationBarType.shifting,
            selectedLabelStyle: TextStyle(fontFamily: 'Quicksand', fontWeight: FontWeight.bold),
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(icon: Icon(Icons.show_chart_rounded, ), label: 'Estadísticas', backgroundColor: Color(0xFF5967ff), ),
              BottomNavigationBarItem(icon: Icon(Icons.developer_board, ), label: 'Arduino', backgroundColor: Color(0xFF5967ff),),
              BottomNavigationBarItem(icon: Icon(Icons.person, ), label: 'Perfil', backgroundColor: Color(0xFF5967ff),),
              ],
              currentIndex: _selectedIndex,
              selectedItemColor: Colors.white,
              unselectedItemColor: Colors.white54,
              onTap: _onItemTapped,
          ),
        )
    );
  }

  Future<bool> _onWillPop() async {
    return (await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        //title: const Text(''),
        content: const Text('¿Quieres cerrar la aplicación?', style: TextStyle(fontFamily: 'Quicksand')),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('No', style: TextStyle(fontFamily: 'Quicksand')),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Sí', style: TextStyle(fontFamily: 'Quicksand')),
          ),
        ],
      ),
    )) ?? false;
  }


  
}