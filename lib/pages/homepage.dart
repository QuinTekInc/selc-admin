

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:selc_admin/components/text.dart';
import 'package:selc_admin/pages/courses_page.dart';
import 'package:selc_admin/pages/dashboard_page.dart';
import 'package:selc_admin/pages/lecturers_page.dart';
import 'package:selc_admin/pages/questions_page.dart';
import 'package:selc_admin/pages/settings_page.dart';
import 'package:selc_admin/pages/user_management/users_page.dart';
import 'package:selc_admin/providers/page_provider.dart';
import 'package:selc_admin/providers/pref_provider.dart';
import 'package:selc_admin/providers/selc_provider.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();

}

class _HomepageState extends State<Homepage> {

  int selectedIndex = 0;

  List<Widget> fragments = [
    
  ];

  List<String> fragmentNames = [];

  bool isSuperuser = false;

  @override
  void initState() {

    isSuperuser = Provider.of<SelcProvider>(context, listen: false).user.isSuperuser;


    fragments = [
      DashboardPage(),
      LecturersPage(),
      CoursesPage(),
      QuestionsPage(), 
      if(isSuperuser) UsersPage(),
      SettingsPage()
    ];



    fragmentNames = [
      'Dashboard',
      'Lecturers',
      'Courses',
      'Questionnaire',
      if(isSuperuser) 'Users',
      'Settings'
    ];



    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      //Colors.grey.shade100
      backgroundColor: PreferencesProvider.getColor(context, 'primary-color'),

      body: Row(  
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [

          SideBar(
            isSuperSuper: isSuperuser,
            selectedIndex: selectedIndex,
            onSelectionChanged: (newIndex) => setState(() {
              selectedIndex = newIndex;
              Provider.of<PageProvider>(context, listen: false).pushReplacementPage(fragments[newIndex], fragmentNames[selectedIndex]);
            }),
          ),

          Expanded(
            child: Provider.of<PageProvider>(context).navigatorStack.last
          )

        ],
      ),
    );
  }



}




class SideBar extends StatefulWidget {

  final bool isSuperSuper;
  final int selectedIndex;
  final void Function(int) onSelectionChanged;

  const SideBar({super.key, required this.isSuperSuper,  required this.selectedIndex, required this.onSelectionChanged});

  @override
  State<SideBar> createState() => _SideBarState();
}

class _SideBarState extends State<SideBar> {


  List<dynamic> navigatorItems = [];


  @override
  void initState() {

    navigatorItems = [
      (CupertinoIcons.list_dash, 'Dashboard'),
      (CupertinoIcons.person, 'Lecturers'),
      (CupertinoIcons.book, 'Courses'),
      (CupertinoIcons.chat_bubble_2, 'Questions'),
      if(widget.isSuperSuper) (CupertinoIcons.person_3, 'Users'),
      (Icons.settings_outlined, 'Settings')
    ];


    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(12),
      elevation: 12,

      //color: Colors.grey.shade300
      color: PreferencesProvider.getColor(context, 'alt-primary-color'),

      child: Container(
        //width: 129,
        padding: EdgeInsets.symmetric(vertical:12, horizontal: 0),
      
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12)
        ),
      
        child: Column(  
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
      
          children:[ 
      
            Image.asset(
              'lib/assets/imgs/UENR-Logo.png',
              height: 60,
            ),
      
            const SizedBox(height: 12,),


            Expanded(
              flex: 2,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: List<Widget>.generate(  
                    navigatorItems.length,
                    (int index) => NavigatorItem(
                      icon: navigatorItems[index].$1, //gets the icon data.
                      name: navigatorItems[index].$2, //gets the section name
                      selected: widget.selectedIndex == index, 
                      onTap: () => widget.onSelectionChanged(index)
                    )
                  ),
                ),
              ),
            )
      
          
          ]
        ),
      ),
    );
  }
}


class NavigatorItem extends StatefulWidget {

  final IconData icon;
  final String name;
  final bool selected;
  final void Function() onTap;

  const NavigatorItem({super.key, required this.icon, required this.name, required this.selected, required this.onTap});

  @override
  State<NavigatorItem> createState() => _NavigatorItemState();
}

class _NavigatorItemState extends State<NavigatorItem> {

  bool isHovered = false;

  @override
  Widget build(BuildContext context) {

    Color iconColor = (isHovered || widget.selected) ? Colors.white :
      Theme.of(context).brightness == Brightness.dark ? Colors.white38 : Colors.green.shade500;

    Color tileBackgroundColor = isHovered ? Colors.green.shade200 : PreferencesProvider.getColor(context, 'table-background-color');

    Color? textColor;

    if(widget.selected){
      tileBackgroundColor = Colors.green.shade500;
      textColor = Colors.green.shade400;
    }


    return GestureDetector(
      onTap: widget.onTap,

      child: MouseRegion(
        onEnter: (pointerEvent) => setState(() => isHovered = true),
        onExit: (pointerEvent) => setState(() => isHovered = false),

        child: Container(

          padding: EdgeInsets.all(8),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
          
            children: [
      
              Card(

                color: tileBackgroundColor,

                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Icon(
                    widget.icon, 
                    size: 35, 
                    color: iconColor,
                  ),
                ),
              ), 
      
              SizedBox(height: 8,),
      
              CustomText(
                widget.name,
                textColor: textColor,
                fontWeight: widget.selected ? FontWeight.w600 : FontWeight.normal,
                padding: EdgeInsets.zero,
              )
          
            ],
          ),
        ),
      ),
    );
  }
}