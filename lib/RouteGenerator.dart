
import 'package:seller_app/views/Canhotos.dart';
import 'package:seller_app/views/Entradas.dart';
import 'package:seller_app/views/Inicio.dart';
import 'package:seller_app/views/Login.dart';
import 'package:seller_app/views/NovaVenda.dart';
import 'package:seller_app/views/Vendas.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';


class RouteGenerator {

  static Route<dynamic> generateRoute(RouteSettings settings){

    final args = settings.arguments;

    switch( settings.name ){
      case "/inicio" :
        return MaterialPageRoute(
            builder: (_) => Inicio()
        );
      case "/login" :
        return MaterialPageRoute(
            builder: (_) => Login()
        );
      case "/entrada" :
        return MaterialPageRoute(
            builder: (_) => Entradas()
        );
      case "/vendas" :
        return MaterialPageRoute(
            builder: (_) => Vendas()
        );
      case "/nova-venda" :
        return MaterialPageRoute(
            builder: (_) => NovaVenda()
        );
      case "/canhoto" :
        return MaterialPageRoute(
            builder: (_) => Canhotos()
          //  builder: (_) => Comprovante()
        );
      default:
        _erroRota();
    }

  }

  static Route<dynamic> _erroRota(){

    return MaterialPageRoute(
        builder: (_){
          return Scaffold(
            appBar: AppBar(
              title: Text("Tela não encontrada!"),
            ),
            body: Center(
              child: Text("Tela não encontrada!"),
            ),
          );
        }
    );

  }

}