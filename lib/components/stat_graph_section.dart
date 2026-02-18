
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:selc_admin/components/charts/pie_chart.dart';
import 'package:selc_admin/components/text.dart';
import 'package:selc_admin/components/utils.dart';
import 'package:selc_admin/model/models.dart';
import 'package:selc_admin/pages/dash_pages/best_lecturer_card.dart';
import 'package:selc_admin/providers/pref_provider.dart';

import 'charts/bar_chart.dart';

class GraphSection extends StatelessWidget {

  final Map<String, dynamic> graphData;

  const GraphSection({super.key, required this.graphData});

  @override
  Widget build(BuildContext context) {


    final Widget responseRatePieChart = buildResponseRatePieChart(context, Map<String, dynamic>.from(graphData['registration_summary']));

    final Widget sentimentPieChart = buildSuggestionSentimentPieChart(context, Map<String, dynamic>.from(graphData['sentiment_summary']));

    final Widget ratingBarChart = buildLecturerRatingBarChart(context, Map<String, dynamic>.from(graphData['lecturer_rating']));

    final Widget bestCourseCard = buildBestCourseCard(context, Map<String, dynamic>.from(graphData['best_class_course']));

    final Widget bestLecturerCard = buildBestLecturerCard(context, Map<String, dynamic>.from(graphData['best_lecturer']));



    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      spacing: 12,
      children: [

        //todo: the various graphs


        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 12,
          children: [

            Expanded(
              child: responseRatePieChart
            ),

            Expanded(
              child: sentimentPieChart
            ),

            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              spacing: 12,
              children: [
                bestLecturerCard,

                bestCourseCard
              ],
            )
          ]
        ),


        ratingBarChart,

      ]
    );
  }


  //todo: Pie Chart for the response rate.
  Widget buildResponseRatePieChart(context, Map<String, dynamic> responseRateSummary){

    int overallReg = responseRateSummary['total_registrations'];
    int responseRecv = responseRateSummary['evaluated_registrations'];

    //find the number of those who not yet evaluated
    int totalUnresponse = overallReg - responseRecv;

    double responseRate = (responseRateSummary['response_rate'] as num).toDouble();

    //percentage of those who have not yet evaluated.
    double unresponseRate = 100 - responseRate;

    final rRateItems = [
      ('Total Registrations', overallReg.toString()),
      ('Not Responded/ Not Evaluated', totalUnresponse.toString()),
      ('Total Responses/ Evaluated', responseRecv.toString()),
      ('Response Rate', '${formatDecimal(responseRate)}%')
    ];

    return Container(
        padding: const EdgeInsets.all(12),
        width: 400,

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

              HeaderText('Overall Response Rate'),

              CustomPieChart(
                backgroundColor: Colors.transparent,
                width: double.infinity,
                height: 300,
                centerSpaceRadius: 20,
                showKeys: true,
                //todo: do the rest here.
                pieSections: [

                  CustomPieSection(
                      value: unresponseRate,
                      title: '${formatDecimal(unresponseRate)} %',
                      keyTitle: 'Unevaluated',
                      sectionColor: Colors.red.shade400
                  ),

                  CustomPieSection(
                      value: responseRate,
                      title: '${formatDecimal(responseRate)} %',
                      keyTitle: 'Evaluated',
                      sectionColor: Colors.green.shade400
                  )
                ],
              ),

              HeaderText(
                'Details',
                textColor: PreferencesProvider.getColor(context, 'placeholder-text-color'),
              ),


              ListView.separated(
                itemCount: rRateItems.length,
                shrinkWrap: true,
                separatorBuilder: (context, index) => Divider(),
                itemBuilder: (context, index) => Row(
                    children: [
                      Expanded(
                          child: CustomText(
                              rRateItems[index].$1
                          )
                      ),

                      CustomText(
                          rRateItems[index].$2
                      )
                    ]
                ),
              )
            ]
        )
    );
  }




  //todo: pie chart for suggestion sentiments
  Widget buildSuggestionSentimentPieChart(context, Map<String, dynamic> sentimentSummary){


    final sentiments = ['negative', 'neutral', 'positive'];
    final sectionColors = [Colors.red.shade400, Colors.amber, Colors.green.shade400];

    List<CustomPieSection> sections = [];

    final sentimentDetails = [];

    for(String sentiment in sentiments){

      int ratingCount = sentimentSummary[sentiment];

      double percentage = (sentimentSummary['${sentiment}_percentage'] as num).toDouble();

      sections.add(
        CustomPieSection(
          value: percentage,
          keyTitle: sentiment,
          title: '${formatDecimal(percentage)}%',
          sectionColor: sectionColors[sentiments.indexOf(sentiment)]
        )
      );


      sentimentDetails.add((sentiment, ratingCount, percentage));

    }

    return Container(
      padding: const EdgeInsets.all(12),
      width: 400,

      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: PreferencesProvider.getColor(context, 'alt-primary-color')
      ),


      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        spacing: 12,
        children: [
          HeaderText('Suggestions Sentiment Info'),

          CustomPieChart(
            backgroundColor: Colors.transparent,
            width: double.infinity,
            height: 325,
            centerSpaceRadius: 16,
            showKeys: true,
            pieSections: sections,
          ),

          HeaderText('Details'),

          ListView.separated(
            shrinkWrap: true,
            itemCount: sentimentDetails.length,
            separatorBuilder: (_, index) => Divider(),
            itemBuilder: (_, index){
              return Row(
                children: [

                  Expanded(
                    flex: 2,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      spacing: 3,
                      children: [

                        Container(
                          width: 16,
                          height: 16,
                          color: sectionColors[index],
                        ),

                        CustomText(
                          sentiments[index],
                        )
                      ],
                    ),
                  ),


                  Expanded(
                    flex: 1,
                    child: CustomText(
                      sentimentDetails[index].$2.toString(),
                      textAlignment: TextAlign.right,
                    ),
                  ),

                  Expanded(
                    flex: 1,
                    child: CustomText(
                      '${formatDecimal(sentimentDetails[index].$3)}%',
                      textAlignment: TextAlign.right,
                    ),
                  )

                ],
              );
            },
          )
        ]
      )

    );
  }



  //todo: bar chart for overall lecturer ratings
  Widget buildLecturerRatingBarChart(context, Map<String, dynamic> ratingSummary){

    int totalRated = 0;

    final List<Color> rodColors = [Colors.green.shade400, Colors.blue.shade400, Colors.purple.shade400, Colors.amber, Colors.red.shade400];

    final List<CustomBarGroup> barGroups= [];

    final List lRatingInfo = [];


    for(int i = 5; i >= 1; i--){

      int ratingCount = ratingSummary[i.toString()];

      totalRated += ratingCount;

      double percentage = (ratingSummary['rating_${i}_percentage'] as num).toDouble();

      barGroups.add(
        CustomBarGroup(
          x: i,
          label: i.toString(),
          rods: [
            Rod(
              y: ratingCount.toDouble(),
              rodColor: rodColors[rodColors.length - i]
            )
          ]
        )
      );


      lRatingInfo.add((i, ratingCount, percentage));
    }

    return Container(
      padding: const EdgeInsets.all(12),
      width: MediaQuery.of(context).size.width * 0.64,
      //height: 415,

      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: PreferencesProvider.getColor(context, 'alt-primary-color')
      ),


      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        spacing: 12,
        children: [

          HeaderText('Overall Lecturers Rating'),

          CustomBarChart(
            containerBackgroundColor: PreferencesProvider.getColor(context, 'primary-color'),
            width: double.infinity,
            height: 350,
            maxY: totalRated.toDouble(),
            groups: barGroups,
            rodWidth: 50,
            rodBorderRadius: BorderRadius.circular(4),
          ),


          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
                color: PreferencesProvider.getColor(context, 'alt-primary-color'),
                borderRadius: BorderRadius.circular(12)
            ),

            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,

              children: [

                HeaderText(
                    'Details',
                    textColor: PreferencesProvider.getColor(context, 'placeholder-text-color')
                ),

                const SizedBox(height: 12,),

                //header
                Container(
                  padding: const EdgeInsets.all(8),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: PreferencesProvider.getColor(context, 'primary-color'),
                    borderRadius: BorderRadius.circular(12),
                  ),

                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        flex: 3,
                        child: CustomText(
                          'Stars'
                        ),
                      ),

                      Expanded(
                        child: CustomText(
                          'Count',
                        ),
                      ),

                      Expanded(
                        child: CustomText(
                          'Percentage (%)'
                        ),
                      )
                    ],
                  ),
                ),

                const SizedBox(height: 12,),

                ListView.separated(
                  shrinkWrap: true,
                  itemCount: 5,
                  separatorBuilder: (_, index) => Divider(height: 12),
                  itemBuilder: (_, index){
                    return Row(

                      children: [
                        Expanded(
                          flex: 2,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            spacing: 3,
                            children: [

                              Container(
                                width: 16,
                                height: 16,
                                color: rodColors[index],
                              ),

                              CustomText(
                                lRatingInfo[index].$1.toString(),
                              )
                            ],
                          ),
                        ),


                        Expanded(
                          flex: 1,
                          child: CustomText(
                            lRatingInfo[index].$2.toString(),
                            textAlignment: TextAlign.right,
                          ),
                        ),

                        Expanded(
                          flex: 1,
                          child: CustomText(
                            '${formatDecimal(lRatingInfo[index].$3)}%',
                            textAlignment: TextAlign.right,
                          ),
                        )
                      ],

                    );
                  },
                )
              ],
            ),
          )
        ]
      )
    );
  }



  //todo: card to store the information for the best ClassCourse/Class
  Widget buildBestCourseCard(context, Map<String, dynamic> bestClassMap){
    ClassCourse classCourse = ClassCourse.fromJson(bestClassMap);
    return BestCourseCard(
      classCourse: classCourse
    );
  }


  //todo: card to store the information for the highest rated lecturer.
  Widget buildBestLecturerCard(context, Map<String, dynamic> bestLecturerMap){
    return BestLecturerCard(
      lecturerRatingMap: bestLecturerMap,
    );
  }
}
