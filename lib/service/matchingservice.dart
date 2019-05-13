import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import 'dart:convert';

import 'package:sendlyme/modal/posthttp.dart';
import 'package:sendlyme/service/getconstants.dart';
class MatchingService
{
  MatchingService.postStartInfo(String sessionId, Function(bool,bool) callBack){

    var url = GetConstants.getHasSessionSyncService();
    http.post(url, body: {'sessionid':sessionId} )
        .then((response) {
      print("Response status: ${response.statusCode}");

      if(response.statusCode == 200 )
      {
        final jsonResponse = json.decode(response.body);
        PostHttp resultHttp = PostHttp.fromJson(jsonResponse);
        if(resultHttp.status)
        {
          callBack(true,true);
        }
        else
        {
          callBack(false,false);
        }
      }
    })
        .catchError((onError){
      callBack(null,false);
    }).timeout(const Duration(milliseconds: 1000));

  }
}