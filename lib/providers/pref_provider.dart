

import 'package:flutter/material.dart';
import 'package:selc_admin/components/custom_theme.dart';
import 'package:selc_admin/model/preferences.dart';
import 'package:provider/provider.dart';

class PreferencesProvider extends ChangeNotifier{

  Preferences preferences = Preferences();

  //for handling the themes
  Brightness brightness = Brightness.light;
  Map<String, Color> colorScheme = LIGHT_THEME_COLORS;

  void loadPreferences() async{
    preferences = await  Preferences.fromSharedPreferences();
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



  void setDefaultDownloadPath(String downloadPath){
    try{

      preferences.defaultDownloadDirectory = downloadPath;
      Preferences.save(preferences);

      notifyListeners();
    }catch(_){
      throw Exception();
    }
  }




  static Color getColor(BuildContext context, String color){
    return Provider.of<PreferencesProvider>(context,).colorScheme[color]!;
  }

}





