
import 'package:seller_app/model/Venda.dart';

class ItemVenda {
  String _produtoNome;
  int _produtoCodigo;
  int _codigoItem; //codigo vindo da web
  int _id; //codigoItem na tabela
  int _codigoVenda;
  double _quantidade;
  double _totalParcial;
  double _valorDesconto;
  double _valorGranel;
  double _pesoGranel;
  int _desconto;
  double _total;
  int _produtoPeso;
  double _produtoPreco;
 // double _produtoPrecoUmv;
  bool _produtoGranel;
  double _produtoPrecoVendaUmv;
  String _produtoUmvGranelSigla;
  String _produtoUmv;
  int _produtoUmvPeso;
  int _qtdePedido;
  bool _granel;
  bool get granel => _granel;
  String get produtoUmv => _produtoUmv;
  int _qtdeEstoque;
  double _qtdeEstoqueGranel;
  int status;//controle para atualizar venda
  String _umv; //mostrar medida


  Map toJson() => {
    "produto":{"id":_produtoCodigo},
    "id": _codigoItem ,//_id,
    "quantidade":_quantidade,
    "granel":_granel==null?false:_granel,
    "pesoGranel":_pesoGranel,
    "valorGranel":_valorGranel,
    "desconto":_desconto==null?0.0:_desconto,
    "valorDesconto":_valorDesconto==null?0.0:_valorDesconto,
    "totalParcial":_totalParcial,
    "total":_total,
    "qtdeEstoque":_qtdeEstoque,
    "qtdeEstoqueGranel":_qtdeEstoqueGranel,
    "venda" : {'codigo':_codigoVenda},


  };

  ItemVenda();

  ItemVenda.fromMap(Map<String, dynamic> data,int codigo) { //vem da web
    this.codigoItem = data['id']; // na web - id e primary do item
    this.produtoNome = data['produto']['nome'];
    this.produtoCodigo = data['produto']['id'];
    this.quantidade = data['quantidade'];
    this.granel = data['granel'];
    this.pesoGranel = data['pesoGranel'];
    this.valorGranel = data['valorGranel'];
    this.desconto = data['desconto']==0.0 ? 0 :data['desconto'];
    this.valorDesconto = data['valorDesconto'];
    this.totalParcial = data['totalParcial'];
    this.total = data['total'];
    this.qtdeEstoque = data['qtdeEstoque'];
    this._codigoVenda = codigo;
    //this.produto = data['total'];

  }
  Map toMap() {
  Map<String, dynamic> map = { //vai para o banco
      "produtocodigo": _produtoCodigo,
      "codigoitem":_codigoItem,
       "id": _id,
      "codigovenda":_codigoVenda,
      "produtonome": _produtoNome,
      "quantidade": _quantidade,
      "granel": _granel == null  || _granel == false ? 0 : 1,
      "pesogranel": _pesoGranel,
      "valorgranel": _valorGranel,
      "desconto": _desconto == null ? 0.0 : _desconto,
      "valordesconto": _valorDesconto == null ? 0.0 : _valorDesconto,
      "totalparcial": _totalParcial,
      "total": _total,
      "umv" :_umv
   //   "qtdeEstoque":_qtdeEstoque,
   //   "qtdeEstoqueGranel":_qtdeEstoqueGranel
    };

  //print("map item adicionado:: ${map}");
  return map;
  }

  int get codigoVenda => _codigoVenda;

  set codigoVenda(int value) {
    _codigoVenda = value;
  }

  set produtoUmv(String value) {
    _produtoUmv = value;
  }

  set granel(bool value) {
    _granel = value;
  } // se checkbox a granel for selecionado



  int get qtdePedido => _qtdePedido;

  set qtdePedido(int value) {
    _qtdePedido = value;
  }

  double get valorGranel => _valorGranel;

  set valorGranel(double value) {
    _valorGranel = value;
  }

  double get produtoPrecoVendaUmv => _produtoPrecoVendaUmv;

  set produtoPrecoVendaUmv(double value) {
    _produtoPrecoVendaUmv = value;
  }

  bool get produtoGranel => _produtoGranel;

  set produtoGranel(bool value) {
    _produtoGranel = value;
  }

  int get produtoCodigo => _produtoCodigo;

  set produtoCodigo(int value) {
    _produtoCodigo = value;
  }

  int get produtoPeso => _produtoPeso;

  set produtoPeso(int value) {
    _produtoPeso = value;
  }

  String get produtoNome => _produtoNome;

  set produtoNome(String value) {
    _produtoNome = value;
  }

  double get quantidade => _quantidade;

  double get total => _total;

  set total(double value) {
    _total = value;
  }

  double get valorDesconto => _valorDesconto;

  set valorDesconto(double value) {
    _valorDesconto = value;
  }

  double get totalParcial => _totalParcial;

  set totalParcial(double value) {
    _totalParcial = value;
  }

  set quantidade(double value) {
    _quantidade = value;
  }

  double get produtoPreco => _produtoPreco;

  set produtoPreco(double value) {
    _produtoPreco = value;
  }

 /* double get produtoPrecoUmv => _produtoPrecoUmv;

  set produtoPrecoUmv(double value) {
    _produtoPrecoUmv = value;
  }
*/
  String get produtoUmvGranelSigla => _produtoUmvGranelSigla;

  set produtoUmvGranelSigla(String value) {
    _produtoUmvGranelSigla = value;
  }

  int get produtoUmvPeso => _produtoUmvPeso;

  set produtoUmvPeso(int value) {
    _produtoUmvPeso = value;
  }

  double get pesoGranel => _pesoGranel;

  set pesoGranel(double value) {
    _pesoGranel = value;
  }

  int get desconto => _desconto;

  set desconto(int value) {
    _desconto = value;
  }

  double get qtdeEstoqueGranel => _qtdeEstoqueGranel;

  set qtdeEstoqueGranel(double value) {
    _qtdeEstoqueGranel = value;
  }

  int get qtdeEstoque => _qtdeEstoque;
  set qtdeEstoque(int value) {
    _qtdeEstoque = value;
  }

  int get id => _id;
  set id(int value) {
    _id = value;
  }

  int get codigoItem => _codigoItem;

  set codigoItem(int value) {
    _codigoItem = value;
  }

  String get umv => _umv;

  set umv(String value) {
    _umv = value;
  }
}
