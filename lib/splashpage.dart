import 'package:flutter/material.dart';
import 'package:sendlyme/menupage.dart';
import 'package:sendlyme/splashscreen.dart';
class SplashPage extends StatefulWidget{
  @override
  SplashPageApp createState() => SplashPageApp();
}

class SplashPageApp extends State<SplashPage>
{

  @override
  Widget build(BuildContext context) {

    return new SplashScreen(
        seconds: 4,
        navigateAfterSeconds: new MenuPage(),
        image:  new Image(image: new AssetImage("assets/splash.gif")),
        backgroundColor: Colors.white,
        photoSize: 150.0
    );

  }
}