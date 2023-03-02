import 'dart:convert';

import 'package:seller_app/model/Canhoto.dart';
import 'package:seller_app/model/ItemVenda.dart';
import 'package:seller_app/model/Venda.dart';
import 'package:seller_app/model/Entrada.dart';
import 'package:seller_app/service/LocalService.dart';
import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class HelperDAO {
  static final HelperDAO  _helper = HelperDAO._internal();
  static final LocalService _ls = new LocalService();
  Database _db;
  final f = NumberFormat("###,##0.00", "pt_BR");
  final String TB_VENDAS = "CREATE TABLE vendas (id INTEGER PRIMARY KEY AUTOINCREMENT,codigo INTEGER, pagamento INTEGER, origem INTEGER, "
      "receberagora INTEGER, dinheiro REAL, troco REAL, registro TEXT, total REAL, "
      "desconto REAL,descontoitens REAL,percentual INTEGER, totalsemdesconto REAL, status INTEGER, clientecodigo INTEGER, clientenome TEXT, situacao INTEGER , login TEXT, isdescvenda INTEGER)";

 final String TB_I_VENDAS = "CREATE TABLE itens (id INTEGER PRIMARY KEY, codigovenda INTEGER,codigoitem INTEGER, produtocodigo INTEGER, produtonome TEXT, quantidade REAL, "
      " granel INTEGER, pesogranel REAL, valorgranel REAL, desconto INTEGER, valordesconto REAL, totalparcial REAL, total REAL, status INTEGER, umv TEXT)";

 final  String TB_ENTRADAS = "CREATE TABLE entradas (cod INTEGER PRIMARY KEY AUTOINCREMENT, id INTEGER, codigobarras TEXT, produtocodigo INTEGER, produtonome TEXT, qtde INTEGER, peso INTEGER, registro TEXT, status INTEGER, login TEXT, vencimento TEXT)";

 final  String TB_CANHOTOS = "CREATE TABLE canhotos (cod INTEGER PRIMARY KEY AUTOINCREMENT, valor REAL, login TEXT)";


  factory HelperDAO (){
    return _helper;
  }

  HelperDAO._internal(){}

  get db async{
    if(_db != null){
      return _db;
    }else{
      _db = await start();
      return _db;
    }
  }
 _onCreate(Database db, int version){
  /* String vendas = "CREATE TABLE vendas (id INTEGER PRIMARY KEY AUTOINCREMENT,codigo INTEGER, pagamento INTEGER, origem INTEGER, "
       "receberagora INTEGER, dinheiro REAL, troco REAL, registro DATETIME, total REAL, "
       "desconto REAL, status INTEGER, clientecodigo INTEGER, clientenome TEXT)";

   String itensVenda = "CREATE TABLE itens (id INTEGER PRIMARY KEY, codigovenda INTEGER, produtocodigo INTEGER, produtonome TEXT, quantidade REAL, "
       " granel INTEGER, pesogranel REAL, valorgranel REAL, desconto INTEGER, valordesconto REAL, totalparcial REAL, total REAL)";

   String entradas = "CREATE TABLE entradas (cod INTEGER PRIMARY KEY AUTOINCREMENT, id INTEGER, produtocodigo INTEGER, produtonome TEXT, qtde INTEGER, peso INTEGER)";*/
   db.execute(TB_ENTRADAS);
   db.execute(TB_VENDAS);
   db.execute(TB_I_VENDAS);
   db.execute(TB_CANHOTOS);

 }
  start() async{
   // print("start() .. Criando base local");
    final path = await getDatabasesPath();
    final bdP = join(path, "sales.db");
    var db = await openDatabase(bdP,version: 1,onCreate: _onCreate);
    return db;
  }

  Future <bool> saveVenda(Venda v) async{
    var salesdb = await db;
    bool status = true;
    //var venda = v.toJson();
 //   var body = json.encode(venda);
    String login = await _ls.getUser();
    v.login = login;
    var venda = v.toMap();
    //print("nova venda off:: ${venda}");
    int idVenda = await salesdb.insert("vendas", venda );
    if(idVenda == null){
        return  false;
    }else {
      var itens = v.itemV;
      itens.forEach((element) async {
        element.codigoVenda = idVenda ;// v.codigo;
      //  element.id = idVenda;
        element.status = 0; //true
        Map el = element.toMap();
        int id = await salesdb.insert("itens", el);

        if(id == null){
          //apaga a venda
          int idr = await removeVenda(idVenda);
          return false;
        }else{
         // print("inseriu item corretamente");
         // print("venda:: ${idVenda}  item venda id: ${id}");
        }
      });
    }
  //  List<Map> itens = itemV != null ? itemV.map((i) => i.toJson()).toList() : null;
  //  itens.forEach((element) async{
   //   int id = await salesdb.insert("itens", element );
   // });
    return status;
  }

  Future <int> saveCanhoto(Canhoto v) async{
    var salesdb = await db;
    String login = await _ls.getUser();
  //  var now = DateTime.now();
    v.login = login;
   // v.registro = now.toString();
    var canhoto = v.toMap();
    int idCanhoto = await salesdb.insert("canhotos", canhoto );

    return idCanhoto;
  }

  insereItensVendaAlterada(Venda v,int codigo) async{
    var salesdb = await db;
    var itens = v.itemV;
    int count=0;
    await Future.forEach(itens,(element) async {
   //   await Future.forEach(list, (el) async {
      element.codigoVenda = codigo; //no item usar sempre idvenda - pq e local
      element.status = 0; //true
      element.id =null;
      Map el = element.toMap();

      int id = await salesdb.insert("itens", el);
     // print("insereItensVendaAlterada - codigo Produto ${element.produtoCodigo}");
      if(id == null){

      }else{
        count++;
       // print("inseriu item venda alterada corretamente");
       // print("venda:: ${v.codigo}  item venda id: ${id}");
      }
    });
    return count;
  }


  listVendas() async{
    List<Venda> listaVenda = List();
    var salesdb = await db;
    String login = await _ls.getUser();

    String sql = "SELECT id, status, codigo, clientenome,receberagora, total, desconto,descontoitens,registro,origem,situacao,percentual,totalsemdesconto FROM vendas WHERE status != 2 AND login = '${login}' ORDER BY registro desc"; //todas nao apagadas
    List list = await salesdb.rawQuery(sql);
   await Future.forEach(list, (el) async {
    // print("venda selecionada: ${el}");
      Venda item = Venda();
      item.id = el["id"];
      item.status = el["status"] ;
      item.codigo = el["codigo"];
      item.cliente = el["clientenome"];
      item.total = el["total"];
      item.registro = el["registro"];
      item.desconto = el["desconto"];
      item.descontoItens = el["descontoitens"];
      item.receberAgora = el["receberagora"]== 0 ? true : false;
     item.origem = el["origem"];
     item.situacao = el["situacao"];
     //item.isDescVenda = el["isdescvenda"];
     item.percentual = el["percentual"]; //nao esta na lista da query
      //print("Receber agora:${el["receberagora"]}");

      item.totalSemDesconto = el["totalsemdesconto"];
      String cabecalho = "";
      cabecalho = item.cliente==null?"Anônimo":item.cliente+" - R\$"+f.format(item.total);
      item.cabecalho = cabecalho;
      List<ItemVenda> its = List();
      String detalhes = "";

    //  String sqli = "SELECT produtonome, quantidade, total FROM itens WHERE codigovenda = ${item.id} ";
      String sqli = "SELECT * FROM itens WHERE codigovenda=${item.id}";
      List itens = await salesdb.rawQuery(sqli);
     // print("qdte itens:: ${itens.length}");
      itens.forEach((it) {
        ItemVenda iv = new ItemVenda();
           iv.produtoNome = it["produtonome"];
           iv.codigoVenda = it["codigovenda"];
           iv.produtoCodigo = it["produtocodigo"];
           iv.quantidade = it["quantidade"];
           iv.total = it["total"];
           iv.totalParcial = it["totalparcial"];
           iv.valorDesconto = it["valordesconto"];
           double tmp = iv.quantidade==null?0:iv.quantidade;
           String umv = it["umv"] ==null ?"" :it["umv"];
           String desc = (iv.valorDesconto >0 && iv.valorDesconto != null) ?" (R\$"+f.format(iv.valorDesconto)+")" :"";
           detalhes = detalhes +"${tmp.toStringAsFixed(tmp.truncateToDouble() == tmp ? 0 : 3)} ${umv} - "+limparDescricao(iv.produtoNome)+" R\$"+f.format(iv.total)+desc+" \n";
           //print("detalhes:: ${detalhes}");
          // print(it.toString());
           its.add(iv);
      });
      item.detalhes = detalhes;
      item.itemV = its;
      listaVenda.add(item);

    });
    return listaVenda;
  }

  getVenda(int codigoVenda) async{

    var salesdb = await db;
    String sql = "SELECT id, status, codigo, clientenome,receberagora, total, dinheiro, desconto,descontoitens,troco, registro, origem, situacao,isdescvenda,percentual,totalsemdesconto FROM vendas WHERE codigo = ${codigoVenda}";
    var venda = await salesdb.rawQuery(sql);
     // print("venda selecionada: ${venda}");
      Venda item = Venda();
      item.id = venda[0]["id"];
      item.status = venda[0]["status"] ;
      item.codigo = venda[0]["codigo"];
      item.cliente = venda[0]["clientenome"];
      item.total = venda[0]["total"];
      item.registro = venda[0]["registro"];
      item.desconto = venda[0]["desconto"];
      item.descontoItens = venda[0]["descontoitens"];
      item.dinheiro = venda[0]["dinheiro"];
      item.troco = venda[0]["troco"];
      item.receberAgora = venda[0]["receberagora"]== 0 ? true : false;
      item.origem = venda[0]["origem"];
      item.situacao = venda[0]["situacao"];
      item.isDescVenda = venda[0]["isdescvenda"]== 0 ? true : false;
      item.percentual = venda[0]["percentual"];
      item.totalSemDesconto = venda[0]["totalsemdesconto"];
      //print("Receber agora:${venda[0]["receberagora"]}");
      String cabecalho = "";
      cabecalho = item.cliente==null?"Anônimo":item.cliente+" - R\$"+f.format(item.total);
      item.cabecalho = cabecalho;
      List<ItemVenda> its = List();
      String detalhes = "";

      //  String sqli = "SELECT produtonome, quantidade, total FROM itens WHERE codigovenda = ${item.id} ";
      String sqli = "SELECT * FROM itens WHERE codigovenda=${item.id}";
      List itens = await salesdb.rawQuery(sqli);
      //print("qdte itens:: ${itens.length}");
      itens.forEach((it) {
        ItemVenda iv = new ItemVenda();
        iv.produtoNome = it["produtonome"];
        iv.produtoCodigo = it["produtocodigo"];
        iv.quantidade = it["quantidade"];
        iv.total = it["total"];
        iv.totalParcial = it["totalparcial"];
        iv.valorDesconto = it["valordesconto"];
        iv.codigoVenda = it["codigovenda"];
        double tmp = iv.quantidade==null?0:iv.quantidade;
        detalhes = detalhes +"${tmp.toStringAsFixed(tmp.truncateToDouble() == tmp ? 0 : 3)} - "+limparDescricao(iv.produtoNome)+" R\$"+f.format(iv.total)+" \n";
      //  print("detalhes:: ${detalhes}");
        its.add(iv);
      });
      item.detalhes = detalhes;
      item.itemV = its;


    return item;
  }
  totalVendas() async{
    var salesdb = await db;
    String login = await _ls.getUser();

    String sql = "SELECT sum(total) FROM vendas WHERE status != 2 AND login = '${login}'";
    var result = await salesdb.rawQuery(sql);
    double value = result[0]["sum(total)"];
    return value;
  }

  listVendasSincroniza() async{
    List<Map> listaVenda = List();
    var salesdb = await db;
    String login = await _ls.getUser();
    //String sql = "SELECT * FROM vendas WHERE status = 1"; //0-true 1-false
    //String sql = "SELECT * FROM vendas WHERE origem = 2"; //1-online 2-offline
    String sql = "SELECT * FROM vendas WHERE situacao = 0 AND login = '${login}'"; //0-nao sincrinizadas 1-sincronizadas
    listaVenda = await salesdb.rawQuery(sql);
  /*  await Future.forEach(list, (el) async {
       String sqli = "SELECT produtonome, quantidade, total FROM itens WHERE codigovenda = ${el["id"]} ";
       List itens = await salesdb.rawQuery(sqli);
       List<Map> its = List();
       itens.forEach((it) {
         its.add(it);
         print("adiciona item ${it}");
      });
       Map venda = el;
      venda["itemV"] = its;

      listaVenda.add(venda);

    }); */
    return listaVenda;
  }

  listItens(int id) async{
    var salesdb = await db;
    String sqli = "SELECT produtocodigo,produtonome, quantidade, granel, pesogranel, valorgranel, desconto, valordesconto, totalparcial, total FROM itens WHERE codigovenda = ${id} ";
    List itens = await salesdb.rawQuery(sqli);
    return itens;
  }

  listEntradasSincroniza() async{
    var salesdb = await db;
    String login = await _ls.getUser();

    String sql = "SELECT * FROM entradas WHERE status = 1 AND  login = '${login}'"; //0-true 1-false
    List list = await salesdb.rawQuery(sql);
    return list;
  }

  Future<List<Canhoto>>listCanhotos() async{
    var salesdb = await db;
    String sql = "SELECT * FROM canhotos"; //0-true 1-false
    List list = await salesdb.rawQuery(sql);
    List <Canhoto> result = List();
    list.forEach((el) {
      Canhoto e = Canhoto();
      e.id = el["id"];
      e.valor = el["valor"];
      result.add(e);
    });


    return result;
  }

  Future<List <Entrada>> listEntradas() async{
    var salesdb = await db;
    String login = await _ls.getUser();

    String sql = "SELECT id, cod,produtocodigo,produtonome,codigobarras,qtde,peso,registro, status,vencimento FROM entradas WHERE login = '${login}' ORDER BY registro DESC"; //0-true 1-false
    List<Map> list = await salesdb.rawQuery(sql);

    List <Entrada> entradas = List();
    list.forEach((el) {
       Entrada e = Entrada();
       e.id = el["id"];
       e.cod = el["cod"];
       e.produtoCodigo = el["produtocodigo"];
       e.produtoNome = el["produtonome"];
       e.codigoBarras = el["codigobarras"]==null?"":el["codigobarras"];
       e.qtde = el["qtde"];
       e.peso = el["peso"]==null?"":el["peso"];
       e.registro = el["registro"];
       e.status = el["status"];
       e.vencimento = el["vencimento"]==null?"":el["vencimento"];
       //print("entradas :: ${el}");
       entradas.add(e);
    });
    return entradas;
  }
  Future<int> removeRegistros(String tabela) async{
    var salesdb = await db;
    var now = DateTime.now();
    var ontem = DateTime(now.year,now.month,now.day-1,23,59);
    //print("Sincronizar...${ontem}");
    if(tabela == "vendas") {
   //   String sql = "select * from vendas where registro <= '${ontem.toString()}' and status = 0";
   //   List itens = await salesdb.rawQuery(sql);
   //   print("total de vendas para sincronizar ${itens.length}");
   //   return await salesdb.delete("vendas", where: "registro <= ? and status = ? and codigo != null",  whereArgs: [ontem.toString(), 0]); //apagar todas ja sincornizadas
      //return await salesdb.delete("vendas", where: "registro <= ? and origem = ? ",  whereArgs: [ontem.toString(), 1]); //apagar todas ja sincornizadas
      //return await salesdb.delete("vendas", where: "registro <= ? and status <> ?",  whereArgs: [ontem.toString(), 0]); //apagar todas ja sincornizadas
      return await salesdb.delete("vendas", where: "registro <= ? and situacao = ? ",  whereArgs: [ontem.toString(), 1]); //apagar todas ja sincornizadas

    }else if (tabela == "entradas"){
      return await salesdb.delete("entradas", where: "registro <= ? and status = ?", whereArgs: [ontem.toString(), 0]);  //apagar todas ja sincornizadas 0 - nao sincronizados 1
    }

  }

  void removeItens() async{
    var salesdb = await db;
    var now = DateTime.now();
    var ontem = DateTime(now.year,now.month,now.day-1,23,59);
    //print("Sincronizar...${ontem}");
   // String sqli = "SELECT * FROM vendas WHERE status=0 AND registro <= '${ontem}'";
    String sqli = "SELECT * FROM vendas WHERE situacao = 1 AND registro <= '${ontem.toString()}'"; //0-nao sincronizado 1- sincronizado
    List itens = await salesdb.rawQuery(sqli);
    //print("qdte itens:: ${itens.length}");

    await Future.forEach(itens, (el) async {
       await salesdb.delete("itens", where: "codigovenda= ?",  whereArgs: [el["id"]]); //apagar todas ja sincornizadas
    });
  }

  void removeCanhotos() async{
    var salesdb = await db;

    String sqli = "DELETE FROM canhotos";

  }
  //void statusItensVendaAlterada(int codigoVenda) async{
   // var salesdb = await db;
   // int updateCount = await salesdb.update("itens", {"origem":status,"codigo":codigo}, where: 'id = ?', whereArgs: [id]);
   // print("atualizar status da venda (origem)- codigo api: ${codigo} -  ${updateCount}");
  //}
  Future<int> removeItensVendaAlterada(int idVenda) async{
    var salesdb = await db;
    int qtde = await salesdb.delete("itens", where: "codigovenda= ?",  whereArgs: [idVenda]); //apagar todas ja sincornizadas
    //print("Itens apagados - atualiza venda:: ${qtde}");
    return qtde;
  }


  Future<int> removeVenda(int id) async{
    var salesdb = await db;
    return await salesdb.delete(
        "vendas",
        where: "id = ?",
        whereArgs: [id]
    );
  }
  Future<int> removeEntrada(int id) async{
    var salesdb = await db;
    return await salesdb.delete(
        "entradas",
        where: "cod = ?",
        whereArgs: [id]
    );
  }
  Future<int> atualizarStatusVendaSincronizada(int id, int status, int codigo) async {
    var salesdb = await db;
  //  int updateCount = await db.rawUpdate("UPDATE vendas   SET status = ? WHERE id = ?",[status, id]);
    int updateCount = await salesdb.update("vendas", {"situacao":status,"codigo":codigo}, where: 'id = ?', whereArgs: [id]);
   // print("atualizar status da venda (situacao)- codigo api: ${codigo} -  ${updateCount}");
    return updateCount;
 }
  Future<int> atualizarStatusVenda(Venda v,int status) async { //0 -true receberagora
    var salesdb = await db;
    int updateCount = 0;
    if(status == 1){ //tratar por status - 0-a receber 1-recebido 2-cancelado
      updateCount = await salesdb.update("vendas", {"receberagora":0,"pagamento":v.pagamento,"dinheiro":v.dinheiro,"troco":v.troco,"status":status,"total":v.total,"totalSemDesconto":v.totalSemDesconto,"desconto":v.desconto,"descontoitens":v.descontoItens,"percentual":v.percentual}, where: 'id = ?' , whereArgs: [v.id]);
    }else if(status == 2){ //apagada
      updateCount = await salesdb.update("vendas", {"status":status}, where: 'id = ?' , whereArgs: [v.id]);
    }else if(status == 99 || status == 0){ //status 99 - alterarVendaOff
      updateCount = await salesdb.update("vendas", {"pagamento":v.pagamento,"dinheiro":v.dinheiro,"troco":v.troco,"status":v.status,"total":v.total,"totalsemdesconto":v.totalSemDesconto,"desconto":v.desconto,"descontoitens":v.descontoItens,"percentual":v.percentual}, where: 'id = ?' , whereArgs: [v.id]);
    }
    //int updateCount = await salesdb.update("vendas", {"receberagora":0,"pagamento":v.pagamento,"dinheiro":v.dinheiro,"troco":v.troco}, where: 'id = ?' , whereArgs: [v.id]);
    //print("atualizar status da venda - API - recebida: ${v.codigo} -  ${updateCount}");
    return updateCount;
  }
  Future<int> atualizarStatusEntrada(int id, int status, int codigo) async {
    var salesdb = await db;
   // int updateCount = await db.rawUpdate("UPDATE entradas  SET status = ? WHERE cod = ?",[status, id]);
    int updateCount = await salesdb.update("entradas",{"status":status,"id":codigo}, where: 'cod = ?', whereArgs: [id]);
   // print(updateCount);
    return updateCount;
  }
  recriaVendas() async{
    var salesdb = await db;
    await salesdb.execute("DROP TABLE IF EXISTS vendas");
    await salesdb.execute(TB_VENDAS);

    await salesdb.execute("DROP TABLE IF EXISTS itens");
    await salesdb.execute(TB_I_VENDAS);

  }

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
      //    print("tama"+tam.toString());
          nomeFormat= nomeFormat + nome.substring(0,tam)+". ";
        }else{
          nomeFormat= nomeFormat + nome+" ";
        }
      }
    //  print("nomeFormatado:"+nomeFormat);
      return nomeFormat;
    }else
      return nomeProduto;
  }
  Future <bool> saveEntrada(Entrada v) async{
    var salesdb = await db;
    bool status = true; //da tentativa de gravar
    String user = await _ls.getUser();
    v.login = user;
    var entrada = v.toMap();
    int id = await salesdb.insert("entradas", entrada );
    return id == null ? false : true;
  }
}