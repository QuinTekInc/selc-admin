
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:selc_admin/components/alert_dialog.dart';
import 'package:selc_admin/components/button.dart';
import 'package:selc_admin/components/charts/bar_chart.dart';
import 'package:selc_admin/components/custom_notification_badge.dart';
import 'package:selc_admin/components/server_connector.dart';
import 'package:selc_admin/components/text.dart';
import 'package:selc_admin/components/utils.dart';
import 'package:selc_admin/model/models.dart';
import 'package:selc_admin/pages/dash_pages/admin_dash_details.dart';
import 'package:selc_admin/pages/dash_pages/best_lecturer_card.dart';
import 'package:selc_admin/pages/dash_pages/course_ratings_page.dart';
import 'package:selc_admin/pages/files_page.dart';
import 'package:selc_admin/pages/dash_pages/lecturer_ratings_page.dart';
import 'package:selc_admin/pages/auth/login_page.dart';
import 'package:selc_admin/pages/notifications_page.dart';
import 'package:selc_admin/pages/user_profile_page.dart';
import 'package:selc_admin/providers/page_provider.dart';
import 'package:selc_admin/providers/pref_provider.dart';
import 'package:selc_admin/providers/selc_provider.dart';

import '../components/charts/pie_chart.dart';

class DashboardPage extends StatefulWidget {

  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {

  final _cardsScrollController = ScrollController();

  bool isLRatingsLoading = false;
  bool isCRatingsLoading = false;

  SelcProvider? _selcProvider;
  SelcProvider get selcProvider => _selcProvider!;

  //this data is grabbed using the web channel serivce
  Map<String, dynamic> dashboardGraphData = {};

  @override
  void initState() {
    super.initState();

    _selcProvider = Provider.of<SelcProvider>(context, listen:false);
    
    loadLRatingsRank();
    loadCRatingsRank();
    
  }


  void loadLRatingsRank() async {

    setState(() => isLRatingsLoading = true);


    try{
      await selcProvider.getLecturerRatingsRank(
        filterBody: {
          'semester': Provider.of<SelcProvider>(context, listen:false).currentSemester,
          'year': Provider.of<SelcProvider>(context, listen: false).currentAcademicYear
        }
      );
    }catch(exception){

      showCustomAlertDialog(
        context,
        title: 'Error',
        contentText: exception.toString()
      );

    }

    setState(() => isLRatingsLoading = false);
  }


  void loadCRatingsRank() async{
    setState(() => isCRatingsLoading = true);

    await selcProvider.getCourseRatingsRank(
      filterBody: {
        'semester': Provider.of<SelcProvider>(context, listen: false).currentSemester,
        'year': Provider.of<SelcProvider>(context, listen: false).currentAcademicYear
      }
    );

    setState(() => isCRatingsLoading = false);
  }


  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          //todo: top row.......more like and app bar.
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,

            children: [

              HeaderText('Dashboard', fontSize: 25,),

              Spacer(),

              //todo: the notification button.
              GestureDetector(

                onTap: () => Provider.of<PageProvider>(context, listen:false).pushPage(NotificationsPage(), "Notifications"),

                child: NotificationBadge(
                  child: Container(
                    height: 43,
                    width: 45,
                    alignment: Alignment.center,

                    decoration: BoxDecoration(
                      color: Colors.grey.shade500,
                      borderRadius: BorderRadius.circular(12)
                    ),

                    child: Icon(CupertinoIcons.bell, color: Colors.white),
                  ),
                ),
              ),

              //todo: the user info section
              SizedBox(
                width: 250,
                child: ListTile(
                  horizontalTitleGap: 4,
                  leading: Container(
                    height: 45,
                    width: 45,
                    decoration: BoxDecoration(
                      color: Colors.green.shade400,
                      borderRadius: BorderRadius.circular(12)
                    ),

                    child: Icon(CupertinoIcons.person, color: Colors.white, ),
                  ),

                  title: CustomText(
                    'Welcome',
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),

                  subtitle: CustomText(
                    Provider.of<SelcProvider>(context).user.username!,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    maxLines: 1,
                    softwrap: false,
                    overflow: TextOverflow.ellipsis,
                  ),

                  trailing: PopupMenuButton(
                    icon: Icon(Icons.arrow_drop_down),

                    onSelected: (newValue){

                      switch(newValue){


                        case 'viewProfile':
                          //todo: navigate to the user profile page.
                          Provider.of<PageProvider>(context, listen: false).pushPage(UserProfilePage(), 'User Profile');
                          return;

                        case 'logout':
                          //todo: logout the user.
                          handleLogout(context);
                          return;

                        default:
                          break;
                      }

                    },

                    itemBuilder: (_){
                      return <PopupMenuItem>[

                        PopupMenuItem(
                          value: 'viewProfile',
                          child: Row(
                            mainAxisSize: MainAxisSize.min,

                            children: [

                              Icon(CupertinoIcons.person, color: Colors.green.shade400,),

                              const SizedBox(width: 8,),

                              CustomText(
                                'View Profile'
                              )

                            ],
                          ),
                        ),

                        PopupMenuItem(
                          value: 'logout',
                          child: Row(
                            mainAxisSize: MainAxisSize.min,

                            children: [

                              Icon(CupertinoIcons.square_arrow_right, color: Colors.red.shade400,),

                              const SizedBox(width: 8,),

                              CustomText(
                                'Logout'
                              )

                            ],
                          ),
                        ),

                      ];
                    },
                  ),
                ),
              )

            ],
          ),

          Expanded(
            flex: 2,

            child: SingleChildScrollView(

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,

                children: [

                  //welcome container
                  Container(
                    margin: EdgeInsets.only(top: 8),
                    padding: EdgeInsets.all(12),
                    child: buildUserWelcomeWidget(context),
                  ),

                  SizedBox(height: 8,),

                  //todo: dashboard summary details.
                  Scrollbar(
                    controller: _cardsScrollController,
                    scrollbarOrientation: ScrollbarOrientation.bottom,
                    thumbVisibility: true, //throws error when set to false because scrollbar track cannot be drawn without a thumb
                    trackVisibility: false,
                    interactive: true,
                    thickness: 8,
                    radius: Radius.circular(12),

                    child: SingleChildScrollView(
                      controller: _cardsScrollController,
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,

                        children: [
                          //todo: fix this later.
                          buildSummaryCard(
                              icon: CupertinoIcons.calendar,
                              name: 'Academic Year',
                              detail: Provider.of<SelcProvider>(context).generalStat.currentSemester.toString(), //TODO: fix the problem later.
                              backgroundColor: Colors.grey.shade600
                          ),

                          buildSummaryCard(
                            icon: CupertinoIcons.calendar_today,
                            name: 'Current Semester',
                            detail: Provider.of<SelcProvider>(context).generalStat.currentSemester.toString(), //TODO: fix the problem later.
                            backgroundColor: Colors.grey.shade400
                          ),

                          buildSummaryCard(
                            icon: CupertinoIcons.question,
                            name: 'Number of Questions',
                            detail: Provider.of<SelcProvider>(context).generalStat.questionsCount.toString(),
                            backgroundColor: Colors.blue.shade400
                          ),


                          buildSummaryCard(
                            icon: CupertinoIcons.person,
                            name: 'Lecturers',
                            detail: Provider.of<SelcProvider>(context).generalStat.lecturersCount.toString()
                          ),


                          buildSummaryCard(
                            icon: CupertinoIcons.book,
                            name: 'Number of Classes',
                            detail: Provider.of<SelcProvider>(context).generalStat.coursesCount.toString(),
                            backgroundColor: Colors.yellow.shade700
                          ),

                          buildSummaryCard(
                            icon: CupertinoIcons.chat_bubble,
                            name: 'Evaluations Submitted',
                            detail: Provider.of<SelcProvider>(context).generalStat.evaluationsCount.toString(),
                            backgroundColor: Colors.red.shade400
                          ),


                          buildSummaryCard(
                            icon: CupertinoIcons.chat_bubble_2,
                            name: 'Suggestions Made',
                            detail: Provider.of<SelcProvider>(context).generalStat.evalSuggestionsCount.toString(),
                            backgroundColor: Colors.purple.shade400
                          ),


                          const SizedBox(width: 12,),
                          
                          //todo: button to show in-depth administrator dashboard of the course evaluation
                          DashSeeMoreButton(onPressed: () => Provider.of<PageProvider>(context, listen:false).pushPage(AdminDashPage(), 'Overall Details')),
                        ],
                      ),
                    ),
                  ),



                  const SizedBox(height: 12,),

                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [

                      //todo: ratings tables section
                      Expanded(
                        flex: 3,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          spacing: 12,

                          children: [


                            //todo: this part needs to be put inside a stream builder to load data from the websocket
                            DashboardGraphSection(),

                            buildLecturerRatingsTable(context),

                            buildCourseRatingsTable(context),

                          ],
                        ),
                      ),



                      const SizedBox(width: 12),


                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          spacing: 12,

                          children: [

                            BestLecturerCard(isLoading: this.isLRatingsLoading,),

                            BestCourseCard(isLoading: this.isCRatingsLoading),

                            buildRecentFilesSection(),

                            //buildRecentAction(context),

                          ],
                        ),
                      )
                    ],
                  ),


                ],
              ),
            ),
          ),
        ],
      ),
    );
  }




  Column buildUserWelcomeWidget(BuildContext context) {

    String name = Provider.of<SelcProvider>(context).user.fullName();

    return Column(   
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,

      children: [

        CustomText('Welcome', fontSize: 17, fontWeight: FontWeight.w600,),

        CustomText(
          '$name,', 
          fontSize: 20, 
          fontWeight: FontWeight.bold,
        ),

        CustomText('to your workspace', fontWeight: FontWeight.w500,)

      ],

    );
  }




  Widget buildSummaryCard({IconData? icon, required String name, required String detail, Color? backgroundColor}) {
    
    backgroundColor ??= Colors.green.shade400;
    
    return Container(
      width: 300,
      height: 100,
      margin: EdgeInsets.only(left: 8, right: 8, bottom: 12),
      padding: EdgeInsets.all(12),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12)
      ),

      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: Color.lerp(backgroundColor, Colors.white, 0.4),
            child: Icon(
              icon, 
              size: 50,
              color: Colors.white,
            ),
          ),

          const SizedBox(width: 12,),

          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [

                CustomText(
                  detail,
                  fontSize: 25,
                  fontWeight: FontWeight.w800,
                  textColor: Colors.white,
                ),

                CustomText(
                  name,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  textColor: Colors.white,
                  softwrap: true,
                  overflow: TextOverflow.ellipsis,
                )
              ],
            ),
          )
        ]
      ),
    );
  }




  //todo: function to show recent evaluations
  Widget buildRecentFilesSection(){

    int filesLength = Provider.of<PreferencesProvider>(context).downloadedFiles.length;

    return Container(
      //width: 400,
      padding: const EdgeInsets.all(8),
      height: MediaQuery.of(context).size.height * 0.46,

      decoration: BoxDecoration(
        //Colors.white
        color: PreferencesProvider.getColor(context, 'table-background-color'),
        borderRadius: BorderRadius.circular(12)
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
      
        children: [
      
          Row(
            children: [
              HeaderText(
                'Recent Files',
                fontSize: 15,
              ),

              Spacer(),


              //todo: do something here
              TextButton(
                onPressed: () => PageProvider.of(context, listen:false).pushPage(FilesPage(), 'Files'),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CustomText(
                      'See more',
                      textColor: Colors.green.shade400,
                    ),

                    const SizedBox(width: 3,),

                    Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.green.shade200,
                    )
                  ],
                )
              )
            ],
          ),
      
          SizedBox(height: 8,),
      
      
          if(filesLength == 0) Expanded(
            child: CollectionPlaceholder(
              title: 'No Files Yet', 
              detail: 'All saved files appear here'
            )
          )
          else ListView.separated(
                
            physics: NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: filesLength >= 5 ? 5 : filesLength,
            
            itemBuilder: (_, index) {

              ReportFile reportFile = Provider.of<PreferencesProvider>(context, listen: false).downloadedFiles[index];

              String fileName = reportFile.fileName;
              String fileType = reportFile.fileType;

              return ListTile(
                leading: Container(
                  height: 45,
                  width: 45,
                        
                  decoration: BoxDecoration(
                    color: Colors.brown.shade100,
                    borderRadius: BorderRadius.circular(8)
                  ),
                        
                        
                  child: Icon( 
                    CupertinoIcons.book,
                    color: Colors.white,
                  ),
                        
                ),
              
                //todo replace with the course name
                title: CustomText(
                  fileName,
                  fontWeight: FontWeight.w600,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                        
                subtitle: CustomText(
                  fileType,
                  maxLines: 1,
                  softwrap: false,
                ),

                trailing: IconButton(
                  tooltip: 'Open',
                  icon: Icon(Icons.open_in_new),

                  //todo: implement a function to open a file
                  onPressed: (){},
                )
                        
              );
            },

            separatorBuilder: (_, index) => SizedBox(height: 8,)
          )
      
        ],
      
      ),
    );
  }



  //todo: recent actions
  Widget buildRecentAction(BuildContext context){

    return Container(  
      padding: const EdgeInsets.all(8),
      //width: 400,
      height: MediaQuery.of(context).size.height * 0.35,

      // constraints: BoxConstraints(
      //   minHeight: MediaQuery.of(context).size.height * 0.35,
      // ),

      decoration: BoxDecoration(
        //Colors.white
        color: PreferencesProvider.getColor(context, 'table-background-color'),
        borderRadius: BorderRadius.circular(12)
      ),


      child: Column(  
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,

        children: [

          CustomText(  
            'Recent Actions',
            fontWeight: FontWeight.w600,
          ),


          Expanded(
            child: Center(
              child: CustomText('No recent action'),
            ),
          )

        ],
      ),

    );
  }




  //todo: lecturer ratings table.
  Widget buildLecturerRatingsTable(BuildContext context){

    return Container(
      padding: const EdgeInsets.all(8),
      width: double.infinity,
      height: MediaQuery.of(context).size.height * 0.5,

      decoration: BoxDecoration(
        //Colors.white
        color: PreferencesProvider.getColor(context, 'table-background-color'),
        borderRadius: BorderRadius.circular(12)
      ),


      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [

          Row(
            children: [

              Row(
                spacing: 8,
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  HeaderText(
                    'Lecturer Ratings',
                    fontSize: 15,
                  ),

                  CustomText('[For the current semester]', textColor: PreferencesProvider.getColor(context, 'placeholder-text-color'),)
                ],
              ),

              Spacer(),

              TextButton(
                onPressed: () => Provider.of<PageProvider>(context, listen: false).pushPage(const LecturerRatingsPage(), 'Lecturer Ratings'),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CustomText(
                      'See more',
                      textColor: Colors.green.shade400,
                    ),

                    const SizedBox(width: 3,),

                    Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.green.shade200,
                    )
                  ],
                )
              )
            ],
          ),

          const SizedBox(height: 8,),

          //todo: build the table rows.

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(8),

            decoration: BoxDecoration(
              //Colors.grey.shade200
              color: PreferencesProvider.getColor(context, 'alt-primary-color'),
              borderRadius: BorderRadius.circular(12)
            ),


            child: Row(
              children: [

                SizedBox(
                  width: 120,
                  child: CustomText(
                    'No.'
                  ),
                ),


                Expanded(
                  flex: 2,
                  child: CustomText(
                    'Lecturer'
                  ),
                ),


                Expanded(
                  child: CustomText(
                    'Courses',
                    textAlignment: TextAlign.center,
                  ),
                ),



                SizedBox(
                  width: 120,
                  child: CustomText(
                    'Rate'
                  ),
                )
              ],
            )
          ),


          //todo: table contents

          if(isLRatingsLoading) Expanded(
            child: Center(
              child: CircularProgressIndicator()
            ),
          )
          else if(!isLRatingsLoading && Provider.of<SelcProvider>(context).lecturersRatings.isEmpty) Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomText(
                    'No Lecturer Ratings',
                    fontWeight: FontWeight.w600,
                  ),

                  CustomText(
                    'The first ten rows of lecturer rating appear here.'
                  )
                ],
              ),
            ),
          )else Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,

              children: List<Widget>.generate(
                Provider.of<SelcProvider>(context).lecturersRatings.length >= 5 ? 5 : Provider.of<SelcProvider>(context).lecturersRatings.length,
                (int index){
                  LecturerRating lRating = Provider.of<SelcProvider>(context, listen: false).lecturersRatings[index];

                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [

                        SizedBox(
                          width: 120,
                          child: CustomText(
                            (index+1).toString()
                          ),
                        ),


                        Expanded(
                          flex: 2,
                          child: CustomText(
                            lRating.lecturer.name
                          ),
                        ),


                        Expanded(
                          child: CustomText(
                            lRating.numberOfCourses.toString(),
                            textAlignment: TextAlign.center
                          ),
                        ),



                        SizedBox(
                          width: 120,
                          child: CustomText(
                            lRating.parameterRating.toStringAsFixed(2)
                          ),
                        )

                      ],
                    ),
                  );
                }
              ),
            ),
          )
        ],
      ),
    );

  }





  //todo: sample course ratings table.
  Widget buildCourseRatingsTable(BuildContext context){
    return Container(
      padding: const EdgeInsets.all(8),
      width: double.infinity,

      constraints: BoxConstraints(
        minHeight: MediaQuery.of(context).size.height * 0.5
      ),

      decoration: BoxDecoration(
        //Colors.white
        color: PreferencesProvider.getColor(context, 'table-background-color'),
        borderRadius: BorderRadius.circular(12)
      ),


      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,

        children: [

          Row(
            children: [

              Row(
                spacing: 8,
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  HeaderText(
                    'Course Ratings',
                    fontSize: 15,
                  ),

                  CustomText('[For the current semester]', textColor: PreferencesProvider.getColor(context, 'placeholder-text-color'),)
                ],
              ),

              Spacer(),


              TextButton(
                onPressed: () => Provider.of<PageProvider>(context, listen: false).pushPage(CourseRatingsPage(), 'Course Ratings'),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [

                    CustomText(
                      'See more',
                      textColor: Colors.green.shade400,
                    ),

                    const SizedBox(width: 3,),

                    Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.green.shade400,
                    )
                  ],
                )
              )
            ],
          ),

          const SizedBox(height: 8,),


          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(8),

            decoration: BoxDecoration(
              //Colors.grey.shade200
              color: PreferencesProvider.getColor(context, 'table-header-color'),
              borderRadius: BorderRadius.circular(12)
            ),


            child: Row(
              children: [

                //position
                const SizedBox(
                  width: 120,
                  child: CustomText('No.'),
                ),


                //course code
                Expanded(
                  child: CustomText(
                    'Course Code'
                  ),
                ),



                //course title
                Expanded(
                  flex: 2,
                  child: CustomText(
                    'Title'
                  ),
                ),


                //Number of students registered for the course.
                SizedBox(
                    width: 130,
                    child: CustomText('Lecturers')
                ),



                //Number of students registered for the course.
                SizedBox(
                  width: 130,
                  child: CustomText('Eval. Students')
                ),



                //collective mean score
                SizedBox(
                  width: 120,
                  child: CustomText(
                    'Mean Score'
                  ),
                ),



                SizedBox(
                  width: 130,
                  child: CustomText(
                    'Percentage(%)'
                  ),
                )
              ],
            )
          ),


          //todo: the table data itself.

          if(isCRatingsLoading) Container(
            height: 130,
            alignment: Alignment.center,
            child: CircularProgressIndicator(),
          )
          else if(!isCRatingsLoading && Provider.of<SelcProvider>(context).coursesRatings.isEmpty) Container(
            height: 130,
            alignment: Alignment.center,
            child: CollectionPlaceholder(
              title: 'Course Ratings',
              detail: 'The first ten rows on the course rating appears here.',
            ),
          )
          else Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: List<Widget>.generate(
              Provider.of<SelcProvider>(context, listen: false).coursesRatings.length >= 10 ? 10: Provider.of<SelcProvider>(context, listen: false).coursesRatings.length,
              (int index){
                CourseRating courseRating = Provider.of<SelcProvider>(context, listen: false).coursesRatings[index];
                return Padding(
                  padding: EdgeInsets.all(8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [


                      //position

                      SizedBox(
                        width: 120,
                        child: CustomText(
                         '${index+1}'
                        ),
                      ),


                      //course code

                      Expanded(
                        child: CustomText(
                          courseRating.course.courseCode
                        ),
                      ),



                      //course title
                      Expanded(
                        flex: 2,
                        child: CustomText(
                          courseRating.course.title,
                          maxLines: 1,
                          softwrap: false,
                        ),
                      ),




                      //Number of lecturers.
                      SizedBox(
                          width: 130,
                          child: CustomText(courseRating.numberOfLecturers.toString())
                      ),



                      //Number of students who have evaluated this course.
                      SizedBox(
                          width: 130,
                          child: CustomText(courseRating.evaluatedStudents.toString())
                      ),



                      SizedBox(
                        width: 120,
                        child: CustomText(
                          courseRating.parameterMeanScore.toStringAsFixed(2)
                        ),
                      ),


                      SizedBox(
                        width: 130,
                        child: CustomText(formatDecimal(courseRating.percentageScore)),
                      )

                    ],
                  ),
                );
              }
            ),
          )
        ],
      ),
    );
  }





  void handleLogout(BuildContext context) async {

    showDialog(  
      context: context, 
      builder: (_) => LoadingDialog(message: 'Logging Out.....Please wait',)
    );


    try{

      await Provider.of<SelcProvider>(context, listen: false).logout();

      Navigator.pop(context); //close the loading dialog dialog.

      Navigator.pushAndRemoveUntil(
        context, 
        MaterialPageRoute(
          builder: (_) => LoginPage(),
        ),
        (route) => false
      );

    }on SocketException catch(_){

      Navigator.pop(context); //close the loading dialog

      showCustomAlertDialog(
        context, 
        title: 'Logout Error', 
        contentText: 'Make sure you are connected to the internet'
      );

    }on Exception catch(exception){
      Navigator.pop(context); //close the loading dialog
      showCustomAlertDialog(
        context, 
        title: 'Error', 
        contentText: exception.toString()
      );
    }

  }


}




//total number of unique courses being handled in the semester
//total number of class courses
//total number of lecturers


//todo: shows all the graph for all the data recieved this semester.
class DashboardGraphSection extends StatefulWidget {

  const DashboardGraphSection({super.key});

  @override
  State<DashboardGraphSection> createState() => _DashboardGraphSectionState();
}

class _DashboardGraphSectionState extends State<DashboardGraphSection> {

  final WebSocketService websocketService = WebSocketService(consumerEndpoint: 'ws/selc-admin/dashboard/');

  @override void dispose(){
    websocketService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return  StreamBuilder(  
      stream: websocketService.dataStream,
      builder: (context, snapshot){

        switch(snapshot.connectionState){
          case ConnectionState.waiting: 
            return Container(
              width: double.infinity, 
              height: MediaQuery.of(context).size.height * 0.6,
              alignment: Alignment.center,

              decoration: BoxDecoration( 
                borderRadius: BorderRadius.circular(12),
                color: PreferencesProvider.getColor(context, 'alt-primary-color'),
              ),

              child: CircularProgressIndicator(),
            );

          default: 
            break;
        }



        if(snapshot.hasError){
          return Container(
            width: double.infinity,
            height: MediaQuery.of(context).size.height * 0.6,
            alignment: Alignment.center,

            decoration: BoxDecoration(  
              borderRadius: BorderRadius.circular(12),
              color: PreferencesProvider.getColor(context, 'alt-primary-color'),
            ),

            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              spacing: 8,
              children: [

                Icon(Icons.warning_rounded, color: Colors.red.shade400, size: 100),

                CustomText(  
                  'Could not load chart data',
                  fontWeight: FontWeight.w600, 
                  fontSize: 16
                ),


                SizedBox(
                  width: 350,
                  child: CustomText(
                    'Error: ${snapshot.error}',
                    textAlignment: TextAlign.center,
                  )
                ),

                CustomButton.withText(  
                  'Refresh',
                  onPressed: () => websocketService.connect(), //connect again when there is an error
                )
              ],
            ),
          );
        }



        if(!snapshot.hasData){
          return Center(  
            child: CustomText('No data received from server'),
          );
        }


        Map<String, dynamic> graphData = Map<String, dynamic>.from(snapshot.data);

        return Column(  
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          spacing: 12,
          children: [

            //todo: the various graphs

            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 12,
              children: [

                Expanded(
                  child: buildResponseRatePieChart(
                    Map<String, dynamic>.from(graphData['registration_summary'])
                  )
                ),

                Expanded(
                  child: buildSuggestionSentimentPieChart(
                    Map<String, dynamic>.from(graphData['sentiment_summary'])
                  )
                )
              ]
            ),


            Center(
              child: buildLecturerRatingBarChart(
                Map<String, dynamic>.from(graphData['lecturer_rating'])
              )
            ),

          ]
        );
      }
    );

  }



  ///todo: pie chart for suggestion sentiments
  Widget buildSuggestionSentimentPieChart(Map<String, dynamic> sentimentSummary){


    final sentiments = ['negative', 'neutral', 'positive'];
    final sectionColors = [Colors.red.shade400, Colors.amber, Colors.green.shade400];

    List<CustomPieSection> sections = [];

    final sentimentDetails = [];

    for(String sentiment in sentiments){

      int ratingCount = sentimentSummary[sentiment];

      double percentage = sentimentSummary['${sentiment}_percentage'];

      sections.add(
        CustomPieSection(
          value: percentage,
          keyTitle: sentiment,
          title: '${formatDecimal(percentage)}%',
          sectionColor: sectionColors[sentiments.indexOf(sentiment)]
        )
      );


      sentimentDetails.add((sentiment, ratingCount, percentage));

    }

    return Container(
      padding: const EdgeInsets.all(12),
      width: 400,

      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: PreferencesProvider.getColor(context, 'alt-primary-color')
      ),


      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 12,
        children: [
          HeaderText('Suggestions Sentiment Info'),

          CustomPieChart(
            backgroundColor: Colors.transparent,
            width: double.infinity,
            height: 325,
            centerSpaceRadius: 16,
            showKeys: true,
            pieSections: sections,
          ),

          HeaderText('Details'),

          ListView.separated(
            shrinkWrap: true,
            itemCount: sentimentDetails.length,
            separatorBuilder: (_, index) => Divider(),
            itemBuilder: (_, index){
              return Row(
                children: [

                  Expanded(
                    flex: 2,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      spacing: 3,
                      children: [

                        Container(
                          width: 16,
                          height: 16,
                          color: sectionColors[index],
                        ),

                        CustomText(
                          sentiments[index],
                        )
                      ],
                    ),
                  ),


                  Expanded(
                    flex: 1,
                    child: CustomText(
                      sentimentDetails[index].$2.toString(),
                      textAlignment: TextAlign.right,
                    ),
                  ),

                  Expanded(
                    flex: 1,
                    child: CustomText(
                      '${formatDecimal(sentimentDetails[index].$3)}%',
                      textAlignment: TextAlign.right,
                    ),
                  )

                ],
              );
            },
          )
        ]
      )

    );
  }




  //todo: bar chart for overall lecturer ratings
  Widget buildLecturerRatingBarChart(Map<String, dynamic> ratingSummary){

    int totalRated = 0;

    final List<Color> rodColors = [Colors.green.shade400, Colors.blue.shade400, Colors.purple.shade400, Colors.amber, Colors.red.shade400];

    final List<CustomBarGroup> barGroups= [];

    final List lRatingInfo = [];



    for(int i = 5; i >= 1; i--){
    
      int ratingCount = ratingSummary[i.toString()];

      totalRated += ratingCount;
    
      double percentage = ratingSummary['rating_${i}_percentage'];

      barGroups.add(
        CustomBarGroup(
          x: i,
          label: i.toString(),
          rods: [
            Rod(
              y: ratingCount.toDouble(),
              rodColor: rodColors[rodColors.length - i]
            )
          ]
        )
      );


      lRatingInfo.add((i, ratingCount, percentage));
    }

    return Container(
      padding: const EdgeInsets.all(12),
      width: double.infinity,
      //height: 415,

      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: PreferencesProvider.getColor(context, 'table-background-color')
      ),


      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        spacing: 12,
        children: [

          HeaderText('Overall Lecturers Rating'),

          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 12,
            children: [

              Expanded(
                child: CustomBarChart(
                  containerBackgroundColor: PreferencesProvider.getColor(context, 'alt-primary-color'),
                  width: double.infinity,
                  height: 350,
                  maxY: totalRated.toDouble(),
                  groups: barGroups,
                  rodWidth: 50,
                  rodBorderRadius: BorderRadius.circular(4),
                ),
              ),


              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: PreferencesProvider.getColor(context, 'alt-primary-color'),
                    borderRadius: BorderRadius.circular(12)
                  ),

                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [

                      HeaderText(
                        'Details',
                        textColor: PreferencesProvider.getColor(context, 'placeholder-text-color')
                      ),

                      const SizedBox(height: 12,),

                      ListView.separated(
                        shrinkWrap: true,
                        itemCount: 5,
                        separatorBuilder: (_, index) => Divider(height: 12),
                        itemBuilder: (_, index){
                          return Row(

                            children: [
                              Expanded(
                                flex: 2,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  spacing: 3,
                                  children: [

                                    Container(
                                      width: 16,
                                      height: 16,
                                      color: rodColors[index],
                                    ),

                                    CustomText(
                                      lRatingInfo[index].$1.toString(),
                                    )
                                  ],
                                ),
                              ),


                              Expanded(
                                flex: 1,
                                child: CustomText(
                                  lRatingInfo[index].$2.toString(),
                                  textAlignment: TextAlign.right,
                                ),
                              ),

                              Expanded(
                                flex: 1,
                                child: CustomText(
                                  '${formatDecimal(lRatingInfo[index].$3)}%',
                                  textAlignment: TextAlign.right,
                                ),
                              )
                            ],

                          );
                        },
                      )

                    ],
                  ),
                ),
              )


            ],
          )
        ]
      )

    );
  }



  //todo: Pie Chart for the response rate.
  Widget buildResponseRatePieChart(Map<String, dynamic> responseRateSummary){

    int overallReg = responseRateSummary['total_registrations'];
    int responseRecv = responseRateSummary['evaluated_registrations'];

    //find the number of those who not yet evaluated
    int totalUnresponse = overallReg - responseRecv;

    double responseRate = responseRateSummary['response_rate'];

    //percentage of those who have not yet evaluated.
    double unresponseRate = 100 - responseRate;

    final rRateItems = [
      ('Total Registrations', overallReg.toString()),
      ('Not Responded/ Not Evaluated', totalUnresponse.toString()),
      ('Total Responses/ Evaluated', responseRecv.toString()),
      ('Response Rate', '${formatDecimal(responseRate)}%')
    ];

    return Container(
      padding: const EdgeInsets.all(12),

      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: PreferencesProvider.getColor(context, 'alt-primary-color')
      ),


      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        spacing: 8,
        children: [

          HeaderText('Overall Response Rate'),

          CustomPieChart(
            backgroundColor: Colors.transparent,
            width: double.infinity,
            height: 300,
            centerSpaceRadius: 20,
            showKeys: true,
            //todo: do the rest here.
            pieSections: [

              CustomPieSection(
                value: unresponseRate,
                title: '${formatDecimal(unresponseRate)} %',
                keyTitle: 'Unevaluated',
                sectionColor: Colors.red.shade400
              ),

              CustomPieSection(
                value: responseRate,
                title: '${formatDecimal(responseRate)} %',
                keyTitle: 'Evaluated',
                sectionColor: Colors.green.shade400
              )
            ],
          ),


          HeaderText(
            'Details',
            textColor: PreferencesProvider.getColor(context, 'placeholder-text-color'),
          ),


          ListView.separated(
            itemCount: rRateItems.length,
            shrinkWrap: true,
            separatorBuilder: (context, index) => Divider(),
            itemBuilder: (context, index) => Row(
              children: [
                Expanded(
                  child: CustomText(
                    rRateItems[index].$1
                  )
                ),

                CustomText(
                  rRateItems[index].$2
                )
              ]
            ),
          )


        ]
      )

    );
  }

}


