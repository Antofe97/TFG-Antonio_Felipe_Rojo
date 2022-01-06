
import 'package:flutter/material.dart';

Future<void> showMyDialog(context, title, text) async {
  return showDialog<void>(
    context: context,
    barrierDismissible: false, // user must tap button!
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(title, style: TextStyle(fontFamily: 'Quicksand')),
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              Text(text, style: TextStyle(fontFamily: 'Quicksand')),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: const Text('Cerrar', style: TextStyle(fontFamily: 'Quicksand')),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}

Future<void> showLoadingDialog(context, texto) async {
  return showDialog<void>(
    context: context,
    barrierDismissible: false, // user must tap button!
    builder: (BuildContext context) {
      return AlertDialog(
        content: Row(
        children: [
          const CircularProgressIndicator(color: Color(0xFF5967ff),),
          Container(margin: const EdgeInsets.only(left: 20),child: Text(texto, style: const TextStyle(fontFamily: 'Quicksand'),)),
        ],),
        
      );
    },
  );
}