
import  'package:shared_preferences/shared_preferences.dart';

const String AUTHENTICATION_TOKEN_KEY = 'auth_token';


Future<String> getAuthorizationToken() async{
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getString(AUTHENTICATION_TOKEN_KEY) ?? '';
}



Future<void> saveAuthorizationToken(String token) async{

  SharedPreferences prefs = await SharedPreferences.getInstance();
  
  prefs.setString(AUTHENTICATION_TOKEN_KEY, token);
  
}

