import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
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
  bool multiFileSizeCheckWrong = false;
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  bool sendAllVisibility=false,receiveAllVisibility=false;
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
          height: MediaQuery.of(context).size.height-265 ,
          width:MediaQuery.of(context).size.width,
                    child: new SendFileList(widget.userId,widget.sessionId,getFileList(),refreshSendList,progressDialog,removeSendList),
        ),
          Visibility(
              visible: sendAllVisibility,
              child: new Container(
            margin:EdgeInsets.only(left: 25,right: 25),
            width:MediaQuery.of(context).size.width,
            height: 45,

                    child: RaisedButton(
                      elevation: 4.0,
                      shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(30.0)),
                      color: new Color(0xFF254C91),
                      onPressed: sendAll,
                      child: Text(
                        Translations.of(context).text('AllSend'),
                        style: new TextStyle(
                            fontSize: 20,
                            color: Colors.white,
                            fontFamily: 'PTSerif'
                        ),
                      ),
                    ),
          )
          )
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
                      height: MediaQuery.of(context).size.height-210 ,
                      width:MediaQuery.of(context).size.width,
                      child: new ReceiveFileList(getReceiveFileList(),refreshList,progressDialog),
                    ),
                    Visibility(
                        visible: receiveAllVisibility,
                        child: new Container(
                          margin:EdgeInsets.only(left: 25,right: 25),
                          width:MediaQuery.of(context).size.width,
                          height: 45,

                          child: RaisedButton(
                            elevation: 4.0,
                            shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(30.0)),
                            color: new Color(0xFF254C91),
                            onPressed: receiveAll,
                            child: Text(
                              Translations.of(context).text('AllReceive'),
                              style: new TextStyle(
                                  fontSize: 20,
                                  color: Colors.white,
                                  fontFamily: 'PTSerif'
                              ),
                            ),
                          ),
                        )
                    )
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

  void multiFileCheck(key, value) {
    if (value == '') {
      return;
    }
    int fSize = File(value).lengthSync();
    if (((fSize/1024)/1024) > 100) {
      multiFileSizeCheckWrong = true;
    }

  }
  void fileAddList(key,value)
  {
    print("File path: " + value);
    int cntLocation = value.lastIndexOf("/");
    String fileName = value.substring(cntLocation + 1, value.length);
    sendFileList.add(SendFileModal(
        fileName: fileName, orderNo: cnt++, fileWay: value));
    setState(() => this.sendFileList = sendFileList);
    var notSendCnt = 0;
    for(SendFileModal fileModal in this.sendFileList)
    {
      if(fileModal.status!="1")
      notSendCnt++;
    }
    if(notSendCnt>1)
      setState(() { sendAllVisibility = true; });
    else
      setState(() { sendAllVisibility = false; });
  }
  void getFilePath() async {
    try {
      Map<String,String> multiFileList = await FilePicker.getMultiFilePath(type: FileType.ANY);
      multiFileList.forEach(multiFileCheck);

     if(!multiFileSizeCheckWrong)
       {
        multiFileList.forEach(fileAddList);
      }
     else
       {
           _scaffoldKey.currentState.showSnackBar(new SnackBar(
             content: new Text( Translations.of(context).text('FileSizeLimit')),
             duration: Duration(milliseconds: 1500),));
       }
    } catch (e) {
      print("Error while picking the file: " + e.toString());
    }
  }

  void sendAll() async {

    List<SendFileModal> fileList = getFileList();
    sendFile(fileList,0);

  }

  void receiveAll() async {

    List<ReceiveFileModal> fileList = getReceiveFileList();
    receiveFile(fileList,0);

  }

  void refreshList(int)
  {
    this.receiveFileList[int].status = "1";
    setState(() => this.receiveFileList = receiveFileList);
    var notReceiveCnt = 0;
    for(ReceiveFileModal fileModal in this.receiveFileList)
    {
      if(fileModal.status!="1")
        notReceiveCnt++;
    }
    if(notReceiveCnt>1)
      setState(() { receiveAllVisibility = true; });
    else
      setState(() { receiveAllVisibility = false; });
  }

  void refreshSendList(int)
  {
    this.sendFileList[int].status = "1";
    setState(() => this.sendFileList = sendFileList);
    var notSendCnt = 0;
    for(SendFileModal fileModal in this.sendFileList)
    {
      if(fileModal.status!="1")
        notSendCnt++;
    }
    if(notSendCnt>1)
      setState(() { sendAllVisibility = true; });
    else
      setState(() { sendAllVisibility = false; });
  }

  void removeSendList(int)
  {
    this.sendFileList.removeAt(int);
    setState(() => this.sendFileList = sendFileList);
    var notSendCnt = 0;
    for(SendFileModal fileModal in this.sendFileList)
    {
      if(fileModal.status!="1")
        notSendCnt++;
    }
    if(notSendCnt>1)
      setState(() { sendAllVisibility = true; });
    else
      setState(() { sendAllVisibility = false; });
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

              var notReceiveCnt = 0;
              for(ReceiveFileModal fileModal in this.receiveFileList)
              {
                if(fileModal.status!="1")
                  notReceiveCnt++;
              }
              if(notReceiveCnt>1)
                setState(() { receiveAllVisibility = true; });
              else
                setState(() { receiveAllVisibility = false; });
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


  sendFile(List<SendFileModal> fileList,int cnt) async
  {
    SendFileModal fileModal = fileList[cnt];
    if(fileModal.status == "1")
    {
//      Scaffold.of(this.context).showSnackBar(new SnackBar(
//        content: new Text(Translations.of(context).text('Sent')),
//      ));

      if(fileList.length-1 != cnt)
      {
        sendFile(fileList, ++cnt);
      }
      else
      {
        setState(() {
          sendAllVisibility = false;
        });
      }
    }
    else
    {
      //_showDialog();
      progressDialog(true);
      Uri uri = Uri.parse(GetConstants.getUploadService());
      http.MultipartRequest request = new http.MultipartRequest('POST', uri);
      request.fields['userid'] = widget.userId;
  request.fields['sessionid'] = widget.sessionId;


  request.files.add(await http.MultipartFile.fromPath('file', fileModal.fileWay));

  request.send().then((response) {
  print("Response status: ${response.statusCode}");

  if (response.statusCode == 200) {
  refreshSendList(cnt);
  progressDialog(false);
  if(fileList.length-1 != cnt)
    {
      sendFile(fileList, ++cnt);
    }
  else
    {
      setState(() {
        sendAllVisibility = false;
      });
    }
//          final jsonResponse = json.decode(response.body);
//          PostHttp resultHttp = PostHttp.fromJson(jsonResponse);
//          if(resultHttp.status)
//            {
//              Scaffold.of(this.context).showSnackBar(new SnackBar(
//                content: new Text("Servis Erişimi Başarılı Dosya Gönderildi."),
//              ));
//            }
//          else
//          {
//            Scaffold.of(this.context).showSnackBar(new SnackBar(
//              content: new Text("Başarısız"),
//            ));
//          }
  }
  else
  {
  progressDialog(false);
  Scaffold.of(this.context).showSnackBar(new SnackBar(
  content: new Text(Translations.of(context).text('Problem')),
  ));
  }
  })
      .catchError((onError) {
  progressDialog(false);
  Scaffold.of(this.context).showSnackBar(new SnackBar(
  content: new Text(Translations.of(context).text('ServiceConnectionFailed')),
  ));
  }).timeout(const Duration(milliseconds: 1000));

    // http.read("http://example.com/foobar.txt").then(print);
  }
  }

  receiveFile(List<ReceiveFileModal> fileList,int cnt) async
  {
    ReceiveFileModal fileModal = fileList[cnt];
    if(fileModal.status == "1")
    {
//      Scaffold.of(this.context).showSnackBar(new SnackBar(
//        content: new Text(Translations.of(context).text('Sent')),
//      ));

      if(fileList.length-1 != cnt)
      {
        receiveFile(fileList, ++cnt);
      }
      else
      {
        setState(() {
          receiveAllVisibility = false;
        });
      }
    }
    else
    {
        //_showDialog();
        progressDialog(true);
        var url = GetConstants.getDownloadService();
        final response = await http.post(url, body: {'fileid': fileModal.fileId});
        print("Response status: ${response.statusCode}");

        if (response.statusCode == 200) {
          if (response.contentLength == 0) {
            return;
          }
          try {
            Directory externalDir = await getExternalStorageDirectory();
            String tempPath = externalDir.path;
            String fileName = fileModal.fileName;
            File file = new File('$tempPath/$fileName');
            await file.writeAsBytes(response.bodyBytes);
            //Navigator.of(context).pop();
            progressDialog(false);

            var url = GetConstants.getTookFileService();
            http.post(url, body: {'fileid': fileModal.fileId})
                .then((response) {
              print("Response status: ${response.statusCode}");

              if (response.statusCode == 200) {
                final jsonResponse = json.decode(response.body);
                PostHttp.fromJson(jsonResponse);
                refreshList(cnt);
                if(fileList.length-1 != cnt)
                {
                  receiveFile(fileList, ++cnt);
                }
                else
                {
                  setState(() {
                    receiveAllVisibility = false;
                  });
                }
              }
            });
          }
          catch (value) {}
        }
    }
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