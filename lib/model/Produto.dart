
class Produto {
  int _id;
  int _nome;
  String _descricao;
  double _precoVenda;
  double _precoVendaUmv;
  int _umv;
  int _peso;
 int _desconto;
 // _umvGranel
 int _umvPeso;
 int _qtdeEstoque;
 int _qtdeEstoqueGranel;
 String _codigoBarras;
 String _codigoBarrasGranel;

  int get id => _id;


  set id(int value) {
    _id = value;
  }
  int get nome => _nome;
  String get codigoBarrasGranel => _codigoBarrasGranel;

  set codigoBarrasGranel(String value) {
    _codigoBarrasGranel = value;
  }

  String get codigoBarras => _codigoBarras;

  set codigoBarras(String value) {
    _codigoBarras = value;
  }

  int get qtdeEstoque => _qtdeEstoque;

  set qtdeEstoque(int value) {
    _qtdeEstoque = value;
  }

  int get umvPeso => _umvPeso;

  set umvPeso(int value) {
    _umvPeso = value;
  }

  int get desconto => _desconto;

  set desconto(int value) {
    _desconto = value;
  }

  int get peso => _peso;

  set peso(int value) {
    _peso = value;
  }

  int get umv => _umv;

  set umv(int value) {
    _umv = value;
  }

  double get precoVendaUmv => _precoVendaUmv;

  set precoVendaUmv(double value) {
    _precoVendaUmv = value;
  }

  double get precoVenda => _precoVenda;

  set precoVenda(double value) {
    _precoVenda = value;
  }

  String get descricao => _descricao;

  set descricao(String value) {
    _descricao = value;
  }

  set nome(int value) {
    _nome = value;
  }

  int get qtdeEstoqueGranel => _qtdeEstoqueGranel;

  set qtdeEstoqueGranel(int value) {
    _qtdeEstoqueGranel = value;
  }


}
