import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tfg_arduino/utilities/alert_dialogs.dart';
import 'package:tfg_arduino/utilities/user_secure_storage.dart';
import 'package:mysql1/mysql1.dart';
import 'package:charts_flutter/flutter.dart' as charts;

class StatisticsTab extends StatefulWidget {
  const StatisticsTab({ Key? key }) : super(key: key);

  @override
  _StatisticsTabState createState() => _StatisticsTabState();
}

class _StatisticsTabState extends State<StatisticsTab> {

  
  //final emailController = TextEditingController();
  late String _email;
  late Future<List<StatisticsSeries>> _future;

  //List<StatisticsSeries> data = [];

  @override
  void initState() {
    super.initState();
    //userLoged();
    _future = userLoged();//obtenerMediciones(context, emailController.text);
    
  }

  Future<List<StatisticsSeries>> userLoged() async {
    final email = await UserSecureStorage.getEmail();
    _email = email.toString();
    return obtenerMediciones(context, email);
    
    //data = await obtenerMediciones(context, email.toString());//emailController.text);
    //return data;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
      child: Column(
      children: <Widget>[
        Card(
          child: Align( 
              alignment: Alignment.centerLeft,
              child: buildFutureBuilder(),//data//obtenerMediciones(context, emailController.text),
              
          )
        )
      ],
    )
    );
  }

  FutureBuilder<List<StatisticsSeries>> buildFutureBuilder() {
    return FutureBuilder<List<StatisticsSeries>>(
      builder: (context, AsyncSnapshot<List<StatisticsSeries>> snapshot) {
        // Devuelve el widget correspondiente aquí según el estado de la instantánea
       if (snapshot.hasData) {
        List<StatisticsSeries>? mediciones = snapshot.data;
        return RefreshIndicator(
          child: buildStatisticsChart(context, mediciones!),
          onRefresh: refresh);
        }
        else{
          return const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 182),
              child: CircularProgressIndicator(),
            )
          );
        }
      },
      future: _future,
    );
  }

  buildStatisticsChart(BuildContext context, List<StatisticsSeries> mediciones) {
    List<charts.Series<StatisticsSeries, int>> series = [
      charts.Series(
        id: "Mediciones",
        data: mediciones,
        domainFn: (StatisticsSeries series, _) => series.time.second,
        measureFn: (StatisticsSeries series, _) => series.cantidadCO2,
        colorFn: (StatisticsSeries series, _) => series.barColor
      )
    ];

    return Container(
      height: 400,
      //padding: const EdgeInsets.all(20),
      child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: <Widget>[
              const Text(
                "Cantidad de CO2 por día",
                //style: Theme.of(context).textTheme.bodyText2,
              ),
              Expanded(
                child: charts.LineChart(series, animate: true, behaviors: [charts.PanAndZoomBehavior()],),
              )
            ],
          ),
        ),
      
    );
  }

  
 
     // Actualizar los datos y restablecer el futuro
  Future refresh() async {
    setState(() {
      _future = obtenerMediciones(context, _email);
    });
  }


Future<List<StatisticsSeries>> obtenerMediciones(context, email) async {
  List<StatisticsSeries> data = [];

  var settings = ConnectionSettings(
    host: 'tfgarduino.ddns.net', 
    port: 1234,
    user: 'antonio',
    password: 'password',
    db: 'TFG_ARDUINO'
  );

  try{
    var conn = await MySqlConnection.connect(settings);
    var results = await conn.query("SELECT * FROM medicion WHERE alumno = ? AND fecha BETWEEN ? AND ?", [email, '2021-12-09 10:00:00', '2021-12-10 10:00:00']);
    for (var row in results) {
      data.add(StatisticsSeries(cantidadCO2: row[0], time: row[1], barColor: charts.ColorUtil.fromDartColor(Colors.blue)));
    }
    await conn.close();
    return data;
  } on SocketException catch (e){
    print('Error caught: $e');
    Navigator.pop(context);
    showMyDialog(context, 'No se ha podido conectar', 'Error al conectar con la base de datos. Vuelve a intentarlo mas tarde');
    
  }
  return data;
}


}

/*
class StatisticsChart extends StatefulWidget {

  final List<StatisticsSeries> mediciones;
  //const StatisticsChart(this.mediciones);
  const StatisticsChart({ Key? key, required this.mediciones }) : super(key: key);

  @override
  _StatisticsChartState createState() => _StatisticsChartState();
}

class _StatisticsChartState extends State<StatisticsChart> {
  @override
  void initState() {
    super.initState();
    print('PRINT DESDE _StatisticsChartState. IMPRIME widget.mediciones: ');
    print(widget.mediciones);
  }
  
  @override
  Widget build(BuildContext context) {
    List<charts.Series<StatisticsSeries, String>> series = [
      charts.Series(
        id: "Mediciones",
        data: widget.mediciones,
        domainFn: (StatisticsSeries series, _) => series.time.toString(),
        measureFn: (StatisticsSeries series, _) => series.cantidadCO2,
        colorFn: (StatisticsSeries series, _) => series.barColor
      )
    ];

    return Container(
      height: 400,
      padding: const EdgeInsets.all(20),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: <Widget>[
              const Text(
                "Cantidad de CO2 por día",
                //style: Theme.of(context).textTheme.bodyText2,
              ),
              Expanded(
                child: charts.BarChart(series, animate: true),
              )
            ],
          ),
        ),
      ),
    );
  }
}
*/
class StatisticsSeries {
  final int cantidadCO2;
  final DateTime time;
  final charts.Color barColor;

  StatisticsSeries(
    {
      required this.cantidadCO2,
      required this.time,
      required this.barColor
    }
  );
}