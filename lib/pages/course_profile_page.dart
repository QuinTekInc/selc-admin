


import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:selc_admin/components/alert_dialog.dart';
import 'package:selc_admin/components/button.dart';
import 'package:selc_admin/components/cells.dart';
import 'package:selc_admin/components/charts/line_chart.dart';
import 'package:selc_admin/components/text.dart';
import 'package:selc_admin/model/models.dart';
import 'package:selc_admin/pages/evaluations/eval_page.dart';
import 'package:selc_admin/pages/lecturer_info_page.dart';
import 'package:selc_admin/providers/page_provider.dart';
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

  List<ClassCourse> cummulativeClassCourses = [];
  List<ClassCourse> currentCourses = [];


  @override
  void initState() {
    super.initState();

    loadCourseData();
  }


  void loadCourseData() async {

    setState(() => isLoading = true);

    try{

      //first get all the data and store it in the cummulativeClassCourses
      cummulativeClassCourses = await Provider.of<SelcProvider>(context, listen: false).getCourseInformation(widget.course.courseCode!);

      currentCourses = cummulativeClassCourses.where(
        (classCourse) => classCourse.year == DateTime.now().year
            && classCourse.semester == Provider.of<SelcProvider>(context, listen: false).currentSemester)
          .toList();

    }on SocketException catch(_){
      showNoConnectionAlertDialog(context);
    }

    setState(() => isLoading = false);
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
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [


                Column(  
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    buildCourseDetailSection(),

                    const SizedBox(height: 12,),

                    buildCurrentInfoSection(context)

                  ],
                ),


                const SizedBox(width: 12,),

                //todo: where the table will come.

                Expanded(  
                  child: SingleChildScrollView(

                    child: Column(  
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                    
                        //show the trend of course performance over the years in a line chart.
                        if(isLoading)buildChartPlaceholderContainer(
                          child: CircularProgressIndicator()
                        )
                        else if(!isLoading && cummulativeClassCourses.isEmpty) buildChartPlaceholderContainer(
                          child: Column(  
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              CustomText(  
                                'No Data',
                                fontWeight: FontWeight.bold,
                                textAlignment: TextAlign.center,
                              ), 

                              CustomText(
                                'Course performance score over the academic years is visualized here.',
                                textAlignment: TextAlign.center,
                              )
                            ],
                          )
                        )
                        else CustomLineChart(
                          containerBackgroundColor:  PreferencesProvider.getColor(context, 'alt-primary-color'),
                          width: double.infinity,
                          height: MediaQuery.of(context).size.height * 0.5,
                          maxY: 5,
                          minX: 2011,
                          maxX: DateTime.now().year.toDouble(),
                          
                          chartTitle: 'Course Performance Score Trend',
                          titleStyle: TextStyle(
                            color: Colors.green.shade400,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w600,
                            fontSize: 16
                          ),
                          leftAxisTitle: 'Performance Scores',
                          bottomAxisitle: 'Academic Years',
                          axisNameStyle: TextStyle(  
                            fontSize: 14, 
                            fontWeight: FontWeight.w600,
                            color: Colors.black87
                          ),
                          axisLabelStyle: TextStyle(  
                            fontSize: 14, 
                            color: Colors.black87
                          ),
                          
                          spotData: List<CustomLineChartSpotData>.generate(
                            cummulativeClassCourses.length,
                            (index) => CustomLineChartSpotData(
                              label: cummulativeClassCourses[index].year.toString(), 
                              x: cummulativeClassCourses[index].year!.toDouble(), 
                              y: cummulativeClassCourses[index].grandMeanScore
                            )
                          ),
                        ),


                        const SizedBox(height: 12),


                        //cummulative course information
                        buildCummulativeCourseInfoTable()
                    
                      ],
                    ),
                  ),
                )

              ],
            ),
          )
        ],
      ),
    );
  }


  Container buildChartPlaceholderContainer({required Widget child}) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.5,
      width: double.infinity,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12)
      ),

      child: child,
    );
  }



  Widget buildCurrentInfoSection(BuildContext context) {
    return Expanded(
      flex: 2,
      child: Container(  
        width: MediaQuery.of(context).size.width * 0.25,
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
            if(isLoading) Expanded(  
              child: Center(child: CircularProgressIndicator(),),
            )
            //todo: show placeholder message when finished loading and the data is empty
            else if(!isLoading && currentCourses.isEmpty) Expanded(  
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
                itemCount: currentCourses.length,
                itemBuilder: (_, index) {

                  ClassCourse classCourse = currentCourses[index];
                  Lecturer lecturer = classCourse.lecturer!;

                  
                  return ListTile(  
                    leading: Icon(CupertinoIcons.person, color: Colors.green.shade400,),
                    title: CustomText(lecturer.name!, fontWeight: FontWeight.w600),
                    subtitle: CustomText(lecturer.department!),

                    trailing: Container(
                      //padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(12)
                      ),
                      child: Row(  
                        mainAxisAlignment: MainAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      
                          IconButton(
                            icon: Icon(CupertinoIcons.graph_circle, color: Colors.green.shade400,),
                            onPressed: () => Provider.of<PageProvider>(context, listen: false).pushPage(EvaluationPage(classCourse: classCourse), 'Analytics'),
                            tooltip: 'Show Analytics',
                          ),
                      
                      
                      
                          IconButton(
                            icon: Icon(CupertinoIcons.profile_circled, color: Colors.blue.shade400,),
                            onPressed: () {
                              Provider.of<PageProvider>(context, listen: false).pushPage(LecturerInfoPage(lecturer: lecturer), 'Lecturer Information');
                            },
                            tooltip: 'View Lecturer Pofile'
                          ),
                      
                        ],
                      ),
                    ),

                    //onTap: () => Provider.of<PageProvider>(context, listen: false).pushPage(EvaluationPage(course: widget.course), 'Analytics'),
                  );
                },
              ),
            )



          ],
        ),
      ),
    );
  }




  Widget buildCourseDetailSection() {
    return Container(  
      width: MediaQuery.of(context).size.width * 0.25,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 24),

      decoration: BoxDecoration(
        color:  PreferencesProvider.getColor(context, 'alt-primary-color'),
        borderRadius: BorderRadius.circular(12)
      ),
    
      child: Column(  
        mainAxisAlignment: MainAxisAlignment.start,
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

    
          DetailContainer(title: 'Course Code', detail: widget.course.courseCode!),
    

    
          DetailContainer(title: 'Course Title', detail: widget.course.title!),


    
          DetailContainer(title: 'Mean Score / Rating', detail: widget.course.meanScore!.toStringAsFixed(2)),


    
          DetailContainer(title: 'Remark', detail: widget.course.remark!)
    
        ],
      ),
    );
  }





  Widget buildCummulativeCourseInfoTable(){
    return Container(

      width: double.infinity,
      padding: const EdgeInsets.all(8),

      constraints: BoxConstraints(  
        minHeight: 400
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
                    'Perf. Score',
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
            child: CustomText(classCourse.lecturer!.name!),
          ),

          //flex 1
          Expanded(  
            child: CustomText(classCourse.lecturer!.department!),
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





  void lecturerInfoPage(Lecturer lecturer) => Provider.of<PageProvider>(context, listen: false).pushPage(  
    LecturerInfoPage(lecturer: lecturer,),
    "Lecturer Information"
  );

}
