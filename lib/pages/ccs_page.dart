

import 'dart:io';

import 'package:contextmenu/contextmenu.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:selc_admin/components/alert_dialog.dart';
import 'package:selc_admin/components/button.dart';
import 'package:selc_admin/components/report_wizard.dart';
import 'package:selc_admin/components/text.dart';
import 'package:selc_admin/model/models.dart';
import 'package:selc_admin/pages/evaluations/eval_page.dart';
import 'package:selc_admin/pages/lecturer_management/lecturer_info_page.dart';
import 'package:selc_admin/providers/page_provider.dart';
import 'package:selc_admin/providers/selc_provider.dart';

import '../providers/pref_provider.dart';


class ClassCoursesPage extends StatefulWidget {

  const ClassCoursesPage({super.key});

  @override
  State<ClassCoursesPage> createState() => _ClassCoursesPageState();
}

class _ClassCoursesPageState extends State<ClassCoursesPage> {

  final searchController = TextEditingController();

  List<ClassCourse> filteredClassCourses = [];

  bool isLoading = false;

  bool shouldEnableAllResponses = false;  //only affects courses for the current semester

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    loadData();
  }

  void loadData() async {
    setState(() => isLoading = true);

    try{

      await Provider.of<SelcProvider>(context, listen: false).getClassCourses();
      filteredClassCourses = Provider.of<SelcProvider>(context, listen: false).classCourses;

    }on SocketException{
      showNoConnectionAlertDialog(context);
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
        spacing: 8,

        children: [

          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              HeaderText('Class Courses', fontSize: 25,),

              Spacer(),


              TextButton(
                onPressed: () => showCustomModalBottomSheet(context: context, isScrollControlled: true,  child: ReportWizard()),
                child: CustomText('Generate Report', textColor: Colors.green.shade400,)
              ),

              const SizedBox(width: 12,),

              refreshButton(onPress: loadData)
            ],
          ),

          SizedBox(
            width: MediaQuery.of(context).size.width * 0.45,
            child: CustomTextField(
              controller: searchController,
              hintText: 'Search by year, semester, course code, title, lecturer, department .....',
              leadingIcon: Icons.search,
              onChanged: handleSearchFilter,
            ),
          ),


          //tableview
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: PreferencesProvider.getColor(context, 'table-background-color'),
                borderRadius: BorderRadius.circular(12)
              ),

              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 8,
                children: [

                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: PreferencesProvider.getColor(context, 'table-header-color')
                    ),

                    child: Row(
                      children: [

                        SizedBox(
                          width: 120,
                          child: CustomText('Year'),
                        ),

                        SizedBox(
                          width: 120,
                          child: CustomText('Semester'),
                        ),


                        Expanded(
                          flex: 3,
                          child: CustomText('Lecturer'),
                        ),


                        SizedBox(
                          width: 120,
                          child: CustomText('Course Code'),
                        ),


                        Expanded(
                          flex: 2,
                          child: CustomText('Course title'),
                        ),


                        SizedBox(
                          width: 120,
                          child: CustomText('Students'),
                        ),


                        SizedBox(
                          width: 120,
                          child: CustomText('Accept Eval.'),
                        )

                      ]
                    ),
                  ),

                  ///listview builder for the class courses items
                  if(isLoading)Expanded(  
                    child: Center(  
                      child: CircularProgressIndicator()
                    )
                  )
                  else if(filteredClassCourses.isEmpty && searchController.text.isNotEmpty)Expanded(
                    child: CollectionPlaceholder(
                      detail: 'Search Information not found'
                    )
                  )
                  else if(filteredClassCourses.isEmpty && Provider.of<SelcProvider>(context).classCourses.isEmpty)Expanded(
                    child: CollectionPlaceholder.withRefresh(
                      detail: 'No class courses found. Please try again',
                      onPressed: loadData,
                    )
                  )
                  else Expanded(
                    child: ListView.builder(
                      itemCount: filteredClassCourses.length,
                      itemBuilder: (_, index) => ClassCourseCell(classCourse: filteredClassCourses[index])
                    ),
                  )

                ],
              )
            ),
          )
        ],
      )
    );
  }





  void handleSearchFilter(_){

    if(searchController.text.isEmpty){
      setState(() => filteredClassCourses = Provider.of<SelcProvider>(context, listen: false).classCourses);
      return;
    }


    String searchLower = searchController.text.toLowerCase();

    filteredClassCourses = Provider.of<SelcProvider>(context, listen: false).classCourses.where(
      (classCourse) {
        return classCourse.course.courseCode.toLowerCase().contains(searchLower) ||
              classCourse.course.title.toLowerCase().contains(searchLower) ||
              classCourse.lecturer.name.toLowerCase().contains(searchLower) ||
              classCourse.lecturer.department.toLowerCase().contains(searchLower) ||
              classCourse.semester.toString().contains(searchLower) ||
              classCourse.year.toString().contains(searchLower);
      }
    ).toList();


    setState(() {});

  }

}



//todo: rename this widget to "ClassCourseTableRow"
class ClassCourseCell extends StatefulWidget {

  final ClassCourse classCourse;

  const ClassCourseCell({super.key, required this.classCourse});

  @override
  State<ClassCourseCell> createState() => _ClassCourseCellState();
}


class _ClassCourseCellState extends State<ClassCourseCell> {

  bool acceptingResponse = false;

  Color backgroundColor = Colors.transparent;

  bool isUpdatingResponse = false;

  @override
  void initState() {
    // TODO: implement initState
    acceptingResponse = widget.classCourse.isAcceptingResponse;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {


    final List<Widget> actions = [
      ListTile(
        leading: Icon(Icons.info, size: 25,),
        title: CustomText('View Course Information'),
        onTap: () => handleViewCourseInfo(),
      ),

      ListTile(
        leading: Icon(Icons.bar_chart, size: 25,),
        title: CustomText('View Evaluation'),
        onTap: () => handleViewEvaluation(),
      ),
    ];

    return MouseRegion(

      onHover: (mouseEvent) => setState(() => backgroundColor = Colors.green.shade100),
      onExit: (mouseEvent) => setState(() => backgroundColor = Colors.transparent),

      child: GestureDetector(
        onTap: () => handleViewCourseInfo(),
        onSecondaryTapDown: (detail) => showContextMenu(
          detail.globalPosition,
          context,
          (_) => actions,
          12.0, 250.0
        ),

        child: Container(
          padding: const EdgeInsets.all(8),

          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: backgroundColor
          ),

          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [

              //year
              SizedBox(
                width: 120,
                child: CustomText(widget.classCourse.year.toString()),
              ),

              //semester
              SizedBox(
                width: 120,
                child: CustomText(widget.classCourse.semester.toString()),
              ),

              //lecturer
              Expanded(
                flex: 3,
                child: CustomText(widget.classCourse.lecturer.name),
              ),


              //course code
              SizedBox(
                width: 120,
                child: CustomText(widget.classCourse.course.courseCode),
              ),


              //course title
              Expanded(
                flex: 2,
                child: CustomText(widget.classCourse.course.title),
              ),


              //number of students in the class
              SizedBox(
                width: 120,
                child: CustomText(widget.classCourse.registeredStudentsCount.toString()),
              ),


              //switch for togging accepting evaluation state
              SizedBox(
                width: 120,
                child: isUpdatingResponse ? CircularProgressIndicator(color: Colors.green.shade300,) : Switch(
                  value: widget.classCourse.isAcceptingResponse,
                  onChanged: handleSwitchToggled,
                  activeColor: Colors.green.shade400,
                )
              )

            ]
          ),
        ),
      ),
    );
  }


  void handleViewCourseInfo() => showCustomModalBottomSheet(context: context, isScrollControlled: true, child: ClassCourseInfoModalSheet(classCourse: widget.classCourse));

  void handleViewEvaluation() => Provider.of<PageProvider>(context, listen: false).pushPage(EvaluationPage(classCourse: widget.classCourse), 'Course Evaluation');


  void handleSwitchToggled(newValue) async {


    setState(() => isUpdatingResponse = true);


    //todo: perform the class_course update here.
    try{
      await Provider.of<SelcProvider>(context, listen: false).updateClassCourse(widget.classCourse.classCourseId, newValue!);

      setState(() {
        widget.classCourse.isAcceptingResponse = newValue;
        isUpdatingResponse = false;
      });

      return;
    }on SocketException{
      showToastMessage(context, 'No Connection!. Please make sure you are connected to the internet.');
    }on Error catch(error, stackTrace){
      showToastMessage(context, 'An unexpected error occurred. Could not update Class Course.');
      debugPrint(error.toString());
      debugPrint(stackTrace.toString());
    } 

    setState(() {
      widget.classCourse.isAcceptingResponse = !newValue;
      isUpdatingResponse = false;
    });
  }
}


