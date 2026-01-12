

import 'package:http/http.dart' as http;
import 'dart:async';

import 'package:selc_admin/components/preferences_util.dart';

import 'package:web_socket_channel/web_socket_channel.dart';


const String baseUrl = 'http://127.0.0.1:8000';
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

  final wsURL = Uri.parse('ws://127.0.0.1:800/admin-api/ws/admin-dasboard');
  late WebSocketChannel websocket;

  WebSocketService(){
    websocket  = WebSocketChannel.connect(wsURL);
  }


}

