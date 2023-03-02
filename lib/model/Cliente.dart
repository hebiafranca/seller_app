
class Cliente {
  int _codigo;
  String _nome;
  String _cpf;

  int get codigo => _codigo;

  set codigo(int value) {
    _codigo = value;
  }

  String get nome => _nome;

  String get cpf => _cpf;

  set cpf(String value) {
    _cpf = value;
  }

  set nome(String value) {
    _nome = value;
  }
}
