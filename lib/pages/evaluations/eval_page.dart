


import 'dart:io';

import 'package:animations/animations.dart';
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
import 'package:selc_admin/components/cells.dart';
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
  List<CategoryRemark> categoryRemarks = [];
  
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
      categoryRemarks = ccSummary.map((jsonMap) => CategoryRemark.fromJson(jsonMap)).toList();

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
    return Padding(
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

          NavigationTextButtons(),

          const SizedBox(height: 8),

          Expanded(
            flex: 2,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 12,
              children: [


                //todo: build the class course information section
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  spacing: 12,
                  children: [

                    buildClassCourseInfoSection(),

                    buildResponseSection(),

                    buildRatingsAndScoresDetail(),

                  ],
                ),
            

            
                //todo: the side that actually shows the data in real time.
                if(isLoading) Expanded(
                  flex: 2,
                  child: Center(
                    child: CircularProgressIndicator()
                  ),
                )
                else Expanded(
                  flex: 2,

                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: PreferencesProvider.getColor(context, 'table-background-color'),
                      borderRadius: BorderRadius.circular(12)
                    ),

                    child: DefaultTabController(
                      initialIndex: 0,
                      length: 5,

                      child: Column(
                        children: [

                          //todo: tab bar for handling switch
                          Container(
                            margin: const EdgeInsets.only(top: 12, left: 12, right: 12),
                            height: 50,
                            width: double.infinity, //MediaQuery.of(context).size.width * 0.4,

                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey.shade400)
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
                      ),

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


  Widget buildSelectedWidget(){

    if(selectedTab == 0){
      return QuestionnaireEvalTable(
        evaluationSummaries: evalSummary,
      );
    }


    else if(selectedTab == 1) {
      return VisualizationSection(
        lecturerRating: widget.classCourse.lecturerRating,
        questionEvaluations: evalSummary,
        categorySummaries: categoryRemarks,
        ratingSummary: evalLecturerRatingSummaries,
        sentimentSummary: suggestionSummaryReport.sentimentSummaries,
      );
    }

    else if(selectedTab == 2){
      return CategoryRemarksTable(
        categoryRemarks: categoryRemarks,
      );
    }

    else if(selectedTab == 4){
      return CCProgramDetailSection(  
        programDetail: ccProgramsInfo
      );
    }


    return SuggestionsTable(
      summaryReport: suggestionSummaryReport, 
      lecturerRating: evalLecturerRatingSummaries,
      courseLRating: widget.classCourse.lecturerRating,
    );
  }



  //course information section

  Widget buildClassCourseInfoSection(){
    return Card(  
      shape: RoundedRectangleBorder(  
        borderRadius: BorderRadius.circular(12),
      ),

      child: Container(  
        width: MediaQuery.of(context).size.width * 0.2,
        padding: const EdgeInsets.all(8),

        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: PreferencesProvider.getColor(context, 'alt-primary-color')
        ),


        child: Column(  
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 8,

          children: [

            HeaderText(
              'Course Information'
            ),



            DetailContainer(title: 'Course', detail: course!.toString()),


            DetailContainer(title: 'Lecturer', detail: widget.classCourse.lecturer.name),


            DetailContainer(title: 'Department', detail: widget.classCourse.lecturer.department),


            Row(  
              mainAxisAlignment: MainAxisAlignment.start,
              spacing: 8,
              children: [

                Expanded(
                  child: DetailContainer(title: 'Credit', detail: widget.classCourse.credits.toString()),
                ),

                Expanded(
                  child: DetailContainer(title: 'Year', detail: widget.classCourse.year.toString()),
                ),


                Expanded(
                  child: DetailContainer(title: 'Semester', detail: widget.classCourse.semester.toString()),
                )
              ],
            )

          ],
        ),
      ),
    );
  }





  Widget buildResponseSection(){
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12)
      ),

      child: Container(
        padding: const EdgeInsets.all(8),
        width: MediaQuery.of(context).size.width * 0.2,

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

            HeaderText('Students and Responses Info'),


            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              spacing: 8,

              children: [
                Expanded(
                  child: DetailContainer(
                    title: 'No. of Students',
                    detail: '${widget.classCourse.registeredStudentsCount}',
                  ),
                ),


                Expanded(
                  child: DetailContainer(
                    title: 'No. of Responses',
                    detail: '${widget.classCourse.evaluatedStudentsCount}',
                  ),
                ),
              ],
            ),


            DetailContainer(
              title: 'Response Rate',
              detail: '${formatDecimal(widget.classCourse.calculateResponseRate())} %'
            ),

          ],
        ),
      )
    );
  }





  Widget buildRatingsAndScoresDetail(){
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12)
      ),

      child: Container(
        padding: const EdgeInsets.all(8),
        width: MediaQuery.of(context).size.width * 0.2,

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

            HeaderText('Ratings, Scores and Remarks'),


            DetailContainer(
              title: 'Avg. Lecturer Rating',
              detail: formatDecimal(widget.classCourse.lecturerRating),
            ),


            DetailContainer(
                title: 'Class Course Score',
                detail: formatDecimal(widget.classCourse.grandMeanScore)
            ),


            DetailContainer(title: 'Remark', detail: widget.classCourse.remark!),

          ],
        ),
      )
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