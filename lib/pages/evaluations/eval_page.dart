


import 'dart:io';

import 'package:animations/animations.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:selc_admin/components/alert_dialog.dart';
import 'package:selc_admin/components/donwloader_util/file_downloader.dart';
import 'package:selc_admin/components/text.dart';
import 'package:selc_admin/components/button.dart';
import 'package:selc_admin/components/utils.dart';
import 'package:selc_admin/model/models.dart';
import 'package:selc_admin/pages/evaluations/cc_program_detail.dart';
import 'package:selc_admin/pages/evaluations/questionnaire_eval_table.dart';
import 'package:selc_admin/pages/evaluations/suggestions_table.dart';
import 'package:selc_admin/pages/evaluations/visualization_section.dart';
import 'package:selc_admin/providers/pref_provider.dart';
import 'package:selc_admin/providers/selc_provider.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'category_remarks_table.dart';


class EvaluationPage extends StatefulWidget {

  final ClassCourse classCourse;

  const EvaluationPage({super.key, required this.classCourse});

  @override
  State<EvaluationPage> createState() => _EvaluationPageState();
}


class _EvaluationPageState extends State<EvaluationPage> {

  int selectedTab = 0;

  List<CourseEvaluationSummary> evalSummary = [];
  List<CategoryEvaluation> categoryRemarks = [];
  
  List<CCProgramInfo> ccProgramsInfo = [];

  late SuggestionSummaryReport suggestionSummaryReport;

  List<EvalLecturerRatingSummary> evalLecturerRatingSummaries = [];

  bool isLoading = false;

  Course? course;

  @override
  void initState() {
    // TODO: implement initState

    course = widget.classCourse.course;
    loadEvalSummary();
    super.initState();
  }


  void loadEvalSummary() async{

    setState(() => isLoading = true);

    await Future.delayed(Duration(seconds: 5), (){});

    try{

      List<dynamic> ccSummary = await Provider.of<SelcProvider>(context, listen: false).getClassCourseEvaluation(widget.classCourse.classCourseId);

      //collect the questions map from each category into on giant list
      final List<Map<String, dynamic>> questionsMapList =[
        for(final summary in ccSummary)
          for(final questionMap in summary['questions'] ?? [])
            questionMap
      ];


      //convert them to a list of "CourseEvaluationSummary" objects
      evalSummary = questionsMapList.map(
              (jsonMap) => CourseEvaluationSummary.fromJson(jsonMap))
              .toList();

      //extract the category remarks into list of "CategoryRemark" objects
      categoryRemarks = ccSummary.map((jsonMap) => CategoryEvaluation.fromJson(jsonMap)).toList();

      suggestionSummaryReport =  await Provider.of<SelcProvider>(context, listen: false).getEvaluationSuggestions(widget.classCourse.classCourseId);

      evalLecturerRatingSummaries = await Provider.of<SelcProvider>(context, listen: false).getEvalLecturerRatingSummary(widget.classCourse.classCourseId);

      ccProgramsInfo = await Provider.of<SelcProvider>(context, listen: false).getCCProgramsInfo(widget.classCourse.classCourseId);

    }on SocketException{

      showNoConnectionAlertDialog(context);

    }on Error catch (e, stackTrace){

      debugPrintStack(label: e.toString(), stackTrace: stackTrace);

      showCustomAlertDialog(
        context,
        alertType: AlertType.warning,
        title: 'Error',
        contentText: e.toString()
      );

    }


    setState(() => isLoading = false);
  }


  @override
  Widget build(BuildContext context) {
    return DefaultTabController(

      initialIndex: 0,
      length: 6,

      child: Padding(
        padding: const EdgeInsets.all(16),

        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Row(
              children: [

                HeaderText(
                  'Evaluation of ${course!.title} [${course!.courseCode}]',
                  fontSize: 25,
                ),

                Spacer(),

                //todo: implement exporting current data to xml or csv for manual analysis in excel.
                TextButton(
                  onPressed: () => this.handleGenerateClassCourseReport('.xlsx'),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.download, color: Colors.green.shade400,),
                      const SizedBox(width: 8,),
                      CustomText(
                        'Export Excel(.xlsx)',
                        textColor: Colors.green.shade400,
                      )
                    ],
                  )
                ),


                //todo: implement saving report to pdf.

                TextButton(
                  onPressed: () => handleGenerateClassCourseReport('.pdf'),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.picture_as_pdf, color: Colors.green.shade400,),
                      const SizedBox(width: 8,),
                      CustomText(
                        'Export PDF',
                        textColor: Colors.green.shade400,
                      )
                    ],
                  )
                )

              ],
            ),

            const SizedBox(height: 8,),

            NavigationTextButtons(),

            const SizedBox(height: 8),

            //Tab headers
            Container(
              margin: const EdgeInsets.only(top: 12, left: 12, right: 12),
              height: 50,
              width: double.infinity, //MediaQuery.of(context).size.width * 0.4,

              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade400)
              ),

              child: IgnorePointer(
                ignoring: isLoading,
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

                    Tab(
                      text: 'Basic Info',
                    ),

                    Tab(
                      text: 'Questionnaire Answer Analysis',
                    ),

                    Tab(
                        text: 'Visualisations'
                    ),

                    Tab(
                      text: 'Category Remarks',
                    ),

                    Tab(
                      text: 'Suggestions',
                    ),

                    Tab(
                        text: 'Individual Classes'
                    )

                  ]
                ),
              ),
            ),

            const SizedBox(height: 12,),

            if(isLoading)Expanded(
              child: Center(
                child: Column(
                  spacing: 8,
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    CircularProgressIndicator(),
                    CustomText(
                      'Loading data Please wait.',
                      textAlignment: TextAlign.center,
                    )
                  ],
                )
              ),
            )
            else Expanded(
              flex: 2,
              child: buildMainBody(),
            )
          ],
        ),
      ),
    );
  }



  Widget buildMainBody(){

    return Column(
      children: [

        const SizedBox(height: 8,),

        Expanded(
          child: PageTransitionSwitcher(
            duration: Duration(milliseconds: 500),

            transitionBuilder: (child, animation, secondaryAnimation ) => FadeThroughTransition(
              animation: animation,
              secondaryAnimation: secondaryAnimation,
              fillColor: Colors.transparent,
              child: child,
            ),

            child: buildSelectedWidget()
          ),
        )
      ],
    );
  }


  Widget buildSelectedWidget(){

    switch(selectedTab){
      case 0:
        return SizedBox(
          width: double.infinity,
          height: MediaQuery.of(context).size.height * 0.9,
          child: Center(
              child: buildCCInfoSection()
          )
        );

      case 1:
        return QuestionnaireEvalTable(
          evaluationSummaries: evalSummary,
        );

      case 2:
        return VisualizationSection(
          lecturerRating: widget.classCourse.lecturerRating,
          questionEvaluations: evalSummary,
          categorySummaries: categoryRemarks,
          ratingSummary: evalLecturerRatingSummaries,
          sentimentSummary: suggestionSummaryReport.sentimentSummaries,
        );

      case 3:
        return CategoryRemarksTable(
          categoryRemarks: categoryRemarks,
        );

      case 4:
        return SuggestionsSection(
          summaryReport: suggestionSummaryReport,
          lecturerRating: evalLecturerRatingSummaries,
          courseLRating: widget.classCourse.lecturerRating,
        );

      case 5:
      default:
        return CCProgramDetailSection(
          programDetail: ccProgramsInfo
        );
    }
  }


  //course information section

  Widget buildCCInfoSection(){

    Map<String, List<(String, dynamic, IconData)>> gridItems = {
      "Basic Info": [
        ("Course", '${ widget.classCourse.course.title} [${widget.classCourse.course.courseCode}]', CupertinoIcons.book),
        ("Lecturer", widget.classCourse.lecturer.name, CupertinoIcons.person),
        ("Department", widget.classCourse.lecturer.department, CupertinoIcons.home),
        ("Credit Hours", widget.classCourse.credits.toString(), CupertinoIcons.timer),
        ("Semester", widget.classCourse.semester.toString(), CupertinoIcons.alarm),
        ("Academic Year", widget.classCourse.year.toString(), CupertinoIcons.calendar),
        ("Level", widget.classCourse.level.toString(), Icons.school_outlined),
        ("Number of Programs", widget.classCourse.programs.length.toString(), CupertinoIcons.cloud),

      ],

      "Registration Info":[
        ("Number of Students", widget.classCourse.registeredStudentsCount.toString(), CupertinoIcons.person_2),
        ("Evaluated Students", widget.classCourse.evaluatedStudentsCount.toString(), CupertinoIcons.person_crop_circle_badge_checkmark),
        ("Response Rate", '${formatDecimal(widget.classCourse.calculateResponseRate())}%', CupertinoIcons.percent)
      ],

      "Eval Info": [
        ("Mean Score", formatDecimal(widget.classCourse.grandMeanScore), CupertinoIcons.check_mark),
        ("Percentage", "${formatDecimal(widget.classCourse.grandPercentageScore)}%", CupertinoIcons.percent),
        ("Remark", widget.classCourse.remark, CupertinoIcons.chat_bubble),

        ("Lecturer Rating for Course", formatDecimal(widget.classCourse.lecturerRating), Icons.thumb_up_outlined)
      ]
    };

    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.8,
      height: MediaQuery.of(context).size.height * 0.7,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 12,
        children: [

          //Simple Image, Course title and Code
          Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            spacing: 12,
            children: [

              Container(
                width: 300,
                height: 300,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.green.shade400,
                  borderRadius: BorderRadius.circular(12)
                ),
                child: Icon(CupertinoIcons.book, color: Colors.white, size: 70,)
              ),

              CustomText(
                widget.classCourse.course.courseCode,
                textColor: Colors.green.shade400,
                fontWeight: FontWeight.w600,
                fontSize: 18,
                textAlignment: TextAlign.center,
              ),

            ],
          ),


          //todo: basic course Information
          Expanded(
            child: MasonryGridView.count(
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              crossAxisCount: 2,
              itemCount: gridItems.length,
              itemBuilder: (_, index){

                String sectionTitle = gridItems.keys.elementAt(index);

                List<Widget> sectionItems = List.generate(
                  gridItems[sectionTitle]!.length, (index) {

                    String title = gridItems[sectionTitle]![index].$1;
                    String detail = gridItems[sectionTitle]![index].$2;
                    IconData icon = gridItems[sectionTitle]![index].$3;

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        spacing: 8,
                        children: [

                          CircleAvatar(
                            backgroundColor: PreferencesProvider.getColor(context, 'primary-color'),
                            radius: 30,
                            child: Icon(icon, color: Colors.green.shade400, size: 20,),
                          ),

                          Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            spacing: 5,
                            children: [
                              CustomText(
                                title,
                                fontWeight: FontWeight.w600,
                              ),

                              CustomText(detail)
                            ],
                          ),
                        ],
                      ),
                    );
                });

                return Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: PreferencesProvider.getColor(context, 'alt-primary-color'),
                    borderRadius: BorderRadius.circular(12)
                  ),

                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomText(
                        sectionTitle,
                        fontWeight: FontWeight.w600,
                        fontSize: 17,
                        textColor: Colors.green.shade300,
                      ),

                      SizedBox(height: 12,),

                      ...sectionItems
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



  //TODO: implement exporting to various formats.
  void handleGenerateClassCourseReport(String fileType) async {

    Map<String, dynamic> reportParams = {
      'report_type': 'class_course',
      'id': widget.classCourse.classCourseId,
      'file_type': fileType
    };

    try{

      ReportFile? reportFile = await Provider.of<PreferencesProvider>(context, listen: false).generateReportFile(reportParams);

      if(reportFile == null) return;

      FileDownloader downloader = getDownloader();

      downloader.download(reportFile: reportFile, context: context, onProgress: null);

    }on SocketException{
      showNoConnectionAlertDialog(context);
    }on Error catch (e){
      showCustomAlertDialog(
        context, 
        alertType: AlertType.warning, 
        title: 'Error', 
        contentText:  e.toString()
      );
    }


    //after generating the report file, hand it to the download scheduler

    // ExcelExporter excelExporter = ExcelExporter(
    //   classCourse: widget.classCourse,
    //   questionnaireData: evalSummary,
    //   categoryData: categoryRemarks,
    //   ratingSummary: evalLecturerRatingSummaries,
    //   sentimentSummary: suggestionSummaryReport.sentimentSummaries
    // );
    //
    // excelExporter.save(context);

  }
}