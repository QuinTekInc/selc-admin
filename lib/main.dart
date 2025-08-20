
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:selc_admin/pages/auth/login_page.dart';
import 'package:selc_admin/providers/page_provider.dart';
import 'package:selc_admin/providers/pref_provider.dart';
import 'package:selc_admin/providers/selc_provider.dart';


void main(){

  WidgetsFlutterBinding.ensureInitialized();


  runApp(

    MultiProvider(
      providers: [

        ChangeNotifierProvider(
          create: (_) => SelcProvider(),
        ),

        ChangeNotifierProvider(
          create: (_) => PageProvider(),
        ),

        ChangeNotifierProvider(
          create: (_){
            PreferencesProvider prefProvider = PreferencesProvider();
            prefProvider.loadPreferences();
            return prefProvider;
          }
        )
      ],

      child: const SelcAdminApp()
    )
    
  );
}


class SelcAdminApp extends StatelessWidget {

  const SelcAdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginPage()
    );
  }
  
}


//now we need to study the excel file.

