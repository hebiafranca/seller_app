import 'dart:async';
import 'dart:io';

import 'package:seller_app/model/Venda.dart';
import 'package:seller_app/model/ItemVenda.dart';
import 'package:seller_app/model/postRc.dart';
import 'package:seller_app/service/HelperDAO.dart';
import 'package:seller_app/service/HttpServiceCRUD.dart';
import 'package:seller_app/service/LocalService.dart';
import 'package:flutter/material.dart';
//import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

extension Ex on double {
  double toPrecision(int n) => double.parse(toStringAsFixed(n));
}
class HttpServiceSincroniza extends HttpServiceCRUD {


  var _db = HelperDAO();

  void listarItens() async{
    //http.Response req = await montarRequestList("entradacopa/all-app");
    http.Response req = await montarRequestList("produtos/offline");
    Venda item = Venda();
    if (req.statusCode == 200) {
      //var dadosJson = json.encode(utf8.decode(req.bodyBytes));
    //  var dadosJson = json.decode(req.body);
      var dadosJson = utf8.decode(req.bodyBytes);
    //  var dadosJson = json.encode(req.body);
   //   var dadosJson = req.body;
       LocalService lservice = new LocalService();
      try {
        var arquivo = await lservice.getFileProdutos();
        try {
          if(arquivo.existsSync()){
         //   print("produtos existe ... vou apagar");
            await arquivo.delete();
          }else{
        //    print("produtos nao existe");
          };

        } catch (e) {
        //  print("nao consegui apagar produt");
        }
      await  arquivo.writeAsString(dadosJson, mode: FileMode.writeOnly, encoding: utf8);
       // await arquivo.writeAsString(dadosJson, encoding: utf8);
      //  print("arquivo off produtos::" + dadosJson);
      }catch (e) {
       // print("Couldn't read file:: ${e}");
      }
      //informar api que ja atualizou
    /*  http.Response reqI = await montarRequestList("valida-token/informa-atualizacao/0");
      if (reqI.statusCode != 200) {
        tratarHttpRC(reqI.statusCode,"");
      }

*/
    } else  {
      tratarHttpRC(req.statusCode,"");
    }
  }

  void listarClientes() async{
    //http.Response req = await montarRequestList("entradacopa/all-app");
    http.Response req = await montarRequestList("clientes/offline");
    Venda item = Venda();
    if (req.statusCode == 200) {
   //   var dadosJson = json.encode(utf8.decode(req.bodyBytes));
      //var dadosJson = json.decode(req.body);
    //  var dadosJson = utf8.decode(req.bodyBytes);
   //  var dadosJson = req.body;
      var dadosJson = utf8.decode(req.bodyBytes);
      LocalService lservice = new LocalService();
      var arquivo  = await lservice.getFileClientes();
      try {
        await arquivo.delete();
      } catch (e) {}
        //   arquivo.writeAsString( dadosJson.toString() );
      await arquivo.writeAsString( dadosJson,mode: FileMode.writeOnly, encoding: utf8);
    // await arquivo.writeAsString( dadosJson, encoding: utf8);
      //print("arquivo off clientes::"+dadosJson);
      //informar api que ja atualizou
    /* http.Response reqI = await montarRequestList("valida-token/informa-atualizacao/1");
      if (reqI.statusCode != 200) {
        tratarHttpRC(reqI.statusCode,"");
      }

     */
    } else  {
      tratarHttpRC(req.statusCode,"");
    }
  }


  void vendas() async{
    List<Map> vendas =  await _db.listVendasSincroniza();
    int qtdeVendas = vendas.length;
    int vendasSincro = 0;
  //  print(qtdeVendas);
    //chama api
    await Future.forEach(vendas, (el) async {
      try {
        //consultar itens
        List<Map> itensM = List();
        List<Map> itens = await _db.listItens(el["id"]);
        itens.forEach((it) {
          Map i = {
            "produto": {"id": it["produtocodigo"], "nome": it["produtonome"]},
            "quantidade": it["quantidade"],
            "granel": it["granel"],
            "pesoGranel": it["pesogranel"],
            "valorGranel": it["valorgranel"],
            "desconto": it["desconto"],
            "valorDesconto": it["valordesconto"],
            "totalParcial": it["totalparcial"],
            "total": it["total"]
          };
          itensM.add(i);
        });
        //montar
        // var body = json.encode(el);
       // print("total:: ${el["total"]}");
       // print("total:: ${el["desconto"]}");
        double valorVenda = el["total"];

        var val =el["total"].toString().split(".");
        if(val.length > 1 && val[1].length > 2){
        //  print("venda nao arredondada");
          double valor = el["total"];
          valorVenda = valor.toPrecision(2);
          //print("valor arredodnado:: ${valorVenda}");
        }

        double valorDesconto = el["desconto"];
        var val1 =el["desconto"].toString().split(".");
        if(val1.length > 1 && val1[1].length > 2){
        //  print("desconto nao arredondada");
          double valor = el["desconto"];
          valorDesconto = valor.toPrecision(2);
         // print("desconto arredondado:: ${valorDesconto}");
        }
      //  print ("percentual ${el["percentual"]}");
        var body = json.encode(
            {
              //  "id":el["id"],
              "cliente": {
                "codigo": el["clientecodigo"],
                "nome": el["clientenome"]
              },
              "pagamento": el["pagamento"],
              "origem": 2, //offline,
              "status":el["status"],
              "receberAgora": el["receberagora"]==0 ?true : false,
              "dinheiro": el["dinheiro"],
              "troco": el["troco"],
              "timestamp": el["registro"],
            //  "total": el["total"],
              "total": valorVenda,
            //  "desconto": el["desconto"],
              "desconto": valorDesconto,
              "descontoItens": el["descontoitens"],
              "percentual": el["percentual"],
              "totalSemDesconto": el["totalsemdesconto"],
              "itens": itensM
              //"status"

            }
        );

        //print(body);
        PostRc rc = await montarRequestPost("vendas", body);
        if ((rc.rc == 201 || rc.rc == 200) && rc.id != null) { //se tiver um id de retorno
          //atualiza banco local
          _db.atualizarStatusVendaSincronizada(el["id"],1,rc.id); //1 -online (sincronizada) idVenda
          vendasSincro++;
        } else {
          if(rc.rc ==401){
            tratarHttpRC(401,"");
          }else if(rc.rc == 302) {
           // print("venda já enviada anteriormente.. será desconsiderada");
            _db.atualizarStatusVendaSincronizada(0,1,rc.id); //1 -online (sincronizada) idVenda
          }else{ // nao conseguiu gravar a venda
            tratarHttpRC(409,
                "Não foi possível enviar a Venda, que foi registrada Offline e será enviada na próxima sincronização!");
          }
        }
      }on SocketException{
        throw "Não foi possível sincronizar todos os dados! Faremos na próxima, ok!";
      }on TimeoutException {
        throw "Não foi possível sincronizar todos os dados! Faremos na próxima, ok!";
      }  catch(e){ //mesmo dando erro ele vai tentar sincronizar as demais
        //print(e);
       //return 500;
      throw "Não foi possível sincronizar todos os dados! Faremos na próxima, ok!";

      }
      } //for - para cada venda
      );
      //apaga apenas as ateriores a hoje
   await _db.removeItens();
   int qtdev =  await _db.removeRegistros("vendas");
  // print("De ${qtdeVendas} - ${vendasSincro} foram sincronizadas com sucesso! ...${qtdev} ...");
  }

  void entradas() async{
    List<Map> entradas =  await _db.listEntradasSincroniza();

    await Future.forEach(entradas, (el) async {
      try{
 //    DateTime dt = DateTime.parse(el["registro"]);
    //  String dt =  el["registro"];

      //el["registro"] = dt;
      var body = json.encode(
          {
            "codigoBarras":el["codigobarras"],
            "produto" :{
              "id":el["produtocodigo"]
            },
            "qtde":el["qtde"],
            "timestamp":el["registro"],
            // "vencimento":item.vencimento
            "dtaVencto":el["vencimento"]
         //   "registro":dt.replaceAll("\"", "")

          }
      );
      //var body = json.encode(el);
    //  print("entrada:${body}");
      PostRc rc = await montarRequestPost("entrada", body);
      if((rc.rc == 201 || rc.rc == 200) && rc.id != null){
        //atualiza banco local
        _db.atualizarStatusEntrada(el["cod"],0,rc.id); //0 -true idVenda
      }else if(rc.rc == 302) {
        tratarHttpRC(302, "Código Comercial já utilizado em outro produto! Apague a Entrada: "+el["produtonome"]);
      }else{// nao conseguiu gravar a venda
        tratarHttpRC(409, "Não foi possível enviar a Entrada, que foi registrada Offline e será enviada na próxima sincronização!");
      }


      }catch(e){
        //print(e);
        throw e.message ==null ? "Não foi possível sincronizar todos os dados! Faremos na próxima, ok!" : e.message;
      }

    });//for fim das entradas sincronizadas
    //apaga apenas as ateriores a hoje
    int qtdev =  await  _db.removeRegistros("entradas");
  //  print("Entradas sincronizadas com sucesso! ...${qtdev} ...");
  }
}