import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:tfg_arduino/utilities/alert_dialogs.dart';
import 'package:tfg_arduino/utilities/user_secure_storage.dart';
import 'package:mysql1/mysql1.dart';
import 'package:charts_flutter/flutter.dart' as charts;

import 'package:intl/intl.dart';

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


    _future = userLoged();//obtenerMediciones(context, emailController.text);
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(onPressed: () => {refresh(1)}, child: const Text('1H')),
                  TextButton(onPressed: () => {refresh(2)}, child: const Text('1D')),
                  TextButton(onPressed: () => {refresh(3)}, child: const Text('1S')),
                  TextButton(onPressed: () => {refresh(4)}, child: const Text('1M')),
                  TextButton(onPressed: () => {refresh(5)}, child: const Text('1A')),
                ],
              ),
              Row(
                children: <Widget>[
                  DateTimePicker(),
                ],
              ),
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
    List<charts.Series<StatisticsSeries, int>> series = [
      charts.Series(
        id: "Mediciones",
        data: mediciones,
        domainFn: (StatisticsSeries series, _) => series.time.day,
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
  Future refresh(button) async {
    setState(() {
      untilDate = DateTime.now();
      if(button == 1){fromDate = DateTime(untilDate.year, untilDate.month, untilDate.day, untilDate.hour - 1, untilDate.minute, untilDate.second);}
      if(button == 2){fromDate = DateTime(untilDate.year, untilDate.month, untilDate.day - 1, untilDate.hour, untilDate.minute, untilDate.second);}
      if(button == 3){fromDate = DateTime(untilDate.year, untilDate.month, untilDate.day - 7, untilDate.hour, untilDate.minute, untilDate.second);}
      if(button == 4){fromDate = DateTime(untilDate.year, untilDate.month - 1, untilDate.day, untilDate.hour, untilDate.minute, untilDate.second);}
      if(button == 5){fromDate = DateTime(untilDate.year - 1, untilDate.month, untilDate.day, untilDate.hour, untilDate.minute, untilDate.second);}
      _future = obtenerMediciones(context, _email, fromDate, untilDate);
    });
  }


Future<List<StatisticsSeries>> obtenerMediciones(context, email, fromDate, untilDate) async {
  List<StatisticsSeries> data = [];

  var settings = ConnectionSettings(
    host: 'tfgarduino.ddns.net', 
    port: 1234,
    user: 'antonio',
    password: 'password',
    db: 'TFG_ARDUINO'
  );

  try{
    print('SENTENCIA SQL');
    print(email);
    print(fromDate.toString());
    print(untilDate.toString());
    var conn = await MySqlConnection.connect(settings);
    var results = await conn.query("SELECT * FROM medicion WHERE alumno = ? AND fecha BETWEEN ? AND ?", [email, fromDate.toString(), untilDate.toString()]);
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
      data.add(StatisticsSeries(cantidadCO2: row[0], time: row[1], barColor: charts.ColorUtil.fromDartColor(Colors.blue)));
    }
    if(results.isNotEmpty){
    media = (media/results.length).round();
    }
    print(media);
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

class DateTimePicker extends StatefulWidget {
  const DateTimePicker({ Key? key }) : super(key: key);

  @override
  _DateTimePickerState createState() => _DateTimePickerState();
}

class _DateTimePickerState extends State<DateTimePicker> {
  DateTime dateTime = DateTime.now();

  Widget getText() {
    if (dateTime == null) {
      return const Text('Seleccionar Fecha');
    } else {
      return Text(DateFormat('dd/MM/yyyy HH:mm').format(dateTime));
    }
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () { pickDateTime(context); }, 
      child: getText()
    );
  }

  void pickDateTime(BuildContext context) async {
    final date = await pickDate(context);
    if (date == null) return;

    final time = await pickTime(context);
    if (time == null) return;
    
    setState(() {
      dateTime = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
  }

  //Future<DateTime> pickDate(BuildContext context) async {
  Future pickDate(BuildContext context) async {
    //final initialDate = DateTime.now();
    final newDate = await showDatePicker(
      context: context,
      locale: const Locale("es", "ES"),
      
      initialDate: dateTime,//??initialDate,
      firstDate: DateTime(DateTime.now().year - 5),
      lastDate: DateTime(DateTime.now().year + 5),
    );

    if (newDate == null) return null;

    return newDate;
  }

  Future pickTime(BuildContext context) async {
    //final initialTime = TimeOfDay.now();
    final newTime = await showTimePicker(
      context: context,
      builder: (context, child){
        return Localizations.override(
          context: context,
          locale: const Locale('es', 'ES'),
          child: child,
        );
      },
      initialTime: TimeOfDay(hour: dateTime.hour, minute: dateTime.minute)
    );

    if (newTime == null) return null;

    return newTime;
  }
}