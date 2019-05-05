import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:http_parser/http_parser.dart';
import 'package:sendlyme/localizationlib/translations.dart';
import 'package:sendlyme/modal/sendfilesmodal.dart';
import 'package:http/http.dart' as http;
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:sendlyme/service/getconstants.dart';

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
          child: SendFileListItem(userId,sessionId,_sendFileModal[int],refreshSendList,int,progressDialog),
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
  Function(bool) progressDialog;
  final String userId;
  final String sessionId;
  var itemNo=0;

  SendFileListItem(this.userId,this.sessionId,this._sendFileModal,this.refreshSendList,this.itemNo,this.progressDialog);
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
            borderRadius: new BorderRadius.circular(12.0),
              color: new Color(0x77FFFFFF)
          ),
          child:
            Row(
          crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,

            children: <Widget>[

              Expanded(
                flex: 4,
                child:
                new Container(
                  margin: EdgeInsets.only(left: 10),
                  child: Row(children: <Widget>[
                    new Text((_sendFileModal.orderNo).toString(),style: customTextStyle(),),
                    new Text('-',style: customTextStyle(),),
          Expanded(
            child: new Text(_sendFileModal.fileName,style: customTextStyle(),maxLines: 1,softWrap: true,overflow: TextOverflow.ellipsis)
          )

                    ,
                  ],),
                ),
              ),

      Expanded(
        flex: 3,
        child: new Container(


          height: 45,
          padding: EdgeInsets.all(3),
          margin: EdgeInsets.only(left: 10.0),
          child: new RaisedButton(
            shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(20.0)),
            elevation: 4.0,
            color: new Color(0xFF254C91),
            onPressed:  () => sendFile(this.userId,this.sessionId, _sendFileModal.fileWay),
            child: getText(),

          ),
        )
      ),


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
      return new Text(Translations.of(context).text('Sent'),style: sendTextStyle());
    }
    else
    {
      return new Text(Translations.of(context).text('Send'), style: sendTextStyle(),);
    }

  }
}

