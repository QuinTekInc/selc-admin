

import 'package:flutter/material.dart';
import 'package:selc_admin/components/charts/bar_chart.dart';
import 'package:selc_admin/components/charts/pie_chart.dart';
import 'package:selc_admin/components/text.dart';
import 'package:selc_admin/components/utils.dart';
import 'package:selc_admin/model/models.dart';
import 'package:selc_admin/providers/pref_provider.dart';



class VisualizationSection extends StatefulWidget {

  final double lecturerRating;

  final List<CategoryRemark> categorySummaries;
  final List<CourseEvaluationSummary> questionEvaluations;
  final List<EvalLecturerRatingSummary> ratingSummary;

  final List<SuggestionSentimentSummary> sentimentSummary;

  const VisualizationSection({
    super.key,
    required this.lecturerRating,
    required this.categorySummaries,
    required this.questionEvaluations,
    required this.ratingSummary,
    required this.sentimentSummary
  });

  @override
  State<VisualizationSection> createState() => _VisualizationSectionState();
}


class _VisualizationSectionState extends State<VisualizationSection> {


  late final Map<String, List<Widget>> evalData;


  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    evalData = {};

    for (final summary in widget.categorySummaries) {

      final List<Widget> children = [];

      for (final question in summary.questions) {

        for (final evaluation in widget.questionEvaluations) {
          if (question == evaluation.question){
            children.add(
              QuestionnaireCard(
                questionnaireNumber: 1 + widget.questionEvaluations.indexOf(evaluation),
                summary: evaluation
              )
            );
          }
        }
      }

      evalData[summary.categoryName] = children;
    }


    //add lecturer rating and suggestion sentiment
    evalData['Section B'] = [

      SizedBox(
        height: 400,
        child: LecturerRatingCard(
            lecturerRating: widget.lecturerRating,
            ratingSummary: widget.ratingSummary
        ),
      ),

      SizedBox(
        height: 400,
        child: SuggestionSentimentVisual(
          sentimentSummary: widget.sentimentSummary
        ),
      )
    ];

  }


  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        for (final evalDataKey in evalData.keys.toList()) ...[
          /// Category header
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: HeaderText(evalDataKey),
              ),
            ),
          ),

          /// Grid for category
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            sliver: SliverGrid(
              delegate: SliverChildBuilderDelegate(
                childCount: evalData[evalDataKey]!.length,
                    (context, index){
                  final card = evalData[evalDataKey]![index];

                  return card;
                },

              ),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                mainAxisExtent: 525,
              ),
            ),
          ),

          /// Space after each category
          const SliverToBoxAdapter(
            child: SizedBox(height: 16),
          ),
        ]
      ],
    );

  }

}





class QuestionnaireCard extends StatefulWidget {

  final CourseEvaluationSummary summary;
  final int questionnaireNumber;

  const QuestionnaireCard({super.key, required this.summary, required this.questionnaireNumber});

  @override
  State<QuestionnaireCard> createState() => _QuestionnaireCardState();
}

class _QuestionnaireCardState extends State<QuestionnaireCard> {

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


    for(int i = 0; i < answerSummary.keys.length; i++){

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
      final pieSection = CustomPieSection(title: '$answer [$answerCount]', value: answerCount.toDouble(), keyTitle: answer);
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
                          detail: formatDecimal(widget.summary.meanScore)
                      ),

                      buildQuestionnaireField(
                          title: 'Percentage Score(%)',
                          detail: formatDecimal(widget.summary.meanScore)
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




class LecturerRatingCard extends StatelessWidget {

  final double lecturerRating;
  final List<EvalLecturerRatingSummary> ratingSummary;

  const LecturerRatingCard({super.key, required this.lecturerRating, required this.ratingSummary});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      width: MediaQuery.of(context).size.width * 0.5,
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300)
      ),


      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        spacing: 8,

        children: [

            //top row of the cell.
          Row(
            spacing: 8,
            children: [

              //todo: put a star here.
              Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.all(8),
                height: 50,
                width: 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.grey.shade200
                ),

                child: Icon(Icons.star, color: Colors.grey.shade500)
              ),

              CustomText(
                'Students sentiment level of lecturer',
                fontSize: 15,
              ),

              Spacer(),

              SizedBox(
                  height: 45,
                  child: VerticalDivider(width: 0, thickness: 1.5,)
              ),

              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,

                children: [
                  CustomText(
                      'AnswerType',
                      fontWeight: FontWeight.w600,
                      textColor: Colors.grey.shade600
                  ),

                  CustomText(
                      'Rating',
                      textColor: Colors.green.shade400
                  )
                ]
              )
            ],
          ),


          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [

              Expanded(
                flex: 2,
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 8,
                    children: List.generate(
                      ratingSummary.length,
                        (index) => Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        spacing: 8,
                        children: [

                          Expanded(
                              child: buildStars(ratingSummary[index].rating)
                          ),

                          SizedBox(
                            width: 140,
                            child:  CustomText(
                              '${ratingSummary[index].percentage}%',
                              fontSize: 15,
                            ),
                          ),

                          SizedBox(
                            width: 140,
                            child:  CustomText(
                              '${ratingSummary[index].ratingCount}',
                              fontSize: 15,
                            ),
                          )

                        ]
                      )
                    ),
                  )
                ),
              ),


              SizedBox(
                width: 200,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        Icon(
                          Icons.star_rounded,
                          color: Colors.yellow,
                          size: 150,
                        ),

                        CustomText(
                          formatDecimal(lecturerRating),
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          textColor: Colors.grey.shade700,
                        )
                      ]
                    ),


                    CustomText(
                        'Average rating of lecturer for this course',
                        textAlignment: TextAlign.center
                    )
                  ],
                ),
              )
            ],
          )
        ]
      )
    );
  }



  //build a specified number of stars in a row
  Widget buildStars(int n) => Row(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.center,
    mainAxisAlignment: MainAxisAlignment.start,
    spacing: 3,
    children: List<Widget>.generate(
      n,
      (index) => Icon(Icons.star_rounded, color: Colors.yellow, size: 28,)
    )
  );
}





class SuggestionSentimentVisual extends StatelessWidget {

  final List<SuggestionSentimentSummary> sentimentSummary;

  const SuggestionSentimentVisual({
    super.key,
    required this.sentimentSummary
  });


  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      width: MediaQuery.of(context).size.width * 0.5,

      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
          color: Colors.grey.shade50
      ),

      child: Column(

        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        spacing: 8,

        children: [

          Row(
            spacing: 8,
            children: [

              Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.all(8),
                height: 50,
                width: 50,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.grey.shade200
                ),

                child: Icon(Icons.chat_bubble, color: Colors.grey.shade500,)
              ),

              CustomText(
                'Evaluation Suggestion Sentiment Summary',
                fontSize: 15,
              ),

              Spacer(),

              SizedBox(
                  height: 35,
                  child: VerticalDivider()
              ),


              Column(
                mainAxisSize: MainAxisSize.min,
                children: [

                  CustomText(
                    'Answer Type',
                    fontWeight: FontWeight.w600,
                    textColor: Colors.grey.shade600,
                  ),

                  CustomText(
                    'Suggestion',
                    textColor: Colors.green.shade400,
                  )
                ]
              )
            ],
          ),

          const SizedBox(height: 8),

          FractionallySizedBox(
            widthFactor: 0.5,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              spacing: 8,

              children: List<Widget>.generate(
                sentimentSummary.length,
                (int index) {

                  String sentiment = sentimentSummary[index].sentiment;
                  int count = sentimentSummary[index].sentimentCount;
                  double percent = sentimentSummary[index].sentimentPercent;

                  return Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [

                      Expanded(
                        flex: 2,
                        child: CustomText(
                            sentiment,
                            fontWeight: FontWeight.w600,
                            fontSize: 15
                        ),
                      ),

                      Expanded(
                        child: CustomText(
                            count.toString(),
                            fontSize: 15,
                            textAlignment: TextAlign.center
                        ),
                      ),

                      Expanded(
                        child: CustomText(
                          '$percent %',
                          fontSize: 15,
                          textAlignment: TextAlign.center,
                        ),
                      )

                    ]
                  );
                }
              )
            )
          )
        ]
      )
    );
  }
}

