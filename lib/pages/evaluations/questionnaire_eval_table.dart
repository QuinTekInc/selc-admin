
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
                child: CustomText(summary.averageScore.toString()),
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








class QuestionnaireVisualSection extends StatelessWidget {

  final List<CourseEvaluationSummary> evaluationSummaries;

  const QuestionnaireVisualSection({super.key, required this.evaluationSummaries});

  @override
  Widget build(BuildContext context) {
    return QuestionnaireVisualisationCell(questionnaireNumber: 1, summary: evaluationSummaries[0]);
  }
}




class QuestionnaireVisualisationCell extends StatefulWidget {

  final CourseEvaluationSummary summary;
  final int questionnaireNumber;

  const QuestionnaireVisualisationCell({super.key, required this.summary, required this.questionnaireNumber});

  @override
  State<QuestionnaireVisualisationCell> createState() => _QuestionnaireVisualisationCellState();
}

class _QuestionnaireVisualisationCellState extends State<QuestionnaireVisualisationCell> {

  final chartTypeController = DropdownController<String>();

  final List<CustomPieSection> pieSections = [];
  final List<CustomBarGroup> customBarGroups = [];


  final List<String> chartTypes = ['Text Stat', 'Pie Chart', 'Bar Chart'];


  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    chartTypeController.value = chartTypes[1];


    Map<String, dynamic> answerSummary = widget.summary.answerSummary!;


    for(int i =0; i < answerSummary.keys.length; i++){

      String answer = answerSummary.keys.elementAt(i);

      int answerCount = answerSummary[answer];

      //todo: create a piechart section
      final pieSection = CustomPieSection(title:answer, value: answerCount.toDouble(),);
      pieSections.add(pieSection);

      final barGroup = CustomBarGroup(label: answer, x: i, rods: [Rod(y: answerCount.toDouble())]);
      customBarGroups.add(barGroup);

    }


  }


  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      widthFactor: 0.6,
      child: Container(
        padding: const EdgeInsets.all(12),

        decoration: BoxDecoration(
          color: PreferencesProvider.getColor(context, 'alt-primary-color'),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300, width: 1.5)
        ),

        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          spacing: 8,
          children: [

            Row(
              spacing: 8,
              children: [

                Container(
                  padding: const EdgeInsets.all(12),
                  height: 50,
                  width: 50,
                  decoration: BoxDecoration(
                    color: PreferencesProvider.getColor(context, 'table-background-color'),
                    borderRadius: BorderRadius.circular(12)
                  ),
                  child: CustomText(
                    widget.questionnaireNumber.toString(),
                    textColor: PreferencesProvider.getColor(context, 'placeholder-text-color'),
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),


                Expanded(
                  child: CustomText(
                    widget.summary.question,
                    fontSize: 15
                  )
                ),

                SizedBox(
                  height: 45,
                  child: VerticalDivider(
                    width: 0,
                    thickness: 1.5,
                    color: PreferencesProvider.getColor(context, 'table-background-color'),
                  ),
                ),


                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CustomText(
                      'Answer type',
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),

                    CustomText(
                      widget.summary.answerType.typeString,
                      fontSize: 13,
                      textColor: Colors.green.shade400,
                    )
                  ],
                )
              ]
            ),

            Align(
              alignment: Alignment.centerRight,
              child: FractionallySizedBox(
                widthFactor: 0.4,
                child: CustomDropdownButton(
                  controller: chartTypeController,
                  hint: 'Select Chart Type',
                  items: chartTypes,
                  onChanged: (newValue) => setState((){})
                ),
              )
            ),


            //todo: chart
            buildCellChartSection(),


            Align(
              alignment: Alignment.centerRight,
              child: FractionallySizedBox(
                widthFactor: 0.4,

                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [

                    buildQuestionnaireField(
                      title: 'Mean Score',
                      detail: widget.summary.averageScore.toStringAsFixed(4)
                    ),

                    buildQuestionnaireField(
                        title: 'Percentage Score(%)',
                        detail: widget.summary.averageScore.toStringAsFixed(4)
                    ),


                    buildQuestionnaireField(
                      title: 'Remark',
                      detail: widget.summary.remark,
                      detailWeight: FontWeight.w600
                    ),

                  ]
                ),
              ),
            )
          ]

        )

      )
    );
  }



  Widget buildCellChartSection(){

    if(chartTypeController.value == chartTypes[0]){
      return Container(
        height: 250,
        width: double.infinity,
        alignment: Alignment.center
      );
    }

    else if(chartTypeController.value == chartTypes[1]){
      return CustomPieChart(
        //width: 90,
          height: 300,
          pieSections: pieSections,
          backgroundColor: Colors.transparent
      );
    }


    return CustomBarChart(
      containerBackgroundColor: Colors.transparent,
      width: double.infinity,
      height: 300,
      leftAxisTitle: 'Frequency',
      bottomAxisTitle: 'Answer Variations',
      axisNameStyle: TextStyle(color: PreferencesProvider.getColor(context, 'text-color')),
      axisLabelStyle: TextStyle(color: PreferencesProvider.getColor(context, 'placeholder-text-color')),
      groups: customBarGroups,
    );

  }



  Widget buildQuestionnaireField({required String title, required String detail, FontWeight detailWeight = FontWeight.normal}){
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [

        Expanded(
          flex: 2,
          child: CustomText(title, fontWeight: FontWeight.w600, fontSize: 13,)
        ),

        Expanded(
          child: CustomText(detail, fontWeight: detailWeight, fontSize: 13,)
        )

      ],
    );
  }
}





