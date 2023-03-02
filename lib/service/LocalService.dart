import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:seller_app/model/User.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalService {

  final _storage = FlutterSecureStorage();

  Future<File> getFileProdutos() async {
    final diretorio = await getApplicationDocumentsDirectory();
    return File("${diretorio.path}/produtos.json");
  }
  Future<File> getFileClientes() async {
    final diretorio = await getApplicationDocumentsDirectory();
    return File("${diretorio.path}/clientes.json");
  }

  Future<User> login(String user, String pass) async {
    String u = await _storage.read(key: "user");
    String p = await _storage.read(key: "pass");
    User ul = User();
    if (user == u && pass == p) {
      ul.ok = true;
      ul.nome = "";
      ul.roles = "";
      ul.username = "";

      //  String id =  prefs.getString("ID");

    } else {
      ul.ok = false;
      ul.mensagem = "Verifique Usuário e Senha, para acesso Offline!";
    }
    return ul;
  }

  Future<User> isMesmologin(String user) async {
    String u = await _storage.read(key: "user");

    User ul = User();
    if (user == u) {
    ul.atualiza = false;
    } else {
      ul.atualiza = true;

    }
    return ul;
  }

  Future<String> getUser() async {
    String u = await _storage.read(key: "user");
    return u;
  }
/*
  listarProdutos() async {
    try {
      List lista;
     final arquivo = await getFileProdutos();
     await arquivo.readAsString().then( (dados){
       // lista = json.decode(dados);
       print("produtos: ${dados}");
        lista = json.decode(dados);
      });
      return  lista;//arquivo.readAsString();

    } catch (e) {
      return null;
    }
  }

  listarClientes() async {
    try {
      List lista;
      final arquivo = await getFileClientes();
      await arquivo.readAsString().then( (dados){
        lista = json.decode(dados);
      });
      return lista;
    } catch (e) {
      return null;
    }
  }

 */
}