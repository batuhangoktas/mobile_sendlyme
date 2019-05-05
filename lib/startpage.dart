import 'dart:async';

import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:sendlyme/constants/MessagesString.dart';
import 'package:sendlyme/sendreceivepage.dart';
import 'package:sendlyme/service/matchingservice.dart';
import 'package:sendlyme/service/startservice.dart';
import 'package:screen/screen.dart';
  class StartPageApp extends StatefulWidget {
  @override
  StartPage createState() => new StartPage();
  }

class StartPage extends State<StartPageApp> {

  String userId="";
  String sessionId="";
  Timer timer;
  double currentBrightness=0.0;
  final GlobalKey<ScaffoldState> mScaffoldState = new GlobalKey<ScaffoldState>();
  @override
  void initState() {
    super.initState();
    getBrightness();
    StartService.postStartInfo("192.16.8.1",getQrCallback);
  }

  @override
  void dispose() {
    Screen.setBrightness(currentBrightness);
    super.dispose();
  }

  getBrightness()
  async {
    currentBrightness = await Screen.brightness;
    Screen.setBrightness(1);
  }

  getQrCallback(String sessionId,String userId,bool status) {
    if(status)
    {
      this.userId = userId;
      setState(() {
        this.sessionId=sessionId;
      });


      timer = Timer.periodic(Duration(seconds: 2), (Timer t) => MatchingService.postStartInfo("123.123.123.123",this.sessionId,getMatchCallback));
    }
    else
      {
        final snackBar = new SnackBar(content: new Text("Eşleşme yapılamadı."));
        mScaffoldState.currentState.showSnackBar(new SnackBar(
            content: new Text(MessagesString().serverProblem))
        );
                      }
  }

  getMatchCallback(bool match,bool status) {
    if(status)
    {
      if(match) {
        timer?.cancel();
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => SendReceiveApp(sessionId: sessionId,userId: userId)),
        );
      }
    }
    else
    {

    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
        key: mScaffoldState,
      appBar: AppBar(
        title: Text("Start"),
      ),

      body: new Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        padding: EdgeInsets.all(20),
        color: new Color(0xFFBFE0F3),
        child:
        new Center (child: new QrImage(
          data: sessionId,
        ),
        )
      )
    );
  }
}