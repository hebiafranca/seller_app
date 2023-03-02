import 'dart:async';
import 'dart:io';

import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:intl/intl.dart';
import 'package:seller_app/model/Entrada.dart';
import 'package:seller_app/service/HelperFile.dart';
import 'package:seller_app/service/HttpServiceEntrada.dart';
import 'package:seller_app/service/LocalService.dart';
import 'package:seller_app/views/Login.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Entradas extends StatefulWidget {
  @override
  _EntradasState createState() => _EntradasState();
}

class _EntradasState extends State<Entradas> {
  //BuildContext scaffoldContext;
  BuildContext scaffoldContext;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final f = new DateFormat('dd-MM-yyyy');

  TextEditingController _quantidadeController = TextEditingController();
  TextEditingController _cdProprietarioController = TextEditingController();
  List<Entrada>  _entradasList;
  String _barcode;
  Entrada _item;
  DateTime currentDate;
  int _cor;
  var _f = HelperFile();

  HttpServiceEntrada _service = HttpServiceEntrada();

  Future<List<Entrada>> _listarItens() async{
    try{
    List<Entrada> lista = await _service.listarItens();
    setState(() {
      _entradasList = lista;
   //   print(_entradasList);
    });
    }catch(e){
      return null;
    }



  }
  /*
  _verificarCor() async {
    // final prefs = await SharedPreferences.getInstance();
    // isOffline = prefs.get("isOffline");
    //   isOffline = true;
    final prefs = await SharedPreferences.getInstance().whenComplete(() => null);
    bool isOffline = prefs.get("isOffline");
    print("Offline: ${isOffline}");
     _cor = isOffline == true ? 0xfff8c007 : 0xff20c997;
    print("cor: ${_cor}==> ${isOffline}");
   // return cor;
  }
*/
  @override
  void initState() {
    super.initState();
    _listarItens();
   // _verificarCor();
    //_chamarValida();

  }
  _chamarValida() async{
    int rc = await _service.validarToken();
    if(rc != 200){
      String msg = "Token expirado! Faça login novamente!";
      if(rc == 500){
        msg = "O serviço na nuvem está temporariamente indisponível! Tente mais tarde!";
      }
      setState(() {
        _setMensagem(context,msg, false);
        Timer(Duration(seconds: 2), () {
          Navigator.push(context,
              MaterialPageRoute(builder: (context)=>Login()));
        });
      });

    }
  }
  Future _entradaCopa (context) async {

    try {
      _barcode = "";
      _barcode = await FlutterBarcodeScanner.scanBarcode('#ff6666', 'Cancel', true, ScanMode.BARCODE);
    //
      //
      //  print(_barcode);
   //  var barcoder = await BarcodeScanner.scan();
   //   print("barcode...${barcoder.rawContent}");
  //    _barcode = barcoder.rawContent;
//       _barcode ="0100003"; // "0100029";// "0100017";//"0100045";//"0100049";//"0100043";//"0100047";// "0100007";// "0100030";
     //  print(_barcode);
    } on PlatformException catch (e) {
     // if (e.code == BarcodeScanner.cameraAccessDenied) {
        print("sem permissao da camera");
    //  } else {
    //    print('Unknown error: $e');
     // }
    } on FormatException{
      print('null (User returned using the "back"-button before scanning anything. Result)');
    } catch (e) {
      print('Unknown error: $e');
    }

     if(_barcode == ""){
       //throw("Não foi possível realizar a leitura do Código de Barras");
       _setMensagem(context,"Não foi possível realizar a leitura do Código de Barras", false);
       return null;

     }else {
       //consultar api
       //try {
         Entrada item = await _service.getItem(_barcode);
         if (item != null) {
           _item = item;
         }else{
           _setMensagem (context,"Código de Barras à Granel não pode ser utilizado para dar entrada em Produtos!",false);
           return null;

         }
       //  print("...... fim apresnetacao camera");

         Future<void>  _selectDate(setState) async {
           final DateTime pickedDate = await showDatePicker(
               context: context,
               initialDate: DateTime.now(),
               firstDate: DateTime(2022),
               lastDate: DateTime(2050)).then((value) {
               setState(() {
                 currentDate = value;
                // _item.vencimento = currentDate.toString();
               });
           });

         }
         showDialog(context: _scaffoldKey.currentContext ,//scaffoldContext,
             builder: (context) {
               return StatefulBuilder(builder: (context, setState) {
                 return AlertDialog(
                   title: Text(_item.produtoNome==null?"":_item.produtoNome),
                   content: Column(
                     mainAxisSize: MainAxisSize.min,
                     crossAxisAlignment: CrossAxisAlignment.stretch,
                     children: [
                       //Text(_barcode),
                      // Text(_item.qtde.toString(),
                      //   textAlign: TextAlign.justify,),
                      // Text(_item.produtoNome + " - " + _item.codigoBarras+" ml/g"),
                      // Text(_item.produtoDescricao ),
                      TextField(
                 decoration: InputDecoration(
                 suffixIcon:IconButton(
                     onPressed: (){
                       _codigoProprietario(context);

                   //_novoProduto(context);
                 },
                 icon: Icon(Icons.camera_alt,
                 color: Colors.blue,
                 )),

           //      prefixIcon: IconButton(
             //    onPressed: (){
                 //_produtoController.clear();
            //     },
            //     icon: Icon(
           //      Icons.clear,
           //      color: Colors.blue,
           //      )),
                // border: OutlineInputBorder(),
                 labelText: 'Código de Barras Proprietário',
                 ),
                 autofocus: false,
                   onTap: () =>_codigoProprietario(context),
                 controller: _cdProprietarioController,
                 //focusNode: fieldFocusNode,
                 style: const TextStyle(fontWeight: FontWeight.bold),
                 ),
                       TextField(
                         controller: _quantidadeController,
                         autofocus: true,
                         keyboardType: TextInputType.number,
                         style: TextStyle(fontSize: 20),
                         decoration: InputDecoration(
                             labelText: "Quantidade"
                         ),
                         //onChanged: (text){
                         //  _item.quantidade = int.parse(text);
                         // },
                       ),
                       Text(currentDate==null?"":f.format(currentDate)),
                       ElevatedButton(
                         onPressed: () => _selectDate(setState),
                         child: Text('Data de vencimento'),
                       ),
                     /*  CheckboxListTile(
                           title: Text("Entrada de doação"),
                           value: _doacao,
                           //  selected: _doacao,
                           onChanged: (valor) {
                             setState(() {
                               _doacao = valor;
                             });
                           }
                       ),*/


                     ],
                   ),

                   actions: [
                     TextButton(
                       style: TextButton.styleFrom(
                         backgroundColor:Color(0xff398439),
                         foregroundColor: Colors.white, // foreground
                         ),
                       //color: Color(0xff398439),
                      // textColor: Colors.white,
                       child: Text("Salvar",
                         style: TextStyle(fontSize: 20),),
                       onPressed: () async {
                         //salvar
                         _item.qtde = int.parse(_quantidadeController.text==""?"1":_quantidadeController.text);
                         _item.vencimento = currentDate.toString();
                        try {
                           await _service.novoItem(_item);
                           _setMensagem(context,"Item inserido com sucesso!", true);
                           _quantidadeController.text = "";
                           _cdProprietarioController.text = "";
                           Navigator.pop(context);
                           Navigator.of(context).pushReplacementNamed('/entrada');
                         } on HttpException catch (e) {
                           _setMensagem(context,e.message, false);
                           _quantidadeController.text = "";

                         }
                     },

                     ),
                     TextButton(
                       style: TextButton.styleFrom(
                         backgroundColor:Color(0xfff0ad4e),
                         foregroundColor: Colors.white, // foreground
                       ),
                      // color: Color(0xfff0ad4e),
                      // textColor: Colors.white,
                       child: Text("Cancelar",
                         style: TextStyle(fontSize: 20),),
                       onPressed: () {
                         Navigator.of(_scaffoldKey.currentContext ).pop(context);
                       },
                     )
                   ],
                 );
               });
             });
    //   } on HttpException catch (e) {
    //     _setMensagem(context,e.message, false);
         // Navigator.pop(context);
     //  }
     }
      //setState(() => this.barcode = barcode);



  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: Icon(Icons.close),
            onPressed: () {
              Navigator.of(context).pushNamedAndRemoveUntil('/inicio', (Route<dynamic> route) => false);
            },
          )
        ],
        title: Text("Entradas de Produtos"),
      ),
      body: Container(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                            itemCount:  _entradasList==null?0:_entradasList.length,
                            itemBuilder: (context, index){
                            final  item = _entradasList[index];
                              return Dismissible(
                                key: Key( DateTime.now().millisecondsSinceEpoch.toString() ),
                                  direction: DismissDirection.startToEnd,
                                  onDismissed: (DismissDirection direction) async {
                                    try {
                                      final bool res = await showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              content: Text(
                                                  "Deseja apagar a Entrada?"),
                                              actions: <Widget>[
                                                TextButton(child: Text(
                                                  "Cancelar", style: TextStyle(
                                                    color: Colors.black),),
                                                  onPressed: () {
                                                    Navigator.of(context).pop();
                                                    Navigator.of(context).pushReplacementNamed('/entrada');
                                                  },),
                                                TextButton(child: Text("Apagar",
                                                  style: TextStyle(
                                                      color: Colors.red),),

                                                  onPressed: () {
                                                    _service.apagarItem(item).whenComplete(() {
                                                      Navigator.of(context).pop();
                                                      _setMensagem(context,"Entrada apagada com sucesso!",true);
                                                    });
                                                    ;
                                                    //Navigator.of(context).pushNamedAndRemoveUntil('/vendas', (Route<dynamic> route) => false);
                                                    //Navigator.of(context).pop();
                                                    // _setMensagem(context, "Venda apagada com sucesso!", true);
                                                  },
                                                ),
                                              ],
                                            );
                                          });
                                      return res;
                                    } on HttpException catch (e) {
                                      _setMensagem(context, e.message, false);
                                      setState(() {
                                        // _listarItens();
                                      });
                                    }
                                  },
                                background: Container(
                                  color: Colors.red,
                                  padding: EdgeInsets.all(16),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: <Widget>[
                                      Icon(
                                        Icons.delete,
                                        color: Colors.white,
                                      )
                                    ],
                                  ),
                                ),
                                child: ListTile(
                                  leading: CircleAvatar(
                                    child: Text(item.qtde.toString(),
                                        style: TextStyle(
                                          color: Colors.black
                                        ),),
                                   // backgroundColor: Colors.green,
                                    //backgroundColor: Color(_verificarCor()),
                                    backgroundColor: Color( item.status == 0 ? 0xff20c997 :0xfff8c007),

                                  ),
                                  title: Text("${item.produtoNome}"),
                                  //subtitle: Text("${item.produtoDescricao == null ?"" :item.produtoDescricao}"),
                                  subtitle: Text((item.vencimento == "null" || item.vencimento == "" ) ? "${item.codigoBarras}" : "${item.codigoBarras} - Validade: ${f.format(DateTime.parse(item.vencimento))}"),
                                //  subtitle: Text("${item.registro}"),
                                )
                              );
                            }
              ),
            )
          ],
        ),
      ),  floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
          child: Icon(Icons.add),
          onPressed: (){
           // try {
              _entradaCopa(context);
           // }catch(e){
           //   _setMensagem(context,e, false);
          //  }
        },
        ),
    );
  }


  _setMensagem(BuildContext context,String mensagem,bool success){
    final snackbar = SnackBar(
      backgroundColor: success ? Colors.green : Colors.red,
      duration: Duration(seconds: 4),
      content: Text(mensagem),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackbar);
  }


  _codigoProprietario (BuildContext context) async {
    scaffoldContext = context;
    //var f = NumberFormat("###.00", "pt_BR");
    try {
      //var barcoder = await BarcodeScanner.scan();
      _barcode = "";
      _barcode = await FlutterBarcodeScanner.scanBarcode('#00f227', 'Cancel', true, ScanMode.BARCODE);
      //_barcode = barcoder.rawContent;
      if (_barcode == "") {
        _setMensagem(
            context, "Não foi possível realizar a leitura do Código de Barras",
            false);
      } else {
        _cdProprietarioController.text = _barcode;
        _item.codigoBarras = _barcode;
        //setState(() => this.barcode = barcode);
      }
    } on PlatformException catch (e) {
     // if (e.code == BarcodeScanner.cameraAccessDenied) {
      //  print("sem permissao da camera");
    //  } else {
     //   print('Unknown error: $e');
     // }
    } on FormatException {
      print(
          'null (User returned using the "back"-button before scanning anything. Result)');
    } catch (e) {
      print('Unknown error: $e');
    }
  }
}
