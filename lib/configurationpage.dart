import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:sendlyme/service/getconstants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ConfigurationPage extends StatefulWidget{
  @override
  ConfigurationPageApp createState() => ConfigurationPageApp();
}

class ConfigurationPageApp extends State<ConfigurationPage> {
String ipAdress="";
String port="";
final ipController = TextEditingController();
final portController = TextEditingController();

@override
void dispose() {
  // Clean up the controller when the Widget is disposed
  ipController.dispose();
  portController.dispose();
  super.dispose();
}

  @override
  Widget build(BuildContext context) {
    getConf();
    return Scaffold(
      appBar: AppBar(
        title: Text("Configuration"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
        TextField(
          controller: ipController,
          style: new TextStyle(
            color: Colors.red,
            fontSize: 25.0,
          ),
        decoration: InputDecoration(
            border: InputBorder.none,
            hintText: 'Ip Adress',
        ),

      ),
        TextField(
          style: new TextStyle(
            color: Colors.red,
            fontSize: 25.0,
          ),
          controller: portController,

          decoration: InputDecoration(
              border: InputBorder.none,
              hintText: 'Port'
          ),

        ),
        new RaisedButton(
          child: const Text('Kaydet Çık'),
          color: Theme.of(context).accentColor,
          elevation: 4.0,
          splashColor: Colors.blueGrey,
          onPressed: () {
            saveConf( ipController.text);
            Navigator.pop(context);
          },
        ),
          ],
        ),
      ),
    );
  }

getConf() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  ipController.text = (prefs.getString('ip'));
  portController.text = (prefs.getString('port'));

}
}

saveConf(String address) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  GetConstants.hostAdress = address;
  await prefs.setString('address', address);
}