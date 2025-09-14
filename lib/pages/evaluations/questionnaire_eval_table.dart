
import 'package:flutter/material.dart';
import 'package:selc_admin/components/charts/bar_chart.dart';
import 'package:selc_admin/components/charts/pie_chart.dart';
import 'package:selc_admin/components/utils.dart';
import 'package:selc_admin/model/models.dart';

import '../../components/text.dart';
import '../../providers/pref_provider.dart';


class QuestionnaireEvalTable extends StatelessWidget {

  final List<CourseEvaluationSummary> evaluationSummaries;

  final BorderRadius? borderRadius;

  const QuestionnaireEvalTable({
    super.key,
    required this.evaluationSummaries,
    this.borderRadius
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0, right: 8, bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [

          //todo:table column headers for the question evaluations.
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(8),

            decoration: BoxDecoration(
              color: PreferencesProvider.getColor(context, 'alt-primary-color'),
              borderRadius: BorderRadius.circular(12)
            ),


            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [

                Expanded(
                  flex: 3,
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
                  flex: 2,
                  child: CustomText(
                    'Answer Variations',
                    fontWeight: FontWeight.w600
                  ),
                ),


                const SizedBox(
                  width: 130,
                  child: CustomText(
                    'Mean Score',
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(
                  width: 130,
                  child: CustomText(
                    'Mean Score',
                    fontWeight: FontWeight.w600,
                  ),
                ),

                Expanded(
                  child: CustomText(
                    'Answer Type',
                    fontWeight: FontWeight.w600
                  ),
                ),

              ],
            ),
          ),


          //todo: question analysis table rows
          Expanded(
            flex: 2,

            child: ListView.builder(
                itemCount: evaluationSummaries.length,
                itemBuilder: (_, index) {
                  CourseEvaluationSummary summary = evaluationSummaries[index];
                  return buildQuestionnaireTableRow(context, summary);
                }
            ),
          ),

        ],
      ),
    );
  }



  Widget buildQuestionnaireTableRow(BuildContext context, CourseEvaluationSummary summary){


    QuestionAnswerType answerType = summary.answerType;
    Map<String, dynamic> answerSummary = summary.answerSummary!;

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



    Color dividerColor = PreferencesProvider.getColor(context, 'placeholder-text-color');


    final divider = VerticalDivider(thickness: 1.5, width: 0, color: dividerColor);

    return Container(

      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
              color: dividerColor,
              width: 1.5
          )
        )
      ),

      child: IntrinsicHeight(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: CustomText(
                  summary.question
                ),
              ),
            ),


            divider,


            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 12),
                child: CustomText(
                    answerType.typeString
                )
              ),
            ),


            divider,


            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: statRows
                )
              ),
            ),


            divider,


            SizedBox(
              width: 130,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: CustomText(summary.meanScore.toString()),
              ),
            ),

            divider,

            SizedBox(
              width: 130,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: CustomText(summary.percentageScore.toString()),
              ),
            ),

            divider,

            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: CustomText(summary.remark),
              ),
            )

          ],
        ),
      ),
    );

  }

}







