


import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:selc_admin/components/excel_convert.dart';
import 'package:selc_admin/components/text.dart';
import 'package:selc_admin/components/button.dart';
import 'package:selc_admin/components/utils.dart';
import 'package:selc_admin/model/models.dart';
import 'package:selc_admin/pages/evaluations/questionnaire_eval_table.dart';
import 'package:selc_admin/pages/evaluations/suggestions_table.dart';
import 'package:selc_admin/pages/evaluations/visualization_section.dart';
import 'package:selc_admin/providers/pref_provider.dart';
import 'package:selc_admin/providers/selc_provider.dart';

import 'package:selc_admin/components/cells.dart';
import 'package:selc_admin/providers/page_provider.dart';
import '../../components/report_view.dart';
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
  List<EvaluationSuggestion> evaluationSuggestions = [];
  List<SuggestionSentimentSummary> sentimentSummaries = [];

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

    evalSummary = await Provider.of<SelcProvider>(context, listen: false).getClassCourseEvaluation(widget.classCourse.classCourseId);
    categoryRemarks = await Provider.of<SelcProvider>(context, listen: false).getCourseEvalCategoryRemark(widget.classCourse.classCourseId);

    suggestionSummaryReport =  await Provider.of<SelcProvider>(context, listen: false).getEvaluationSuggestions(widget.classCourse.classCourseId);

    evalLecturerRatingSummaries = await Provider.of<SelcProvider>(context, listen: false).getEvalLecturerRatingSummary(widget.classCourse.classCourseId);

    // sentimentSummaries = suggestionSummaryReport.sentimentSummaries;
    // evaluationSuggestions = suggestionSummaryReport.suggestions;

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
                onPressed: handleExcelExport, 
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
                onPressed: handlePDFExport, 
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

                    Container(  
                      padding: const EdgeInsets.all(8),
                      width: MediaQuery.of(context).size.width * 0.2,
                      decoration: BoxDecoration(
                        color: PreferencesProvider.getColor(context, 'alt-primary-color'),
                        borderRadius: BorderRadius.circular(12)
                      ),

                      child: Column(  
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          HeaderText('Lecturer rating for this course'),
                          const SizedBox(height: 8,),

                          DetailContainer(
                              title: 'Rating',
                              detail: formatDecimal(widget.classCourse.lecturerRating)
                          )
                        ],
                      )
                    ),

                    Container(  
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

                        children: [

                          HeaderText('Course Remark'),

                          const SizedBox(height: 12,),

                          DetailContainer(
                              title: 'Score',
                              detail: formatDecimal(widget.classCourse.grandMeanScore)
                          ),

                          const SizedBox(height: 8,),

                          DetailContainer(title: 'Remark', detail: widget.classCourse.remark!),

                        ],
                      ),
                    )
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
                      length: 4,

                      child: Column(
                        children: [

                          //todo: tab bar for handling switch
                          Container(
                            margin: const EdgeInsets.only(top: 12),
                            height: 50,
                            width: MediaQuery.of(context).size.width * 0.4,

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
        borderRadius: BorderRadius.zero,
      );
    }


    else if(selectedTab == 1) {
      return QuestionnaireVisualSection(evaluationSummaries: evalSummary);
    }

    else if(selectedTab == 2){
      return CategoryRemarksTable(
        categoryRemarks: categoryRemarks,
        borderRadius: BorderRadius.zero,
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

          children: [

            HeaderText(
              'Course Information'
            ),


            const SizedBox(height: 8),

            DetailContainer(title: 'Course', detail: course!.toString()),

            const SizedBox(height: 8,), 

            DetailContainer(title: 'Lecturer', detail: widget.classCourse.lecturer.name),

            const SizedBox(height: 8,),

            DetailContainer(title: 'Department', detail: widget.classCourse.lecturer.department),

            const SizedBox(height: 8,),

            Row(  
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Expanded(
                  child: DetailContainer(title: 'Year', detail: widget.classCourse.year.toString()),
                ),
                
                const SizedBox(width: 8,),

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





  //todo: the section that handles the user filtering
  //you can also call it filter console.
  Widget buildFilterSection(BuildContext context) {
    return Card(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.2,
        padding: const EdgeInsets.all(8),

        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,

          children: [


            HeaderText(
              'Filter',
              fontSize: 15,
            ),

            const SizedBox(height: 12,),


            CustomCheckBox(
              value: true,
              text: 'Show All',
            ),

            const SizedBox(height: 8,),

            CustomCheckBox(
              value: false,
              text: 'Custom Filter'
            ),

            Divider(),

            CustomText(
              'Academic Year',
              fontWeight: FontWeight.w600,
            ),

            const SizedBox(height: 8,),

            CustomDropdownButton<String>(
              hint: 'Select Academic Year',
              controller: DropdownController<String>(),
              items: List<String>.generate(10, (index) {
                return '${2011 + index} / ${2011 + index+1}';
              }),
              onChanged: (newValue){}
            ),



            //todo: select the semester to which that course was learned or offered
            const SizedBox(height: 12,),

            CustomText(
              'Semester',
              fontWeight: FontWeight.w600,
            ),

            const SizedBox(height: 8,),

            CustomDropdownButton<int>(
              hint: 'Select Semester',
              controller: DropdownController<int>(),
              items: <int>[1, 2],
              onChanged: (newValue){}
            ),



            //todo: the lecturers that taught the course.
            const SizedBox(height: 12,),

            CustomText(
              'Lecturer',
              fontWeight: FontWeight.w600,
            ),

            const SizedBox(height: 8,),

            CustomDropdownButton<String>(
              hint: 'Select Lecturer',
              controller: DropdownController<String>(),
              items: List<String>.generate(10, (index) => 'Lecturer ${index+1}'),
              onChanged: (newValue){}
            ),



            //todo: the class that learned the course.
            const SizedBox(height: 12,),

            CustomText(
              'Class',
              fontWeight: FontWeight.w600,
            ),

            const SizedBox(height: 8,),

            CustomDropdownButton<String>(
              hint: 'Select the class',
              controller: DropdownController<String>(),
              items: ['Bsc. Computer Science Level 200', 'Bsc. Computer Science Level 100', 'Hospitality Management'],
              onChanged: (newValue){}
            ),


            Divider(),

            CustomButton.withText(
              'Clear',
              width: double.infinity,
              onPressed: (){},
            )

          ],
        ),
      ),
    );
  }





  //TODO: implement exporting to various formats.
  void handleExcelExport() async {

    ExcelExporter excelExporter = ExcelExporter(
      classCourse: widget.classCourse,
      questionnaireData: evalSummary,
      categoryData: [],
      ratingSummary: [],
      sentimentSummary: sentimentSummaries
    );


    excelExporter.save(context);

  }


  void handlePDFExport() async {

    Provider.of<PageProvider>(context, listen: false).pushPage(
      ReportView(
        classCourse: widget.classCourse,
        evaluationSummaries: this.evalSummary,
        categoryRemarks: this.categoryRemarks,
      ),
      'Report View'
    );

  }
}