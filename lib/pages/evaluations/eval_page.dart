


import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:selc_admin/components/charts/pie_chart.dart';
import 'package:selc_admin/components/text.dart';
import 'package:selc_admin/components/button.dart';
import 'package:selc_admin/components/utils.dart';
import 'package:selc_admin/model/course.dart';
import 'package:selc_admin/model/question.dart';
import 'package:selc_admin/pages/evaluations/suggestions_table.dart';
import 'package:selc_admin/providers/selc_provider.dart';

import '../../components/cells.dart';
import '../../components/report_view.dart';
import '../../providers/page_provider.dart';
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

  bool loading = false;

  Course? course;

  @override
  void initState() {
    // TODO: implement initState

    course = widget.classCourse.course;
    
    loadEvalSummary();
    super.initState();
  }



  void loadEvalSummary() async{

    setState(() => loading = true);

    evalSummary = await Provider.of<SelcProvider>(context, listen: false).getClassCourseEvaluation(widget.classCourse.classCourseId!);
    categoryRemarks = await Provider.of<SelcProvider>(context, listen: false).getCourseEvalCategoryRemark(widget.classCourse.classCourseId!);
    evaluationSuggestions = await Provider.of<SelcProvider>(context, listen: false).getEvaluationSuggestions(widget.classCourse.classCourseId!);

    setState(() => loading = false);
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
                onPressed: handleXMLExport, 
                child: Row(  
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.download, color: Colors.green.shade400,),
                    const SizedBox(width: 8,),
                    CustomText(
                      'Export XML',
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
              children: [


                //todo: build the class course information section
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [

                    buildClassCourseInfoSection(),
                    const SizedBox(height: 12,),

                    Container(  
                      padding: const EdgeInsets.all(8),
                      width: MediaQuery.of(context).size.width * 0.2,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
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



                    const SizedBox(height: 12),



                    Container(  
                      padding: const EdgeInsets.all(8),
                      width: MediaQuery.of(context).size.width * 0.2,
                      decoration: BoxDecoration(  
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.grey.shade200
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
            
                
            
            
                const SizedBox(width: 12,),
            
                //todo: the side that actually shows the data in real time.
                Expanded(
                  flex: 2,
                  child: DefaultTabController(
                    initialIndex: 0,
                    length: 3,
                    child: Column(
                      children: [
                        
                        //todo: tab bar for handling switch 
                        TabBar(
                          indicatorColor: Colors.green.shade200,
                          indicatorPadding: const EdgeInsets.all(8),
                          labelPadding: const EdgeInsets.all(8),
                          dividerColor: Colors.black26,
                          indicatorAnimation: TabIndicatorAnimation.elastic,
                          onTap: (newValue) => setState(() => selectedTab = newValue),
                          tabs: [

                            CustomText(
                              'Questionnaire Answer Analysis',
                              fontWeight: FontWeight.w600,
                              textColor: selectedTab == 0 ? Colors.green.shade300 : Colors.black87,
                            ),
                        
                        
                            CustomText(
                              'Category Remarks',
                              fontWeight: FontWeight.w600,
                              textColor: selectedTab == 1 ? Colors.green.shade300 : Colors.black87
                            ),



                            CustomText(
                              'Suggestions',
                              fontWeight: FontWeight.w600,
                              textColor: selectedTab == 2 ? Colors.green.shade300 : Colors.black87
                            )
                        
                          ]
                        ), 


                        const SizedBox(height: 8,),


                        Expanded(
                          child: PageTransitionSwitcher(

                            duration: Duration(milliseconds: 200),

                            transitionBuilder: (child, animation, secondaryAnimation ) => FadeThroughTransition(
                              animation: animation,
                              secondaryAnimation: secondaryAnimation,
                              child: child,
                            ),

                            child: selectedTab == 0 ? buildQuestionnaireTable() :
                                    selectedTab == 1 ? CategoryRemarksTable(categoryRemarks: categoryRemarks) :
                                    SuggestionsTable(suggestions: evaluationSuggestions)
                          ),
                        )

                        
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
          color: Colors.grey.shade200
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

            DetailContainer(title: 'Lecturer', detail: widget.classCourse.lecturer!.name!),

            const SizedBox(height: 8,),

            DetailContainer(title: 'Department', detail: widget.classCourse.lecturer!.department!),

            const SizedBox(height: 8,),

            Row(  
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Expanded(
                  child: DetailContainer(title: 'Year', detail: widget.classCourse.year!.toString()),
                ),
                
                const SizedBox(width: 8,),

                Expanded(
                  child: DetailContainer(title: 'Semester', detail: widget.classCourse.semester!.toString()),
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





  //todo: questionnaire analysis table. 
  Container buildQuestionnaireTable() {
    return Container(  
      width: double.infinity,
      height: double.infinity,
    
      padding: const EdgeInsets.all(8),
    
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12)
      ),
    
    
      child: Column( 
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start, 
        children: [
                  
          HeaderText(
            'Questionnaire Answer Ananlysis',
            fontSize: 15,
          ),


          const SizedBox(height: 8),
          
          //todo:table column headers for the question evaluations.
          Container(
            width: double.infinity,  
            padding: const EdgeInsets.all(8),
                            
            decoration: BoxDecoration(  
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(12)
            ),
                            
                            
            child: Row( 
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center, 
              children: [
                            
                Expanded(  
                  flex: 2,
                  child: CustomText(  
                    'Question',
                    fontWeight: FontWeight.w600,
                  ),
                ),


                Expanded(  
                  child: CustomText(
                    'Answer Type',
                    fontWeight: FontWeight.w600
                  ),
                ),
                            
                Expanded(
                  child: CustomText(
                    'Answer Variations',
                    fontWeight: FontWeight.w600
                  ),
                ), 
                            
                Expanded(  
                  child: CustomText(
                    'Visualization',
                    textAlignment: TextAlign.center, 
                    fontWeight: FontWeight.w600,
                  ),
                )
              ],
            ),
          ),
                  
                  
          //todo: question analysis table rows
          Expanded(
            flex: 2,
    
            child: loading? Center(child: CircularProgressIndicator(),) : ListView.builder(
              itemCount: evalSummary.length,

              //separatorBuilder: (_, index) => Divider(),

              itemBuilder: (_, index) => buildQuestionnaireTableRow(index)
            ),
          ),                         
          
        ],
      ),
    );
  }





  Widget buildQuestionnaireTableRow(int index){

    CourseEvaluationSummary summary = evalSummary[index];

    QuestionAnswerType answerType = summary.answerType;

    //but actually is Map<String, int>
    Map<String, dynamic> answerSummary = summary.answerSummary!;

    List<CustomPieSection> pieSections = [];

    List<Row> statRows = [];



    for(String answer in answerSummary.keys){

      int answerCount = answerSummary[answer];


      statRows.add(
        Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CustomText(answer),
            Spacer(),
            CustomText(answerCount.toString())
          ]
        )
      );

      //todo: create a piechart section
      final pieSection = CustomPieSection(title:answer, value: answerCount.toDouble(),);
      pieSections.add(pieSection);

    }


    // if(answerSummary.containsKey("No Answer")){
    //
    //   statRows.add(
    //       Row(
    //         mainAxisSize: MainAxisSize.min,
    //         mainAxisAlignment: MainAxisAlignment.start,
    //         crossAxisAlignment: CrossAxisAlignment.center,
    //
    //         children: [
    //           CustomText("No Answer"),
    //           Spacer(),
    //           CustomText(answerSummary['No Answer'].toString())
    //         ],
    //
    //       )
    //   );
    //
    //
    //   pieSections.add(
    //       CustomPieSection(
    //           title: "No Answer", value: answerSummary["No Answer"].toDouble())
    //   );
    //
    // }

    return Container(

      decoration: BoxDecoration(
        border: Border(
          left: BorderSide.none,
          top: BorderSide.none,
          right: BorderSide.none,
          bottom: BorderSide(
              color: Colors.black38,
              width: 1
          )
        )
      ),

      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: CustomText(
                  summary.question
              ),
            ),
          ),


          CustomVerticalDivider(color: Colors.black38),


          Expanded(
            child: Padding(
                padding: const EdgeInsets.only(top: 12),
                child: CustomText(
                    answerType.typeString
                )
            ),
          ),


          CustomVerticalDivider(color: Colors.black38),


          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: statRows
              )
            ),
          ),


          CustomVerticalDivider(color: Colors.black38,),


          Expanded(
            child: CustomPieChart(
              //width: 90,
              height: 250,
              pieSections: pieSections,
            ),
          )

        ],
      ),
    );

  }





  //TODO: implement exporting to various formats.
  void handleXMLExport() async {

  }


  void handlePDFExport() async {

    Provider.of<PageProvider>(context, listen: false).pushPage(ReportView(classCourse: widget.classCourse), 'Report View');

  }
}