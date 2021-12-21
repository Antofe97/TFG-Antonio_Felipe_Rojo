import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:tfg_arduino/utilities/alert_dialogs.dart';
import 'package:tfg_arduino/utilities/user_secure_storage.dart';
import 'package:tfg_arduino/utilities/date_time_picker.dart';
import 'package:mysql1/mysql1.dart';
import 'package:charts_flutter/flutter.dart' as charts;


//import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';

class StatisticsTab extends StatefulWidget {
  const StatisticsTab({ Key? key }) : super(key: key);

  @override
  _StatisticsTabState createState() => _StatisticsTabState();
}

class _StatisticsTabState extends State<StatisticsTab> {

  
  //final emailController = TextEditingController();
  late String _email;
  late Future<List<StatisticsSeries>> _future;

  //Estilos TextButtons Filtros
  List<bool> isSelected = List.generate(5, (index) => false);

  //Controller botones rango fechas
  late TextEditingController controllerFrom;
  
  late TextEditingController controllerUntil;

  late DateTime untilDate;
  late DateTime fromDate;

  int minimo = 0;
  int media = 0;
  int maximo = 0;

  //List<StatisticsSeries> data = [];

  @override
  void initState() {
    super.initState();
    //userLoged();
    untilDate = DateTime.now();
    fromDate = DateTime(untilDate.year, untilDate.month, untilDate.day, untilDate.hour - 1, untilDate.minute, untilDate.second);

    //Primer boton de los filtros seleccionado
    isSelected[0] = true;

    //Controller botones rango fechas
    controllerFrom = TextEditingController();
    controllerUntil = TextEditingController();

    controllerFrom.addListener(() {
      if(controllerFrom.text.isNotEmpty && controllerUntil.text.isNotEmpty){
        fromDate = DateTime.parse(controllerFrom.text);
        untilDate = DateTime.parse(controllerUntil.text);
        setState(() {
        _future = obtenerMediciones(context, _email, fromDate, untilDate);
        });
      }
    });
    controllerUntil.addListener(() {
      if(controllerFrom.text.isNotEmpty && controllerUntil.text.isNotEmpty){
        fromDate = DateTime.parse(controllerFrom.text);
        untilDate = DateTime.parse(controllerUntil.text);
        setState(() {
        _future = obtenerMediciones(context, _email, fromDate, untilDate);
        });
      }
    });


    _future = userLoged();//obtenerMediciones(context, emailController.text);
  }

  @override
  void dispose(){
    controllerFrom.removeListener(() { });
    controllerFrom.dispose();
    controllerUntil.removeListener(() { });
    controllerUntil.dispose();
    super.dispose();
  }

  Future<List<StatisticsSeries>> userLoged() async {
    final email = await UserSecureStorage.getEmail();
    _email = email.toString();
    return obtenerMediciones(context, email, fromDate, untilDate);
    
    //data = await obtenerMediciones(context, email.toString());//emailController.text);
    //return data;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
      children: <Widget>[
        Card(
          child: Align( 
              alignment: Alignment.centerLeft,
              child: buildFutureBuilder(),//data//obtenerMediciones(context, emailController.text),
              
          )
        ),
        /*Card(
          child: TextButton(
                onPressed: () {
                  DatePicker.showDateTimePicker(context, showTitleActions: true,
                      onChanged: (date) {
                    print('change $date in time zone ' +
                        date.timeZoneOffset.inHours.toString());
                  }, onConfirm: (date) {
                    print('confirm $date');
                  },
                      currentTime: DateTime(2008, 12, 31, 23, 12, 34),
                      locale: LocaleType.es);
                },
                child: const Text(
                  'show date time picker (Spanish)',
                  style: TextStyle(color: Colors.blue),
                )),
        ),*/
        Card(
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Column(
                children: <Widget>[
                  const Text('Minimo:'),
                  Text(minimo.toString(), style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold),)
                ],
              ),
              Container(
                width: 1,
                height: 45,
                color: Colors.grey,
              ),
              Column(
                children: <Widget>[
                  const Text('Media:'),
                  Text(media.toString(), style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold),)
                ],
              ),
              Container(
                width: 1,
                height: 45,
                color: Colors.grey,
              ),
              Column(
                children:  <Widget>[
                  const Text('Maximo:'),
                  Text(maximo.toString(), style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold),)
                ],
              )
            ],
          ),
          )
        ),
        Card(
          child: Column(
            children: <Widget>[
              //Row(
                //mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                //children: [
                ToggleButtons(children: const <Widget> [
                    Padding(padding: EdgeInsets.symmetric(horizontal: 23), child: Text('1H', style: TextStyle(fontSize: 20))),
                    Padding(padding: EdgeInsets.symmetric(horizontal: 23), child: Text('1D', style: TextStyle(fontSize: 20))),
                    Padding(padding: EdgeInsets.symmetric(horizontal: 23), child: Text('1S', style: TextStyle(fontSize: 20))),
                    Padding(padding: EdgeInsets.symmetric(horizontal: 23), child: Text('1M', style: TextStyle(fontSize: 20))),
                    Padding(padding: EdgeInsets.symmetric(horizontal: 23), child: Text('1A', style: TextStyle(fontSize: 20))),
                  ], 
                  onPressed: (int index) {
                    setState(() {
                      if(!isSelected[index]){
                        for (int buttonIndex = 0; buttonIndex < isSelected.length; buttonIndex++) {
                          if (buttonIndex == index) {
                            isSelected[buttonIndex] = !isSelected[buttonIndex];
                          } else {
                            isSelected[buttonIndex] = false;
                          }
                        }
                      }
                    });
                    refresh(index);
                  },
                  isSelected: isSelected,
                  color: Colors.grey,
                  selectedColor: Colors.blue,
                  renderBorder: false,
                  fillColor: Colors.white,
                  splashColor: Colors.white,
                  

                ),
                  
                //],
              //),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children:  <Widget>[
                    const Text('De'),
                    DateTimePicker(controller: controllerFrom),
                    const Text('A'),
                    DateTimePicker(controller: controllerUntil),
                  ],
                  ),
              )
            ],
          )
        )
      ],
    )
    );
  }

  

  FutureBuilder<List<StatisticsSeries>> buildFutureBuilder() {
    // EL _future = userLoged();,  TAMBIEN SE PUEDE PONER AQUI
    return FutureBuilder<List<StatisticsSeries>>(
      builder: (context, AsyncSnapshot<List<StatisticsSeries>> snapshot) {
        // Devuelve el widget correspondiente aquí según el estado de la instantánea
      if (snapshot.hasData) {
        List<StatisticsSeries>? mediciones = snapshot.data;
        return buildStatisticsChart(context, mediciones!);
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
    List<charts.Series<StatisticsSeries, DateTime>> series = [
      charts.Series(
        id: "Mediciones",
        data: mediciones,
        domainFn: (StatisticsSeries series, _) => series.time,
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
              /*const Text(
                "Cantidad de CO2 por día",
                //style: Theme.of(context).textTheme.bodyText2,
              ),*/
              Expanded(
                child: charts.TimeSeriesChart(series, animate: true, dateTimeFactory: const charts.LocalDateTimeFactory(),),//behaviors: [charts.PanAndZoomBehavior()],),
              )
            ],
          ),
        ),
      
    );
  }

  
 
     // Actualizar los datos y restablecer el futuro
  Future refresh(button) async {
    setState(() {
      untilDate = DateTime.now();
      if(button == 0){fromDate = DateTime(untilDate.year, untilDate.month, untilDate.day, untilDate.hour - 1, untilDate.minute, untilDate.second);}
      if(button == 1){fromDate = DateTime(untilDate.year, untilDate.month, untilDate.day - 1, untilDate.hour, untilDate.minute, untilDate.second);}
      if(button == 2){fromDate = DateTime(untilDate.year, untilDate.month, untilDate.day - 7, untilDate.hour, untilDate.minute, untilDate.second);}
      if(button == 3){fromDate = DateTime(untilDate.year, untilDate.month - 1, untilDate.day, untilDate.hour, untilDate.minute, untilDate.second);}
      if(button == 4){fromDate = DateTime(untilDate.year - 1, untilDate.month, untilDate.day, untilDate.hour, untilDate.minute, untilDate.second);}
      _future = obtenerMediciones(context, _email, fromDate, untilDate);
    });
  }


  Future<List<StatisticsSeries>> obtenerMediciones(context, email, fromDate, untilDate) async {
    List<StatisticsSeries> data = [];

    var settings = ConnectionSettings(
      host: 'tfgarduino.ddns.net', 
      port: 1234,
      user: 'arduino',
      password: 'Arduino.1234',
      db: 'TFG_ARDUINO'
    );
    int confLowCO2 = 0;
    int confHighCO2 = 0;
    try{
      print('SENTENCIA SQL');
      print(email);
      print(fromDate.toString());
      print(untilDate.toString());
      var conn = await MySqlConnection.connect(settings);
      //var results = await conn.query("SELECT * FROM medicion WHERE alumno = ? AND fecha BETWEEN ? AND ?", [email, fromDate.toString(), untilDate.toString()]);
      var configuracion = await conn.query("SELECT * FROM configuracion WHERE alumno = ?" , [email]);
      for (var row in configuracion){
        confLowCO2 = row[0];
        confHighCO2 = row[1];
      }
      var results;
      if(fromDate.difference(untilDate).inHours <= 1){
        results = await conn.query("SELECT ROUND(AVG(co2), 0) DIV 1, STR_TO_DATE(left(fecha, 16), '%Y-%m-%d %H:%i:%s') FROM medicion WHERE alumno = ? AND fecha BETWEEN ? AND ? GROUP BY STR_TO_DATE(left(fecha, 16), '%Y-%m-%d %H:%i:%s')", [email, fromDate.toString(), untilDate.toString()]);
      } else if(fromDate.difference(untilDate).inDays <= 1){
        results = await conn.query("SELECT ROUND(AVG(co2), 0) DIV 1, STR_TO_DATE(left(fecha, 15), '%Y-%m-%d %H:%i:%s') FROM medicion WHERE alumno = ? AND fecha BETWEEN ? AND ? GROUP BY STR_TO_DATE(left(fecha, 16), '%Y-%m-%d %H:%i:%s')", [email, fromDate.toString(), untilDate.toString()]);

      } else if(fromDate.difference(untilDate).inDays <= 7){
        results = await conn.query("SELECT ROUND(AVG(co2), 0) DIV 1, STR_TO_DATE(left(fecha, 14), '%Y-%m-%d %H:%i:%s') FROM medicion WHERE alumno = ? AND fecha BETWEEN ? AND ? GROUP BY STR_TO_DATE(left(fecha, 16), '%Y-%m-%d %H:%i:%s')", [email, fromDate.toString(), untilDate.toString()]);
      } else if(fromDate.difference(untilDate).inDays <= 30){
        results = await conn.query("SELECT ROUND(AVG(co2), 0) DIV 1, STR_TO_DATE(left(fecha, 13), '%Y-%m-%d %H:%i:%s') FROM medicion WHERE alumno = ? AND fecha BETWEEN ? AND ? GROUP BY STR_TO_DATE(left(fecha, 16), '%Y-%m-%d %H:%i:%s')", [email, fromDate.toString(), untilDate.toString()]);

      } else {
        results = await conn.query("SELECT ROUND(AVG(co2), 0) DIV 1, STR_TO_DATE(left(fecha, 12), '%Y-%m-%d %H:%i:%s') FROM medicion WHERE alumno = ? AND fecha BETWEEN ? AND ? GROUP BY STR_TO_DATE(left(fecha, 16), '%Y-%m-%d %H:%i:%s')", [email, fromDate.toString(), untilDate.toString()]);
      }
      //results = await conn.query("SELECT ROUND(AVG(co2), 0) DIV 1, STR_TO_DATE(left(fecha, 16), '%Y-%m-%d %H:%i:%s') FROM medicion WHERE alumno = ? AND fecha BETWEEN ? AND ? GROUP BY STR_TO_DATE(left(fecha, 16), '%Y-%m-%d %H:%i:%s')", [email, fromDate.toString(), untilDate.toString()]);
      print (results.length);
      if(results.isNotEmpty){
        minimo = results.first[0];
        media = 0;
        maximo = results.first[0];
      } else {
        minimo = 0;
        media = 0;
        maximo = 0;
      }
      for (var row in results) {
        if(row[0] < minimo){ minimo = row[0];}
        if(row[0] > maximo){ maximo = row[0];}
        media = media + row[0] as int;
        
        if(row[0] >= confHighCO2){data.add(StatisticsSeries(cantidadCO2: row[0], time: row[1], barColor: charts.ColorUtil.fromDartColor(Colors.red)));}
        else if (row[0] >= confLowCO2) {data.add(StatisticsSeries(cantidadCO2: row[0], time: row[1], barColor: charts.ColorUtil.fromDartColor(Colors.orange)));}
        else {data.add(StatisticsSeries(cantidadCO2: row[0], time: row[1], barColor: charts.ColorUtil.fromDartColor(Colors.blue)));}
        
      }
      if(results.isNotEmpty){
      media = (media/results.length).round();
      }
      await conn.close();
      setState(() {});
      return data;
    } on SocketException catch (e){
      print('Error caught: $e');
      //Navigator.pop(context);
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

