
import 'package:seller_app/model/ItemVenda.dart';
import 'package:intl/intl.dart';

class Venda {
  int _id; //uso apenas no app
  int _codigo;
  String _cliente;
  int _clienteCodigo;
  int _pagamento;
  int _origem;
  bool _receberAgora;
  double _dinheiro;
  double _troco;
  String _registro;
  double _total;
  double _desconto;
  double _descontoItens;
  double _totalSemDesconto;
  bool _isDescVenda;
  int _percentual;

  List<ItemVenda> _itemV;
  String _detalhes;
  String _cabecalho;
  int _status; //true enviada para app - false falta sincronizar  //0 - receber  1- pago  2-cancelado
  //var f = NumberFormat("###.###,00", "pt_BR");
 int _situacao; //0-nao sincronizado 1- sincronizado
 String _login;

  Map toJson() {
    List<Map> itens =    this._itemV != null ? this._itemV.map((i) => i.toJson()).toList() : null;
    return {
      'codigo': _codigo,
      'cliente': {'codigo':_clienteCodigo,'nome':_cliente},
      'pagamento':_pagamento ,
      'receberAgora': _receberAgora==null?false:_receberAgora,
      'dinheiro':_dinheiro ,
      'troco': _troco,
      'registro': _registro,
      'total': _total,
      'desconto': _desconto==null?0.0:_desconto,
      'descontoItens': _descontoItens==null?0.0:_descontoItens,
      'percentual':_percentual,
      'totalSemDesconto': _totalSemDesconto,
      'itens': itens,
      'origem':_origem,
      'status':_status,
      'isDescVenda': _isDescVenda
     };
  }
  Map toMap() {
    Map<String, dynamic> map = {
      'codigo': _codigo,
      'pagamento':_pagamento ,
      'origem':_origem ,
     // 'receberAgora': _receberAgora==null?false:_receberAgora,
     // 'receberAgora': _receberAgora==true?0:1,
      'receberagora': _receberAgora==true?0:1,
      'dinheiro':_dinheiro ,
      'troco': _troco,
      'registro': _registro,
      'total': _total,
      'desconto': _desconto==null?0.0:_desconto,
      'descontoitens': _descontoItens==null?0.0:_descontoItens,
      'percentual': _percentual,
      'totalsemdesconto': _totalSemDesconto,
      //'status' : _status==true?0:1,
      'status' : _status,
      'clientecodigo':_clienteCodigo,
      'clientenome':_cliente,
      'situacao':_situacao,
      'login' : _login,
      'isdescvenda': _isDescVenda==true?0:1

    };
    return map;
  }
  Venda.fromJson(Map<String, dynamic> json)
        :_cliente = json['cliente']['nome'],
        _total = json['total'],
    //   _detalhes = "${json["quantidade"]} - "+limparDescricao(json["produto"]["nome"])+" R\$"+f.format(json["total"])+" \n";
        _detalhes = "${json["quantidade"]} - "+json["produto"]["nome"]+" R\$"+json["total"]+" \n",
        _registro = json['registro'];



  Venda();

  /* Venda.name(this._codigo, this._cliente, this._clienteCodigo, this._pagamento,
      this._origem, this._receberAgora, this._dinheiro, this._troco,
      this.registro, this._total, this._desconto, this._itemV, this._detalhes,
      this._cabecalho, this._status);
*/


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
        //  print("tama"+tam.toString());
          nomeFormat= nomeFormat + nome.substring(0,tam)+". ";
        }else{
          nomeFormat= nomeFormat + nome+" ";
        }
      }
     // print("nomeFormatado:"+nomeFormat);
      return nomeFormat;
    }else
      return nomeProduto;
  }

  /** getters */


  int get id => _id;

  set id(int value) {
    _id = value;
  }

  int get clienteCodigo => _clienteCodigo;
  int get status => _status;

  set status(int value) {
    _status = value;
  }

  int get origem => _origem;

  set origem(int value) {
    _origem = value;
  }

  set clienteCodigo(int value) {
    _clienteCodigo = value;
  }

  String get cabecalho => _cabecalho;

  set cabecalho(String value) {
    _cabecalho = value;
  }

  String get detalhes => _detalhes;

  set detalhes(String value) {
    _detalhes = value;
  }

  List<ItemVenda> get itemV => _itemV;

  set itemV(List<ItemVenda> value) {
    _itemV = value;
  }

  int get codigo => _codigo;

  set codigo(int value) {
    _codigo = value;
  }

  String get cliente => _cliente;

  double get desconto => _desconto;

  set desconto(double value) {
    _desconto = value;
  }

  double get descontoItens => _descontoItens;

  set descontoItens(double value) {
    _descontoItens = value;
  }

  double get total => _total;

  set total(double value) {
    _total = value;
  }

  set cliente(String value) {
    _cliente = value;
  }

  int get pagamento => _pagamento;

  set pagamento(int value) {
    _pagamento = value;
  }

  bool get receberAgora => _receberAgora;

  set receberAgora(bool value) {
    _receberAgora = value;
  }

  double get dinheiro => _dinheiro;

  set dinheiro(double value) {
    _dinheiro = value;
  }

  double get troco => _troco;

  set troco(double value) {
    _troco = value;
  }

  int get situacao => _situacao;

  set situacao(int value) {
    _situacao = value;
  }

  String get login => _login;

  set login(String value) {
    _login = value;
  }

  String get registro => _registro;

  set registro(String value) {
    _registro = value;
  }

  double get totalSemDesconto => _totalSemDesconto;

  set totalSemDesconto(double value) {
    _totalSemDesconto = value;
  }


  int get percentual => _percentual;

  set percentual(int value) {
    _percentual = value;
  }

  bool get  isDescVenda => _isDescVenda;

  set isDescVenda(bool value) {
    _isDescVenda = value;
  }


}
