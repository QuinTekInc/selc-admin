


import 'dart:io';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:selc_admin/components/alert_dialog.dart';
import 'package:selc_admin/components/button.dart';
import 'package:selc_admin/components/cells.dart';
import 'package:selc_admin/components/charts/line_chart.dart';
import 'package:selc_admin/components/text.dart';
import 'package:selc_admin/components/utils.dart';
import 'package:selc_admin/model/models.dart';
import 'package:selc_admin/pages/lecturer_management/lecturer_info_page.dart';
import 'package:selc_admin/providers/pref_provider.dart';
import 'package:selc_admin/providers/selc_provider.dart';


class CourseProfilePage extends StatefulWidget {

  final Course course;

  const CourseProfilePage({super.key, required this.course});

  @override
  State<CourseProfilePage> createState() => _CourseProfilePageState();
}

class _CourseProfilePageState extends State<CourseProfilePage> {



  bool isLoading = false;

  Map<String, dynamic> courseInfoMap = {};

  List<dynamic> wCourseInfoList = [];

  List<ClassCourse> cummulativeClassCourses = [];
  List<ClassCourse> currentClassCourses = [];

  @override
  void initState() {
    super.initState();

    loadCourseData();
  }


  void loadCourseData() async {

    setState(() => isLoading = true);

    try{

      //first get all the data and store it in the cummulativeClassCourses
      courseInfoMap = await Provider.of<SelcProvider>(context, listen: false).getCourseInformation(widget.course.courseCode);

      initWCourseInfoList();

      cummulativeClassCourses = List<Map<String, dynamic>>.from(courseInfoMap['cummulative_class_courses'])
                                    .map((jsonMap) => ClassCourse.fromJson(jsonMap)).toList();

      currentClassCourses =  List<Map<String, dynamic>>.from(courseInfoMap['current_class_courses'])
          .map((jsonMap) => ClassCourse.fromJson(jsonMap)).toList();

    }on SocketException catch(_){
      showNoConnectionAlertDialog(context);
    }

    setState(() => isLoading = false);
  }


  void initWCourseInfoList(){
    wCourseInfoList = [
      ('Total Classes', courseInfoMap['total_classes'].toString(), Icons.school),
      ('Overall Mean Score', formatDecimal(courseInfoMap['overall_mean_score']), CupertinoIcons.check_mark),
      ('Overall Percentage Score', formatDecimal(courseInfoMap['overall_percentage_score']), CupertinoIcons.percent),
      ('Overall Course Remark', courseInfoMap['overall_remark'], Icons.download),

      ('Number of Lecturers', courseInfoMap['c_number_of_lecturers'].toString(), CupertinoIcons.person_alt_circle),
      ('Mean Score [This Semester]', formatDecimal(courseInfoMap['c_mean_score']), CupertinoIcons.check_mark_circled),
      ('Percentage Score [This Semester]', formatDecimal(courseInfoMap['c_percentage_score']), Icons.download),
      ('Remark', courseInfoMap['remark'], Icons.chat_bubble_outline),

      ('Registered Students [This Semester]', courseInfoMap['registered_students'].toString(), Icons.person_outlined),
      ('Evaluated Students', courseInfoMap['evaluated_students'].toString(), CupertinoIcons.person_crop_circle_badge_checkmark),
      ('Response Rate', formatDecimal(courseInfoMap['response_rate']), Icons.percent_outlined),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(  
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          HeaderText(
            '${widget.course.title} [${widget.course.courseCode}]',
            fontSize: 25,
          ),

          const NavigationTextButtons(),

          const SizedBox(height: 12,),

          Expanded(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 12,

                children: [

                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 12,
                    children: [

                      buildCourseNameSection(),

                      Expanded(
                        flex: 2,
                        child: buildCourseInfoGrid()
                      ),

                      Expanded(
                        flex: 1,
                          child: buildChartSection()
                      ),

                    ],
                  ),


                  //todo: where the table will come.
                  //cummulative course information
                  buildCummulativeCourseInfoTable()

                ],
              ),
            ),
          )
        ],
      ),
    );
  }






  Widget buildChartSection(){
    return Container(
      width: double.infinity,
      height: MediaQuery.of(context).size.height * 0.45,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
          color: PreferencesProvider.getColor(context, 'alt-primary-color'),
          borderRadius: BorderRadius.circular(12)
      ),

      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          HeaderText('Course Performance Trend'),

          if(isLoading)  Expanded(
            child: Center(
              child: SizedBox(
                height: 70,
                width: 70,
                child: CircularProgressIndicator()
              )
            )
          )
          else if(!isLoading && cummulativeClassCourses.isEmpty) Expanded(
            child: CollectionPlaceholder(
              title: 'No Data!',
              detail: 'Course Performance trend over the academic years appear here.'
            )
          )
          else Expanded(
            child: buildTrendLineChart()
          ),
        ]
      )
    );
  }

  CustomLineChart buildTrendLineChart() {
    return CustomLineChart(
      containerBackgroundColor:  Colors.transparent,
      width: double.infinity,
      height: MediaQuery.of(context).size.height * 0.35,
      showXLabels: false,
      showYLabels: false,
      maxY: 5,
      leftAxisTitle: 'Performance Scores',
      bottomAxisitle: 'Academic Years',
      spotData: List<CustomLineChartSpotData>.generate(
        cummulativeClassCourses.length,
        (index) => CustomLineChartSpotData(
          label: cummulativeClassCourses[index].year.toString(),
          x: index.toDouble(),
          y: cummulativeClassCourses[index].grandMeanScore
        )
      ) + List.generate(
        49,
        (index) {

          double gMeanScore = [1, 1.7, 2, 2.1, 2.5, 2, 3.2, 3.6, 4, 4.3, 4.8, 5][Random().nextInt(12)].toDouble();

          return CustomLineChartSpotData(
            x: (1+index).toDouble(),
            y: gMeanScore,
            label: 'Year: ${2026+index}\nMean Score: ${formatDecimal(gMeanScore)}\nIndex: $index'
          );
        },
      )
    );
  }




  Widget buildCurrentInfoSection(BuildContext context) {
    return Expanded(
      flex: 2,
      child: Container(  
        width: MediaQuery.of(context).size.width * 0.2,
        height: double.infinity,
        padding: const EdgeInsets.all(8),

        decoration: BoxDecoration(  
          color:  PreferencesProvider.getColor(context, 'alt-primary-color'),
          borderRadius: BorderRadius.circular(12)
        ),

        child: Column(  
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            HeaderText(  
              'Lectures handling this course currently',
              fontWeight: FontWeight.w600,
            ),


            const SizedBox(height: 8,),

            //todo: show circle progress bar when loading
            if(isLoading)  Expanded(
              child: Center(
                child: SizedBox(
                  height: 70,
                  width: 70,
                  child: CircularProgressIndicator()
                )
              )
            )
            //todo: show placeholder message when finished loading and the data is empty
            else if(!isLoading && currentClassCourses.isEmpty) Expanded(  
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CustomText(  
                      'No Data yet',
                      fontWeight: FontWeight.w600,
                      textAlignment: TextAlign.center,
                    ),
                    CustomText(
                      'Lectures handling ${widget.course.courseCode} for this academic year and semester appear here.',
                      textAlignment: TextAlign.center,
                    ),
                  ],
                ),
              ),
            )
            //todo: load the actual data into the list view
            else Expanded(  
              child: ListView.builder(  
                itemCount: currentClassCourses.length,
                itemBuilder: (_, index) => LCurrentCourseCell(classCourse: currentClassCourses[index], useLecturerName: true)
              ),
            )
          ],
        ),
      ),
    );
  }




  Widget buildCourseNameSection() {
    return Container(  
      width: MediaQuery.of(context).size.width * 0.2,
      height: MediaQuery.of(context).size.height * 0.45,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 24),

      decoration: BoxDecoration(
        color:  PreferencesProvider.getColor(context, 'alt-primary-color'),
        borderRadius: BorderRadius.circular(12)
      ),
    
      child: Column(  
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        spacing: 8,
        children: [
    
          CircleAvatar(
            backgroundColor: Colors.green.shade400,
            radius: 65,
            child: const Icon(Icons.school, color: Colors.white, size: 70,),
          ),


          const SizedBox(height: 12),

    
          DetailContainer(title: 'Course Code', detail: widget.course.courseCode),
    
          DetailContainer(title: 'Course Title', detail: widget.course.title),

        ],
      ),
    );
  }




  Widget buildCourseInfoGrid(){

    return Container(
      width: double.infinity,
      height: MediaQuery.of(context).size.height * 0.45,
      padding: const EdgeInsets.all(12),


      decoration: BoxDecoration(
        color: PreferencesProvider.getColor(context, 'alt-primary-color'),
        borderRadius: BorderRadius.circular(12)
      ),

      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 12,
        children: [

          HeaderText("Course Information"),


          if(isLoading) Expanded(
            child: Center(
              child: SizedBox(
                height: 70,
                width: 70,
                child: CircularProgressIndicator()
              )
            )
          )
          else Expanded(
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 300,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                mainAxisExtent: 95
              ),
              itemCount: wCourseInfoList.length,
              itemBuilder: (_, index){

                final wListItem = wCourseInfoList[index];


                String title = wListItem.$1 as String;
                String value = (wListItem.$2).toString();
                IconData icon = wListItem.$3 as IconData;

                return Container(
                  padding: const EdgeInsets.all(8),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: PreferencesProvider.getColor(context, 'alt-primary-color'),
                    borderRadius: BorderRadius.circular(12)
                  ),

                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 8,
                    children: [

                      CircleAvatar(
                        radius: 30,
                        backgroundColor: PreferencesProvider.getColor(context, 'primary-color'),
                        child: Icon(icon, color: Colors.green.shade600, size: 25,),
                      ),


                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          spacing: 8,
                          children: [

                            CustomText(
                              title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),


                            CustomText(
                              value,
                              fontWeight: FontWeight.w600,
                            )

                          ],
                        ),
                      )
                    ],
                  )
                );
              },
            )
          )

        ]
      )
    );
  }





  Widget buildCummulativeCourseInfoTable(){
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(8),

      constraints: BoxConstraints(  
        minHeight: MediaQuery.of(context).size.height * 0.5
      ),

      decoration: BoxDecoration(
        color:  PreferencesProvider.getColor(context, 'table-background-color'),
        borderRadius: BorderRadius.circular(12)
      ),

      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          HeaderText(
            'Course History',
            fontWeight: FontWeight.w600,
          ),


          const SizedBox(height: 8,),


          Container(  
            padding: const EdgeInsets.all(8),
            width: double.infinity,

            decoration: BoxDecoration(
              color:  PreferencesProvider.getColor(context, 'alt-primary-color'),
              borderRadius: BorderRadius.circular(12),
            ),

            child: Row(  
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [

                const SizedBox(
                  width: 150,
                  child: CustomText('Year'),
                ),


                const SizedBox(
                  width: 120,
                  child: CustomText('Semester'),
                ),


                Expanded(
                  flex: 2,
                  child: CustomText('Lecturer'),
                ),


                Expanded(
                  child: CustomText('Department'),
                ),


                SizedBox(  
                  width: 150,
                  child: CustomText(  
                    'Avg Score',
                    textAlignment: TextAlign.center
                  ),
                )

              ],

            ),
          ),


          //todo: show loading CircularProgressIndicator 
          if(isLoading)SizedBox(
            height: 150,
            child: Center(child: CircularProgressIndicator()),
          )
          //todo: show a placeholder of the message.
          else if(!isLoading && cummulativeClassCourses.isEmpty) SizedBox(
            height: 120,
            child: Center(  
              child: CustomText('This table shows the list of lecturers who have handle this course'),
            ),
          )
          //todo: show the actual items of the table.
          else ListView.builder(  
            physics: NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: cummulativeClassCourses.length,
            itemBuilder: (_, index) => buildCummulativeTableRow(cummulativeClassCourses[index]),
          )

        ],
      ),

    );
  }


  Widget buildCummulativeTableRow(ClassCourse classCourse){
    return Container(  
      width: double.infinity,
      padding: const EdgeInsets.all(8),
      child: Row(  
        children: [

          //150
          SizedBox(
            width: 150, 
            child: CustomText(classCourse.year.toString()),
          ),
          

          //120
          SizedBox(
            width: 120, 
            child: CustomText(classCourse.semester.toString()),
          ),

          //flex 2
          Expanded(  
            flex: 2,
            child: CustomText(classCourse.lecturer.name),
          ),

          //flex 1
          Expanded(  
            child: CustomText(classCourse.lecturer.department),
          ),

          //150
          SizedBox(
            width: 150, 
            child: CustomText(
              classCourse.grandMeanScore.toStringAsFixed(3),
              textAlignment: TextAlign.center
            ),
          )
        ],
      ),
    );
  }



}


//total number of classes
//total distinct number of lecturers who have handled this course
//overall average score of course
//overall remark of courses

//total number of classes this semester
//overall response rate for this semester
//total number of students taking the course this semester[evaluated]
//average score of course and remarks this semester
//number of lecturers currently handling this course
