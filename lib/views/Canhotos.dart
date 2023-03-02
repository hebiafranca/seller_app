import 'dart:async';
import 'dart:io';

import 'package:flutter_mobile_vision/flutter_mobile_vision.dart';
import 'package:intl/intl.dart';
import 'package:seller_app/model/Canhoto.dart';
import 'package:seller_app/service/HttpServiceCanhoto.dart';
import 'package:seller_app/views/Login.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Canhotos extends StatefulWidget {
  @override
  _CanhotosState createState() => _CanhotosState();
}

class _CanhotosState extends State<Canhotos> {
  //BuildContext scaffoldContext;
  BuildContext scaffoldContext;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final f = new DateFormat('dd-MM-yyyy');

  TextEditingController _valorController = TextEditingController();
  //TextEditingController _cdProprietarioController = TextEditingController();
  List<Canhoto>  _canhotoList;
  String _barcode;
  Canhoto _item;
  DateTime currentDate = DateTime.now();
  HttpServiceCanhoto _service = HttpServiceCanhoto();
  //ocr
  int _cameraOcr = FlutterMobileVision.CAMERA_BACK;
  bool _autoFocusOcr = true;
  bool _torchOcr = false;
  bool _multipleOcr = false;
  bool _waitTapOcr = false;
  bool _showTextOcr = true;
  Size _previewOcr;
  List<OcrText> _textsOcr = [];

  Future<List<Canhoto>> _listarItens() async{
    try{
    List<Canhoto> lista = await _service.listarItens();
    setState(() {
      _canhotoList = lista;
      print(_canhotoList);
    });
    }catch(e){
      return null;
    }
  }

  @override
  void initState() {
    super.initState();
    FlutterMobileVision.start().then((previewSizes) => setState(() {
       _previewOcr = previewSizes[_cameraOcr].first;
    }));
    _listarItens();

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
  Future _canhotoLer (context) async {

    List<OcrText> texts = [];
    String _textValue="";
    try {
      texts = await FlutterMobileVision.read(
        multiple: true,
        camera: _cameraOcr,
        waitTap: false, //true
        showText: true

      );
      print(texts);
      setState(() {
        _textValue = texts[0].value; // Getting first text block....
        print(" .... leitura de comprovante...");
        for (var ocor in texts) {
          //String valor = ocor.value;
          String valor = ocor.value.split(" ").join("");
          print("::"+valor);
          //RegExp numeroCheck =  new RegExp("(\d{1,3}(\.\d{3})*|\d+)(\,\d{2})?");
          //RegExp numeroCheck =  new RegExp("^(R?\$?|\S?)?([1-9]\d{0,2}((\.\d{3})*|\d*))(\,|.\d{2})?\$");
     //     RegExp numeroCheck =  new RegExp("^(R\$?|RS?)?(\d{1,3}(\.\d{3})*|\d+)(\,\d{2})?");

      //  if(numeroCheck.hasMatch(valor)){
            print(" .... pdoe ser numero...");
            print(valor);
            if(valor.contains("RS|R\$")){
              print("pode ser valor"+ocor.value);
            }
     //     }



         // RegExp numeroPonto =  new RegExp("^[R,S|'\$\']\s [0-9](.|,)[0-9]{1,2}");
          RegExp numeroPonto =  new RegExp("^R\$(\d{1,3}(\.\d{3})*|\d+)(\,\d{2})?");
        if(numeroPonto.hasMatch(ocor.value.split(" ").join(""))){
            print(" .... candidato...");
            print(ocor.value.split(" ").join(""));
          }
        }
        print(" .... fim...");
        _item = new Canhoto();
         _item.valor =2.39;
         _valorController.text = _item.valor.toString();
        //_service.novoItem(can);
       // print(_textValue);
      });
    } on Exception {
      texts.add(new OcrText('Failed to recognize text.'));
    }


      // _setMensagem(context,"Não foi possível realizar a leitura do Código de Barras", false);

         Future<void>  _selectDate(BuildContext context) async {
           final DateTime pickedDate = await showDatePicker(
               context: context,
               initialDate: currentDate,
               firstDate: DateTime(2022),
               lastDate: DateTime(2050));
           if (pickedDate != null && pickedDate != currentDate)
             setState(() {
               currentDate = pickedDate;
               //_item.vencimento = currentDate.toString();
             });
         }
         showDialog(context: _scaffoldKey.currentContext ,//scaffoldContext,
             builder: (context) {
               return StatefulBuilder(builder: (context, setState) {
                 return AlertDialog(
                   //title: Text("Valor"),
                   content: Column(
                     mainAxisSize: MainAxisSize.min,
                     crossAxisAlignment: CrossAxisAlignment.stretch,
                     children: [
                       TextField(
                         controller: _valorController,
                         autofocus: true,
                         keyboardType: TextInputType.number,
                         style: TextStyle(fontSize: 20),
                         decoration: InputDecoration(
                             labelText: "Valor Comprovante"
                         ),
                         //onChanged: (text){
                         //  _item.quantidade = int.parse(text);
                         // },
                       ),
                       Text(f.format(currentDate)),
                       ElevatedButton(
                         onPressed: () => _selectDate(context),
                         child: Text('Data do Fechamento'),
                       ),
                     ],
                   ),

                   actions: [
                     TextButton(
                      // color: Color(0xff398439),
                      // textColor: Colors.white,
                       child: Text("Salvar",
                         style: TextStyle(fontSize: 20),),
                       onPressed: () async {
                         //salvar
                       //  _item.qtde = int.parse(_quantidadeController.text==""?"1":_quantidadeController.text);
                        try {
                           await _service.novoItem(_item);
                           _setMensagem(context,"Item inserido com sucesso!", true);
                           _valorController.text = "";
                           //_cdProprietarioController.text = "";
                           Navigator.pop(context);
                           Navigator.of(context).pushReplacementNamed('/canhoto');
                         } on HttpException catch (e) {
                           _setMensagem(context,e.message, false);
                           _valorController.text = "";

                         }
                     },

                     ),
                     TextButton(

                      // color: Color(0xfff0ad4e),
                     //  textColor: Colors.white,
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
        title: Text("Leitura de Comprovantes"),
      ),
      body: Container(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                            itemCount:  _canhotoList==null?0:_canhotoList.length,
                            itemBuilder: (context, index){
                            final  item = _canhotoList[index];
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
                                                  "Deseja apagar?"),
                                              actions: <Widget>[
                                                TextButton(child: Text(
                                                  "Cancelar", style: TextStyle(
                                                    color: Colors.black),),
                                                  onPressed: () {
                                                    Navigator.of(context).pop();
                                                    Navigator.of(context).pushReplacementNamed('/canhoto');
                                                  },),
                                                TextButton(child: Text("Apagar",
                                                  style: TextStyle(
                                                      color: Colors.red),),

                                                  onPressed: () {
                                                    _service.apagarItem(item).whenComplete(() {
                                                      Navigator.of(context).pop();
                                                      _setMensagem(context,"Comprovante apagado com sucesso!",true);
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
                                 /* leading: CircleAvatar(
                                    child: Text(item.qtde.toString(),
                                        style: TextStyle(
                                          color: Colors.black
                                        ),),
                                   // backgroundColor: Colors.green,
                                    //backgroundColor: Color(_verificarCor()),
                                    backgroundColor: Color( item.status == 0 ? 0xff20c997 :0xfff8c007),

                                  ), */
                                  title: Text("${item.valor}"),
                                  //subtitle: Text("${item.produtoDescricao == null ?"" :item.produtoDescricao}"),
                                 // subtitle: Text(item.vencimento == null ?"${item.codigoBarras}" :"${item.codigoBarras} - ${item.vencimento}"),
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
            _canhotoLer(context);
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

}
