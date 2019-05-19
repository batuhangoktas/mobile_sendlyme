import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:sendlyme/localizationlib/translations.dart';
import 'package:sendlyme/modal/posthttp.dart';
import 'package:sendlyme/modal/receivefilesmodal.dart';
import 'package:sendlyme/modal/sendfilesmodal.dart';
import 'package:sendlyme/receivefilelist.dart';
import 'package:sendlyme/sendfilelist.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:sendlyme/service/getconstants.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

class SendReceiveApp extends StatefulWidget {
  final String userId;
  final String sessionId;
  const SendReceiveApp({this.userId,this.sessionId});

  @override
  SendReceive createState() => new SendReceive();
}

class SendReceive extends State<SendReceiveApp> {
  List<SendFileModal> sendFileList = new List<SendFileModal>();
  List<ReceiveFileModal> receiveFileList = new List<ReceiveFileModal>();
  int cnt=1;
  String _filePath;
  Timer timer;
  String _platformVersion;
  bool _saving = false;
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  @override
  initState() {
    super.initState();
    getPendingFile(widget.userId,widget.sessionId);
    timer = new Timer.periodic(Duration(seconds: 2), (Timer t) => getPendingFile(widget.userId,widget.sessionId));
  }

  @override
  void dispose() {
    timer?.cancel();

    super.dispose();
  }

  void progressDialog(bool isVisibility)
  {
    setState(() {
      _saving = isVisibility;
    });
  }

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      key: _scaffoldKey,
      body:  ModalProgressHUD(opacity: 0.4,inAsyncCall: this._saving  ,
        child: DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            bottom: TabBar(
              tabs: [
                Tab(icon: Icon(Icons.send)),
                Tab(icon: Icon(Icons.receipt)),
              ],
            ),
            title: Text( Translations.of(context).text('SendReceive')),
          ),
          body: TabBarView(
            children: [
              new Container(
color: new Color(0xFFBFE0F3),
                child: new CustomPaint(
          painter: ShapesPainterSend(),

          child:
          new Column(
                  mainAxisAlignment: MainAxisAlignment.start,

                  children: <Widget>[
                    new Container(
                      margin:EdgeInsets.only(top: 15.0,left: 10,right: 10),
                      width:MediaQuery.of(context).size.width,
                      height: 45,

                      child: RaisedButton(
                        elevation: 4.0,
                        shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(30.0)),
                        color: new Color(0xFF254C91),
                        onPressed: getFilePath,
                        child: Text(
                          Translations.of(context).text('FileSelect'),
                          style: new TextStyle(
                            fontSize: 20,
                            color: Colors.white,
                            fontFamily: 'PTSerif'
                          ),
                        ),
                      ),
                    ),
        new Container(
          margin:EdgeInsets.only(top: 5),
          height: MediaQuery.of(context).size.height-215 ,
          width:MediaQuery.of(context).size.width,
                    child: new SendFileList(widget.userId,widget.sessionId,getFileList(),refreshSendList,progressDialog,removeSendList),
        ),

                  ],
                ),
                ),
              ),

              new Container(
                color: new Color(0xFFBFE0F3),
                child: new CustomPaint(
                  painter: ShapesPainterReceive(),

                  child:new Column(
                  mainAxisAlignment: MainAxisAlignment.start,

                  children: <Widget>[

                    new Container(
                      margin:EdgeInsets.only(top: 10),
                      height: MediaQuery.of(context).size.height-205 ,
                      width:MediaQuery.of(context).size.width,
                      child: new ReceiveFileList(getReceiveFileList(),refreshList,progressDialog),
                    ),

                  ],
                ),

              ),

              ),
            ],

          ),
        ),),
      ),
    );
  }



  getFileList() {

    return sendFileList;
  }

  getReceiveFileList() {

    return receiveFileList;
  }

  void getFilePath() async {
    try {
      String filePath = await FilePicker.getFilePath(type: FileType.ANY);
      if (filePath == '') {
        return;
      }
      int fSize = File(filePath).lengthSync();
      if (((fSize/1024)/1024) > 100) {
       _scaffoldKey.currentState.showSnackBar(new SnackBar(
          content: new Text( Translations.of(context).text('FileSizeLimit')),
        duration: Duration(milliseconds: 1500),));
      }
      else {
        print("File path: " + filePath);
        int cntLocation = filePath.lastIndexOf("/");
        String fileName = filePath.substring(cntLocation + 1, filePath.length);
        sendFileList.add(SendFileModal(
            fileName: fileName, orderNo: cnt++, fileWay: filePath));
        setState(() => this.sendFileList = sendFileList);
      }
    } catch (e) {
      print("Error while picking the file: " + e.toString());
    }
  }


  void refreshList(int)
  {
    this.receiveFileList[int].status = "1";
    setState(() => this.receiveFileList = receiveFileList);
  }

  void refreshSendList(int)
  {
    this.sendFileList[int].status = "1";
    setState(() => this.sendFileList = sendFileList);
  }

  void removeSendList(int)
  {
    this.sendFileList.removeAt(int);
    setState(() => this.sendFileList = sendFileList);
  }

  void getPendingFile(String userId,String sessionId)
  {

    print("SessionId: ${widget.sessionId}");
    print("userId: ${widget.userId}");
    var url = GetConstants.getService()+"/sendlyme/session/filereceive";
    http.post(url, body: {'userid':userId, 'sessionid':sessionId} )
        .then((response) {
      print("Response status: ${response.statusCode}");

      if(response.statusCode == 200 )
      {
        final jsonResponse = json.decode(response.body);
        PostHttpList resultHttp = PostHttpList.fromJson(jsonResponse);


        if(resultHttp.status)
        {
          receiveFileList.clear();
          int receiveCnt=0;
          //test et
//          var dataResponse = json.decode("{\"status\":true,\"data\":[{\"id\":\"f37d1f19-75d7-4834-a5fd-7312d014ae7d\",\"name\":\"Screenshot_2018-11-15-23-35-24.png\",\"status\":\"0\"}]}");


          if(resultHttp.timestatus== false) {
            _scaffoldKey.currentState.showSnackBar(new SnackBar(
              content: new Text(Translations.of(context).text('SessionTime')),
              duration: Duration(milliseconds: 3000),
            ));
            Navigator.pop(context);
          }
          else {

              resultHttp.data.forEach((data) {
              String fileId = data['id'];
              String fileName = data['name'];
              String fileStatus = data['status'];
              receiveFileList.add(new ReceiveFileModal(
                  ++receiveCnt, fileId, fileName, fileStatus));
            });

            setState(() => this.receiveFileList = receiveFileList);
          }
        }
        else
        {
          _scaffoldKey.currentState.showSnackBar(new SnackBar(
            content: new Text(Translations.of(context).text('Failed')),
            duration: Duration(milliseconds: 1500),
          ));
        }
      }
    })
        .catchError((onError){
      _scaffoldKey.currentState.showSnackBar(new SnackBar(
        content: new Text(Translations.of(context).text('ServiceConnectionFailed')),
        duration: Duration(milliseconds: 1500),
      ));
    }).timeout(const Duration(milliseconds: 1000));

    // http.read("http://example.com/foobar.txt").then(print);

  }

}


//
//class SendReceive extends State<SendReceiveApp> {
//  String barcode = "";
//
//  @override
//  initState() {
//
//    super.initState();
//  }
//
//  @override
//  Widget build(BuildContext context) {
//
//
//    return Scaffold(
//      appBar: AppBar(
//        title: Text('Gönder/Al'),
//      ),
//      body: new Container(
//              child: new Column(
//                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                  children: [
//                    Container(
//                        child: Text('Gönder'),
//                      alignment: Alignment.topCenter,
//                      height: 10,
//                    ),
//                    new Expanded(
//                      flex: 1,
//                      child: new Container(
//                        alignment: Alignment.topCenter,
//                        child: Text('a1'), //varaible above
//                      ),
//                    ),
//                    Container(
//                      child: Text('Alınanlar'),
//                      alignment: Alignment.topCenter,
//                      height: 10,
//                    ),
//                    new Expanded(
//                      flex: 1,
//                      child: new Container(
//                        alignment: Alignment.topCenter,
//                        child: Text('a2'), //variable above
//                      ),
//                    ),
//         ]
//      ),
//      ),
//
//    );
//  }
//
//
//}

class ShapesPainterSend extends CustomPainter {
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
    path.lineTo(size.width,size.height*0.90);
    path.lineTo(0,size.height*0.80);
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

class ShapesPainterReceive extends CustomPainter {
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
    path.lineTo(0,size.height*0.90);
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