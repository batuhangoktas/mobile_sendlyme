
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sendlyme/localizationlib/translations.dart';
import 'package:sendlyme/modal/receivefilesmodal.dart';
import 'package:http/http.dart' as http;
import 'package:sendlyme/modal/posthttp.dart';
import 'package:sendlyme/service/getconstants.dart';
import 'dart:convert';

import 'package:open_file/open_file.dart';
class ReceiveFileList  extends StatelessWidget {
  final List<ReceiveFileModal> _receiveFileModal;
  Function(int) refreshList;
  Function(bool) progressDialog;
  ReceiveFileList(this._receiveFileModal,this.refreshList,this.progressDialog);

  @override
  Widget build(BuildContext context) {



    return Container(height:MediaQuery.of(context).size.height-200,child: _buildList(context));
  }

  ListView _buildList(context) {
    return ListView.builder(

      // Must have an item count equal to the number of items!
      itemCount: _receiveFileModal.length,
      // A callback that will return a widget.
      itemBuilder: (context, int) {
        // In our case, a DogCard for each doggo.
        return ReceiveFileListItem(_receiveFileModal[int],refreshList,int,progressDialog);
      },
    );
  }

}

class ReceiveFileListItem extends StatelessWidget {
  final ReceiveFileModal _receiveFileModal;
  Function(int) refreshList;
  Function(bool) progressDialog;
  var itemNo=0;
  ReceiveFileListItem(this._receiveFileModal,this.refreshList,this.itemNo,this.progressDialog);
  BuildContext context;


  bool _loading = true;

  @override
  Widget build(BuildContext context) {
    this.context=context;



    return new Container(

        padding: EdgeInsets.only(left: 10,right: 10,top: 10),
      child: Column(children: <Widget>[
      new Container(
      decoration: new BoxDecoration(
      borderRadius: new BorderRadius.circular(12.0),
        color: new Color(0x77FFFFFF)
    ),child:
      Row(

      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,

      children:  <Widget>[

        Expanded(
          flex: 4,
          child:
          new Container(
            margin: EdgeInsets.only(left: 10),
            child: Row(children: <Widget>[
              new Text((_receiveFileModal.orderNo).toString(),style: customTextStyle(),),
              new Text('-',style: customTextStyle(),),
              Expanded(
                  child: new Text(_receiveFileModal.fileName,style: customTextStyle(),maxLines: 1,softWrap: true,overflow: TextOverflow.ellipsis)
              )

              ,
            ],),
          ),
        ),

        Expanded(
            flex: 2,
            child: new Container(


              height: 45,
              padding: EdgeInsets.all(3),
              margin: EdgeInsets.only(left: 10.0),
              child: new RaisedButton(
                shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(20.0)),
                elevation: 4.0,
                color: new Color(0xFF254C91),
                onPressed:  () => getFile(_receiveFileModal.fileId,_receiveFileModal.fileName),
                child: getText(),

              ),
            )
        ),



      ],

      ),
    ),
      ],)
    );


  }

  TextStyle customTextStyle()
  {
    return TextStyle(fontSize: 17, fontFamily: 'PTSerif', color: new Color(0xFF254C91),);
  }

  TextStyle receiveTextStyle()
  {
    return TextStyle(fontSize: 17, fontFamily: 'PTSerif', color: Colors.white,);
  }

  void getFile(String fileId,String fileName) async{

    if(_receiveFileModal.status == "1")
      {
        Directory externalDir = await getExternalStorageDirectory();
        String tempPath = externalDir.path;
        File file = new File('$tempPath/$fileName');

//        Scaffold.of(this.context).showSnackBar(new SnackBar(
//        content: new Text(file.path),
//      ));

        OpenFile.open(file.path);

      }
else {
      //_showDialog();
      progressDialog(true);

      var url = GetConstants.getDownloadService();
      final response = await http.post(url, body: {'fileid': fileId});
      print("Response status: ${response.statusCode}");

      if (response.statusCode == 200) {
        if (response.contentLength == 0) {
          return;
        }
        try {
          Directory externalDir = await getExternalStorageDirectory();
          String tempPath = externalDir.path;
          File file = new File('$tempPath/$fileName');
          await file.writeAsBytes(response.bodyBytes);
          //Navigator.of(context).pop();
          progressDialog(false);

          var url = GetConstants.getTookFileService();
          http.post(url, body: {'fileid': fileId})
              .then((response) {
            print("Response status: ${response.statusCode}");

            if (response.statusCode == 200) {
              final jsonResponse = json.decode(response.body);
              PostHttp.fromJson(jsonResponse);
              refreshList(itemNo);
            }
          });
        }
        catch (value) {}
      }
    }
  }

//  Future<File> _downloadFile(String url, String filename) async
//  {
//    _showDialog();
//      String extension = url.substring(url.lastIndexOf("."));
//      filename = filename.replaceAll(" ", "_").trim()+extension;
//      http.Client client = new http.Client();
//      var req = await client.get(Uri.parse(url));
//      var bytes = req.bodyBytes;
//      String dir = (await getExternalStorageDirectory()).path;
//      File file = new File('$dir/$filename');
//      await file.writeAsBytes(bytes);
//
//      Scaffold.of(this.context).showSnackBar(new SnackBar(
//        content: new Text(filename + " indirildi."),
//      ));
//    Navigator.of(context).pop();
//      return file;
//  }

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
    if(_receiveFileModal.status=="1") {
      return new Text(Translations.of(context).text('Show'), style: receiveTextStyle(),);
    }
    else
      {
        return new Text(Translations.of(context).text('Download'), style: receiveTextStyle(),);
      }
  }
}