
import 'package:flutter/material.dart';

Future<void> showMyDialog(context, title, text) async {
  return showDialog<void>(
    context: context,
    barrierDismissible: false, // user must tap button!
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(title),
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              Text(text),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: const Text('Cerrar'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}

Future<void> showLoadingDialog(context) async {
  return showDialog<void>(
    context: context,
    barrierDismissible: false, // user must tap button!
    builder: (BuildContext context) {
      return AlertDialog(
        content: Row(
        children: [
          const CircularProgressIndicator(),
          Container(margin: const EdgeInsets.only(left: 20),child: const Text("Iniciando Sesión..." )),
        ],),
        
      );
    },
  );
}