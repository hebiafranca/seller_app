import 'dart:async';
import 'dart:io';
//import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:seller_app/model/Venda.dart';
import 'package:seller_app/model/postRc.dart';
import 'package:seller_app/service/HttpService.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class HttpServiceCRUD extends HttpService {

 Future<http.Response> montarRequestGet(String operacao, String codigo) async{
    String token = await getToken();
    String url =  await getURL();
    Venda v = null;
    http.Response res = await http.get(
   //   getURL()+"/itemalmoxarifados/"+codigoBarras,
      url+"/"+operacao+"/"+codigo,
      headers: {
        "Content-type": "application/json; charset=UTF-8",
        "Authorization2": "Bearer $token",
      },);
   // print("resposta: ${res.statusCode}");
  //  print("body: ${res.body}");
   // return req.statusCode;
   return res;
   //return p;
  }

  Future<PostRc> montarRequestPost(String operacao, body) async{
    String token = await getToken();
    String url =  await getURL();
    http.Response req = await http.post(

       // getURL() + "/entradaalmoxarifados" ,
        url + "/"+operacao+"/" ,
        headers: {
          "Content-type": "application/json; charset=UTF-8",
          "Authorization2": "Bearer $token",
        }, body: body).timeout(Duration(seconds: 50));;
    //print("resposta novoItem(): ${req.statusCode}");
    int id=0;
    if(!req.bodyBytes.isEmpty) {
     // print("res:: ${req.bodyBytes}");
      id = json.decode(utf8.decode(req.bodyBytes));
     // print("res:: ${id}");
      //id = res["id"];
      //print("novo id entrada: ${id}");
    }
    PostRc p = PostRc(req.statusCode, id);
   // return req.statusCode;
    return p;

  }

  Future<int> montarRequestDel(String operacao, int codigo) async {
    String token = await getToken();
    String url =  await getURL();
   // print("codigo apagar::: ${codigo}");


      http.Response req = await http.delete(
        //  getURL() + "/saidaalmoxarifados/" + codigo.toString(),
        url + "/"+operacao+"/" + codigo.toString(),
        headers: {
          "Content-type": "application/json; charset=UTF-8",
          "Authorization2": "Bearer $token",
        },);
     // print("Apagar Item resposta...:${url} ... ${req.statusCode}");

    return req.statusCode;
  }

  Future<http.Response> montarRequestList(String operacao) async {

    String token = await getToken();
    String url =  await getURL();
    http.Response req = await http.get(
  //    getURL() + "/entradaalmoxarifados/all-app",
      url + "/"+ operacao,
      headers: {
        "Content-type": "application/json; charset=UTF-8",
        "Authorization2": "Bearer $token",
      },).timeout(Duration(seconds: TIMEOUT));
   // print("resposta: ${req.statusCode}");
//  print("resposta: ${req.body}");
  return req;

  }

 Future<int> montarRequestPut(String operacao, body, int codigo) async{
   String token = await getToken();
   String url =  await getURL();
   http.Response req = await http.put(url + "/"+operacao+"/${codigo.toString()}" ,
       headers: {
         "Content-type": "application/json; charset=UTF-8",
         "Authorization2": "Bearer $token",
       }, body: body);
   //print("resposta putItem(): ${req.statusCode}");
   //int id=0;
   //if(!req.bodyBytes.isEmpty) {
    // print("res:: ${req.bodyBytes}");
  //   id = json.decode(utf8.decode(req.bodyBytes));
    // print("res:: ${id}");
     //id = res["id"];
     //print("novo id entrada: ${id}");
  // }
  // PostRc p = PostRc(req.statusCode, id);
    return req.statusCode;
  // return p;

 }



}