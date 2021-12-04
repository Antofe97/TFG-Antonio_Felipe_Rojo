import 'package:flutter/material.dart';
import 'package:mysql1/mysql1.dart';
import 'package:tfg_arduino/tabs/profile_tab.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({ Key? key }) : super(key: key);

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {

  int _selectedIndex = 0;
  //Color topBarColor = Colors.red;

  static const TextStyle optionStyle = TextStyle(fontSize: 30, fontWeight: FontWeight.bold);

  static const List<Widget> _widgetOptions = <Widget>[
    //PrimeraPantalla(),
    //SegundaPantalla(),
    //profileScreen()
    Text(
      'Index 0: Estadisticas',
      style: optionStyle,
    ),
    Text(
      'Index 1: Arduino',
      style: optionStyle,
    ),
    ProfileTab()
  ];

  static const List<Color> _colorOptions = [Colors.red, Colors.green, Colors.blue];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(''),
          backgroundColor: _colorOptions.elementAt(_selectedIndex),
        ),
        body: Center(
          child: _widgetOptions.elementAt(_selectedIndex),
          ),
          bottomNavigationBar: BottomNavigationBar(
            type: BottomNavigationBarType.shifting,
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(icon: Icon(Icons.show_chart_rounded), label: 'Estadísticas', backgroundColor: Colors.red,),
              BottomNavigationBarItem(icon: Icon(Icons.developer_board), label: 'Arduino', backgroundColor: Colors.green,),
              BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil', backgroundColor: Colors.blue,),
              ],
              currentIndex: _selectedIndex,
              selectedItemColor: Colors.amber[800],
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
        content: const Text('¿Quieres cerrar la aplicación?'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Sí'),
          ),
        ],
      ),
    )) ?? false;
  }


  
}