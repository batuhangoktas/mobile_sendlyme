import 'package:http/http.dart' as http;

import 'dart:convert';

import 'package:sendlyme/modal/posthttp.dart';
import 'package:sendlyme/service/getconstants.dart';
class JoinService
{
  JoinService.post(String sessionId, Function(String,bool) callBack){

    var url = GetConstants.getJoinSessionService();
    http.post(url, body: {'sessionid':sessionId} )
        .then((response) {
      print("Response status: ${response.statusCode}");

      if(response.statusCode == 200 )
      {
        final jsonResponse = json.decode(response.body);
        PostHttp resultHttp = PostHttp.fromJson(jsonResponse);
        if(resultHttp.status)
        {
          String userId = resultHttp.data['userId'].toString();
          callBack(userId,true);
        }
        else
        {
          callBack("",false);
        }
      }
    })
        .catchError((onError){
      callBack("",false);
    }).timeout(const Duration(milliseconds: 1000));

  }
}