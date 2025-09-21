

import 'package:flutter/material.dart';
import 'package:selc_admin/components/button.dart';
import 'package:selc_admin/components/text.dart';
import 'package:selc_admin/components/utils.dart';
import 'package:selc_admin/model/models.dart';
import 'package:selc_admin/providers/pref_provider.dart';

class ReportView extends StatelessWidget {

  final ClassCourse classCourse;
  final List<CourseEvaluationSummary> evaluationSummaries;
  final List<CategoryRemark> categoryRemarks;
  final List<EvalLecturerRatingSummary> ratingSummary;
  final List<SuggestionSentimentSummary> sentimentSummary;

  const ReportView({
    super.key,
    required this.classCourse,
    required this.evaluationSummaries,
    required this.categoryRemarks,
    required this.ratingSummary,
    required this.sentimentSummary
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),

      child: Center(
        child: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.all(8),
          width: MediaQuery.of(context).size.width * 0.5,


          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            color: Colors.grey.shade50//PreferencesProvider.getColor(context, 'alt-primary-color')
          ),

          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 8,
            children: [

              //todo: the header of the report view
              buildReportHeader(),
              NavigationTextButtons(),



              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      //todo: build the lecturer details.
                      buildCourseInformationSection(),


                      const SizedBox(height: 8),


                      Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(12)
                          ),

                          child: CustomText(
                            'Questionnaire Summary',
                            fontWeight: FontWeight.w600,
                          )
                        ),
                      ),

                      const SizedBox(height: 8,),
                      //todo: to be replaced with official description statement provided
                      CustomText('Summary information as how students anwered the evaluation questionnaire'),

                      const SizedBox(height: 8),

                      buildQuestionnaireTable(),

                      const SizedBox(height: 16),




                      Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(12)
                          ),

                          child: CustomText(
                            'Summary Report',
                            fontWeight: FontWeight.w600,
                          )
                        ),
                      ),

                      const SizedBox(height: 8,),
                      //todo: to be replaced with official description statement provided
                      CustomText('The table below the categorical(core area) summary of the questionnaire.'),

                      const SizedBox(height: 8),

                      buildCategoryTable(),

                      const SizedBox(height: 12,),





                      Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(12)
                          ),

                          child: CustomText(
                            'Lecturer Rating summary',
                            fontWeight: FontWeight.w600,
                          )
                        ),
                      ),

                      const SizedBox(height: 8,),
                      //todo: to be replaced with official description statement provided
                      CustomText(
                        'The table shows the rating summary of the lecturer for this course.'
                      ),


                      const SizedBox(height: 8,),

                      buildLRatingTable(),


                      const SizedBox(height: 16,),




                      Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(12)
                            ),

                            child: CustomText(
                              'Suggestion Sentiment Summary',
                              fontWeight: FontWeight.w600,
                            )
                        ),
                      ),

                      const SizedBox(height: 8,),
                      //todo: to be replaced with official description statement provided
                      CustomText(
                        'This shows the summary of sentiments of students regaard this course and lecturer. '
                        'Sentiment is based the tone of the suggestion made by the student during the evaluation of this course.'
                        '\nNB: For the actual suggestios, kindly check the evaluation report on this course in your portal'
                      ),


                      const SizedBox(height: 9,),

                      buildSentimentTable()

                    ],
                  )
                )
              )

            ]
          ),
        ),
      ),
    );
  }



  Widget buildReportHeader(){
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 8,
      children: [

        Image.asset(
          'lib/assets/imgs/UENR-Logo.png',
          height: 80,
          width: 80,
        ),


        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              HeaderText(
                'University of Energy and Natural Resources',
                fontSize: 20,
              ),
              HeaderText(
                'Quality Assurance and Academic Planning Committee',
                fontSize: 18,
              ),
              HeaderText(
                'Students Evaluation of Lecturers and Courses (SELC)',
                fontSize: 16,
              )
            ]
          ),
        )

      ],
    );
  }



  Widget buildCourseInformationSection(){

    Lecturer lecturer = classCourse.lecturer;
    Course course = classCourse.course;

    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 8,
      children: [

        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300)
          ),
          child: CustomText(
            'Information',
            fontWeight: FontWeight.w600,
          )
        ),


        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          spacing: 12,
          children: [
            //todo: lecturer information
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [

                  buildDetailField(title: 'Lecturer :', detail: lecturer.name),

                  buildDetailField(title: 'Email :', detail: lecturer.email),

                  buildDetailField(title: 'Department :', detail: lecturer.department)

                ]
              ),
            ),



            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [

                  buildDetailField(title: 'Course Code :', detail: course.courseCode),
                  buildDetailField(title: 'Course Title :', detail: course.title),

                  buildDetailField(title: 'No. on roll: ', detail: classCourse.registeredStudentsCount.toString()),

                  buildDetailField(title: 'Academic Year :', detail: classCourse.year.toString()),
                  buildDetailField(title: 'semester :', detail: classCourse.semester.toString())


                ]
              ),
            )


          ],
        ),


      ],
    );
  }



  Widget buildDetailField({required String title, required String detail}){
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        CustomText(
          title,
          fontWeight: FontWeight.w600,
        ),

        const SizedBox(width: 8,),

        CustomText(
          detail,
        ),
      ],

    );
  }





  Widget buildQuestionnaireTable(){
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12)
      ),

      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [

          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(12)
            ),


            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: CustomText(
                    'Questions',
                    fontWeight: FontWeight.w600,
                  ),
                ),


                Expanded(
                  child: CustomText(
                    'Answers',
                    fontWeight: FontWeight.w600,
                  ),
                ),


                SizedBox(
                  width: 120,
                  child: CustomText(
                    'Percentage Score(%)',
                    fontWeight: FontWeight.w600,
                  ),
                ),

                SizedBox(
                  width: 120,
                  child: CustomText(
                      'Mean score',
                      fontWeight: FontWeight.w600,
                  ),
                ),


                Expanded(
                  child: CustomText(
                    'Remark',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ]
            )
          ),


          for(int i=0; i < evaluationSummaries.length; i++) DecoratedBox(
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.grey.shade300))
            ),
            child: buildQuestionnaireTableCell(evaluationSummaries[i])
          )

        ]
      )
    );
  }



  //create some mandatory cells.
  Widget buildQuestionnaireTableCell(CourseEvaluationSummary summary){

    final divider = VerticalDivider(width: 0, thickness: 1.5,);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,  
        children: [

          Expanded(
            flex: 2,
            child: Padding(  
              padding: const EdgeInsets.all(8),
              child: CustomText(  
                summary.question
              ),
            ),
          ),

          divider,

          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: List<Widget>.generate(
                  summary.answerSummary!.length,
                  (index) {

                    String answerKey = summary.answerSummary!.keys.elementAt(index);

                    int answerFrequency = summary.answerSummary![answerKey];

                    return Row(
                      children: [
                        CustomText('$answerKey :'),
                        Spacer(),
                        CustomText(answerFrequency.toString())
                      ],
                    );
                  }
                )
              ),
            )
          ),



          divider,


          //todo: percentage score
          SizedBox(
            width: 120,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: CustomText(formatDecimal(summary.percentageScore)),
            )
          ),


          divider,


          SizedBox(
            width: 120,
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: CustomText(formatDecimal(summary.meanScore))
            )
          ),


          divider,


          Expanded(
            child: CustomText(summary.remark)
          )
        ],
      ),
    );
  }






  Widget buildCategoryTable(){
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300,),
        borderRadius: BorderRadius.circular(12),
      ),

      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,

        children: [

          //todo: categories table row
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(12),
            ),


            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  flex: 2,
                  child: CustomText(
                    'Core Area (Category)',
                    fontWeight: FontWeight.w600
                  )
                ),



                Expanded(
                  child: CustomText(
                    'Mean Score',
                    textAlignment: TextAlign.center,
                    fontWeight: FontWeight.w600,
                  ),
                ),




                Expanded(
                  child: CustomText(
                    'Percentage Score',
                    textAlignment: TextAlign.center,
                    fontWeight: FontWeight.w600,
                  ),
                ),


                Expanded(
                  child: CustomText(
                    'Remarks',
                    fontWeight: FontWeight.w600,
                  ),
                )


              ]
            )
          ),



          ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: categoryRemarks.length,
            itemBuilder: (_, index){


              final categoryRemark = categoryRemarks[index];

              final divider = VerticalDivider(width: 0, thickness: 1.5,);


              return Container(
                padding: EdgeInsets.zero,
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Colors.grey.shade300)
                  ),
                ),

                child: IntrinsicHeight(
                  child: Row(
                    children: [
                      //todo: category name
                      Expanded(
                        flex: 2,
                        child: CustomText(categoryRemark.categoryName),
                      ),
                  
                  
                      divider,

                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: CustomText(
                            formatDecimal(categoryRemark.meanScore),
                            textAlignment: TextAlign.center,
                          ),
                        ),
                      ),
                  
                      divider,
                  
                      //the percentage score
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: CustomText(
                            formatDecimal(categoryRemark.percentageScore),
                            textAlignment: TextAlign.center,
                          ),
                        ),
                      ),
                  
                      divider,
                  
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: CustomText(categoryRemark.remark),
                        ),
                      ),
                    ]
                  ),
                )
              );
            }
          )

        ]
      ),
    );
  }



  

  Widget buildScoringTable(){
    return Container();
  }




  Widget buildLRatingTable(){
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12)
      ),

      child: Column(  
        children: [

          Container(  
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(  
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(12)
            ),

            child: Row(  
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(  
                  child: CustomText('Rating', fontWeight: FontWeight.w600,),
                ),


                Expanded(  
                  child: CustomText(
                    'Count', 
                    fontWeight: FontWeight.w600,
                    textAlignment: TextAlign.center
                  ),
                ),


                Expanded(  
                  child: CustomText(
                    'Percentage', 
                    fontWeight: FontWeight.w600,
                    textAlignment: TextAlign.center,
                  ),
                ),
              ]
            )
          ),


          ListView.builder(  
            physics: NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: ratingSummary.length,
            //separatorBuilder: (_, __) => Divider(thickness: 1.5,),
            itemBuilder: (_, index){

              final divider = VerticalDivider(width: 0, thickness: 1.5);

              final isLast = index == (ratingSummary.length - 1);

              return IntrinsicHeight(
                child: DecoratedBox(
                  decoration: BoxDecoration(  
                    border: isLast ? null : Border(
                      bottom: BorderSide(color: Colors.grey.shade300, width: 1.5)
                    )
                  ),
                  child: Row(  
                    children: [
                      Expanded(  
                        child: Padding(  
                          padding: const EdgeInsets.all(12),
                          child: CustomText(ratingSummary[index].rating.toString()),
                        )
                      ),
                  
                      divider,
                  
                      Expanded(  
                        child: Padding(  
                          padding: const EdgeInsets.all(12),
                          child: CustomText(
                            ratingSummary[index].ratingCount.toString(),
                            textAlignment: TextAlign.center
                          ),
                        )
                      ),
                  
                      divider,
                  
                      Expanded(  
                        child: Padding(  
                          padding: const EdgeInsets.all(12),
                          child: CustomText(
                            formatDecimal(ratingSummary[index].percentage),
                            textAlignment: TextAlign.center,
                          ),
                        )
                      )
                    ]
                  ),
                ),
              );
            }
          ),


          //todo: mean rating of the lecturer
          IntrinsicHeight(
            child: Row(
              children: [
                Spacer(),

                VerticalDivider(width: 0, thickness: 1.5,),
            
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: CustomText(  
                      'Average Rating',
                      fontWeight: FontWeight.bold,
                      textAlignment: TextAlign.right,
                    ),
                  ),
                ),
                            
                VerticalDivider(width: 0, thickness: 1.5,),
                            
                Expanded(  
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: CustomText(  
                      formatDecimal(classCourse.lecturerRating),
                      textAlignment: TextAlign.center,
                      fontWeight: FontWeight.w600,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                )
              ],
            ),
          )

        ]
      ),
    );
  }




  Widget buildSentimentTable(){
    return Container(
      decoration: BoxDecoration( 
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300)
      ),

      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children:[

          Container(  
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(  
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(12)
            ),

            child: Row(  
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(  
                  child: CustomText('Sentiment', fontWeight: FontWeight.w600,),
                ),


                Expanded(  
                  child: CustomText(
                    'Count', 
                    fontWeight: FontWeight.w600,
                    textAlignment: TextAlign.center
                  ),
                ),


                Expanded(  
                  child: CustomText(
                    'Percentage', 
                    fontWeight: FontWeight.w600,
                    textAlignment: TextAlign.center,
                  ),
                ),
              ]
            )
          ),



          ListView.builder(  
            physics: NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: sentimentSummary.length,
            //separatorBuilder: (_, __) => Divider(thickness: 1.5,),
            itemBuilder: (_, index){

              final divider = VerticalDivider(width: 0, thickness: 1.5);

              final isLast = index == (sentimentSummary.length -1);

              return IntrinsicHeight(
                child: DecoratedBox(
                  decoration: BoxDecoration(  
                    border: isLast ? null : Border(bottom: BorderSide(color: Colors.grey.shade300, width: 1.5))
                  ),
                  child: Row(  
                    children: [
                      Expanded(  
                        child: Padding(  
                          padding: const EdgeInsets.all(12),
                          child: CustomText(sentimentSummary[index].sentiment),
                        )
                      ),
                  
                      divider,
                  
                      Expanded(  
                        child: Padding(  
                          padding: const EdgeInsets.all(12),
                          child: CustomText(
                            sentimentSummary[index].sentimentCount.toString(),
                            textAlignment: TextAlign.center
                          ),
                        )
                      ),
                  
                      divider,
                  
                      Expanded(  
                        child: Padding(  
                          padding: const EdgeInsets.all(12),
                          child: CustomText(
                            formatDecimal(sentimentSummary[index].sentimentPercent),
                            textAlignment: TextAlign.center,
                          ),
                        )
                      )
                    ]
                  ),
                ),
              );
            }
          )



        ]
      )
    );
  }





  Widget buildGeneralEvaluationSummary(){
    //course mean score
    //course percentage score
    //course remark
    //lecturer average rating
    //average sentiment
    //response rate (number of registered students and those who have submitted thier evaluation)
    //final QAAPD statement.
    return Placeholder();
  }

}



