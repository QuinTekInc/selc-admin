
import 'dart:convert';
import 'package:flutter/material.dart';

import 'package:selc_admin/model/models.dart';
import 'package:selc_admin/components/server_connector.dart' as connector;

class FilesProvider extends ChangeNotifier{


  Future<List<ReportFile>> getReportFiles() async {

    final response = await connector.getRequest(endPoint: 'core/all-files/');

    if(response.statusCode != 200){
      throw Exception('An unexpected error occurred. Please try again');
    }

    List<dynamic> responseBody = jsonDecode(response.body);

    return  responseBody.map((jsonMap) => ReportFile.fromJson(jsonMap)).toList();


  }
}