import 'dart:io';

import 'package:seller_app/model/Canhoto.dart';
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

class HttpServiceCanhoto extends HttpServiceCRUD {
  var _db = HelperDAO();

  void novoItem(Canhoto item) async {
    //item.registro = DateTime.now().toString();
    await _gravarOff(item);
  }

  Future<List<Canhoto>> listarItens() async{
    List<Canhoto> list = await _db.listCanhotos();
    return list;
  }

  apagarItem(Canhoto item) async {
    await _db.removeCanhotos();
  }

   void _gravarOff(Canhoto item) async{
     int result = await _db.saveCanhoto(item);
    if(result == null){
      tratarHttpRC(409, "Não foi possível registrar o Comprovante! Tente novamente.");
    }
    print(result);
  }

}