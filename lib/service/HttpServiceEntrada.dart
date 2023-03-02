import 'dart:io';

import 'package:seller_app/model/Entrada.dart';
import 'package:seller_app/model/Produto.dart';
import 'package:seller_app/model/postRc.dart';
import 'package:seller_app/service/HelperDAO.dart';
import 'package:seller_app/service/HelperFile.dart';
import 'package:seller_app/service/HttpServiceCRUD.dart';
import 'package:flutter/material.dart';
//import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class HttpServiceEntrada extends HttpServiceCRUD {
  var _db = HelperDAO();
  var _f = HelperFile();

  Future<Entrada> getItem(String codigoBarras) async{
    List prods = await _f.produtos;
  //  print (prods);
  //  final res = prods.singleWhere((element) => element['codigoBarras'] == codigoBarras || element['codigoBarrasGranel'] == codigoBarras || element['codigoBarrasComercial'] == codigoBarras, orElse: () {
    final res = prods.singleWhere((element) => element['codigoBarras'] == codigoBarras ||  element['codigoBarrasComercial'] == codigoBarras, orElse: () {
      return null;
    });
    Entrada item = Entrada();
    if(res != null) {
      item.produtoNome = res['nome'];
      item.produtoCodigo = res['id'];
      item.produtoDescricao = res['descricao'];
      item.peso = res["peso"];
      item.codigoBarras = res['codigoBarrasComercial'] == "" ? codigoBarras :res['codigoBarrasComercial'];
      item.status = res['status'];
    }else{
      item = null;
    }
    return item;

  }

  void novoItem(Entrada item) async {
    //verificar offline - nao posso nem tentar pq o cliente quer offline
    SharedPreferences  prefs = await SharedPreferences.getInstance();
    bool off = prefs.get("isOffline");
    if(off == true){
      item.status = 1;//false;
      item.registro = DateTime.now().toString();
     // print("data ${item.registro}");
      await _gravarOff(item);
    }else {  //venda online
      var body = json.encode(
          {
            "codigoBarras":item.codigoBarras,
            "produto" :{
              "id":item.produtoCodigo,
              //"codigoBarrasComercial":item.codigoBarras
            },
            // "isDoacao":item.isDoacao,
            "qtde":item.qtde, //adicionar isApp=true
           // "vencimento":item.vencimento
            "dtaVencto":item.vencimento
          }
      );
  //    print(body);
      PostRc rc = await montarRequestPost("entrada", body);
      if(rc.rc == 201 || rc.rc == 200){
        item.id = rc.id; //id nova entrada
        item.status = 0;//true; //foi sincronizada
        item.registro = DateTime.now().toString();
       // print("data ${item.registro}");
        await _gravarOff(item);
        //tratarHttpRC(409, "Não foi possível enviar a Venda, que foi registrada Offline e será enviada na próxima sincronização!");
      }else if(rc.rc == 302) {
        tratarHttpRC(302, "Código Comercial já utilizado em outro produto!"+item.produtoNome);
      }else{// nao conseguiu gravar a venda
        item.status = 1;//false; //Nao foi sincronizada
        await _gravarOff(item);
        tratarHttpRC(409, "Não foi possível enviar a Entrada, que foi registrada Offline e será enviada na próxima sincronização!");
      }
      tratarHttpRC(rc.rc, "");
    }

  /*  var body = json.encode(
        {
          "produto" :{
            "id":item.produtoCodigo
          },
         // "isDoacao":item.isDoacao,
          "qtde":item.qtde //adicionar isApp=true
        }
    );
    int rc =  await montarRequestPost("entrada",body);
    tratarHttpRC(rc,"");

   */

  }

  Future<List<Entrada>> listarItens() async{
    List<Entrada> list = await _db.listEntradas();
  //  print("qtde itens(service):: ${list.length}");
    return list;
    //http.Response req = await montarRequestList("entradacopa/all-app");
 /*   http.Response req = await montarRequestList("entrada/all-app");
    Entrada item = Entrada();
    if (req.statusCode == 200) {
      return montarResponse(req);
    } else  {
      tratarHttpRC(req.statusCode,"");
    } */
  }



  apagarItem(Entrada item) async {

    if(item.status == 1 ){
      //item status 1 (ainda nao foi enviado para api - basta apagar na base
     int rc = await _db.removeEntrada(item.cod);
    // print("delete ${rc}");
     //verificar rc
    }else{ //status 0 - ja foi atualizado
      SharedPreferences prefs = await SharedPreferences.getInstance();
      bool off = prefs.get("isOffline");
      if (off == true) {
        tratarHttpRC(409, "Entrada sincronizada não pode ser apagada enquanto estiver Offline!");
      } else { //venda online
        int rc = await montarRequestDel("entrada", item.id);
        if(rc == 204){ //apagou na api pode apagar local
          int rc = await _db.removeEntrada(item.cod);
          //verificar rc
        }else {
          tratarHttpRC(rc, "Entrada não pode ser apagada. Há Venda registrada para ela");
        }
      }
    }


  }

   void _gravarOff(Entrada item) async{
     bool result = await _db.saveEntrada(item);
    if(result == false){
      tratarHttpRC(409, "Não foi possível registrar sua Entrada! Tente novamente.");
    }
  }

}