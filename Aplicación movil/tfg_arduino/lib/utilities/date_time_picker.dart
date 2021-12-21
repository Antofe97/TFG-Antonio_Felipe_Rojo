import 'package:flutter/material.dart';
import 'package:intl/intl.dart';


class DateTimePicker extends StatefulWidget {

  final TextEditingController controller;
  const DateTimePicker({ Key? key, required this.controller}) : super(key: key);

  @override
  _DateTimePickerState createState() => _DateTimePickerState();
}

class _DateTimePickerState extends State<DateTimePicker> {

  DateTime dateTime = DateTime.now();
  bool dateSelected = false;
  late TextEditingController controller;

  @override
  void initState() {
    super.initState();
    controller = widget.controller;
  }
  
  Widget getText() {
    if (!dateSelected) {
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
    if (date == null){
      setState(() {dateSelected = false;});
      return;
    }

    final time = await pickTime(context);
    if (time == null){
      setState(() {dateSelected = false;});
      return;
    }
    
    setState(() {
      dateSelected = true;
      dateTime = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
      
      controller.text = DateFormat('yyyy-MM-dd HH:mm:ss').format(dateTime);
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