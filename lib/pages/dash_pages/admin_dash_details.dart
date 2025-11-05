

import 'dart:io';

import 'package:animations/animations.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:selc_admin/components/admin_excel_export.dart';
import 'package:selc_admin/components/alert_dialog.dart';
import 'package:selc_admin/components/button.dart';
import 'package:selc_admin/components/text.dart';
import 'package:selc_admin/components/utils.dart';
import 'package:selc_admin/model/models.dart';
import 'package:selc_admin/pages/dash_pages/dash_tables/course_performance_table.dart';
import 'package:selc_admin/pages/dash_pages/dash_tables/suggestion_sentiments_table.dart';
import 'package:selc_admin/providers/pref_provider.dart';
import 'package:selc_admin/providers/selc_provider.dart';

import 'dash_tables/lecturer_ratings_table.dart';
import 'dash_tables/response_rate_table.dart';


class AdminDashPage extends StatefulWidget {
  const AdminDashPage({super.key});

  @override
  State<AdminDashPage> createState() => _AdminDashPageState();
}

class _AdminDashPageState extends State<AdminDashPage> {

  int selectedTab = 0;

  List<ClassCourse> classCourses = [];
  List<DashboardSuggestionSentiment> suggestionSentiments = [];
  List<DashboardCategoriesSummary> dashCategoriesSummary = [];

  @override
  void initState() {
    super.initState();
    
    loadData();
  }



  void loadData() async {
    try{

      classCourses = await Provider.of<SelcProvider>(context, listen: false).getCurrentClassCourses();
      suggestionSentiments = await Provider.of<SelcProvider>(context, listen: false).getDashSuggestionSentiments();
      dashCategoriesSummary = await Provider.of<SelcProvider>(context, listen: false).getDashCategoriesSummary();

      //todo: write a function to handle the querying of the suggestion sentiments
    } on SocketException{
      showNoConnectionAlertDialog(context);
    }

    setState(() {});
  }


  @override
  Widget build(BuildContext context) {
    return Padding(  
      padding: const EdgeInsets.all(16),

      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          
          Row(
            children: [
              HeaderText('OVERALL DETAILS', fontSize: 25,),

              Spacer(),


              //todo: button to handle excel export
              TextButton.icon(

                onPressed: () async {
                  AdminReportExcelExport adminExcelReport = AdminReportExcelExport(context: context, classCourses: classCourses, categoriesSummary: dashCategoriesSummary, suggestionSentiments: suggestionSentiments);
                  adminExcelReport.save();
                },
                //write out this function later.
                icon: Icon(Icons.download, color: Colors.green.shade400),
                label: CustomText('Export to Excel', textColor: Colors.green.shade400,),
              ),


              const SizedBox(width: 12,),



              //todo: button to handle refreshing
              TextButton.icon(
                onPressed: loadData,
                icon: Icon(Icons.refresh, color: Colors.green.shade400),
                label: CustomText('Refresh', textColor: Colors.green.shade400,),
              )

            ],
          ),
          NavigationTextButtons(),


          const SizedBox(height: 12,),

          //todo: add the rest of the ui here.
          Expanded(
            child: DefaultTabController(
              initialIndex: 0,
              length: 4,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                spacing: 12,
                children: [

                  //TabBar
                  Container(  
                    //padding: const EdgeInsets.all(8),
                    height: 50,
                    decoration: BoxDecoration(
                      border: Border.all(width: 1.5, color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(12)
                    ),

                    child: TabBar(
                      indicatorColor: Colors.green.shade200,
                      indicatorSize: TabBarIndicatorSize.tab,
                      dividerColor: Colors.transparent,
                      indicatorPadding: EdgeInsets.zero,

                      indicator: BoxDecoration(
                        borderRadius: BorderRadius.circular(8.0),
                        color: Colors.green.shade400,
                      ),

                      padding: const EdgeInsets.all(4),
                      labelPadding: const EdgeInsets.all(8),
                      indicatorAnimation: TabIndicatorAnimation.elastic,
                      labelColor: Colors.white,

                        labelStyle: TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w600
                        ),
                        unselectedLabelStyle: TextStyle(
                            fontFamily: 'Poppins'
                        ),


                        onTap: (newValue) => setState(() => selectedTab = newValue),
                        tabs: [

                          // Tab(
                          //   text: 'General',
                          // ),

                          Tab(
                            text: 'Response Rates',
                          ),

                          Tab(  
                            text: 'Course Scores'
                          ),

                          Tab(  
                            text: 'Lecturer Ratings'
                          ),

                          Tab(   
                            text: 'Suggestion Sentiments'
                          )

                        ]
                    ),

                  ),


                  //todo tabviews.
                  Expanded(  
                    child: PageTransitionSwitcher(

                      duration: Duration(milliseconds: 500),

                      transitionBuilder: (child, animation, secondaryAnimation ) => FadeThroughTransition(
                        animation: animation,
                        secondaryAnimation: secondaryAnimation,
                        fillColor: Colors.transparent,
                        child: child,
                      ),

                      child: selectedTab ==  0 ?  ResponseRateTable(classCourses: classCourses,) :
                            selectedTab == 1 ? CoursePerformanceTable(classCourses: classCourses,) :
                            selectedTab == 2 ? LecturerRatingsTable(classCourses: classCourses,) :
                            selectedTab == 3 ? SuggestionSentimentsTable(sentiments: suggestionSentiments) : Placeholder()
                    ),
                  )

                ],

              )
            ),
          )

        ],
      ),
    );
  }
}



//read more on signals in django
//caches and cache invalidation using django



//red obsession