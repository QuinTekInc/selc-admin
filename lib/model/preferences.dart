

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:selc_admin/components/utils.dart';

class Preferences {

  static const String _PREF_SHARED_KEY = "preferences";

  double fontScale;
  bool darkMode;
  String? defaultDownloadDirectory;

  List<String> savedFiles;

  Preferences({
    this.fontScale=0, 
    this.darkMode=false, 
    this.defaultDownloadDirectory, 
    this.savedFiles = const []
  }){
    defaultDownloadDirectory ??= getAppDocumentsDirectory();
  }


  factory Preferences.fromJson(Map<String, dynamic> jsonMap){
    return Preferences(
      fontScale: jsonMap['font_scale'].toDouble(),
      darkMode: jsonMap['dark_mode'],
      defaultDownloadDirectory: jsonMap['default_download_directory'],
      savedFiles:  List<String>.from(jsonMap['saved_files'])
    );
  }



  Map<String, dynamic> toMap() =>{
    'font_scale': fontScale,
    'dark_mode': darkMode,
    'default_download_directory': defaultDownloadDirectory,
    'saved_files': savedFiles
  };



  static Future<Preferences> fromSharedPreferences() async {

    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

    if(!sharedPreferences.containsKey(_PREF_SHARED_KEY)){
      return Preferences();
    }


    final prefString = sharedPreferences.getString(_PREF_SHARED_KEY);

    Map<String, dynamic> jsonMap = jsonDecode(prefString!);

    return Preferences.fromJson(jsonMap);
  }




  static void save(Preferences preferences) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setString(_PREF_SHARED_KEY, jsonEncode(preferences.toMap()));
  }

}