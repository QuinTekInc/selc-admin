

import 'dart:io';

import 'package:animations/animations.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:selc_admin/components/alert_dialog.dart';
import 'package:selc_admin/components/button.dart';
import 'package:selc_admin/components/cells.dart';
import 'package:selc_admin/components/custom_tab_bar.dart';
import 'package:selc_admin/components/stat_graph_section.dart';
import 'package:selc_admin/components/utils.dart';
import 'package:selc_admin/model/models.dart';
import 'package:selc_admin/pages/dashboard_page.dart';
import 'package:selc_admin/pages/evaluations/eval_page.dart';
import 'package:selc_admin/pages/lecturer_management/lecturer_info_page.dart';
import 'package:selc_admin/providers/pref_provider.dart';
import 'package:selc_admin/providers/selc_provider.dart';

import '../../components/report_wizard.dart';
import '../../components/text.dart';
import '../../providers/page_provider.dart' show PageProvider;


class DepartmentProfilePage extends StatefulWidget {

  final Department department;

  const DepartmentProfilePage({super.key, required this.department});

  @override
  State<DepartmentProfilePage> createState() => _DepartmentProfilePageState();
}

class _DepartmentProfilePageState extends State<DepartmentProfilePage> {

  int selectedTab = 0;

  List<Lecturer> lecturers = [];
  List<ClassCourse> classCourses = [];
  int currentCoursesCount = 0;

  Map<String, dynamic> graphData = {};

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

      graphData = await Provider.of<SelcProvider>(context, listen: false).getDepartmentGraph(widget.department.departmentId);

    } on SocketException {
      showNoConnectionAlertDialog(context);

    } on Error{
      showCustomAlertDialog(context, title: 'Error', contentText: 'An unknown error occurred. Please try again');
    }
    
    setState(() => isLoading = false);

  }


  @override
  Widget build(BuildContext context) {

    return DefaultTabController(
      initialIndex: 0,
      length: 3,
      child: Padding(
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
      
            const SizedBox(height: 8),
            
            //tabs
            CustomTabBar(
              tabLabels: ['Basic Info', 'Lecturers', 'Class Courses'],
              onChanged: (index) => setState(() => selectedTab = index)
            ),
            
            const SizedBox(height: 12,),
      
            Expanded(
              child: PageTransitionSwitcher(
                duration: Duration(milliseconds: 500),

                transitionBuilder: (child, animation, secondaryAnimation ) => FadeThroughTransition(
                  animation: animation,
                  secondaryAnimation: secondaryAnimation,
                  fillColor: Colors.transparent,
                  child: child,
                ),

                child: Builder(
                  builder: (_){
                    switch(selectedTab){
                      case 0:
                        return buildDashboardSection();

                      case 1:
                        return buildLecturersList();

                      case 2:
                        return buildClassCoursesSection();

                      default:
                        return Center(
                          child: CustomText('You selected the wrong tab'),
                        );
                    }
                  },
                )
              )
            )
          ],
        ),
      ),
    );
  }



  Widget buildDepartmentInfoCard({required String title, required String detail, IconData? icon}){

    return Card(  
      shape: RoundedRectangleBorder( 
        borderRadius: BorderRadius.circular(12)
      ),

      child: Container(  
        padding: const EdgeInsets.all(8),
        width: 300,
        decoration: BoxDecoration(  
          borderRadius: BorderRadius.circular(12),
          color: PreferencesProvider.getColor(context, 'alt-primary-color')
        ),


        child: Row(  
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          spacing: 12,

          children: [

            CircleAvatar(  
              radius: 30,
              backgroundColor: PreferencesProvider.getColor(context, 'primary-color'),
              child: Icon(icon, color: Colors.green.shade400, size: 30,),
            ),


            Column(  
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [

                CustomText(  
                  title,
                  padding: EdgeInsets.zero,
                ),


                HeaderText(  
                  detail,
                  textColor: PreferencesProvider.getColor(context, 'text-color'),
                )
              ],
            )
          ]
        )
      )
    );
  }


  Widget buildDashboardSection(){

    final cardItems = [
      ('Lecturers', lecturers.length.toString(), CupertinoIcons.person),
      ('All Classes', classCourses.length.toString(), CupertinoIcons.book),
      ('Current Courses', currentCoursesCount.toString(), Icons.menu_book)
    ];

    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 12,
      
        children: [
      
      
          //department info (number of lecturers, number of courses)
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: List.generate(
              cardItems.length,
                (index) => buildDepartmentInfoCard(
                title: cardItems[index].$1,
                detail: cardItems[index].$2,
                icon: cardItems[index].$3
              )
            )
          ),
      
      
          if(isLoading) Container(
            width: double.infinity,
            height: MediaQuery.of(context).size.height * 0.6,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: PreferencesProvider.getColor(context, 'alt-primary-color'),
              borderRadius: BorderRadius.circular(12)
            ),
          
            child: CircularProgressIndicator(),
          )
          else GraphSection(
            graphData: graphData,
          ),
        ]
      ),
    );
  }


  Widget buildLecturersList(){

    return Container(
      padding: const EdgeInsets.all(12),
      width: double.infinity,
      height: double.infinity,

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
      height: double.infinity,
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




          if(classCourses.isNotEmpty) Align(
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

    showCustomModalBottomSheet(
      context: context,
      isScrollControlled: true,
      child: ReportWizard(
        reportType: 'Department',
        id: widget.department.departmentId,
        semester: Provider.of<SelcProvider>(context, listen: false).generalSetting.currentSemester,
        year: Provider.of<SelcProvider>(context, listen: false).generalSetting.academicYear,
      )
    );

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
