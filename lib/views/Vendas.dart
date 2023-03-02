import 'dart:io';
import 'package:seller_app/model/Venda.dart';
import 'package:seller_app/service/HttpServiceVenda.dart';
import 'package:seller_app/views/NovaVenda.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Vendas extends StatefulWidget {
  @override
  _VendasState createState() => _VendasState();
}

class _VendasState extends State<Vendas> {
  BuildContext scaffoldContext;
 // Map<String, dynamic>  _entradasList;
  List<Venda> _entradasList;
  String _totalVendas;
 bool _isOffline =  false;
  HttpServiceVenda _service = HttpServiceVenda();
  final f = NumberFormat("###,##0.00", "pt_BR");

   _listarItens() async{
     try{
       double tot  = await _service.totalVendas();
       List<Venda> list = await _service.listarItens();
       setState(() {
         _totalVendas = f.format(tot);
         _entradasList = list;
          //print(_entradasList);
       });
     }catch(e){
       return null;
     }
  }
  String limparNome(String t){
    var l = t.split(" ");
    var cpf = l[l.length - 1]; //ultimo
    //print ("cpf :: ${cpf}");
    if(int.tryParse(cpf) == null){
      return t; //nome inteiro pq nao tem numero
    }else{
      var tam  = t.length-cpf.length;
      var n = t.substring(0,tam).trim();
     // print ("nome limpo ${n}");
      return n;
    }
  }
  _verificarCor() async {
    final prefs = await SharedPreferences.getInstance();
    _isOffline = prefs.get("isOffline");
  }
   _apagarItem(Venda item) async{
     try{
        await _service.apagarItem(item);
        await _listarItens();
     } on HttpException catch (e) {
       _setMensagem(context,e.message, false);
      // Navigator.of(context).pushReplacementNamed('/login');
       // Navigator.pop(context);
     }
  }
   _sincronizar() async{
    await _service.verificaSincronizacaoVendas();
    await _listarItens();
  }
  @override
  void initState() {
    super.initState();
    _verificarCor().whenComplete((){
      setState(() {});
    });
   _listarItens();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        actions: [
          Visibility(
          visible: _isOffline == false , //se for online
            child:IconButton(
            icon: Icon(Icons.wifi_protected_setup),
            onPressed: () {
              //Navigator.of(context).pushNamedAndRemoveUntil('/inicio', (Route<dynamic> route) => false);
              //atualizarVendas
               //_service.verificaSincronizacaoVendas().whenComplete((){

            //  setState(() {
              _sincronizar().whenComplete((){
                Navigator.of(context).pushNamedAndRemoveUntil('/vendas', (Route<dynamic> route) => false);
              });
             // });
              //}); //sincronizar todas as vendas
              //setState - talvez atualize
              //_listarItens();

            },
          ),),
          IconButton(
            icon: Icon(Icons.close),
            onPressed: () {
              Navigator.of(context).pushNamedAndRemoveUntil('/inicio', (Route<dynamic> route) => false);
            },
          ),

        ],
        title: Text("Vendas - R\$\ ${_totalVendas == null ? 0 : _totalVendas}"),
      ),
      body: Container(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                  itemCount: _entradasList==null?0:_entradasList.length,
                  itemBuilder: (context, index){
                    scaffoldContext = context;
                    //  List<ItemVenda> lista = _itens;
                  //  Venda item = _entradasList[index];
                   // final  item = _entradasList[index];
                    var item = _entradasList[index];
                 //   print("item::${item}");
                    //print(_isOffline);
                  //  print(item.situacao);
                    return Dismissible(
                        //confirmDismiss: _isOffline == false ||(_isOffline == true && item.origem == 2)  ? null :(DismissDirection direction) async { //se for offline mostra dialog
                        //confirmDismiss: _isOffline == false ||(_isOffline == true && item.situacao == 1)  ? null :(DismissDirection direction) async { //foi sincronizada e esta off
                        confirmDismiss: _isOffline == false || (_isOffline == true && item.situacao != 1)  ? null :(DismissDirection direction) async { //foi sincronizada e esta off
                          return await showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text("Alerta!"),
                                content: const Text("Você esta offline! Não poderá alterar uma Venda já sincronizada! Faça Login Online para alterar a Venda!"),
                                actions: <Widget>[
                                  TextButton(
                                    onPressed: () => Navigator.of(context).pop(false),
                                    child: const Text("Entendi!"),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        key: Key( DateTime.now().millisecondsSinceEpoch.toString() ),
                       // direction: DismissDirection.endToStart,
                        onDismissed: (DismissDirection direction) async{
                          try{
                            if(direction == DismissDirection.startToEnd) {
                               final bool res = await showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    content: Text("Deseja apagar a Venda?"),
                                    actions: <Widget>[
                                      TextButton( child: Text("Cancelar",style: TextStyle(color: Colors.black),),
                                        onPressed: () { Navigator.of(context).pop();
                                        Navigator.of(context).pushReplacementNamed('/vendas');}, ),

                                      TextButton( child: Text( "Apagar", style: TextStyle(color: Colors.red), ),

                                        onPressed: () {
                                          _apagarItem(item).whenComplete((){
                                            Navigator.of(context).pop();
                                            _setMensagem(context, "Venda apagada com sucesso!", true);
                                          });;
                                          //Navigator.of(context).pushNamedAndRemoveUntil('/vendas', (Route<dynamic> route) => false);
                                          //Navigator.of(context).pop();
                                         // _setMensagem(context, "Venda apagada com sucesso!", true);
                                        },
                                      ),
                                    ],
                                  );
                                });
                            return res;
                          }else if(direction == DismissDirection.endToStart) {
                              if (_isOffline == true) {
                                Navigator.push(
                                context,MaterialPageRoute(builder: (context) => NovaVenda(vendaE: item)));
                              } else { //online
                                Venda atualizada = await _service.verificaSincronizacaoVenda(item);
                                if (atualizada != null && atualizada.origem == 99) { //foi excluida
                                  //ser for excluída recarregar a lista e mostrar mensagem de venda excluida na web
                                  return await showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: const Text("Alerta!"),
                                        content: const Text(
                                            "Venda foi Excluída na Web. Não será possível alterá-la!"),
                                        actions: <Widget>[
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.of(context).pop(
                                                    false),
                                            child: const Text("Entendi!"),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                } else {
                                  //atualizar os dados item = atualizada
                                 if(atualizada != null){
                                   item = atualizada;
                                   //print(item);
                                 }
                                  Navigator.push(
                                      context, MaterialPageRoute(
                                      builder: (context) =>
                                          NovaVenda(vendaE: item)));
                                }
                              }
                            }
                          } on HttpException catch (e){
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
                        secondaryBackground: Container(
                          color: Colors.green,
                          padding: EdgeInsets.all(16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: <Widget>[
                              Icon(
                                Icons.edit,
                                color: Colors.white,
                              )
                            ],
                          ),
                        ),
                      child:   Card( color: Color(item.situacao == 1 ? 0xffd3f8e3 :0xfff5fbbc),
                              child: ExpansionTile(
                              title:Transform.translate(
                                offset: Offset(-35, -2),
                           //     child:  Text("${item.cliente==null?"Anônimo":limparNome(item.cliente)} - R\$\ ${f.format(item.total)} ${item.desconto==0?"":"( R\$"+f.format(item.desconto)+")"}",
                                child:  Text("${item.cliente==null?"Anônimo":item.cliente} - R\$"+f.format(item.total)+" ${item.desconto==0?"":"(R\$"+f.format(item.desconto)+")"}",
                                  //  title: Text("${item.cabecalho}",
                                  style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.w500, color: Colors.black    ),

                                ),
                              ),

                                //  leading: item.status == true ? Icon(FontAwesomeIcons.solidClock, size: 15.0,color:Color(item.receberAgora == true ? 0xff20c997: 0xfff8c007)): Icon(FontAwesomeIcons.exchangeAlt, size: 15.0,color:Color(0xfff8c007)),
                                  leading: item.receberAgora == true || item.status == 1 ? Icon(FontAwesomeIcons.check, size: 15.0,color:Color(0xff20c997)): Icon(FontAwesomeIcons.solidClock, size: 15.0,color:Color(0xfff8c007)),
                              children: <Widget>[
                                ListTile(
                                minLeadingWidth : 10,
                                title: Text("${item.detalhes}",
                                // style: TextStyle(fontWeight: FontWeight.w700),
                                style: TextStyle(fontSize: 13.0, fontWeight: FontWeight.normal),
                                ),
                          )]))
                        );
                  }

              ),
            )
          ],
        ),
      ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
          child: Icon(Icons.add),
          onPressed: (){
            Navigator.push(context,
                MaterialPageRoute(builder: (context)=>NovaVenda(vendaE: null))
            );
          },
        )
    );
  }

  _setMensagem(BuildContext context,String mensagem,bool success){
    final snackbar = SnackBar(
      backgroundColor: success ? Colors.green : Colors.red,
      duration: Duration(seconds: 3),
      content: Text(mensagem),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackbar);

  }

}
