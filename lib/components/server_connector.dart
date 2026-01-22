

import 'dart:convert';

import 'package:http/http.dart' as http;
import 'dart:async';

import 'package:selc_admin/components/preferences_util.dart';
import 'package:web_socket_client/web_socket_client.dart';


const String baseUrl = 'http://127.0.0.1:8000'; //rename to httpUrl
//const String base_url = 'https://selc-backend.onrender.com';



String concat(String other, {useCore = false}){
  
  if(useCore) return '$baseUrl/core/$other';
  
  return '$baseUrl/admin-api/$other';
}




Future<http.Response> getRequest({required String endpoint, dynamic body, useCore=false}) async {

  final url = Uri.parse(concat(endpoint, useCore: useCore));

  Map<String, String> headers = {'Content-Type': 'application/json'};

  String token = await getAuthorizationToken();

  if(token.trim().isNotEmpty){
    headers.addEntries({'Authorization': 'Token ${token.trim()}'}.entries);
  }

  final response = await http.get(url, headers: headers);

  return response;
}


Future<http.Response> postRequest({required String endpoint, required Object body, useCore=false}) async {

  final url = Uri.parse(concat(endpoint, useCore: useCore));

  //adding authorization to it. 
  Map<String, String> headers = {
    'Content-Type': 'application/json'
  };

  String token = await getAuthorizationToken();

  if(token.trim().isNotEmpty){
    headers.addEntries({'Authorization': 'Token ${token.trim()}'}.entries);
  }

  return await http.post(
    url,
    headers: headers,
    body: body
  );
}






class WebSocketService{

  late WebSocket _websocket;

  final StreamController<Map<String, dynamic>> _streamController = StreamController<Map<String, dynamic>>.broadcast();

  Stream get dataStream =>  _streamController.stream;

  final String consumerEndpoint;

  WebSocketService({required this.consumerEndpoint}){
    connect();
  }

  String _buildUrl(String endpoint){
    return 'ws://127.0.0.1:8000/$endpoint';
  }


  void connect() async {

    String token = await getAuthorizationToken();

    final wsURL = Uri.parse(_buildUrl(consumerEndpoint));

    try{
      _websocket = WebSocket(wsURL, headers: {'Authorization': 'Token ${token.trim()}'});

      _websocket.messages.listen(
        (message) {
          // Assuming the incoming message is a JSON string
          final Map<String, dynamic> data =  jsonDecode(message);

          _streamController.add(data);

        }, 
        onError: (error) async  {
          _streamController.addError(error);
          await _streamController.close();
        },

        onDone: () => _websocket.close()
      );

    }catch(error){
      throw Error();
    }
  }


  void dispose(){
    _websocket.close();
    _streamController.close();
  }


}

