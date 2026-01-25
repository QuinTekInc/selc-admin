

import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:selc_admin/components/alert_dialog.dart';
import 'package:selc_admin/components/button.dart';
import 'package:selc_admin/components/cells.dart';
import 'package:selc_admin/components/utils.dart';
import 'package:selc_admin/model/models.dart';
import 'package:selc_admin/pages/evaluations/eval_page.dart';
import 'package:selc_admin/pages/lecturer_management/lecturer_info_page.dart';
import 'package:selc_admin/providers/pref_provider.dart';
import 'package:selc_admin/providers/selc_provider.dart';

import '../../components/text.dart';
import '../../providers/page_provider.dart' show PageProvider;


class DepartmentProfilePage extends StatefulWidget {

  final Department department;

  const DepartmentProfilePage({super.key, required this.department});

  @override
  State<DepartmentProfilePage> createState() => _DepartmentProfilePageState();
}

class _DepartmentProfilePageState extends State<DepartmentProfilePage> {


  List<Lecturer> lecturers = [];
  List<ClassCourse> classCourses = [];
  int currentCoursesCount = 0;



  bool isLoading = false;

  @override
  void initState() {
    // TODO: implement initState

    //sort the lecturers who are in this department
    lecturers = Provider.of<SelcProvider>(context, listen: false).lecturers
                        .where((lecturer) => lecturer.department == widget.department.departmentName).toList();


    loadData();

    super.initState();
  }



  void loadData() async {

    setState(() => isLoading = true);

    try{

      //todo: load the necessary data here.

      classCourses = await Provider.of<SelcProvider>(context, listen: false).getDepartmentClassCourses(widget.department.departmentId);

      currentCoursesCount = classCourses.where((classCourse) =>
                              classCourse.semester == Provider.of<SelcProvider>(context, listen: false).generalSetting.currentSemester &&
                              classCourse.year == Provider.of<SelcProvider>(context, listen: false).generalSetting.academicYear).length;
    } on SocketException {
      showNoConnectionAlertDialog(context);

    } on Error{
      showCustomAlertDialog(context, title: 'Error', contentText: 'An unknown error occurred. Please try again');
    }


    setState(() => isLoading = false);

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
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              HeaderText(
                'Department of ${widget.department.departmentName}',
                fontSize: 25,
              ),

              Spacer(),


              TextButton.icon(
                icon: Icon(Icons.edit_document, color: Colors.green.shade300, size: 25,),
                label: CustomText('Generate Report', textColor: Colors.green.shade300, fontSize: 16,),
                onPressed: handleGenerateReport,
              )
            ],
          ),

          const SizedBox(height: 8,),

          NavigationTextButtons(),

          const SizedBox(height: 12),

          Expanded(
            flex: 2,
            child: SingleChildScrollView(

              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 12,


                children: [

                  //department name


                  //department info (number of lecturers, number of courses)
                  Row(
                    children: [

                      buildDepartmentInfoCard(
                        title: 'Lecturers',
                        detail: lecturers.length.toString(),
                        icon: CupertinoIcons.person
                      ),


                      buildDepartmentInfoCard(
                        title: 'Class Courses',
                        detail: classCourses.length.toString(),
                        icon: CupertinoIcons.book,
                        backgroundColor: Colors.amber
                      ),



                      buildDepartmentInfoCard(
                          title: 'Current Class Courses',
                          detail: currentCoursesCount.toString(),
                          icon: Icons.menu_book,
                          backgroundColor: Colors.red.shade500
                      ),

                    ]
                  ),



                  //lecturers list
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 12,
                    children: [
                      buildLecturersList(),

                      Expanded(
                        child: buildClassCoursesSection(),
                      )
                    ],
                  )


                  //the courses(taught by lecturers in the department) list should be beside the lecturers list ranging from current to oldest.
                ]
              )
            ),
          )

        ],
      ),
    );
  }



  Widget buildDepartmentInfoCard({required String title, required String detail, IconData? icon, Color? backgroundColor}){


    if(backgroundColor == null){
      backgroundColor = Colors.green.shade300;
    }

    return Card(  
      shape: RoundedRectangleBorder( 
        borderRadius: BorderRadius.circular(12)
      ),

      child: Container(  
        padding: const EdgeInsets.all(8),
        width: 300,
        decoration: BoxDecoration(  
          borderRadius: BorderRadius.circular(12),
          color: backgroundColor
        ),


        child: Row(  
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          spacing: 12,

          children: [

            CircleAvatar(  
              radius: 30,
              backgroundColor: Color.lerp(backgroundColor, Colors.white, 0.3),
              child: Icon(icon, color: Colors.white, size: 30,),
            ),



            Column(  
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [

                CustomText(  
                  title, 
                  textColor: Colors.white,
                  padding: EdgeInsets.zero,
                ),


                HeaderText(  
                  detail, 
                  textColor: Colors.white,
                )
              ],
            )
          ]
        )
      )
    );
  }


  Widget buildLecturersList(){

    return Container(
      padding: const EdgeInsets.all(12),
      width: MediaQuery.of(context).size.width * 0.25,
      height: MediaQuery.of(context).size.height * 0.45,

      decoration: BoxDecoration(
        color: PreferencesProvider.getColor(context, 'table-background-color'),
        borderRadius: BorderRadius.circular(12)
      ),


      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        spacing: 12,

        children: [

          HeaderText('Lecturers'),

          if(lecturers.isEmpty) Expanded(
            child: CollectionPlaceholder(detail: 'Lecturers in this department appear here.')
          )
          else Expanded(
            child: ListView.builder(
              itemCount: lecturers.length,
              itemBuilder: (_, index){

                Lecturer lecturer = lecturers[index];


                return DLecturerCell(lecturer: lecturer);
              },
            ),
          )

        ],
      )
    );
  }



  //class course table.
  Widget buildClassCoursesSection(){


    return Container(
      padding: const EdgeInsets.all(12),
      height: MediaQuery.of(context).size.height * 0.45,
      width: double.infinity,
      decoration: BoxDecoration(
        color: PreferencesProvider.getColor(context, 'table-background-color'),
        borderRadius: BorderRadius.circular(12)
      ),


      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 8,

        children: [

          HeaderText('Class Courses'),


          //table header

          Container(
            padding: const EdgeInsets.all(8),
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: PreferencesProvider.getColor(context, 'table-header-color'),
            ),

            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                SizedBox(
                  width: 90,
                  child: CustomText('Year'),
                ),


                SizedBox(
                  width: 90,
                  child: CustomText('Semester'),
                ),


                Expanded(
                  flex: 2,
                  child: CustomText('Lecturer')
                ),


                SizedBox(
                  width: 120,
                  child: CustomText('C. Code'),
                ),

                Expanded(
                  flex: 2,
                  child: CustomText('Course title')
                ),


                SizedBox(
                  width: 120,
                  child: CustomText('No. Students'),
                ),


                SizedBox(
                  width: 120,
                  child: CustomText('Avg. Score')
                ),


                SizedBox(
                  width: 130,
                  child: CustomText('Remark')
                ),

              ],
            )
          ),



          if(isLoading) Expanded(
            child: Center(
              child: CircularProgressIndicator()
            )
          )
          else if(classCourses.isEmpty) Expanded(
            child: CollectionPlaceholder(
              detail: 'All Class Courses in handled by lecturers in this department appear here.',
            ),
          )
          else Expanded(
            child: ListView.builder(
              itemCount: classCourses.length,
              itemBuilder: (_, index){

                final classCourse = classCourses[index];

                return DClassCourseCell(classCourse: classCourse);
              }
            )
          ),




          if(!classCourses.isEmpty) Align(
            alignment: Alignment.centerRight,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              spacing: 8,
              children: [

                Icon(CupertinoIcons.info, color: Colors.green.shade400,),

                CustomText(
                  'Press on a class course item in the table to view its evaluation summary',
                  fontStyle: FontStyle.italic,
                  textColor: PreferencesProvider.getColor(context, 'placeholder-text-color'),
                )
              ]
            ),
          )

        ]
      )
    );
  }



  void handleGenerateReport() async {

  }
}







//department lecturer cell.
class DLecturerCell extends StatefulWidget {

  final Lecturer lecturer;

  const DLecturerCell({super.key, required this.lecturer});

  @override
  State<DLecturerCell> createState() => _DLecturerCellState();
}

class _DLecturerCellState extends State<DLecturerCell> {


  Color backgroundColor = Colors.transparent;

  @override
  Widget build(BuildContext context) {

    return MouseRegion(
      onHover: (mouseEvent) => setState(() => backgroundColor = Colors.green.shade100),
      onExit: (mouseEvent) => setState(() => backgroundColor = Colors.transparent),

      child: Container(

        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12)
        ),

        child: ListTile(

          onTap: () => Provider.of<PageProvider>(context, listen: false).pushPage(
              LecturerInfoPage(lecturer: widget.lecturer),
              'Lecturer Information'
          ),

          leading: Container(
            color: Colors.green.shade300,
            padding: const EdgeInsets.all(8),
            child: Icon(CupertinoIcons.person, size: 25, color: Colors.white,),
          ),

          title: CustomText(widget.lecturer.name, fontSize: 15, maxLines: 1, fontWeight: FontWeight.w600,),

          subtitle: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            spacing: 1,

            children: [
              CustomText(widget.lecturer.email, maxLines: 1,),

              Row(
                mainAxisSize: MainAxisSize.min,
                spacing: 8,
                children: [

                  RatingStars(
                    rating: widget.lecturer.rating,
                    zeroPadding: true,
                    transparentBackground: true,
                    spacing: 0,
                  ),


                  CustomText(
                    '(${formatDecimal(widget.lecturer.rating)})',
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  )
                ],
              )

            ],
          ),
        ),
      )
    );
  }
}




//class course cell for department information section
class DClassCourseCell extends StatefulWidget {

  final ClassCourse classCourse;

  const DClassCourseCell({super.key, required this.classCourse});

  @override
  State<DClassCourseCell> createState() => _DClassCourseCellState();
}

class _DClassCourseCellState extends State<DClassCourseCell> {

  Color hoverColor = Colors.transparent;

  bool isCurrentCourse = false;

  @override
  void initState() {
    // TODO: implement initState

    bool isCurrentYear = widget.classCourse.year == DateTime.now().year;
    bool isCurrentSemester = widget.classCourse.semester == Provider.of<SelcProvider>(context, listen: false).generalSetting.currentSemester;

    isCurrentCourse = isCurrentSemester && isCurrentYear;

    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onHover: (mouseEvent) => setState(() => hoverColor = Colors.green.shade100),
      onExit: (mouseEvent) => setState(() => hoverColor = Colors.transparent),

      child: GestureDetector(
        onTap: () => Provider.of<PageProvider>(context, listen: false).pushPage(
          EvaluationPage(classCourse: widget.classCourse),
          'Evaluation'
        ),


        child: Container(

          padding: const EdgeInsets.all(8),

          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: hoverColor
          ),

          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [


              if(isCurrentCourse) CircleAvatar(
                radius: 3,
                backgroundColor: Colors.green.shade400
              ),


              //academic year
              SizedBox(
                width: 90,
                child: CustomText(widget.classCourse.year.toString()),
              ),


              //semester
              SizedBox(
                width: 90,
                child: CustomText(widget.classCourse.semester.toString()),
              ),


              //lecturer's name
              Expanded(
                  flex: 2,
                  child: CustomText(widget.classCourse.lecturer.name)
              ),


              //course code
              SizedBox(
                width: 120,
                child: CustomText(widget.classCourse.course.courseCode),
              ),


              //course title
              Expanded(
                flex: 2,
                child: CustomText(widget.classCourse.course.title)
              ),


              //number of students who registered for the class
              SizedBox(
                width: 120,
                child: CustomText(widget.classCourse.registeredStudentsCount.toString()),
              ),


              //average score of this course
              SizedBox(
                  width: 120,
                  child: CustomText(formatDecimal(widget.classCourse.grandMeanScore))
              ),


              //remark of the score after evaluation
              SizedBox(
                width: 130,
                child: CustomText(widget.classCourse.remark!)
              ),

            ],
          ),
        ),
      ),
    );
  }
}




//number of lecturers in the department
//number of students in department
//number of classes being handled in the semester



/*
FOR THE GENERATE REPORT SECTION,
I will create a simple wizard to let the user select the appropriate parameters
for the report generation [for both administrator and departmental]

when "admin" report_type is selected, the user will have the chance to  choose the
desired semester and academic year, to which he want's the report generated.


when "department" report_type is selected, the user has options to choose the semester
and academic year and particular department to which the report will be generated for.

in generating a report for a department at the department_profile screen, the department will only be highlighted,
and the user will only have to choose the semester and academic year


Also actual fully function report generator wizard will be accessible at the "Classes" tab of the system.
 */


//from the school's database, courses are grouped in categories [core, optional]
