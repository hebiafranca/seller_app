class User{

  String _login;
  String _senha;
  bool _ok;
  String _mensagem;
  String _nome;
  String _roles;
  String _username;
  bool _isFirst;
  bool _atualiza;


  bool get atualiza => _atualiza;

  set atualiza(bool value) {
    _atualiza = value;
  }

  bool get isFirst => _isFirst;

  set isFirst(bool value) {
    _isFirst = value;
  } //User(this._ok,this._mensagem);

  //User(this._nome,this._roles,this._username,this._ok,this._mensagem,);


  String get nome => _nome;

  set nome(String value) {
    _nome = value;
  }

  String get mensagem => _mensagem;

  set mensagem(String value) {
    _mensagem = value;
  }

  bool get ok => _ok;

  set ok(bool value) {
    _ok = value;
  }

  String get login => _login;

  set login(String value) {
    _login = value;
  }

  String get senha => _senha;

  set senha(String value) {
    _senha = value;
  }

  String get roles => _roles;

  set roles(String value) {
    _roles = value;
  }

  String get username => _username;

  set username(String value) {
    _username = value;
  }


}