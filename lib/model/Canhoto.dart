
class Canhoto {
  int _id;
  double _valor;
  String _registro;
  String _login;

  Map toMap() {
    Map<String, dynamic> map = {
   //   'id': _id,
      'valor':_valor,
  //    'registro': _registro,
      'login':_login
    };
    return map;
  }

  String get registro => _registro;

  set registro(String value) {
    _registro = value;
  } //true enviada para app - false falta sincronizar


  double get valor => _valor;

  set valor(double value) {
    _valor = value;
  }

  int get id => _id;

  set id(int value) {
    _id = value;
  }

  String get login => _login;

  set login(String value) {
    _login = value;
  }
}
