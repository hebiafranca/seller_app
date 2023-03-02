
class Entrada {
  int _id;
  int _cod;
  int _produtoCodigo;
  String _produtoNome;
  String _produtoDescricao;
  String _codigoBarras;
  int _qtde;
  int _peso;
  String _registro;
  String _vencimento;
  int _status;
  String _login;

  Map toMap() {
    Map<String, dynamic> map = {
      'cod': _cod,
      'id': _id,
      'produtocodigo':_produtoCodigo,
      'produtonome':_produtoNome,
      'codigobarras':_codigoBarras,
      'qtde':_qtde,
      'peso':_peso,
      'registro': _registro,
      'status':_status,
      'login': _login,
      'vencimento':_vencimento
    };
    return map;
  }


  int get cod => _cod;

  set cod(int value) {
    _cod = value;
  }

  String get vencimento => _vencimento;

  set vencimento(String value) {
    _vencimento = value;
  }

  String get registro => _registro;

  set registro(String value) {
    _registro = value;
  } //true enviada para app - false falta sincronizar


  String get produtoDescricao => _produtoDescricao;

  set produtoDescricao(String value) {
    _produtoDescricao = value;
  }

  int get produtoCodigo => _produtoCodigo;

  set produtoCodigo(int value) {
    _produtoCodigo = value;
  }

  String get produtoNome => _produtoNome;


  String get codigoBarras => _codigoBarras;

  set codigoBarras(String value) {
    _codigoBarras = value;
  }

  set produtoNome(String value) {
    _produtoNome = value;
  }

  int get peso => _peso;

  set peso(int value) {
    _peso = value;
  }

  int get id => _id;

  set id(int value) {
    _id = value;
  }

  int get qtde => _qtde;

  set qtde(int value) {
    _qtde = value;
  }

  int get status => _status;

  set status(int value) {
    _status = value;
  }

  String get login => _login;

  set login(String value) {
    _login = value;
  }
}
