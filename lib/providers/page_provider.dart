

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:selc_admin/pages/dashboard_page.dart';



class PageProvider extends ChangeNotifier{

  List<Widget> navigatorStack = [DashboardPage()]; //by default the dashboard would be showing.
  List<String> pageNames = ['Dashboard'];



  PageProvider(); //unnamed construction

  void pushPage(Widget page, String name){

    navigatorStack.add(page);
    pageNames.add(name);

    notifyListeners();
  }


  void popPage(){

    if(navigatorStack.length == 1) return;

    navigatorStack.removeLast();
    pageNames.removeLast();

    notifyListeners();
  }


  void popUntil(bool Function() flag){


    while(flag() != true && navigatorStack.isNotEmpty && pageNames.isNotEmpty){
      navigatorStack.removeLast();
      pageNames.removeLast();
    }

    notifyListeners();
  }



  void pushReplacementPage(Widget replacementPage, String name){
    
    navigatorStack = [replacementPage];
    pageNames = [name];

    notifyListeners();
  }




  factory PageProvider.of(BuildContext context, {listen = false}) => Provider.of<PageProvider>(context, listen: listen);

}
