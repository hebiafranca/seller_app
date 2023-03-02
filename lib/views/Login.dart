import 'dart:async';

import 'package:seller_app/model/User.dart';
import 'package:seller_app/service/HttpService.dart';
import 'package:seller_app/service/LocalService.dart';
import 'package:seller_app/views/Inicio.dart';
import 'package:seller_app/views/widgets/BotaoCustomizado.dart';
import 'package:seller_app/views/widgets/InputCustomizado.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';


class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {

  TextEditingController _controllerUser = TextEditingController(); // " 59682145877  valdete 83938484848" , 036925 GES ,27383837373 MANU,023453 ENF
  TextEditingController _controllerSenha = TextEditingController();
  TextEditingController _controllerID = TextEditingController();

  String _mensagemErro ="";
  String _id ="";
  bool isOffline=true;//false


  @override
  void initState() {
    super.initState();
    _init();

  }
  _init() async {
   final prefs = await SharedPreferences.getInstance();
    String id =  prefs.getString("ID");
   String cpf =  prefs.getString("CPF");
    if(id != null){
      setState(() {
        _controllerID.text = id.toUpperCase();
       // _controllerUser.text = "52399887111";//"63528887744";//"56239874588";// "59682145877"; //"56239874588";
      //  _controllerSenha.text =  "valdete"; //"562398";
      });
    }else{
      setState(() {
        _controllerID.text = "4SELLER";
    });
    }
   if(cpf != null){
     setState(() {
       _controllerUser.text = cpf;//"52399887111";//"63528887744";//"56239874588";// "59682145877"; //"56239874588";

     });
   }
  }
   _login()async{

     setState(() {
       visible = true;
     });

    //String id = "SALES";//_controllerID.text;
     String id = _controllerID.text;
    String usuario =_controllerUser.text;
    String senha = _controllerSenha.text;

    LocalService lservice = LocalService();
    final prefs = await SharedPreferences.getInstance();
    if(id.isNotEmpty && id.length >= 4) {
      if (usuario.isNotEmpty && usuario.length >= 6) {
        if (senha.isNotEmpty && senha.length >= 6) {
          User user = User();
          if(isOffline == true){

            user = await lservice.login(usuario.trim(),senha.trim());
         //   final prefs = await SharedPreferences.getInstance();
            await prefs.setBool("isOffline", true);
          }else {
            HttpService service = HttpService();
            service.setId(id.toLowerCase(),usuario); //sempre minusculo
            user = await service.login(usuario.trim(), senha.trim());
        //    final prefs = await SharedPreferences.getInstance();
            await prefs.setBool("isOffline", false);
          }
          if (user.ok) {
           // print("ok ... login realizado com sucesso");
          //  if (user.roles == "MANU") {
              //  Navigator.pushNamed(context, "/inicio");
            User u =  await lservice.isMesmologin(user.login);
            if(u.atualiza){
              await prefs.setBool("atualiza", user.atualiza==null?false:user.atualiza);
              await prefs.setString("tipoAtualiza",user.roles); //no app o tipo de atualizaco vira no roles 0-produtos 1- clientes 2-os dois
            }else{
              await prefs.setBool("atualiza", true);
              await prefs.setString("tipoAtualiza",2.toString()); //no app o tipo de atualizaco vira no roles 0-produtos 1- clientes 2-os dois
            }

            Navigator.push(context,  MaterialPageRoute( builder: (context) => Inicio() ));
          //  Navigator.popAndPushNamed(context,'/inicio');

           // }
          } else {
          //  service.delId();
            setState(() {
             // print("erro::" + user.mensagem);
              _mensagemErro = user.mensagem;
              Timer(Duration(seconds: 4), () {
                setState(() {
                  _mensagemErro = "";
                });
              });
            });
          }
          //print("finalizando login");
        } else {
          setState(() {
            _mensagemErro = "Forneça a Senha!";
            Timer(Duration(seconds: 4), () {
              setState(() {
                _mensagemErro = "";
              });
            });
          });
        }
      } else {
        setState(() {
          _mensagemErro = "Forneça o ID!";
          Timer(Duration(seconds: 4), () {
            setState(() {
              _mensagemErro = "";
            });
          });
        });
      }
    }
     setState(() {
       visible = false;
     });

   }
  bool visible = false ;
 /* loadProgress(){
    if(visible == true){
      setState(() {
        visible = false;
      });
    }
    else{
      setState(() {
        visible = true;
      });
    }

  }*/

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
       title: Text("4 S E L L E R - App do Vendedor"),
       // title: Image(image: AssetImage('4care.png'),width: 40,height: 40,)
      ),
      body: Container(
        padding: EdgeInsets.all(16),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.all(10),
                ),
               Text(_mensagemErro,
                  style: TextStyle(
                      fontSize: 14,
                      color: Color(0xffB22222),
                      fontWeight: FontWeight.bold
                  ),),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[

                    Padding(
                      padding: EdgeInsets.only(bottom: 10),

                    ),
                    Icon(Icons.add_to_home_screen,
                    color: Color(0xff296fa7),),
                    Text("Login",
                    style: TextStyle(
                      fontSize: 25,
                      color: Color(0xff296fa7),
                      fontWeight: FontWeight.bold
                    ),)
                  ],
                ),
                Padding(
                  padding: EdgeInsets.all(5),
                ),
                InputCustomizado(
                  controller: _controllerID,
                  hint: "ID",
                  autofocus: false,
                  type: TextInputType.text,
                  icone: Icon(Icons.business),
                ),
                Padding(
                  padding: EdgeInsets.all(5),
                ),
                InputCustomizado(
                  controller: _controllerUser,
                  hint: "Login",
                  autofocus: true,
                  type: TextInputType.number,
                  icone: Icon(Icons.perm_identity),
                ),
                Padding(
                  padding: EdgeInsets.all(5),
                ),
                InputCustomizado(
                  controller: _controllerSenha,
                  hint: "Senha",
                  obscure: true,
                  icone: Icon(Icons.vpn_key),
                ),
                Padding(
                  padding: EdgeInsets.all(10),
                ),
               Row(
                 mainAxisAlignment: MainAxisAlignment.center,
                 children: <Widget>[
                 Switch(
                   value: isOffline,
                   onChanged: (value) {
                     setState(() {
                       isOffline = value;
                       //print(isOffline);
                     });
                   },
                   activeTrackColor: Color(0xfff8c007),//Colors.lightGreenAccent,
                   activeColor: Color(0xfff8c007),//Colors.green,

                 ),
                 Text("Trabalhar Offline",
                   style: TextStyle(
                       fontSize: 18,
                       color: Color(0xff296fa7),//(),0xfff8c007
                       fontWeight: FontWeight.bold
                   ),),
               ]),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Visibility(
                        maintainSize: true,
                        maintainAnimation: true,
                        maintainState: true,
                        visible: visible,
                        child: Container(
                          // margin: EdgeInsets.only(top: 0, bottom: 30),
                            child: CircularProgressIndicator( )
                        )
                    ),
                    Padding(
                      padding: EdgeInsets.all(10),
                    ),

                    BotaoCustomizado(
                      texto: "Entrar",
                      onPressed: (){
                        _login();

                      },
                    ),

                  ],
                ),
              /*  Padding(
                  padding: EdgeInsets.all(10),
                ),
                Text(_mensagemErro,
                  style: TextStyle(
                      fontSize: 14,
                      color: Color(0xffB22222),
                      fontWeight: FontWeight.bold
                  ),),*/
              ],
            ),
          ),
        ),
      ),
    );
  }


}
