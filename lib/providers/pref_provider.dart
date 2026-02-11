

import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:selc_admin/components/custom_theme.dart';
import 'package:selc_admin/model/preferences.dart';
import 'package:provider/provider.dart';

import '../model/models.dart';
import 'package:selc_admin/components/server_connector.dart' as connector;

class PreferencesProvider extends ChangeNotifier{

  Preferences preferences = Preferences();

  List<ReportFile> reportFiles = [];


  //for handling the themes
  Brightness brightness = Brightness.light;
  Map<String, Color> colorScheme = LIGHT_THEME_COLORS;

  Future<void> loadPreferences() async{

    preferences = await  Preferences.fromSharedPreferences();
    reportFiles = preferences.savedFiles;
    _updateUI(preferences.darkMode);
  }


  void setFontScale(double newScale){

    try{

      preferences.fontScale = newScale;
      Preferences.save(preferences);

      notifyListeners();
    }catch(_){
      //do nothing here.
    }
    
    
  }


  void setDarkMode(bool isDarkMode){
    try{

      preferences.darkMode = isDarkMode;
      Preferences.save(preferences);

      _updateUI(isDarkMode);
    }catch(_){
      //also do nothing here.
    }

  }


  void _updateUI(bool isDarkMode){

    brightness = preferences.darkMode ? Brightness.dark: Brightness.light;
    colorScheme = preferences.darkMode ? DARK_THEME_COLORS : LIGHT_THEME_COLORS;

    notifyListeners();
  }


  void addSavedFile(ReportFile reportFile){

    List<ReportFile> matchedFiles = reportFiles.where(
      (element) => element.fileName == reportFile.fileName && element.fileType == reportFile.fileType && element.url == reportFile.url)
      .toList();

    if(matchedFiles.isNotEmpty){
      int index = reportFiles.indexOf(matchedFiles.first);
      reportFiles[index] = reportFile;
    }else{
      reportFiles.add(reportFile);
    }

    preferences.savedFiles = reportFiles;
    
    Preferences.save(preferences);

    notifyListeners();
  }


  void deleteReportFile(ReportFile reportFile) async {

    final file = File(reportFile.localFilePath!);

    await file.delete();

    try{
      reportFiles.remove(reportFile);
    }on Exception{
      //do nothing
    }

    notifyListeners();
  }



  void setDefaultDownloadPath(String downloadPath){
    try{

      preferences.defaultDownloadDirectory = downloadPath;
      Preferences.save(preferences);

      notifyListeners();
    }catch(_){
      throw Exception();
    }
  }





  // Future<void> getFilesFromBackend() async {
  //
  //   final response = await connector.getRequest(endpoint: 'get-all-files/', useCore: true);
  //
  //   if(response.statusCode != 200){
  //     throw Error();
  //   }
  //
  //
  //   List<dynamic> responseBody = jsonDecode(response.body);
  //
  //   if(responseBody.isEmpty && !kIsWeb){
  //     reportFiles = downloadedFiles;
  //     notifyListeners();
  //     return;
  //   }
  //
  //
  //   if(kIsWeb){
  //     reportFiles = responseBody.map((jsonMap) => ReportFile.fromJson(jsonMap)).toList();
  //     return;
  //   }
  //
  //   reportFiles = responseBody.map((jsonMap){
  //
  //     var matchedFiles = downloadedFiles.where(
  //       (rFile){
  //
  //         bool fNameFlag = rFile.fileName == jsonMap['file_name'];
  //
  //         bool fTypeFlag = rFile.fileType == jsonMap['file_type'];
  //
  //         bool urlFlag = rFile.url == jsonMap['file_url'];
  //
  //         bool localPathFlag = rFile.localFilePath != null;
  //
  //         bool fileExists = rFile.isFileExistLocally;
  //
  //         return fNameFlag && fTypeFlag && urlFlag && localPathFlag && fileExists;
  //       }
  //     ).toList();
  //
  //     if(matchedFiles.isNotEmpty) {
  //       return matchedFiles.first;
  //     }
  //
  //     return ReportFile.fromJson(jsonMap);
  //
  //   }).toList();
  //
  //   notifyListeners();
  //
  // }



  Future<ReportFile?> generateReportFile(Map<String, dynamic> reportParams) async{

    final response = await connector.postRequest(
        endpoint: 'generate-report/', useCore: true, body: jsonEncode(reportParams));

    if(response.statusCode != 200){
      throw Error();
    }

    dynamic responseBody = jsonDecode(response.body);

    return ReportFile.fromJson(responseBody as Map<String, dynamic>);

  }




  static Color getColor(BuildContext context, String color, {listen=true}){
    return Provider.of<PreferencesProvider>(context, listen: listen).colorScheme[color]!;
  }

}





