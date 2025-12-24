
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:selc_admin/components/alert_dialog.dart';
import 'package:selc_admin/components/button.dart';
import 'package:selc_admin/components/charts/bar_chart.dart';
import 'package:selc_admin/components/custom_notification_badge.dart';
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
            'year': DateTime.now().year
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
        'year': DateTime.now().year
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
                          //show some summary

                          buildSummaryCard(
                            icon: CupertinoIcons.calendar,
                            name: 'Current Semester',
                            detail: Provider.of<SelcProvider>(context).generalStat.currentSemester.toString(), //TODO: fix the problem later.
                            backgroundColor: Colors.grey.shade600
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


                            Row(
                              spacing: 12,
                              children: [

                                Expanded(
                                  child: buildBarChart()
                                ),

                                Expanded(
                                    child: buildPieChart()
                                )
                              ]
                            ),




                            // CustomBarChart(
                            //   width: double.infinity,
                            //   height: MediaQuery.of(context).size.height * 0.6,
                            //   chartTitle: 'Recent Evaluations',
                            //   groups: List<CustomBarGroup>.generate(
                            //     10,
                            //     (int index) => CustomBarGroup(
                            //       x: index+1,
                            //       rods: List<Rod>.generate(
                            //         1,
                            //         (int _) => Rod(y: Random().nextDouble() * 20)
                            //       )
                            //     )
                            //   ),
                            // ),


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


                            // CustomPieChart(
                            //   width: 100,
                            //   height: 100,
                            //   pieSections: List.generate(5, (index) => CustomPieSection(title: index.toString(), value: Random().nextDouble() * 20),),
                            // ),


                            buildRecentEvaluations(),


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
  Widget buildRecentEvaluations(){

    int filesLength = Provider.of<PreferencesProvider>(context).preferences.savedFiles.length;

    return Container(
      //width: 400,
      padding: const EdgeInsets.all(8),
      height: MediaQuery.of(context).size.height * 0.5,

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

              ReportFile reportFile = Provider.of<PreferencesProvider>(context, listen: false).preferences.savedFiles[index];

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
                  concatDateTime(DateTime.now()),
                  maxLines: 1,
                  softwrap: false,
                ),

                trailing: reportFile.localFilePath != null ? Icon(Icons.download) : Icon(Icons.open_in_new)
                        
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





///todo: pie chart for suggestion sentiments
  Widget buildPieChart(){

    return Container(
      padding: const EdgeInsets.all(12),
      height: 400,
      width: 400,

      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: PreferencesProvider.getColor(context, 'alt-primary-color')
      ),


      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          HeaderText('Suggestions Sentiment Info'),

          Expanded(
            child: CustomPieChart(
              width: double.infinity,
              height: double.infinity,
              //todo: do the rest here.
            ),
          )
        ]
      )

    );
  }





  //todo: bar chart for overall lecturer ratings
  Widget buildBarChart(){

    return Container(
      padding: const EdgeInsets.all(12),
      height: 400,
      width: 400,

      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: PreferencesProvider.getColor(context, 'alt-primary-color')
      ),


      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          HeaderText('Overall Lecturers Rating'),

          Expanded(
            child: CustomBarChart(
              width: double.infinity,
              height: double.infinity,
              //todo: do the rest here.
            ),
          )
        ]
      )

    );
  }



  //todo: Pie Chart for the response rate.
  Widget buildResponseRatePieChart(){

    return Container(
      padding: const EdgeInsets.all(12),
      height: 400,
      width: 400,

      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: PreferencesProvider.getColor(context, 'alt-primary-color')
      ),


      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          HeaderText('Overall Response Rate'),

          Expanded(
            child: CustomPieChart(
              width: double.infinity,
              height: double.infinity,
              //todo: do the rest here.
            ),
          )
        ]
      )

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