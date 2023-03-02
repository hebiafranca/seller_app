import 'package:flutter/material.dart';

class BotaoCustomizado extends StatelessWidget {

  final String texto;
  final Color corTexto;
  final VoidCallback onPressed;

  BotaoCustomizado({
    @required this.texto,
    this.corTexto = Colors.white,
    this.onPressed
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
       // primary:Color(0xff5cb85c),
        backgroundColor:Color(0xff5cb85c),
        foregroundColor: Colors.white, // foreground
        //foregroundColor: Colors.white, // foreground
      ),

      child: Text(
        this.texto,
        style: TextStyle(
            color: this.corTexto, fontSize: 20
        ),
      ),

      onPressed: this.onPressed,
    );
  }
}
