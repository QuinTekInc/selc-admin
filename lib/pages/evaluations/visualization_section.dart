

import 'package:flutter/material.dart';
import 'package:selc_admin/components/charts/bar_chart.dart';
import 'package:selc_admin/components/charts/pie_chart.dart';
import 'package:selc_admin/components/text.dart';
import 'package:selc_admin/model/models.dart';
import 'package:selc_admin/providers/pref_provider.dart';





class QuestionnaireVisualSection extends StatelessWidget {

  final List<CourseEvaluationSummary> evaluationSummaries;

  const QuestionnaireVisualSection({super.key, required this.evaluationSummaries});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
        itemCount: evaluationSummaries.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12,),
        itemBuilder: (_, index) => QuestionnaireVisualisationCell(summary: evaluationSummaries[index], questionnaireNumber: index+1)
    );
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
  final List<Row> statRows = [];


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
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                              color: PreferencesProvider.getColor(context, 'table-background-color'),
                              borderRadius: BorderRadius.circular(12)
                          ),
                          child: CustomText(
                            widget.questionnaireNumber.toString(),
                            textColor: PreferencesProvider.getColor(context, 'placeholder-text-color'),
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            textAlignment: TextAlign.center,
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
                                detail: widget.summary.meanScore.toStringAsFixed(4)
                            ),

                            buildQuestionnaireField(
                                title: 'Percentage Score(%)',
                                detail: widget.summary.meanScore.toStringAsFixed(4)
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
        alignment: Alignment.center,
        child: FractionallySizedBox(
          widthFactor: 0.6,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            spacing: 8,
            children: List<Widget>.from(statRows),
          ),
        ),
      );
    }

    else if(chartTypeController.value == chartTypes[1]){
      return CustomPieChart(
        //width: 90,
        showKeys: true,
        height: 300,
        width: double.infinity,
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



