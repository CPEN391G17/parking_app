import 'dart:convert';

import 'package:http/http.dart' as http;

class RequestAssistant{

  // change string to uri
  
  static Future<dynamic> getRequest(String url) async{
      http.Response response = await http.get(Uri.parse(url));

      //successfull response
      try {
        if(response.statusCode == 200){
          String jsondata = response.body; //json response data
          var decodeData = jsonDecode(jsondata);
          return decodeData;
        }
        else{
          return "failed";
        }
      } on Exception catch (e) {
        return "failed";
      }

  }

}