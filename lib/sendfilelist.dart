import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:http_parser/http_parser.dart';
import 'package:sendlyme/localizationlib/translations.dart';
import 'package:sendlyme/modal/sendfilesmodal.dart';
import 'package:http/http.dart' as http;
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:sendlyme/service/getconstants.dart';
import 'package:sendlyme/constants/DataUtil.dart';

class SendFileList extends StatelessWidget {
  final List<SendFileModal> _sendFileModal;
  Function(int) refreshSendList;
  Function(int) removeSendList;
  Function(bool) progressDialog;
  final String userId;
  final String sessionId;

  SendFileList(this.userId,this.sessionId,this._sendFileModal,this.refreshSendList,this.progressDialog,this.removeSendList);




  @override
  Widget build(BuildContext context) {
    return Container(height:MediaQuery.of(context).size.height-200,child: _buildList(context));
  }

  ListView _buildList(context) {
    return ListView.builder(

      // Must have an item count equal to the number of items!
      itemCount: _sendFileModal.length,
      // A callback that will return a widget.
      itemBuilder: (context, int) {
        return GestureDetector(
          child: SendFileListItem(userId,sessionId,_sendFileModal[int],refreshSendList,int,progressDialog,removeSendList),
          onLongPress: () => {

          // flutter defined function
          showDialog(
            context: context,
            builder: (BuildContext context) {

              return AlertDialog(
                shape: RoundedRectangleBorder(borderRadius:
                BorderRadius.all(Radius.circular(15))),
                content: new Text(Translations.of(context).text('RemoveItemMessage')),
                actions: <Widget>[
                  new FlatButton(
                    child: new Text(Translations.of(context).text('No'),style: TextStyle(color: Colors.pink),),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  new FlatButton(
                    child: new Text(Translations.of(context).text('Yes'),style: TextStyle(color: Colors.pink),),
                    onPressed: () {
                      Navigator.of(context).pop();
                      removeSendList(int);

                    },
                  ),
                ],
              );
            },
          )

          }
        );

       // return SendFileListItem(userId,sessionId,_sendFileModal[int],refreshSendList,int,progressDialog);
      },
    );
  }

}

class SendFileListItem extends StatelessWidget {
  final SendFileModal _sendFileModal;
  Function(int) refreshSendList;
  Function(int) removeSendList;
  Function(bool) progressDialog;
  final String userId;
  final String sessionId;
  var itemNo=0;

  SendFileListItem(this.userId,this.sessionId,this._sendFileModal,this.refreshSendList,this.itemNo,this.progressDialog,this.removeSendList);
  BuildContext context;
  @override
  Widget build(BuildContext context) {

    this.context=context;
    return new Container(

      padding: EdgeInsets.only(left: 10,right: 10,top: 10),
        child:  new Column(
        children: <Widget>[

        new Container(
          decoration: new BoxDecoration(
            borderRadius: new BorderRadius.circular(5.0),
              color: new Color(0x77FFFFFF),
          ),
          child:
            Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,

            children: <Widget>[

            new Flexible( child:
                new Container(
                  margin: EdgeInsets.only(left: 10),
                  child: new Text(_sendFileModal.fileName,style: customTextStyle(),maxLines: 1,softWrap: true,overflow: TextOverflow.ellipsis)
                ),
            ),
            new GestureDetector(
              onTap: () {
                removeSendList(itemNo);
              },
              child: getDeleteText(),
            ),


            ],
        ),

    ),
        new Container(
          decoration: new BoxDecoration(
            borderRadius: new BorderRadius.circular(5.0),
            color: new Color(0x77FFFFFF),
          ),
          child:
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,

            children: <Widget>[
              new Container(

                width: 40,
                height: 50,
                padding: EdgeInsets.only(left:3,top:3,right:5,bottom:3),
                child: Image(
                    width: 30,
                    height: 30,
                    image: getLogoByType(_sendFileModal.fileName)
                ),
              ),
    new Container(
    margin: EdgeInsets.only(left: 20),
    child: new Text(getFileSize(_sendFileModal.fileWay),style: fileSizeTextStyle(),),
    ),
          new Container(


                    child: new Row(
                      children: <Widget>[

                        new GestureDetector(
                          onTap: () {
                            sendFile(this.userId,this.sessionId, _sendFileModal.fileWay);
                          },
                          child: getText(),
                        ),
                      ],
                    )
                  )



            ],
          ),

        ),

  ]
        ),
    );


  }

  TextStyle customTextStyle()
  {
    return TextStyle(fontSize: 17, fontFamily: 'PTSerif', color: new Color(0xFF254C91),);
  }
  TextStyle fileSizeTextStyle()
  {
    return TextStyle(fontSize: 15, fontFamily: 'PTSerif', color: new Color(0xFF254C91),);
  }
  getFileSize(String fileWay)
  {
    int fSize = File(fileWay).lengthSync();
    return(((fSize)/(1024*1024)).toStringAsFixed(2)+" mb");
  }

  TextStyle sendTextStyle()
  {
    return TextStyle(fontSize: 17, fontFamily: 'PTSerif', color: Colors.white,);
  }

  sendFile(String userId,String sessionId,String fileWay) async
  {
    if(_sendFileModal.status == "1")
    {
      Scaffold.of(this.context).showSnackBar(new SnackBar(
        content: new Text(Translations.of(context).text('Sent')),
      ));
    }
    else
      {
      //_showDialog();
        progressDialog(true);
      Uri uri = Uri.parse(GetConstants.getUploadService());
      http.MultipartRequest request = new http.MultipartRequest('POST', uri);
      request.fields['userid'] = userId;
      request.fields['sessionid'] = sessionId;


      request.files.add(await http.MultipartFile.fromPath('file', fileWay));

      request.send().then((response) {
        print("Response status: ${response.statusCode}");

        if (response.statusCode == 200) {
          refreshSendList(itemNo);
          progressDialog(false);
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
  getText() {
    if(_sendFileModal.status=="1") {
      return new  Image.asset("assets/uploaded.png",height: 45.0,width: 50.0,);
    }
    else
    {
      return new  Image.asset("assets/upload.png",height: 45.0,width: 50.0,);
    }

  }
  getDeleteText() {
    return new Column( children: <Widget>[
     new Container( width: 50,child: new Padding(padding: EdgeInsets.all( 5.0),child: new  Image.asset("assets/delete.png",height: 25.0,width: 25.0),),),
    ],);
    //return new Text(Translations.of(context).text('Delete'), style: sendTextStyle(),);
  }

  getLogoByType(String fileName)
  {
    DataUtil dataUtil = new DataUtil();
    String extension = dataUtil.getLogoByType(fileName);
    return new AssetImage("assets/"+extension);
  }
}

