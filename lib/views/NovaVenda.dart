import 'dart:async';
import 'dart:io';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:seller_app/model/Venda.dart';
import 'package:seller_app/model/ItemVenda.dart';
import 'package:seller_app/service/HelperFile.dart';
import 'package:seller_app/service/HttpServiceVenda.dart';
import 'package:seller_app/views/Login.dart';
import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NovaVenda extends StatefulWidget {
  Venda vendaE;
  NovaVenda({this.vendaE});

  @override
  State<StatefulWidget> createState() {
    return _NovaVendaState(this.vendaE);
  }
  // /@override
  //_NovaVendaState createState() => _NovaVendaState();
}
extension Ex on double {
  double toPrecision(int n) => double.parse(toStringAsFixed(n));
}
class _NovaVendaState extends State<NovaVenda> {
  BuildContext scaffoldContext;
  Venda vendaE;
  _NovaVendaState(this.vendaE);

  //final _globalKey = GlobalKey<ScaffoldMessengerState>();

  TextEditingController _quantidadeController = TextEditingController();
  TextEditingController _valorController = TextEditingController();
  TextEditingController _pesoController = TextEditingController();
  TextEditingController _produtoController = TextEditingController();
//  TextEditingController _clienteController = TextEditingController();
  TextEditingController _dinheiroController= TextEditingController();
  TextEditingController _descontoController= TextEditingController();
  TextEditingController _percentualController= TextEditingController();

  List<ItemVenda> _itens;
  String _barcode;
  ItemVenda _item;
  Venda _venda;
  bool _receberAgora=false;

  int _tipoPagamento = 0;
  int _percentual = 0;
  List  _produtosList;
  List _clientesList;
  List _vendasList;
  double _troco=0.0;
  double _valorDesconto=0.0;

  bool _isOffline =null;
  var _f = HelperFile();
  String _cliente;
  bool _editClient = true;
  String _titulo;
  bool _isEdit =  false;
  bool _habilita =true;
  bool _altItem = false;
  bool _altStatus = false;
  bool _isDescVenda =  false;

  final f = NumberFormat("###,##0.00", "pt_BR");

  HttpServiceVenda _service = HttpServiceVenda();

  apagarItem(ItemVenda item){
    _itens.remove(item);
    //print("### Antes de apagar Total: ${_venda.total} -- desconto: ${_venda.desconto} - item: ${item.total} - desconto item: ${item.valorDesconto}");
    if(_isEdit != null && _isEdit == true){
      _altItem = true;
    }
    setState(() {
      _venda.total = (_venda.total -  item.total) < 0 ? 0 : (_venda.total -  item.total);
      _venda.desconto = (_venda.desconto -  item.valorDesconto) < 0 ? 0 : (_venda.desconto -  item.valorDesconto);

      _venda.total = _venda.total.toPrecision(2);
      _venda.desconto = _venda.desconto.toPrecision(2);

    });
    //print("Depois de apagar Total: ${_venda.total} - Desconto ${_venda.desconto}");

  }
  List<ItemVenda> _listarItens() {
    List<ItemVenda> lista = [];//await _service.listarItens();
    return lista;

  }
 /* bool _isShow(){
    if((_item.granel == true && _item.produtoUmvGranelSigla == 'uni') || _item.granel == false){
      return true;
    }else{
      false;
    }
  }
*/
  bool _isNumber(String string) {
    // Null or empty string is not a number
    if (string == null || string.isEmpty) {
      return false;
    }
    final number = num.tryParse(string);

    if (number == null) {
      return false;
    }

    return true;
  }
  addItem(ItemVenda item){
    _altItem = true;
    double valorG = item.valorGranel;

    if(item.granel != null && item.granel == true){ //produtoGranel
      item.umv = item.produtoUmvGranelSigla;
      if(item.quantidade != null && item.quantidade > 0){ //tratar quantidade
        double valor = item.quantidade * item.produtoPrecoVendaUmv;
        item.totalParcial = valor.toPrecision(2);
        //print(item.totalParcial);
        if(_venda.total == null){
          _venda.total = 0.0;
        }
     //   _venda.total = _venda.total + item.totalParcial;

        //   item.qtdePedido =

      }else if (item.pesoGranel != null && item.pesoGranel > 0){
        double calc = (item.pesoGranel * item.produtoPrecoVendaUmv) /item.produtoUmvPeso;
        if(_venda.total == null){
          _venda.total = 0.0;
        }
        item.totalParcial =  calc.toPrecision(2);
    //    _venda.total = _venda.total + item.totalParcial;
        //print ("calculo por peso:: ${calc}");
        item.quantidade  =  item.pesoGranel;
   //   }else if(item.valorGranel != null && item.valorGranel > 0){ //por valor
      }else if(valorG != null && valorG > 0){ //por valor
        item.totalParcial = valorG.toPrecision(2);
        //double calc = item.pesoGranel * var peso = (valorG * $scope.item.produto.umvPeso)  /$scope.item.produto.precoVendaUmv;
        if(item.desconto != null && item.desconto >0) {
        //  var pesoDescontoAcres = (item.valorGranel * item.desconto) / 100;
          var pesoDescontoAcres = (valorG * item.desconto) / 100;
          //item.valorGranel = item.valorGranel +pesoDescontoAcres; //aumenta o valor 50 +10% = 55
          valorG = valorG+pesoDescontoAcres; //aumenta o valor 50 +10% = 55
          //print("acresc item ${valorG}");

        }
   //     double peso = (item.valorGranel * item.produtoUmvPeso.toDouble() )/ item.produtoPrecoVendaUmv;
        double peso = (valorG * item.produtoUmvPeso.toDouble() )/ item.produtoPrecoVendaUmv;
        item.quantidade = peso.toPrecision(3);
    //    item.totalParcial = item.valorGranel;

        if(_venda.total == null){
          _venda.total = 0.0;
        }
      //  _venda.total = _venda.total + item.totalParcial;
      }else {
        //insere padrao
        item.totalParcial = item.produtoPrecoVendaUmv;
        item.quantidade  =  item.produtoUmvPeso.toDouble();
        if(_venda.total == null){
          _venda.total = 0.0;
        }
       // _venda.total = _venda.total + item.totalParcial;
      }
    }else{ //por quantidade Nao granel
   //   item.umv = item.produtoUmv; //TODO verificar pac qdo inteiro
      if(item.quantidade != null && item.quantidade > 0){ //tratar quantidade
        double valor = item.quantidade * item.produtoPreco;
        item.totalParcial = valor.toPrecision(2);
        //print(item.totalParcial);
        if(_venda.total == null){
          _venda.total = 0.0;
        }
      //  _venda.total = _venda.total + item.totalParcial;

    //    item.qtdePedido = item.qtdeEstoque - item.quantidade.toInt();
        if( item.qtdePedido != null && item.qtdePedido ~/ 1 == 0){
          item.qtdePedido =  item.qtdePedido.toInt();
        }
      }else{
        //insere padrao
        item.quantidade = 1.0;
        item.totalParcial = item.produtoPreco;
        if(_venda.total == null){
          _venda.total = 0.0;
        }
        //_venda.total = _venda.total + item.totalParcial;

      }
      item.qtdePedido = item.quantidade.toInt() -  (item.qtdeEstoque == null ? 0 :item.qtdeEstoque );
      if( item.qtdePedido ~/ 1 == 0){
        item.qtdePedido =  item.qtdePedido.toInt();
      }
      //print("==>item pedido:: ${item.qtdePedido}");
    }//fim por quantidade nao granel
    //tratar desconto
    if(item.desconto == null){
      item.desconto = 0;
      item.valorDesconto = 0;
    }
    item.valorDesconto = ((item.totalParcial * item.desconto)/100).toPrecision(2);

    if(item.valorGranel == 0 || item.valorGranel == null){
      item.total = (item.totalParcial -  item.valorDesconto).toPrecision(2);
    }else{
      item.total = item.totalParcial; //
    }
    _venda.total = _venda.total + item.total;
    //print("desconto item ${item.valorDesconto}");
    _venda.desconto = (_venda.desconto==null?0:_venda.desconto) + item.valorDesconto;
 //   _venda.total =  (_venda.total ==null?0:_venda.total) -  _venda.desconto; //atualiza desconto total
    //print("antes de arredondar:: ${_venda.total} - ${_venda.desconto} - ${item.valorDesconto}");
  //  _venda.total.toStringAsFixed(2); toPrecision(2);
    _venda.total = _venda.total.toPrecision(2);
    //_venda.desconto.toStringAsFixed(2);
    _venda.desconto = _venda.desconto.toPrecision(2);
    //item.valorDesconto.toStringAsFixed(2);
    item.valorDesconto = item.valorDesconto.toPrecision(2);
    //print("arredondados:: ${_venda.total} - ${_venda.desconto} - ${item.valorDesconto}");
    setState(() {
      // _itens.add(item);
      _itens.insert(0,item);
    });
    _quantidadeController.text = "";
    _pesoController.text = "";
    _valorController.text = "";
    _descontoController.text = "";
//    print("### novo item: ${_venda.total} -- desconto: ${_venda.desconto} - item: ${item.total} - desconto item: ${item.valorDesconto}");
  }


  @override
  void initState() {
    super.initState();
    //print("initState");
    _listarItensOff().whenComplete((){
      setState(() {});
    });
    // _entradasList =  _listarItens();
    _itens =  _listarItens();
    if(vendaE != null){
      _venda = vendaE;
      _titulo = "Editar Venda";
      _editClient = false;
      _receberAgora = _venda.receberAgora==null?false:_venda.receberAgora;
      _tipoPagamento = _venda.pagamento==null?0:_venda.pagamento;

      _troco = _venda.troco==null?0:_venda.troco;
      _percentual = _venda.percentual==null?0:_venda.percentual;
      _isEdit = true;
      _isDescVenda =  _venda.isDescVenda==0 ? true : false;

     // aqui

      //print("***venda Edicao ${_venda}");
      setState(() {
        _itens = _venda.itemV;
        _cliente = _venda.cliente;
        _habilita = true;
        _dinheiroController.text = _venda.dinheiro == null ?"":_venda.dinheiro.toString();
        _descontoController.text = _venda.percentual == null ?"":_venda.percentual.toString();
        _percentualController.text =  _venda.percentual == null ?"":_venda.percentual.toString();
      });
    }else {
      _titulo = "Nova Venda";
      _venda = new Venda();
    }

    // _chamarValida();
    //NumberFormat.simpleCurrency(locale: 'pt_BR');
    //Intl.defaultLocale = 'pt_BR';

  }

  Future<void> _listarItensOff() async{
    SharedPreferences  prefs = await SharedPreferences.getInstance();
    bool off = prefs.get("isOffline");
    setState(() {
      _isOffline = off;
    });
    List listaP;
    List lista;
    try{
      //    if(_isOffline == true) {
      //LocalService lservice = LocalService();
      //listaP = await _f.produtos;//lservice.listarProdutos();
      listaP = await _f.produtos;//lservice.listarProdutos();
      setState(() {
        _produtosList = listaP;
      });

      lista = await _f.clientes;//lservice.listarClientes();
      setState(() {
        _clientesList = lista;
        //print("Lista clientes::${_clientesList}");
      });
    }catch(e){
      return null;
    }


  }
  _chamarValida() async{
    int rc = await _service.validarToken();
    if(rc != 200){
      String msg = "Token expirado! Faça login novamente!";
      if(rc == 500){
        msg = "O serviço na nuvem está temporariamente indisponível! Tente mais tarde!";
      }
      setState(() {
        _setMensagem(context, msg, false);
        Timer(Duration(seconds: 2), () {
          Navigator.push(context,
              MaterialPageRoute(builder: (context)=>Login()));
        });
      });

    }
  }
  //------------- finalizar venda ------------------
  _finalizaVenda(){
    setState(() {
      print("====== setState - Finaliza venda"+_percentualController.text);
      print("====== setState - Finaliza venda"+_venda.percentual.toString());
      _habilita = true;
      _venda.totalSemDesconto =  _venda.total;
      print("====== setState - Finaliza venda:: "+_venda.totalSemDesconto.toString());
    });
     showDialog(context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setState) {
            return AlertDialog(
              title: Text( _percentual > 0 || (_venda.percentual  != null && _venda.percentual >0) ? "Total: R\$ "+f.format(_venda.total) +"("+f.format(_venda.desconto)+")" : "Total: R\$ "+f.format(_venda.total) ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    controller: _percentualController,
                    autofocus: true,
                    keyboardType: TextInputType.number,
                    style: TextStyle(fontSize: 20),
                    decoration: InputDecoration(labelText: "Desconto %",
                        prefixIcon: IconButton(
                          onPressed: (){
                            setState(() {
                            _percentualController.text = "";
                            _venda.isDescVenda = _isDescVenda;
                           _venda.total =  _venda.totalSemDesconto;
                            if(_valorDesconto >0.0){
                              _venda.desconto= _venda.desconto - _valorDesconto;
                            }//else{
                             // print("====>> ${_valorDesconto}");
                             // _venda.desconto=0;
                           // }
                            _isDescVenda =  false;
                            _venda.isDescVenda = _isDescVenda;

                            _percentual = 0;
                            _venda.percentual = _percentual;

                            });
                          },
                            icon:Icon(Icons.clear,color: Colors.blue,)),
                        suffixIcon:IconButton(
                        onPressed: (){
                          if(_percentualController.text.length > 0){
                            _percentual = int.parse(_percentualController.text);
                           // print("entrou no if percuentual");
                            _valorDesconto = ((_venda.total * _percentual) /  100).toPrecision(2);
                            //print("valor desconto" + _valorDesconto.toString());
                            // _venda.totalSemDesconto = _venda.total;
                            //_venda.total = _venda.total - valorDesconto;
                            setState(() {
                              _venda.total = _venda.total - _valorDesconto;
                              //TODO nao deixar somar descontos dos itens + desconto da venda
                              //_venda.desconto = _venda.desconto + _valorDesconto;
                              _venda.desconto =  _valorDesconto;
                              _venda.percentual = _percentual;
                              _isDescVenda = true;
                              _venda.isDescVenda = _isDescVenda;
                            });
                          }else{
                           //_venda.total =  _venda.totalSemDesconto;
                            setState(() {
                              _venda.total =  _venda.totalSemDesconto;
                              if(_valorDesconto >0.0){
                                _venda.desconto= _venda.desconto - _valorDesconto;
                              }//else{
                                //_venda.desconto=0;
                              //}

                              _percentual = 0;
                              _venda.percentual = _percentual;
                            });
                          }
                        },
                  //icon: Icon(Icons.touch_app,
                  icon: Icon(Icons.touch_app_sharp,
                    color: Colors.blue,
                  )),),
                    //onChanged: (text){
                //   onTap:() {
                      // _item.quantidade = double.parse(text);

               //       setState(() {
               //       });

                //    },
                  ),
                  CheckboxListTile(
                      title: Text("Receber agora"),
                      value: _receberAgora,
                      //  selected: _doacao,
                      onChanged: (valor) {
                        setState(() {
                          _receberAgora = valor;
                          _altStatus = true;

                          if(valor) {
                            _habilita = false;
                          }else{
                            _habilita = true;
                          }
                        });
                      }
                  ),
                  Visibility(
                      visible: _receberAgora == true ,
                      child:
                      new Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            new Radio(
                                value: 1,
                                groupValue: _tipoPagamento,
                                onChanged:(valor) {
                                  setState(() {
                                    _tipoPagamento = valor;
                                    _habilita = true;
                                  });
                                }
                            ),
                            new Text('Cartão',
                              style: new TextStyle(fontSize: 16.0),
                            ),
                            new Radio(
                                value: 2,
                                groupValue: _tipoPagamento,
                                onChanged:(valor) {
                                  setState(() {
                                    _tipoPagamento = valor;
                                    _habilita = true;
                                  });
                                }
                            ),
                            new Text('Dinheiro',
                              style: new TextStyle(fontSize: 16.0),
                            ),
                          ])),
                  Visibility(
                      visible: _tipoPagamento > 1 && _receberAgora == true ,
                      child:  TextField(
                        inputFormatters: [CurrencyTextInputFormatter(
                          locale: 'pt_Br',
                          decimalDigits: 2,
                          symbol: '', // or to remove symbol set ''.
                        )],
                        controller: _dinheiroController,
                        autofocus: true,
                        keyboardType: TextInputType.number,
                        style: TextStyle(fontSize: 20),
                        decoration: InputDecoration(labelText: "Cliente R\$"),
                        onChanged: (text){
                          // _item.quantidade = double.parse(text);
                          setState(() {
                            var retiraP = text.replaceAll(".","");
                            var formaN =  retiraP.replaceAll(",",".");
                            //print("venda: ${_venda.total}");
                           // print("Dinheiro:"+formaN);
                            _venda.dinheiro = double.parse( formaN);
                        //    if(_venda.dinheiro < _venda.total ){_habilita = false;}
                            var troco = double.parse(formaN) - _venda.total;
                            _troco = troco.toPrecision(2);
                            //print("troco: ${_troco}");
                          });

                        },
                      )
                  ),
                  Visibility(
                    visible: _tipoPagamento > 1 && _receberAgora == true,
                    child:   Text(_troco <= 0 ?"0,0":"Troco: R\$ "+f.format(_troco),
                      style: new TextStyle(fontSize: 20.0,fontWeight: FontWeight.bold),),
                  ),
                 ],
              ),

              actions: [
                TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor: Color(0xff398439),
                    foregroundColor: Colors.white,
                  ),
                  //color: Color(0xff398439),
                  //textColor: Colors.white,
                  child: Text("Finalizar Venda",
                    style: TextStyle(fontSize: 20),),
                    onPressed: _habilita == false ? null : () async {
                    try{
                      setState((){_habilita = false;});
                    _venda.itemV = _itens;
                    if(_receberAgora){
                      _venda.status = 1; //
                    }else{
                      _venda.status = 0; //
                    }
                    _venda.receberAgora = _receberAgora;
                    _venda.pagamento = _tipoPagamento;
                    _venda.troco = _troco;
                    if(_venda.clienteCodigo == null){ //nao teve onselected
                     // print("capturou novo cliente ${_cliente} - ${_habilita}");
                  //    if(_clienteController.text.length > 0){ //digitou nome e cpf de novo cliente
                      if(_cliente != null &&_cliente.length > 0){
                    //    _venda.cliente = _clienteController.text;
                        _venda.cliente = _cliente;
                        _venda.clienteCodigo = 0; //novo cliente
                      //  print("Novo cliente:${_venda.cliente}");
                      }
                    }
                 //   print("arredondados:: ${_venda.total} - ${_venda.desconto} - ${_venda.troco}");
                    //if(_venda.codigo != null ){
                    if(_isEdit != null && _isEdit == true){
                      //try catch - token expirado
                    //  try{
                        await _service.alterarVenda(_venda,_altItem,_altStatus);
                 //     } on HttpException catch (e) {
                 //     _setMensagem(e.message, false);
                 //     Navigator.of(context).pushReplacementNamed('/login');
                      // Navigator.pop(context);
                 //     }
                      _setMensagem(context,"Venda Alterada com sucesso!", true);
                    }else{
                      await _service.novaVenda(_venda);
                      _setMensagem(context,"Venda Inserida com sucesso!", true);
                      _quantidadeController.text = "";
                    }
                    Timer(Duration(milliseconds: 500), () {
                     setState((){_habilita = true;});
                     Navigator.pop(context);
                     Navigator.of(context).pushReplacementNamed('/vendas');
                    });
            } on HttpException catch (e) { //tratar erros
                setState((){_habilita = true;});
                Navigator.pop(context);
                _setMensagem(context,e.message, false);
                Navigator.of(context).pushReplacementNamed('/vendas');
            } }, ),
                // ignore: deprecated_member_use
                TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor: Color(0xfff0ad4e),
                    foregroundColor: Colors.white,
                    shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(2)),
                  ),),

                 // color: Color(0xfff0ad4e),
                 // textColor: Colors.white,
                  child: Text("Cancelar",
                    style: TextStyle(fontSize: 20),),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                )
              ],
            );
          });
        });
  }
  _abrirTelaNovoProduto(){
    showDialog(context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setState) {
            return AlertDialog(
              // title: Text(_item.produtoNome, style: TextStyle(fontSize: 18),),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  //Text(_barcode),
                  Text(_item.produtoNome==null?"":_item.produtoNome, style: TextStyle(fontSize: 15),),
                  Visibility(visible: _item.produtoGranel == true,
                    child:  CheckboxListTile(
                         contentPadding: EdgeInsets.all(0),
                       // title: Text("Granel - UBV ${_item.produtoUmvPeso==null?"0":_item.produtoUmvPeso} ${_item.produtoUmvGranelSigla ==null ? "":_item.produtoUmvGranelSigla} por R\$ ${f.format(_item.produtoPrecoVendaUmv==null?0:_item.produtoPrecoVendaUmv)}" ,style: TextStyle(fontSize: 15),),
                        //title: Text("R\$${f.format(_item.produtoPreco)} - UBV ${_item.produtoUmvPeso==null?"0":_item.produtoUmvPeso} ${_item.produtoUmvGranelSigla ==null ? "":_item.produtoUmvGranelSigla} por R\$${f.format(_item.produtoPrecoVendaUmv==null?0:_item.produtoPrecoVendaUmv)}" ,style: TextStyle(fontSize: 14),),
                        //title: Text("R\$ ${f.format(_item.produtoPreco)} - ${_item.produtoUmvPeso==null?"0":_item.produtoUmvPeso} ${_item.produtoUmvGranelSigla ==null ? "":_item.produtoUmvGranelSigla} por R\$ ${f.format(_item.produtoPrecoVendaUmv==null?0:_item.produtoPrecoVendaUmv)}" ,style: TextStyle(fontSize: 15),),
                        title: Text("${f.format(_item.produtoPreco)} / ${_item.produtoUmvPeso==null?"0":_item.produtoUmvPeso} ${_item.produtoUmvGranelSigla ==null ? "":_item.produtoUmvGranelSigla}: ${f.format(_item.produtoPrecoVendaUmv==null?0:_item.produtoPrecoVendaUmv)}" ,style: TextStyle(fontSize: 15),),
                        value: _item.granel ==null?false:_item.granel,
                        //  selected: _doacao,
                        onChanged: (valor) {
                          setState(() {
                            _item.granel = valor;
                          });
                        }
                    ),),
                 /* Visibility(visible: _item.granel == true,
                   // child: Text("UBV ${_item.produtoUmvPeso==null?"0":_item.produtoUmvPeso}" + _item.produtoUmvGranelSigla ==null ?"":_item.produtoUmvGranelSigla +" por R\$"+f.format(_item.produtoPrecoVendaUmv==null?0:_item.produtoPrecoVendaUmv),
                    child: Text("UBV ${_item.produtoUmvPeso==null?"0":_item.produtoUmvPeso} ${_item.produtoUmvGranelSigla ==null ? "":_item.produtoUmvGranelSigla} por R\$ ${f.format(_item.produtoPrecoVendaUmv==null?0:_item.produtoPrecoVendaUmv)}",
                      textAlign: TextAlign.justify, style: TextStyle(fontSize: 15),),
                  ),*/
                  Visibility(visible: _item.produtoGranel == false || _item.produtoGranel == null,
                    // child: Text("UBV ${_item.produtoUmvPeso==null?"0":_item.produtoUmvPeso}" + _item.produtoUmvGranelSigla ==null ?"":_item.produtoUmvGranelSigla +" por R\$"+f.format(_item.produtoPrecoVendaUmv==null?0:_item.produtoPrecoVendaUmv),
                    child: Text(_item.desconto==0 || _item.desconto==null?"Preço R\$${f.format(_item.produtoPreco)}":"Preço R\$${f.format(_item.produtoPreco)} - Desc. ${_item.desconto}%",
                      textAlign: TextAlign.justify, style: TextStyle(fontSize: 15),),
                  ),
                  //Text(_item.produtoGranel == true ? _item.produtoPrecoVendaUmv.toString()+_item.produtoUmvPeso.toString() + _item.produtoUmvGranelSigla :_item.produtoPreco.toString(),textAlign: TextAlign.justify,),
                  //  Text(_item.total.toString() + " - " + _item.produtoPrecoUmv.toString() + _item.produtoUmvPeso.toString() ),
                  Visibility(
                      visible: ((_item.produtoGranel == true && (_item.produtoUmvGranelSigla == 'uni' || _item.produtoUmvGranelSigla == 'un')) || (_item.granel == null || _item.granel == false)),//_isShow() ,
                      child:TextField(
                        controller: _quantidadeController,
                        //   autofocus: true,
                        keyboardType: TextInputType.number,
                        style: TextStyle(fontSize: 15),
                        decoration: InputDecoration(
                            labelText: "Quantidade"
                        ),
                        onChanged: (text){
                          _item.quantidade = double.parse(text);
                        },
                      )),
                  Visibility(
                      visible:_item.granel == true ,
                      child: TextField(
                        inputFormatters: [CurrencyTextInputFormatter(
                          locale: 'pt_Br',
                          decimalDigits: 2,
                          symbol: '', // or to remove symbol set ''.
                        )],
                        controller: _valorController,
                        //    autofocus: true,
                        keyboardType: TextInputType.number,
                        style: TextStyle(fontSize: 15),
                        decoration: InputDecoration(
                            labelText: "Valor"
                        ),
                        onChanged: (text){
                          var formaN =  text.replaceAll(",",".");
                          print("Dinheiro:"+formaN);
                          _item.valorGranel = double.parse(formaN);
                        },
                      )) ,
                  Visibility(
                      visible:_item.granel == true && (_item.produtoUmvGranelSigla != 'uni' && _item.produtoUmvGranelSigla != 'un'),
                      child: TextField(
                        inputFormatters: [CurrencyTextInputFormatter(
                          locale: 'pt_Br',
                          decimalDigits: 3,
                          symbol: '', // or to remove symbol set ''.
                        )],
                        controller: _pesoController,
                        //     autofocus: true,
                        keyboardType: TextInputType.number,
                        style: TextStyle(fontSize: 15),
                        decoration: InputDecoration(
                            labelText: " ou Peso"
                        ),
                        onChanged: (text){
                          print("textPeso: "+text);
                          var formaN =  text.replaceAll(",",".");
                          print("Dinheiro:"+formaN);
                          _item.pesoGranel = double.parse(formaN);
                          print(_item.pesoGranel);
                        },
                      )),
                  TextField(
                    controller: _descontoController,
                    //    autofocus: true,
                    keyboardType: TextInputType.number,
                    style: TextStyle(fontSize: 15),
                    decoration: InputDecoration(
                        labelText: "Desconto"
                    ),
                    onChanged: (text){
                      _item.desconto = int.parse(text);
                      //_item.desconto = double.parse(text); //TODO a principio percentual e inteiro - 06/01/23
                    },
                  )
                ],
              ),

              actions: [
                TextButton(
                  style: TextButton.styleFrom(
                      backgroundColor: Color(0xff398439),
                      foregroundColor: Colors.white),
                //  color: Color(0xff398439),
                //  textColor: Colors.white,
                  child: Text("Incluir",
                    style: TextStyle(fontSize: 15),),
                  //   onPressed: () async {
                  onPressed: () {
                    //salvar
                    //   _item.quantidade = int.parse( _quantidadeController.text);
                    //   _item.isDoacao = _doacao;

                    //   await _service.novoItem(_item);
                   // print("**** item completo:: ${_item}");
                    addItem(_item);
                    _setMensagem(context,"Item inserido com sucesso!", true);
                    setState(() {
                      _quantidadeController.text = "";
                      _produtoController.text = "";
                    //  _item = null;
                    });
                    //_item =  null;
                    Navigator.pop(context);
                    //    _item.isDoacao = false;
                    //  _doacao = false;
                    /*    Timer(Duration(seconds: 1), () {
                             Navigator.pop(context);
                             Navigator.pushReplacementNamed(
                                 context, '/nova-venda');
                           }); */
                  },

                ),
                TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor: Color(0xfff0ad4e),
                    foregroundColor: Colors.white
                  ),
                 // color: Color(0xfff0ad4e),
                //  textColor: Colors.white,
                  child: Text("Cancelar",
                    style: TextStyle(fontSize: 15),),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                )
              ],
            );
          });
        });
  }
  _novoProduto (BuildContext context) async {
    scaffoldContext = context;
    var f = NumberFormat("###.00", "pt_BR");
    try {
      if(_item == null) {
        _item = new ItemVenda();
       // var barcoder = await BarcodeScanner.scan();
        _barcode = "";
        _barcode = await FlutterBarcodeScanner.scanBarcode('#00f227', 'Cancel', true, ScanMode.BARCODE);
        //   print("barcode...${barcoder.rawContent}");
        //_barcode = barcoder.rawContent;
      //  _barcode ="0100018"; //"01 44";//"0100018";//"0100051";//"0100011";//"0100035";//"0100050";//"0100020";//"0100048";//"0100050";//
        if (_barcode == "") {
          _setMensagem(context,"Não foi possível realizar a leitura do Código de Barras", false);
        } else {
          //consultar api
          try {
            ItemVenda item = await _service.getItem(_barcode);
            if (item != null) {
              setState(() {
                _item = item;
              });
           }else{
              _setMensagem(context,"Código de Barras não identificado! Verifique cadastro do produto!", false);
              return null;
            }
            print("...... fim apresnetacao camera");
            _abrirTelaNovoProduto();
          } on HttpException catch (e) {
            _setMensagem(context,e.message, false);
            // Navigator.pop(context);
          }
        }
      } else{ //produto digitado
        print("produto selecionado via comboo...");
        _abrirTelaNovoProduto();
        //_barcode
      }
      print("Produto selecionado: ${_item.toJson().toString()}");
      //setState(() => this.barcode = barcode);
    } on PlatformException catch (e) {
     // if (e.code == BarcodeScanner.cameraAccessDenied) {
    //    print("sem permissao da camera");
    //  } else {
     //   print('Unknown error: $e');
     // }
    } on FormatException{
      print('null (User returned using the "back"-button before scanning anything. Result)');
    } catch (e) {
      print('Unknown error: $e');
    }


  }



  @override
  Widget build(BuildContext context) {

    return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          actions: [
            IconButton(
              icon: Icon(Icons.close),
              onPressed: () {
                Navigator.of(context).pushNamedAndRemoveUntil('/vendas', (Route<dynamic> route) => false);
              },
            )
          ],
          title: Text(_titulo),
        ),
        body:
        Container(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
            Visibility(visible: _editClient != null && _editClient == true,
            child:
              Padding(
                padding: EdgeInsets.all(15.0),
                child: Autocomplete(
                  optionsBuilder: (TextEditingValue textEditingValue) {
                    if(textEditingValue != null && textEditingValue.text.length >= 3) { //erro suchmethod
                      return _clientesList.where((produto) {
                        if (_isNumber(textEditingValue.text)) {
                          if (produto['cpf'] != null) {
                            return produto['cpf'].toLowerCase().contains(
                                textEditingValue.text.toLowerCase());
                          } else {
                            return produto['nome'].toLowerCase().contains(
                                textEditingValue.text.toLowerCase());
                          }
                        } else {
                          return produto['nome'].toLowerCase().contains(
                              textEditingValue.text.toLowerCase());
                        }
                      });
                    }//else
                    else{
                      return const Iterable<String>.empty();
                    }
                  },
                  displayStringForOption: (cliente) =>"${cliente['nome']}  ${cliente['cpf']==null?"":cliente['cpf']}",
                  fieldViewBuilder: (
                      BuildContext context,
                      TextEditingController _clienteController,
                      FocusNode fieldFocusNode,
                      VoidCallback onFieldSubmitted
                      ) {
                    return TextField(
                      decoration: InputDecoration(
                        prefixIcon: IconButton(
                            onPressed: (){
                              _clienteController.clear();
                            },
                            icon: Icon(
                              Icons.clear,
                              color: Colors.blue,
                            )),
                        border: OutlineInputBorder(),
                        labelText: 'Cliente',
                      ),
                      controller: _clienteController,
                      focusNode: fieldFocusNode,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                      onChanged: (text){
                        print("novo cliente ${text}");
                        setState(() {
                          _cliente = text;
                        });

                      },
                    );
                  },
                  onSelected: (selection) {
                    //  print('Selected: ${selection['cpf']}');
                    //  setState(() {
                    //  _clienteController.text =selection;//" ${selection['nome']}  ${selection['cpf']}";
                    // var cpf = selection['cpf'];
                    //  var cod = selection['codigo']==null?0:selection['codigo']; //se nao tiver codigo
                    _venda.clienteCodigo = selection['codigo']; //enviar cpf
                    print("cliente codigo::${selection['codigo'].toString()}");
                    _venda.cliente = selection['nome'];

                    FocusScope.of(context).nextFocus();
                    //   });
                  },
                  optionsViewBuilder: (
                      BuildContext context,
                      AutocompleteOnSelected onSelected,
                      Iterable options
                      ) {
                    return Align(
                      alignment: Alignment.topLeft,
                      child: Material(
                        child: Container(
                          width: 350,
                          color: Colors.black12,
                          child: ListView.builder(
                            padding: EdgeInsets.all(10.0),
                            itemCount: options == null ? 0 :options.length,
                            itemBuilder: (BuildContext context, int index) {
                              final  option = options.elementAt(index);
                              return GestureDetector(
                                onTap: () {
                                  // onSelected("${option['nome']}  ${option['cpf']==null?"":option['cpf']}");
                                  onSelected(option);
                                },
                                child: ListTile(
                                  //  title: Text(option.values.first, style: const TextStyle(color: Colors.black)),
                                  title: Text("${option['nome']}  ${option['cpf']==null?"":option['cpf']}", style: const TextStyle(color: Colors.black)),
//                          title: Text(option['cpf'], style: const TextStyle(color: Colors.black)),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
          ),
          Visibility(visible: _editClient == false,
            child: Text(_cliente == null?"Venda Anônima" :_cliente,
                style: const TextStyle(fontSize: 18, color: Colors.black, fontWeight: FontWeight.bold))
          ),
              Padding(
                padding: EdgeInsets.all(15.0),
                child: Autocomplete(
                  optionsBuilder: (TextEditingValue textEditingValue) {
                    if(textEditingValue != null && textEditingValue.text.length >= 3) { ////dava erro de suchmethod
                      return _produtosList.where((produto) {
                        return produto['nome'].toLowerCase().contains(
                            textEditingValue.text.toLowerCase()) ||
                            produto['codigoBarras'].toLowerCase().contains(
                            textEditingValue.text.toLowerCase()) ||
                            produto['codigoBarrasGranel'].toLowerCase().contains(
                                textEditingValue.text.toLowerCase());
                      });
                    }//
                     else {return const Iterable<String>.empty();}

                  },
                  displayStringForOption: (produto) => produto['nome'],
                  fieldViewBuilder: (
                      BuildContext context,
                      TextEditingController _produtoController,
                      FocusNode fieldFocusNode,
                      VoidCallback onFieldSubmitted
                      ) {
                    return TextField(
                      decoration: InputDecoration(
                        suffixIcon:IconButton(
                            onPressed: (){
                              setState(() {
                                _item  = null;
                              });
                              _novoProduto(context);
                            },
                            icon: Icon(Icons.camera_alt,
                              color: Colors.blue,
                            )),

                        prefixIcon: IconButton(
                            onPressed: (){
                              _produtoController.clear();
                            },
                            icon: Icon(
                              Icons.clear,
                              color: Colors.blue,
                            )),
                        border: OutlineInputBorder(),
                        labelText: 'Produto / Código de Barras',
                      ),
                      autofocus: true,
                      //   onTap: () =>_novoProduto(context),
                      controller: _produtoController,
                      focusNode: fieldFocusNode,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    );
                  },
                  onSelected: (selection) {  //autocomplete
                    //  print('Selected: ${selection['cpf']}');
                   // print("option produto:: ${selection}");
                    _item = new ItemVenda();
                    _item.produtoCodigo = selection['id'];
                    _item.produtoNome = selection['nome'];
                    _item.produtoPeso = selection['peso'];
                    _item.produtoPreco = selection['precoVenda'];
                    _item.produtoPrecoVendaUmv = selection['precoVendaUmv']==null?double.parse("0"):double.parse(selection['precoVendaUmv'].toString());
                    _item.qtdeEstoque = selection['qtdeEstoque'];
                    _item.qtdeEstoqueGranel = selection['qtdeEstoqueGranel'];
                //    _item.produtoUmvGranelSigla = selection['umvGranel']==null?"":selection['umvGranel']['sigla'];
                    _item.produtoUmvGranelSigla = selection['umvGranelSigla']==null?"":selection['umvGranelSigla'];
                    _item.produtoGranel = selection['granel']; //mostrar
                    _item.produtoUmvPeso = selection['umvPeso'];
                    _item.produtoUmv = selection['umvSigla']; //umvProduto
                    _item.desconto = selection['desconto'];
                  //  _item.produtoUmv = selection['umvGranel']['codigo'];
                    //  _produtoController.text =selection['nome'];//" ${selection['nome']}  ${selection['cpf']}";
                    //umv: {codigo: 25, descricao: Pacote, tipo: 2},
                    // = selection[''];
                    //_produtoController.clear();
                    _novoProduto(context);
                    // FocusScope.of(context).nextFocus();
                    //   setState(() {
                    //     _produtoController.text ="";
                    //      _produtoController.clear();
                    //    });
                  },
                  optionsViewBuilder: (
                      BuildContext context,
                      AutocompleteOnSelected onSelected,
                      Iterable options
                      ) {
                    return Align(
                      alignment: Alignment.topLeft,
                      child: Material(
                        child: Container(
                          width: 350,
                          color: Colors.black12,
                          child: ListView.builder(
                            padding: EdgeInsets.all(5.0),
                            itemCount: options ==null ? 0 : options.length,
                            itemBuilder: (BuildContext context, int index) {
                              final  option = options.elementAt(index);
                              return GestureDetector(
                                onTap: () {
                                  //   onSelected("${option['nome']}");
                                  setState(() {
                                    _produtoController.clear();
                                  });
                                  onSelected(option);
                                },
                                child: ListTile(
                                  //  title: Text(option.values.first, style: const TextStyle(color: Colors.black)),
                                  title: Text("${option['nome']}  - R\$\ ${f.format(option['precoVenda'])}", style: const TextStyle(color: Colors.black,fontSize: 15)),
//                          title: Text(option['cpf'], style: const TextStyle(color: Colors.black)),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              /*   RaisedButton(
              child: Text('Add'),
              onPressed: () {
             //   addItemToList();
              },
            ),*/
              Expanded(
                child: ListView.builder(
                    itemCount: _itens.length,
                    itemBuilder: (context, index){
                      scaffoldContext = context;
                      //  List<ItemVenda> lista = _itens;
                      ItemVenda item = _itens[index];
                      return Dismissible(
                          key: Key( DateTime.now().millisecondsSinceEpoch.toString() ),
                          direction: DismissDirection.startToEnd,
                          onDismissed: (DismissDirection direction) async{
                            try{
                              // await _service.apagarItem(item.produtoCodigo);
                              apagarItem(_itens[index]);
                              final snackbar = SnackBar(
                                backgroundColor: Colors.green,
                                duration: Duration(seconds: 5),
                                content: Text("Produto removido com sucesso!!"),
                              );
                             // Scaffold.of(scaffoldContext).showSnackBar(snackbar);
                              ScaffoldMessenger.of(context).showSnackBar(snackbar);

                            } on HttpException catch (e){
                              _setMensagem(context,e.message, false);
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
                              child: Text(item.quantidade.toStringAsFixed(item.quantidade.truncateToDouble() == item.quantidade ? 0 : 3),
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 15
                                ),),
                              backgroundColor: item.qtdePedido !=null && item.qtdePedido > 0 ? Colors.amber : Colors.blue,

                            ),
                            //title: Text(item.produtoPrecoVendaUmv > 0?"  Preço:  R\$"+f.format(item.produtoPrecoVendaUmv)+" - Total: R\$"+f.format(item.totalParcial):"  Preço:  R\$"+f.format(item.produtoPreco)+" - Total: R\$"+f.format(item.totalParcial)),
                        //    title: Text(item.produtoPrecoVendaUmv == null?"  Preço:  R\$"+f.format(item.produtoPreco)+" - Total: R\$"+f.format(item.totalParcial): "  Preço:  R\$"+f.format(item.produtoPrecoVendaUmv)+" - Total: R\$"+f.format(item.totalParcial)),
                            title: Text("R\$ ${f.format(item.totalParcial==null?0:item.totalParcial)} ${item.valorDesconto==0 ||item.valorDesconto==null?"":"(R\$ "+f.format(item.valorDesconto)+")"} - Total: R\$ ${f.format(item.total==null?0:item.total)}"),
                            subtitle: Text("${item.produtoNome}"),
                          )
                      );


                    }

                ),
              ),
              Padding(
                  padding: EdgeInsets.all(5),
                  child:
                  Visibility(
                    visible: _itens.length > 0,//_item !=null,
                    //child: Text("Total: "+f.format(_item==null?0.00:_item.total),textAlign: TextAlign.right,),
                    child: Text(_venda.total == null?"":"Total: R\$ "+f.format(_venda.total),
                      textAlign: TextAlign.right,
                      style: TextStyle(fontSize: 20),),
                  )
              ),
            ],
          ),
        ),
        floatingActionButton:
        new Visibility(
          visible: _itens.length > 0,
          child: FloatingActionButton(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
            child: Icon(Icons.check),
            onPressed: (){
              // _entradaCopa();
              _finalizaVenda();
            },
          ),)
    );
  }

    _setMensagem(BuildContext context,String mensagem,bool success){
      final snackbar = SnackBar(
        backgroundColor: success ? Colors.green : Colors.red,
        duration: Duration(seconds: 4),
        content: Text(mensagem),
      );
      //   Scaffold.of(context).showSnackBar(snackbar);
      ScaffoldMessenger.of(context).showSnackBar(snackbar);
//    Scaffold.of(context).showSnackBar(snackbar);
    //   _globalKey.currentState.showSnackBar(snackbar);
    //  setState(() {
    //    _entradasList = _listarItens();
    //  });
  }
}
