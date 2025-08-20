

import 'package:flutter/material.dart';
import 'package:selc_admin/model/preferences.dart';

class PreferencesProvider extends ChangeNotifier{

  Preferences preferences = Preferences();

  void loadPreferences() async{
    preferences = await  Preferences.fromSharedPreferences();
   
    notifyListeners();
  }


  void setFontScale(int newScale){

    try{

      preferences.fontScale = newScale;
      preferences.save();

      notifyListeners();
    }catch(_){
      //do nothing here.
    }
    
    
  }


  void setDarkMode(bool isDarkMode){
    try{
      preferences.darkMode = isDarkMode;
      preferences.save();

      notifyListeners();
    }catch(_){
      //also do nothing here.
    }
  }

}