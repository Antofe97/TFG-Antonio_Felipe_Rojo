import 'package:flutter/material.dart';

class CustomTextField extends StatefulWidget {
  final bool obscureText;
  final Widget? prefixedIcon;
  final String? hintText;
  final String? labelText;
  final TextEditingController? controlador;
  
  const CustomTextField({ Key? key , required this.obscureText, this.prefixedIcon, this.hintText, this.labelText, this.controlador}) : super(key: key);

  @override
  _CustomTextFieldState createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {

  
  @override
  Widget build(BuildContext context) {
    return TextField(
              controller: widget.controlador,
              obscureText: widget.obscureText,
              cursorColor: Colors.white,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xFF5967ff),//Color(0xFF5180ff),
                hintText: widget.hintText,
                prefixIcon: widget.prefixedIcon,
                enabledBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.transparent), borderRadius: BorderRadius.all(Radius.circular(12))),
                //border: OutlineInputBorder(borderSide: BorderSide(color: Colors.red), borderRadius: BorderRadius.all(Radius.circular(12))),
                labelText: widget.labelText,
                focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.white, width: 2), borderRadius: BorderRadius.all(Radius.circular(12))),
                labelStyle: const TextStyle(color: Colors.white, fontSize: 18),
                hintStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.w300),
                
                //border: InputBorder.none,

              ),
            );
    /*return Material(
      color: Colors.transparent,
      elevation: 2,
      child: TextField(
        controller: widget.controlador,
        cursorColor: Colors.white,
        cursorWidth: 2,
        obscureText: widget.obscureText,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          border: InputBorder.none,
          filled: true,
          fillColor: Color(0xFF5180ff),
          prefixIcon: widget.prefixedIcon,
          hintText: widget.hintText,
          hintStyle: const TextStyle(
            color: Colors.white54,
            fontWeight: FontWeight.bold,
            //fontFamily: 'PT-Sans',
          ),
        ),
      ),
    );*/
  }
}