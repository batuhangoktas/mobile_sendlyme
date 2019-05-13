import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import 'dart:convert';

import 'package:sendlyme/modal/posthttp.dart';
import 'package:sendlyme/service/getconstants.dart';
class StartService
{
  StartService.postStartInfo(Function(String,String,bool) callBack){

    var url = GetConstants.getCreateSessionService();

    http.post(url,)
        .then((response) {
      print("Response status: ${response.statusCode}");

      if(response.statusCode == 200 )
      {
        final jsonResponse = json.decode(response.body);
        PostHttp resultHttp = PostHttp.fromJson(jsonResponse);
        if(resultHttp.status)
        {
          String userId = resultHttp.data['userId'].toString();
          String sessionId = resultHttp.data['sessionId'].toString();
          callBack(sessionId,userId,true);
        }
        else
        {
          callBack(null,null,false);
        }
      }
    })
        .catchError((onError){
      callBack(null,null,false);
    }).timeout(const Duration(milliseconds: 1000));


  }



}