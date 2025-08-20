

import 'package:http/http.dart' as http;
import 'dart:async';

import 'package:selc_admin/components/preferences_util.dart';

const String base_url = 'http://127.0.0.1:8000';


String concat(String other){
  return '$base_url/admin-api/$other';
}

Future<http.Response> getRequest({required String endPoint, dynamic body}) async {

  final url = Uri.parse(concat(endPoint));

  Map<String, String> headers = {'Content-Type': 'application/json'};

  String token = await getAuthorizationToken();

  if(token.trim().isNotEmpty){
    headers.addEntries({'Authorization': 'Token ${token.trim()}'}.entries);
  }

  final response = await http.get(url, headers: headers);

  return response;
}

Future<http.Response> postRequest({required String endpoint, required Object body}) async {
  final url = Uri.parse(concat(endpoint));

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