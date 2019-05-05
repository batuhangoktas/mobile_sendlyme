import 'package:flutter/material.dart';
import 'package:sendlyme/menupage.dart';
import 'package:sendlyme/service/getconstants.dart';
import 'package:sendlyme/splashpage.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:sendlyme/localizationlib/translations.dart';
BuildContext cnx;

void main() => runApp(MainPageApp());

class MainPageApp extends StatelessWidget {

  static const _methodChannel = const MethodChannel('external');

  @override
  Widget build(BuildContext context) {
    cnx = context;
    requestPermission();
    saveConf("sendly.me");

    return new MaterialApp(
        localizationsDelegates: [
          const TranslationsDelegate(),
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        supportedLocales: [
          const Locale('en', ''),
          const Locale('tr', ''),
        ],
        home : MenuPage());
  }
  requestPermission() async {
    try {
      final int result = await _methodChannel.invokeMethod('external');
    } on PlatformException catch (e) {
      print('Exception ' + e.toString());
    }
  }
  getConf() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    GetConstants.hostAdress = (prefs.getString('address'));

  }
  saveConf(String address) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    GetConstants.hostAdress = address;
    await prefs.setString('address', address,);

    getConf();
  }
}






