
import 'package:flutter/services.dart';
import 'package:seller_app/RouteGenerator.dart';
import 'package:seller_app/views/Login.dart';
import 'package:flutter/material.dart';


ThemeData _temaPadrao = ThemeData(
    primaryColor: Color(0xff296fa7),
    secondaryHeaderColor: Color(0xff20c997)
);

void main(){
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((value) => runApp(
        MaterialApp(
    title: "4 S E L L E R",
    home: Login(),
    theme:  _temaPadrao,
    initialRoute: "/login",
    onGenerateRoute: RouteGenerator.generateRoute,
    debugShowCheckedModeBanner: false,

  )));

}