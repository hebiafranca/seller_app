import 'dart:async';

import 'package:seller_app/service/HttpServiceSincroniza.dart';
import 'package:seller_app/service/HttpServiceVenda.dart';
import 'package:seller_app/views/Canhotos.dart';

import 'package:seller_app/views/Entradas.dart';
import 'package:seller_app/views/Vendas.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

  class Inicio extends StatefulWidget {
   @override
   _InicioState createState() => _InicioState();
 }

 class _InicioState extends State<Inicio>  with SingleTickerProviderStateMixin{//SingleTickerProviderStateMixin {

   TabController _tabController;
   bool isOffline =false;
   bool isAtualiza=false;
//   AnimationController _animationController;
   bool visible =false;
   String passo="";

   _setMensagem(BuildContext context,String mensagem,bool success){
     final snackbar = SnackBar(
       backgroundColor: success ? Colors.green : Colors.red,
       duration: Duration(seconds: 3),
       content: Text(mensagem),
     );
  //   Scaffold.of(context).showSnackBar(snackbar);
     ScaffoldMessenger.of(context).showSnackBar(snackbar);
     //  setState(() {
     //    _entradasList = _listarItens();
     //  });
   }

   @override
  void initState() {
     super.initState();
     _verificaOf().whenComplete((){
       setState(() {});
     });



  }

  /* void dispose() {
     _animationController.dispose();
     super.dispose();
   }*/

   Future<void>_verificaOf()async{
    final prefs = await SharedPreferences.getInstance();
    isOffline = prefs.get("isOffline");
    //print("Offline: ${isOffline}");
    //verifica se tem venda para sincronizar
    HttpServiceSincroniza serviceSincroniza =  new HttpServiceSincroniza();
    HttpServiceVenda _service = HttpServiceVenda();
 //   print("Sincronizar ... ${DateTime.now().subtract(Duration(days:1,hours: 23,minutes: 59))}");


    if(isOffline == false){

      try {
        setState(() {
          passo = "Verificando Vendas não \n sincronizadas com o servidor \n .. Aguarde o envio!";
          visible = true;
        });
        await serviceSincroniza.entradas();
        await serviceSincroniza.vendas();
        await _service.verificaSincronizacaoVendas();
        isAtualiza = await prefs.get("atualiza");
        if (isAtualiza) {
          setState(() {
            passo = "Sincronizando Produtos e Clientes! \n ... Aguarde o recebimento!";
          });
          String tipo = await prefs.get("tipoAtualiza") == null ? "" : prefs.get("tipoAtualiza");
          //int tipo = int.parse();
          switch (tipo) {
            case "0":
            //atualiza produtos
              await serviceSincroniza.listarItens();
              break;
            case "1":
            //atualiza clientes
              await serviceSincroniza.listarClientes();
              break;
            case "2":
              print("Off ....  atualizar os dois - produtos e clientes");
              await serviceSincroniza.listarItens();
              await serviceSincroniza.listarClientes();
              //atualiza os dois
              break;
          }
        }
        setState(() {
          visible = false;
          passo = "Dados atualizados com sucesso! Boas Vendas!!";
          _setMensagem(context,passo, true);
          /* Timer(Duration(seconds: 4), () {
        setState(() {
          passo = "";
        });
      });*/
        });
      }catch(e){
        print(e.toString());
        setState(() {
          visible = false;
          _setMensagem(context,e.toString(), false);
        });
      }
    }


  }
 _abrirVenda(){
     Navigator.push(context,
         MaterialPageRoute(builder: (context)=>Vendas())
     );

   }
   _abrirEntrada(){
     Navigator.push(context,
         MaterialPageRoute(builder: (context)=>Entradas())
     );
   }
   _abrirCanhoto(){
     Navigator.push(context,
         MaterialPageRoute(builder: (context)=>Canhotos())
       //  MaterialPageRoute(builder: (context)=>Comprovante())
     );
   }
   _verificarCor() {
    // final prefs = await SharedPreferences.getInstance();
    // isOffline = prefs.get("isOffline");
  //   isOffline = true;
     int cor = isOffline == true ? 0xfff8c007 : 0xff20c997;
     print("cor: ${cor}==> ${isOffline}");
     return cor;
   }
   @override
   Widget build(BuildContext context) {
     return Scaffold(
       appBar: AppBar(
           automaticallyImplyLeading: false,
         actions: [
           IconButton(
             icon: Icon(Icons.close),
             onPressed: () {
               Navigator.of(context).pushNamedAndRemoveUntil('/login', (Route<dynamic> route) => false);
             },
           )
         ],
         title:
         Text("Menu"),
         //automaticallyImplyLeading: false,
       ),

       body: Container(
         //color: Colors.amberAccent,
         padding: EdgeInsets.all(16),
         child: Column(
           crossAxisAlignment: CrossAxisAlignment.center,
           mainAxisAlignment: MainAxisAlignment.center,
           children: <Widget>[
             Padding (
               padding: EdgeInsets.only(top: 1),
               child: Row(
                 mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                 children: <Widget>[
                   GestureDetector(
                     onTap: visible==false?_abrirVenda:null,
                     child: Column(
                       children: <Widget>[
                         CircleAvatar(
                             child: FaIcon(
                               FontAwesomeIcons.shoppingBasket,
                               color: Colors.white,
                               size: 30,
                             ),
                             radius: 40.0,
                             backgroundColor: Color(_verificarCor()),
                         ),
                         Text("Vendas"),
                       ],
                     ),
                   ),

                   GestureDetector(
                     onTap: visible==false?_abrirEntrada:null,
                     child: Column(
                       children: <Widget>[
                         CircleAvatar(
                           child: FaIcon(
                             FontAwesomeIcons.signInAlt,
                             color: Colors.white,
                             size: 30,
                           ),
                           radius: 40.0,
                             backgroundColor: Color(isOffline == true?0xfff8c007:0xff20c997),
                         ),
                         Text("Entradas"),
                       ],
                     ),
                   ),
                ],
               ),
             ),
            /* Padding (
                 padding: EdgeInsets.only(top: 40),
                 child: Row(
                     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                     children: <Widget>[
                       Visibility(
                         maintainSize: true,
                         maintainAnimation: true,
                         maintainState: true,
                         visible: isOffline == false,
                         child: GestureDetector(
                               onTap: visible==false?_abrirCanhoto:null,
                               child: Column(
                                 children: <Widget>[
                                   CircleAvatar(
                                     child: FaIcon(
                                       FontAwesomeIcons.ticketAlt,
                                       color: Colors.white,
                                       size: 30,
                                     ),
                                     radius: 40.0,
                                     backgroundColor: Color(0xff20c997),


                                   ),
                                   Text("Comprovantes"),
                                 ],
                               ),
                             ),
                           )]
                       )
                       ),
*/
       Padding (
         padding: EdgeInsets.only(top: 65),
         child: Row(
           mainAxisAlignment: MainAxisAlignment.spaceEvenly,
           children: <Widget>[
             Visibility(
               maintainSize: true,
               maintainAnimation: true,
               maintainState: true,
               visible: visible,
               child: Container(
                 // margin: EdgeInsets.only(top: 0, bottom: 30),
                 child: CircularProgressIndicator()
                 ,),

             ),
             Visibility(
               maintainSize: true,
               maintainAnimation: true,
               maintainState: true,
               visible: visible,
               child: Text(passo),

             )])),
          /*   Padding(
               padding: const EdgeInsets.all(50),
               child: Column(
                 mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                 children: <Widget>[
                   const Text(
                     'Verificando atualizações para Vendas Offline.. Aguarde',
                     style: TextStyle(fontSize: 15),
                   ),
                   LinearProgressIndicator(
                     value: _animationController.value,
                     semanticsLabel: 'Linear progress indicator',
                   ),
                 ],
               ),)*/

           ],
         ),
       ),
     );
   }

 }
 