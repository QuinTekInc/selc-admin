

import 'package:flutter/material.dart';
import 'package:selc_admin/components/button.dart';
import 'package:selc_admin/components/text.dart';
import 'package:selc_admin/model/models.dart';
import 'package:selc_admin/providers/pref_provider.dart';

class ReportView extends StatelessWidget {

  final ClassCourse classCourse;
  final List<CourseEvaluationSummary> evaluationSummaries;
  final List<CategoryRemark> categoryRemarks;

  const ReportView({
    super.key,
    required this.classCourse,
    required this.evaluationSummaries,
    required this.categoryRemarks
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
            color: PreferencesProvider.getColor(context, 'alt-primary-color')
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


                      const SizedBox(height: 8),

                      buildQuestionnaireTable(),

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
                              'Summary Report',
                              fontWeight: FontWeight.w600,
                            )
                        ),
                      ),


                      const SizedBox(height: 8),

                      buildSummaryReport()

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
                  flex: 3,
                  child: CustomText(
                    'Questions',
                  ),
                ),


                Expanded(
                  flex: 2,
                  child: CustomText(
                    'Answers'
                  ),
                ),


                SizedBox(
                  width: 120,
                  child: CustomText(
                      'Percentage Score(%)'
                  ),
                ),

                SizedBox(
                  width: 120,
                  child: CustomText(
                      'Mean score'
                  ),
                ),


                Expanded(
                  child: CustomText(
                      'Remark'
                  ),
                ),
              ]
            )
          ),


          for(int i=0; i < evaluationSummaries.length; i++) DecoratedBox(
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.grey.shade300))
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                //todo: the question in the questionnaire
                Expanded(
                  flex: 3,
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: CustomText(evaluationSummaries[i].question),
                  ),
                ),


                CustomVerticalDivider(height: 130),

                //todo: answer type

                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: List<Widget>.generate(
                        evaluationSummaries[i].answerSummary!.length,
                        (index) {

                          String answerKey = evaluationSummaries[i].answerSummary!.keys.toList()[index];

                          int answerFrequency = evaluationSummaries[i].answerSummary![answerKey];

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



                CustomVerticalDivider(height: 130,),


                //todo: percentage score
                SizedBox(
                  width: 120,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: CustomText(evaluationSummaries[i].percentageScore.toString()),
                  )
                ),


                CustomVerticalDivider(height: 130),


                SizedBox(
                  width: 120,
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: CustomText(evaluationSummaries[i].meanScore.toString())
                  )
                ),


                CustomVerticalDivider(height: 130,),


                Expanded(
                  child: CustomText(evaluationSummaries[i].remark)
                )
              ]
            ),
          )

        ]
      )
    );
  }




  Widget buildSummaryReport(){
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
                  child: CustomText('Core Area (Category)')
                ),



                Expanded(
                  child: CustomText(
                    'Percentage Score',
                    textAlignment: TextAlign.center,
                  ),
                ),


                Expanded(
                  child: CustomText(
                    'Mean Rating',
                    textAlignment: TextAlign.center,
                  ),
                ),


                Expanded(
                  child: CustomText('Remarks'),
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


              return Container(
                padding: EdgeInsets.zero,
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Colors.grey.shade300)
                  ),
                ),

                child: Row(
                  children: [
                    //todo: category name
                    Expanded(
                      flex: 2,
                      child: CustomText(categoryRemark.categoryName),
                    ),


                    CustomVerticalDivider(height: 60),

                    //the percentage score
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: CustomText(
                            categoryRemark.percentageScore.toString(),
                          textAlignment: TextAlign.center,
                        ),
                      ),
                    ),

                    CustomVerticalDivider(height: 60),

                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: CustomText(
                            categoryRemark.meanScore.toString(),
                          textAlignment: TextAlign.center,
                        ),
                      ),
                    ),

                    CustomVerticalDivider(height: 60),

                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: CustomText(categoryRemark.remark),
                      ),
                    ),
                  ]
                )
              );
            }
          )

        ]
      ),
    );
  }


}
