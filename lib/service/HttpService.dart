import 'dart:async';
import 'dart:io';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:seller_app/model/User.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class HttpService {

final int TIMEOUT = 10; //30;
String URL = "";
final _storage = FlutterSecureStorage();

//static String _URL = "http://192.168.0.21:8080/4care/rest";
//final storage = FlutterSecureStorage();
 getURL() async{

    String url = await getId();
    //print("==> ${url}");
   //return   "https://www.4sales.openyx.com.br/sales/rest"; //192.168.0.21:8080
    //return "http://192.168.0.14:8080/4sales/rest";
   //return "http://192.168.0.165:8080/sales/rest";
    //return "http://192.168.0.165:8080/4seller-api/rest";
    //return "http://192.168.146.129:8080/4seller-api/rest";
    //return "http://192.168.0.103:8080/4seller-api/rest";
//    return "http://192.168.200.129:8080/4seller-api/rest";
   // return "http://192.168.35.129:8080/4seller-api/rest";
    //return "http://192.168.0.165:8080/4seller-api/rest";
//   return "http://192.168.0.166:8080/4seller-api/rest";
    return "https://www.4seller.openyx.com.br/${url}-api/rest";
 }

_atualizarToken (String jwt) async{
  //storage.write(key: "jwt", value: jwt);
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString("jwt",jwt);
  //print("token atualizado ..."+jwt);
}
 getToken() async{
  final prefs = await SharedPreferences.getInstance();
  String token = await  prefs.getString("jwt");
  return token;
}

setId(String id, String usuario) async {
  final prefs = await SharedPreferences.getInstance();
  prefs.setString("ID", id);
  prefs.setString("CPF", usuario);
}
getId() async{
    final prefs = await SharedPreferences.getInstance();
    String id =  prefs.getString("ID");
    return id.trim();
 }

delId() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.remove("ID");
  }

_guardarUser (String username,String  password) async{
    _storage.write(key: "user", value: username);
    _storage.write(key: "pass", value: password);

  //print("username guardado..");
}
  Future<User> login(String usuario, String senha) async{
    String _mensagem;

    User user = User();
    var body = json.encode(
      {
        "username":usuario,
        "password":senha //adicionar isApp=true
      }
    );
    try {
      String url =  await getURL();
    //  print("url::${url}/auth/login-app");
      http.Response req = await http.post(url + "/auth/login-app",
          headers: {
            "Content-type": "application/json; charset=UTF-8"
          },
          body: body).timeout(Duration(seconds: 7));
    //  print("resposta: ${req.statusCode}");
    //  print("resposta: ${req.body}");
    //  print("jwt: ${req.headers["jwt"]}");


    if(req.statusCode == 200){
      Map<String,dynamic> res = json.decode(req.body);
      String nome = res["nome"];
      String role = res["roles"];
      String username = res["username"];
      bool first = res["first"];
      bool atualiza = res["atualiza"];
      //print("nome"+nome);
     // print("roles"+role);
      if(first){
        user.mensagem = "Primeiro Acesso não pode ser Realizado pelo APP!";
        user.ok = false;
        return user;
      }
      String jwt = req.headers["jwt"];
      _atualizarToken(jwt);
      _guardarUser(username,senha);
      user.ok = true;
      user.nome = nome;
      user.roles = role;
      user.username = username;
      user.atualiza = atualiza;

      return user;

    }else if(req.statusCode == 401 || req.statusCode == 403){
      _mensagem = "Usuário sem Autorização! Verifique Usuário, Senha e/ou Perfil!";
      user.ok = false;
      user.mensagem = _mensagem;
      return user;
    }else if(req.statusCode == 404){
      _mensagem = "Serviço API - indisponível! Tente novamente.";
      user.ok = false;
      user.mensagem = _mensagem;
      return user;
    }

    }on SocketException{
      _mensagem = "Não foi possível realizar Login! Problemas com serviço de Autenticação. Tente mais tarde!";
      user.ok = false;
      user.mensagem = _mensagem;
      return user;
    }on TimeoutException {
      _mensagem = "Não foi possível realizar Login! Problemas com serviço de Autenticação. Tente mais tarde!";
      user.ok = false;
      user.mensagem = _mensagem;
      return user;
    }on HttpException {
      _mensagem = "Serviço indisponível! Tente mais tarde!";
      user.ok = false;
      user.mensagem = _mensagem;
      return user;
    }

  //  return user;
  }

  tratarHttpRC(int rc, msg) {
    if(rc == 401){
      throw HttpException("Token expirado! Faça login novamente!");
    }else if(rc == 404) {
      throw HttpException("Item não encontrado!");
    }
    else if(rc == 302) {
      throw HttpException(msg); //mensagem especifica
    }
    else if(rc == 409) {
      throw HttpException(msg); //mensagem especifica
    }else if(rc == 500) {
      throw HttpException(
          "O serviço na nuvem está temporariamente indisponível! Tente mais tarde!");
    }

  }

  Future<int> validarToken() async{
   try {
      String token = await getToken();
      String url =  await getURL();
      http.Response req = await http.get(
        url+"/valida-token",
        headers: {
          "Content-type": "application/json; charset=UTF-8",
          "Authorization2": "Bearer $token",
        },).timeout(Duration(seconds: TIMEOUT));
      //print("resposta: ${req.statusCode}");
      return req.statusCode;

    }on SocketException{
    // print("");
     return 500;
    }on TimeoutException {
    // print("");
     return 500;
    }on HttpException {
    // print("resposta:");
    }

  }
}