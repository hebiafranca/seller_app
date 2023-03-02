import 'dart:async';
import 'dart:io';

import 'package:seller_app/model/Venda.dart';
import 'package:seller_app/model/ItemVenda.dart';
import 'package:seller_app/model/postRc.dart';
import 'package:seller_app/service/HelperDAO.dart';
import 'package:seller_app/service/HelperFile.dart';
import 'package:seller_app/service/HttpServiceCRUD.dart';
import 'package:seller_app/service/HttpServiceSincroniza.dart';
import 'package:seller_app/service/LocalService.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class HttpServiceVenda extends HttpServiceCRUD {

  var _db = HelperDAO();
  var _f = HelperFile();
  Future<ItemVenda> getItem(String codigoBarras) async{
   // print("procurando ...${codigoBarras}");
    List prods = await _f.produtos;
    var res = prods.singleWhere((element) => element['codigoBarras'] == codigoBarras || element['codigoBarrasGranel'] == codigoBarras || element['codigoBarrasComercial'] == codigoBarras, orElse: () {
    //  return  prods.singleWhere((element) => element['codigoBarrasGranel'] == codigoBarras, orElse: () {
     //   return null;
      //});
      return null;
    });
    //procuro a granel
   // if(res == null) {
    //  res = prods.singleWhere((element) => element['codigoBarrasGranel'] == codigoBarras, orElse: () {
    //    return null;
     // });
    //}
    ItemVenda item = ItemVenda();
    if(res != null) {
      item.produtoCodigo = res["id"];
      item.produtoNome = res["nome"];
      //item.descricao = res["descricao"];
      item.produtoPeso = res["peso"];
      item.produtoPreco = res["precoVenda"];
      item.produtoGranel = res["granel"];
      item.desconto = res["desconto"];
      item.produtoPrecoVendaUmv = res["precoVendaUmv"] == null ? 0.0 : double.parse( res["precoVendaUmv"].toString());
      if(res["umvGranel"] != null) {
    //    item.produtoUmvGranelSigla = res["umvGranel"]["sigla"];
        item.produtoUmvGranelSigla = res["umvGranelSigla"];
      }else{
        item.produtoUmvGranelSigla = "";
      }
      if(codigoBarras == res["codigoBarrasGranel"]){
       // print("busca por codigo barras granel: ");
        item.granel = true;
      }
      item.produtoUmvPeso = res["umvPeso"] ==null ?0 :res["umvPeso"];
      item.produtoUmv = res['umvSigla']; //umvProduto
    }else {
      item = null;
    }
   // print("Produto selecionado: ${res.toString()}");
    return item;
 }

  void novaVenda(Venda item) async {
    //verificar offline - nao posso nem tentar pq o cliente quer offline
    SharedPreferences  prefs = await SharedPreferences.getInstance();
    bool off = prefs.get("isOffline");
    item.status = item.receberAgora == true ? 1 : 0; //0 - receber  1- pago  2-cancelado
    //print("venda.total::${item.total.toString()}");
    double valorVenda = item.total;
    item.total =  valorVenda.toPrecision(2);
    double valorDesconto = item.desconto;
    item.desconto = valorDesconto.toPrecision(2);
    //print("venda.total ajustado::${item.total.toString()}");
    if(off == true){
      item.origem = 2;
      item.situacao = 0; //0-nao sincronizado 1- sincronizado
      item.registro = DateTime.now().toString();
      await _gravarOff(item);
    }else {  //venda online
      item.origem = 1; //1-on 2 -off
      var venda = item.toJson();
      var body = json.encode(venda);
    //  print(body);
      PostRc rc = await montarRequestPost("vendas", body);
      if(rc.rc == 201 || rc.rc == 200){
      //  item.id = rc.id; //id da nova venda
        item.codigo = rc.id;
       // print("nova venda:: ${rc.id}");
        item.registro = DateTime.now().toString();
        //atualizar itens - ids gerados
      //  _db.removeItensVendaAlterada(item.codigo);
      //  _db.insereItensVendaAlterada(item);
        item.situacao = 1; //0-nao sincronizado 1- sincronizado
        await _gravarOff(item);
        verificaSincronizacaoVenda(item);
        //tratarHttpRC(409, "Não foi possível enviar a Venda, que foi registrada Offline e será enviada na próxima sincronização!");
      }else{// nao conseguiu gravar a venda
        item.origem = 2; //mesmo com erro sera offline
        item.situacao = 0; //0-nao sincronizado 1- sincronizado
        await _gravarOff(item);
        //tratarHttpRC(409, "Não foi possível enviar a Venda, que foi registrada Offline e será enviada na próxima sincronização!");
        if(rc.rc == 401){
          tratarHttpRC(401,"");
        }else {
          tratarHttpRC(409,
              "Não foi possível enviar a Venda, que foi registrada Offline e será enviada na próxima sincronização!");
        }
      }
      tratarHttpRC(rc.rc, "");
    }

  }
  void alterarVenda(Venda item , bool altItem, bool altStatus) async {
    //verificar offline - nao posso nem tentar pq o cliente quer offline
    SharedPreferences  prefs = await SharedPreferences.getInstance();
    bool off = prefs.get("isOffline");
    if(off == true){
      await _alterarVendaOff(item,altItem,item.id); //id pq nao sincronizou ainda
    }else {  //venda online
      item.origem = 1; //1-on 2 -off
      item.registro = null;
      var venda = item.toJson();
      var body = json.encode(venda);
     // print(body);

     if(altStatus){
       int rc = await montarRequestPut("vendas/status", body,item.codigo);
       if(rc == 201 || rc == 200  || rc == 204){ //204 - alteracao){
         //item.origem = 1; //foi sincronizada
         item.situacao = 1;
         item.registro = null;// DateTime.now();
         //item.registro = DateTime.now();
         //await _alterarVendaOff(item,altItem,item.codigo); //codigo pq veio na web
         int rc = await _db.atualizarStatusVenda(item, item.status);
       }else{// nao conseguiu gravar a venda
         //item.origem = 2; //Nao foi sincronizada
         item.situacao = 0;
         tratarHttpRC(409, "Não foi possível alterar a Venda, que foi registrada Offline e será enviada na próxima sincronização!");
       }
     }
    if(altItem){
       int rc = await montarRequestPut("vendas", body,item.codigo);
       if(rc == 201 || rc == 200  || rc == 204){ //204 - alteracao){
        // item.origem = 1; //foi sincronizada
         item.situacao = 1;
         item.registro = null;// DateTime.now();
         await _alterarVendaOff(item,altItem,item.id); //usa id pq tabela local so conhece id
       }else{// nao conseguiu gravar a venda
         //item.origem = 2; //Nao foi sincronizada
         item.situacao = 0;
         tratarHttpRC(409, "Não foi possível alterar a Venda, que foi registrada Offline e será enviada na próxima sincronização!");
       }
     }
//      tratarHttpRC(rc, "");
    }

  }
  void _gravarOff(Venda item) async{
    bool result = await _db.saveVenda(item);
    if(result == false){
      tratarHttpRC(409, "Não foi possível registrar sua Venda! Tente novamente.");
    }
  }
  void _alterarVendaOff(Venda item, bool altItem,int idVenda) async{ //codigo qdo vem da web e id qdo nao sincronizado

    int result = await _db.atualizarStatusVenda(item, 99); //status 99 - alterarVendaOff
    if(result < 1){ //nao atualizou nenhum registro
      tratarHttpRC(409, "Não foi possível atualizar sua Venda! Tente novamente.");
    }else if(altItem){
      //apagar itens locais
      int qtdeOri = item.itemV.length;
      int apagados = await _db.removeItensVendaAlterada(idVenda);
      if(qtdeOri == apagados){
       // print("apagou mesma quantidade::${qtdeOri}");
      }
      int inseridos = await _db.insereItensVendaAlterada(item,idVenda);
    }
  }

  listarItens() async{
    List<Venda> list = await _db.listVendas();
   // print("qtde itens(service):: ${list.length}");
    return list;
  /*  http.Response req = await montarRequestList("vendas");
    Venda item = Venda();
    if (req.statusCode == 200) {
      return montarResponse(req);
    } else  {
      tratarHttpRC(req.statusCode,"");
    } */
  }

  totalVendas() async{
   double total = await _db.totalVendas();
   // print("**Total Vendas:: ${total}");
    return total;
  }

  void apagarItem(Venda item) async {
    //  tratarHttpRC(rc,"Entrada Copa não pode ser apagada. Há Saída registrada para ela");
 //   if(item.status == 1 || item.status == false ){
   // if(item.origem == 2 ){
    if(item.situacao == 0 ){
      //item status 1 (ainda nao foi enviado para api - basta apagar na base
   //   int rc = await _db.removeVenda(item.id);
   //   print("delete ${rc}");
      _db.atualizarStatusVenda(item, 2);//2 -apagada
      //verificar rc
    }else{ //status 0 - ja foi atualizado
      SharedPreferences prefs = await SharedPreferences.getInstance();
      bool off = prefs.get("isOffline");
      if (off == true) {
        tratarHttpRC(409, "Venda sincronizada não pode ser apagada enquanto estiver Offline!");
      } else { //venda online
        int rc = await montarRequestDel("vendas", item.codigo);
      //  int rc = await montarRequestPut("vendas", item,item.codigo);
        if(rc == 204){ //apagou na api pode apagar local
          int rc = await _db.removeVenda(item.id);
          //verificar rc
        }else {
          tratarHttpRC(rc, "Não foi possível apagar a venda! Tente novamente.");
        }
      }
    }

  }

  montarResponse(req) {
    var dadosJson = json.decode(utf8.decode(req.bodyBytes));
    List<Venda> lista = List();
    var f = NumberFormat("###.###,00", "pt_BR");
    for (var it in dadosJson) {
      Venda item = Venda();
      item.codigo = it["codigo"];
      item.cliente = it["cliente"]["nome"];
    //  item.descricao = it["item"]["descricao"];
      item.total = it["total"];
      item.desconto = it["desconto"];
      String cabecalho = "";
    //  if(item.desconto > 0) {
       // cabecalho = item.cliente+ " - R\$"+f.format(item.total)+" (-R\$"+f.format(item.desconto)+")";
   //   }else{
        cabecalho = item.cliente+" - R\$"+f.format(item.total);
     // }
      item.cabecalho = cabecalho;
      List<ItemVenda> its = List();
      String detalhes = "";

      for(var p in it["itens"]){
          ItemVenda iv = new ItemVenda();
          iv.produtoNome = p["produto"]["nome"];
          iv.produtoCodigo = p["produto"]["id"];
          iv.quantidade = p["quantidade"];
         // iv.total = p["totalParcial"];
          iv.total = p["total"];

      //    if(p["valorDesconto"] > 0){
         //   detalhes = detalhes +"( ${p["quantidade"]} ) ${p["produto"]["nome"]} - ${p["totalParcial"]} - Desc ${p["valorDesconto"]} \n";
        //    detalhes = detalhes +"${p["quantidade"]} - ${p["produto"]["nome"]} R\$"+f.format(p["totalParcial"])+"- R\$" + f.format(p["valorDesconto"])+" \n";
     //       detalhes = detalhes +"${p["quantidade"]} - "+limparDescricao(p["produto"]["nome"])+" R\$"+f.format(p["total"])+"- R\$" + f.format(p["valorDesconto"])+" \n";
     //     }else{
         //   detalhes = detalhes +"( ${p["quantidade"]} ) ${p["produto"]["nome"]} - R\$\ ${p["totalParcial"]} \n";
            detalhes = detalhes +"${p["quantidade"]} - "+limparDescricao(p["produto"]["nome"])+" R\$"+f.format(p["total"])+" \n";

      //    }
          its.add(iv);
      }
      //if(detalhes.length > ){
      // limparDescricao()}
      item.detalhes = detalhes;
      print("Detalhes:: ${item.detalhes}");
      item.itemV = its;
      lista.add(item);
    }
   // print("qtde itens(service):: ${lista.length}");
    return lista;

  }

 limparDescricao(String nomeProduto){
    nomeProduto = nomeProduto.replaceAll(RegExp(" ao | Ao | AO | e | E | o | O "), "");
    nomeProduto = nomeProduto.replaceAll("para", "p/");
    nomeProduto = nomeProduto.replaceAll("Ração", "Raç.");
    //nomeProduto = nomeProduto.replaceAll("sabor", "sab.");
    if(nomeProduto.length > 30) {
      var lista = nomeProduto.split(" ");
      String nomeFormat ="";
      for(var i in lista){
        String nome = i;
        if(nome.length > 5){
          int tam = (nome.length~/2)+2;
       //   print("tama"+tam.toString());
          nomeFormat= nomeFormat + nome.substring(0,tam)+". ";
        }else{
          nomeFormat= nomeFormat + nome+" ";
        }
      }
    //  print("nomeFormatado:"+nomeFormat);
      return nomeFormat;
    }else
      return nomeProduto;
 }

 verificaSincronizacaoVenda(Venda v) async{
    //2- verificar se houve alteracao 3 - status 4- itens
   var req = await montarRequestGet("vendas/status",v.codigo.toString());
 //  var dadosJson = utf8.decode(req.bodyBytes);
   var dadosJson = req.bodyBytes;
   //print("==>${dadosJson}");

   if(!req.bodyBytes.isEmpty) {
   //  print("res:: ${req.bodyBytes}");
     var dadosJson = json.decode(utf8.decode(req.bodyBytes));
   //  print("res:: ${dadosJson}");
     //Venda atu = new Venda();
     var origem = dadosJson['origem']; //3-status 4-itens
     if(origem == 3 || origem == 4){ //alterou so status
       //verificar se foi excluida
       var status =  dadosJson['status']; //1- recebida 2-cancelada
       if (status == 1 || status == 0 ) { //alterar status
         v.receberAgora = status == 1 ? true : false ;
          v.pagamento = dadosJson['pagamento']; //1-cartao 2-dinheiro
          v.dinheiro = dadosJson['dinheiro'];
          v.troco = dadosJson['troco'];
          v.desconto = dadosJson['desconto'];
          v.total = dadosJson['total'];
          int rc = await _db.atualizarStatusVenda(v,status);
         // return v;
       }else if(status ==2){ //apagar a venda
          int rc = await _db.removeVenda(v.id);
          Venda ap =  new Venda();
          ap.origem = 99 ; //apagada
          return ap; //venda nulla - pq apagou
       }
     }
     if (origem == 4){ //alterou itens
       List<ItemVenda> itensAtua = new List();
       dadosJson['itens'].forEach( (el)  {
            //ItemVenda iv = ItemVenda.fromMap(el,dadosJson['codigo']);
         ItemVenda iv = ItemVenda.fromMap(el,v.id); //id local da venda
           // print(iv.id);
          //  print(el);
            itensAtua.add(iv);
        });
       int qtdeOri = v.itemV.length;
       v.itemV = itensAtua;
        //apagar itens locais
       int apagados = await _db.removeItensVendaAlterada(v.id);
       if(qtdeOri == apagados){
        // print("apagou mesma quantidade::${qtdeOri}");
       }
       int inseridos = await _db.insereItensVendaAlterada(v,v.id);
       if(inseridos != itensAtua.length){
         //lancar erro
       //  print("Nao inseriu como deveria: ${inseridos} - ${itensAtua.length}");
       }
       //inserir novos
       //consulta vendaatualizada
       Venda atu = await _db.getVenda(v.codigo); //devolve a venda vinda da web
       return atu;
     }
     return v;
   }

 }
  verificaSincronizacaoVendas() async{ //so esta disponivel se tiver online - portanto todas as vendas estao sincronizadas
    //selecionar tb-vendas todas as vendas sincronizadas
    //for - para cada venda atualizar
    List<Venda> vendas = await _db.listVendas();
    await Future.forEach(vendas, (el) async {
      try {
       await  verificaSincronizacaoVenda(el);
      }on SocketException{
       // print("");
        return 500;
      }on TimeoutException {
      //  print("");
        return 500;
      }  catch(e){ //mesmo dando erro ele vai tentar sincronizar as demais
     // print(e);
    }
    });
  }



}