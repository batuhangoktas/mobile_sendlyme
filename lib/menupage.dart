import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:sendlyme/localizationlib/translations.dart';
import 'package:sendlyme/service/joinservice.dart';
import 'package:sendlyme/startpage.dart';
import 'package:sendlyme/sendreceivepage.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

class MenuPage extends StatefulWidget{
  @override
  createState() => MenuPageApp();
}


class MenuPageApp extends State<MenuPage>
{
  final GlobalKey<ScaffoldState> mScaffoldState = new GlobalKey<ScaffoldState>();
  String sessionId="";
  bool _saving = false;

  void progressDialog(bool isVisibility)
  {
    setState(() {
      _saving = isVisibility;
    });
  }
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        key: mScaffoldState,
        appBar: AppBar(
          title: Text('Sendly.me'),
        ),
        body: ModalProgressHUD(opacity: 0.2,inAsyncCall: this._saving  ,
        child: new Container(
        height: MediaQuery.of(context).size.height,
    width: MediaQuery.of(context).size.width,
    color: new Color(0xFFBFE0F3),
            child: new CustomPaint(
              painter: ShapesPainter(),

    child: new Column(

      crossAxisAlignment: CrossAxisAlignment.center,

      children: <Widget>[

    new Container(
    width: MediaQuery.of(context).size.width-100,
       height: 70.0,
      alignment: Alignment.center,
margin: EdgeInsets.only(top: MediaQuery.of(context).size.height/5),
      child: new Text("Sendly.me",style: TextStyle(color: Color(0xFF2A5094), fontSize: 50,fontWeight: FontWeight.bold, fontFamily: 'IceBerg'),),
     ),
        
       new Container(
         width: MediaQuery.of(context).size.width-100,
         height: 60.0,
         margin: const EdgeInsets.only(top: 60.0),
         constraints: BoxConstraints(
             maxWidth: 700,
         ),
           child: RaisedButton(
          elevation: 4.0,
          shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(30.0)),
          color: Colors.white,
          onPressed:() {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => StartPageApp()),
            );
          },
          child:  Stack(
            children: <Widget>[
              Align(
                  alignment: Alignment.centerLeft,
                  child: new Container (
                    margin: EdgeInsets.only(left: 10),
                    child: Image(
                    width: 30,
            image: new AssetImage("assets/qr.ico"),
             fit: BoxFit.fitWidth,
           ),
                  ),
              ),
              Align(
                  alignment: Alignment.center,
                  child: Text(
                      Translations.of(context).text('MainPageStart'),
                    style: new TextStyle(
                      fontSize: 25,
                      color: Color(0xFF666A74),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
              ),

               ],
        ),
           ),
    ),
       new Container(
         width: MediaQuery.of(context).size.width-100,
         height: 60.0,
         margin: const EdgeInsets.only(top: 30.0),
         constraints: BoxConstraints(
           maxWidth: 700,
         ),
        child: RaisedButton(
          elevation: 4.0,
          shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(30.0)),
          color: Colors.white,
          onPressed:() {
            scan();
          },
          child: Stack(
        children: <Widget>[
        Align(
            alignment: Alignment.centerLeft,
            child: new Container (
              margin: EdgeInsets.only(left: 10),
                child: Image(
              width: 30,
              image: new AssetImage("assets/join.ico"),
              fit: BoxFit.fitWidth,
            ),
            ),
        ),
         Align(
           alignment: Alignment.center,
           child:
            Text(
              Translations.of(context).text('MainPageJoin'),
            style: new TextStyle(
              fontSize: 25,
              color: Color(0xFF666A74),
              fontWeight: FontWeight.bold,
            ),
          ),
         ),
          ]
          )


        ),
       ),
    new Container(
      margin: EdgeInsets.only(top: 10.0),
      height: 20.0,
      alignment: Alignment.center,
      child: new Text( Translations.of(context).text('Agree'),style: TextStyle(color: Color(0xFF2A5094), fontSize: 15,fontWeight: FontWeight.bold, fontFamily: 'IceBerg'),),
    ),
    new Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        new Container(
          height: 20.0,
          alignment: Alignment.center,
          child:
          new InkWell(
            child: new Text(Translations.of(context).text('LegalInfo'),style: TextStyle(color: Color(0xFF2A5094),decoration: TextDecoration.underline, fontSize: 15,fontWeight: FontWeight.bold, fontFamily: 'IceBerg'),),
            onTap: () => launch('https://sendly.me/#/legalinfo')
        ),


        ),
        new Container(
          height: 20.0,
          alignment: Alignment.center,
          child: new Text(Translations.of(context).text('And'),style: TextStyle(color: Color(0xFF2A5094), fontSize: 15,fontWeight: FontWeight.bold, fontFamily: 'IceBerg'),),
        ),
        new Container(
          height: 20.0,
          alignment: Alignment.center,
          child:
          new InkWell(
            child: new Text(Translations.of(context).text('Privacy'),style: TextStyle(color: Color(0xFF2A5094),decoration: TextDecoration.underline, fontSize: 15,fontWeight: FontWeight.bold, fontFamily: 'IceBerg'),),
              onTap: () => launch('https://sendly.me/#/privacy')
          )
        ),
      ],
    )


//     new GestureDetector(
//       onTap: () {
//         Navigator.push(
//           context,
//           MaterialPageRoute(builder: (context) => ConfigurationPage()),
//         );
//
//       },
//
//       child: new Container(
//         height: 20,
//         width: 100,
//         margin: const EdgeInsets.all(20.0),
//         decoration: new BoxDecoration(
//
//           image: new DecorationImage(
//             image: new AssetImage("assets/start.png"),
//             fit: BoxFit.fill,
//           ),
//
//
//         ),
//
//       ),
//     )


      ],
    ),
    )
        ),),
    );//

  }

  void btnPress(){
//    setState(() =>  counter++);
  }
  Future scan() async {
    try {

      this.sessionId = await BarcodeScanner.scan();

      progressDialog(true);
      //servis işlemi
      JoinService.post(sessionId, getJoinCallback);



//      final snackBar = new SnackBar(content: new Text(barcode));
//      mScaffoldState.currentState.showSnackBar(snackBar);

      //   setState(() => this.barcode = barcode);


    } on PlatformException catch (e) {
      if (e.code == BarcodeScanner.CameraAccessDenied) {
        setState(() {
   //       this.barcode = 'The user did not grant the camera permission!';
        });
      } else {
  //      setState(() => this.barcode = 'Unknown error: $e');
      }
    } on FormatException{
  //    setState(() => this.barcode = 'null (User returned using the "back"-button before scanning anything. Result)');
//      Navigator.push(
//        context,
//        MaterialPageRoute(builder: (context) => SendReceiveApp()),
//      );
    } catch (e) {
  //    setState(() => this.barcode = 'Unknown error: $e');
    }
  }

  getJoinCallback(String userId,bool status) {
    if(status)
    {
      if(userId.isEmpty) {
        progressDialog(false);
        final snackBar = new SnackBar(content: new Text( Translations.of(context).text('PairingFailed')));
        mScaffoldState.currentState.showSnackBar(snackBar);
      }
      else
        {
          progressDialog(false);
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

  void _showDialog() {
    // flutter defined function
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          content: new Container(
            width: 20.0,
            height: 20.0,
            child: CircularProgressIndicator(),) ,
        );
      },
    );
  }


}


class ShapesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    // set the paint color to be white
    paint.color = Color(0xFFF5C072);
    // Create a rectangle with size and width same as the canvas
//    var rect = Rect.fromLTWH(0, 0, size.width, size.height);
//    canvas.drawRect(rect, paint);
    // draw the rectangle using the paint
    // create a path
    var path = Path();
    path.moveTo(size.width,size.height);

    path.lineTo(size.width,size.height);
    path.lineTo(size.width,size.height*0.8);
    path.lineTo(0,size.height*0.85);
    path.lineTo(0,size.height);
    path.lineTo(size.width,size.height);
    // close the path to form a bounded shape
    path.close();
    canvas.drawPath(path, paint);
    // set the color property of the paint
//    paint.color = Colors.deepOrange;
//    // center of the canvas is (x,y) => (width/2, height/2)
//    var center = Offset(size.width / 2, size.height / 2);
//    // draw the circle with center having radius 75.0
//    canvas.drawCircle(center, 75.0, paint);
  }
  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}