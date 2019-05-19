import 'dart:async';

import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:sendlyme/constants/MessagesString.dart';
import 'package:sendlyme/localizationlib/translations.dart';
import 'package:sendlyme/sendreceivepage.dart';
import 'package:sendlyme/service/matchingservice.dart';
import 'package:sendlyme/service/startservice.dart';
import 'package:screen/screen.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

  class StartPageApp extends StatefulWidget {
  @override
  StartPage createState() => new StartPage();
  }



class StartPage extends State<StartPageApp> {

  String userId="";
  String sessionId="";
  Timer timer,timerQr;
  double currentBrightness=0.0;
  final GlobalKey<ScaffoldState> mScaffoldState = new GlobalKey<ScaffoldState>();
  bool _progress = false;
  @override
  void initState() {
    super.initState();
  //  getBrightness();
    StartService.postStartInfo(getQrCallback);
  }

  @override
  void dispose() {
   // Screen.setBrightness(currentBrightness);
    super.dispose();
  }


  void progressDialog()
  {
    setState(() {
      this.sessionId = this.sessionId;
    });
  }
  getBrightness()
  async {
    currentBrightness = await Screen.brightness;
    Screen.setBrightness(1);
  }

  getQrCallback(String sessionId,String userId,bool status) {
    if(status)
    {
      if(timer!=null)
      timer.cancel();

      this.userId = userId;
      setState(() {
        this.sessionId=sessionId;
      });

      if(timerQr==null) {
        timerQr = Timer.periodic(Duration(seconds: 15), (Timer t) =>
        {
        setState(() {
        this.sessionId="";
        }),
        new Timer(const Duration(milliseconds: 1500), () {
        StartService.postStartInfo(getQrCallback);
        })

      });
      }
      timer = Timer.periodic(Duration(seconds: 2), (Timer t) => MatchingService.postStartInfo(this.sessionId,getMatchCallback));
    }
    else
      {
        final snackBar = new SnackBar(content: new Text( Translations.of(context).text('PairingFailed')));
        mScaffoldState.currentState.showSnackBar(new SnackBar(
            content: new Text(MessagesString().serverProblem))
        );
                      }
  }

  getMatchCallback(bool match,bool status) {
    if(status)
    {
      if(match) {
        timerQr.cancel();
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
        child:  ModalProgressHUD(opacity: 0.6,inAsyncCall: this.sessionId.isEmpty,child:   new Center (child: new QrImage(
          data: sessionId,
        ),
        )
          ,  )
      )
    );
  }

}