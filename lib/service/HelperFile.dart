import 'dart:convert';

import 'dart:io';

import 'package:path_provider/path_provider.dart';




class HelperFile {
  static final HelperFile  _helper = HelperFile._internal();
  List _produtos;
  List _clientes;

  factory HelperFile (){
    return _helper;
  }

  HelperFile._internal(){}

  get produtos async{
  //  if(_produtos != null){
  //    return _produtos;
  //  }else{
      _produtos = await startProdutos();
      return _produtos;
  //  }
  }

  get clientes async{
  //  if(_clientes != null){
   //   return _clientes;
   // }else{
      _clientes = await startClientes();
      return _clientes;
   // }
  }
  startProdutos() async{
    try{
    List lista;
    final arquivo = await getFileProdutos();
    await arquivo.readAsString().then( (dados){
      // lista = json.decode(dados);
      print("====>>>>produtos do arquivo: ${dados}");
      lista = json.decode(dados);
   //   lista = dados;
    });
    return  lista;//arquivo.readAsString();

  } catch (e) {
  return null;
  }
  }

  startClientes() async{
    try {
      List lista;
      final arquivo = await getFileClientes();
      await arquivo.readAsString().then( (dados){
    //    print("====>>>>produtos do arquivo: ${dados}");
        lista = json.decode(dados);
      });
      return lista;
    } catch (e) {
      return null;
    }
  }
Future<File> getFileProdutos() async {
  final diretorio = await getApplicationDocumentsDirectory();
  return File("${diretorio.path}/produtos.json");
}
Future<File> getFileClientes() async {
  final diretorio = await getApplicationDocumentsDirectory();
  return File("${diretorio.path}/clientes.json");
}


}