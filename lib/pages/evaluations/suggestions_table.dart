
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:selc_admin/components/cells.dart';
import 'package:selc_admin/components/charts/bar_chart.dart';
import 'package:selc_admin/components/utils.dart';
import 'package:selc_admin/model/models.dart';
import 'package:selc_admin/providers/pref_provider.dart';

import '../../components/text.dart';

class SuggestionsTable extends StatelessWidget {

  final SuggestionSummaryReport summaryReport;
  final List<EvalLecturerRatingSummary> lecturerRating;
  final double courseLRating;

  SuggestionsTable({super.key, required this.summaryReport, required this.lecturerRating, required this.courseLRating});

  final sentimentColors = [Colors.red.shade400, Colors.amber, Colors.green.shade400];

  @override
  Widget build(BuildContext context) {


    return Padding(
      padding: const EdgeInsets.all(8),

      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [



          if(summaryReport.suggestions.isEmpty)buildEmptyPlacehoder()
          else Expanded(
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                spacing: 12,
                children: [


                  Row(  
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    spacing: 12,
                    children: [

                      Expanded(  
                        child: CustomBarChart(
                          height: MediaQuery.of(context).size.height * 0.463,
                          leftAxisTitle: 'Frequency',
                          bottomAxisTitle: 'Sentiment',
                          axisNameStyle: TextStyle( 
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w600,
                            color: PreferencesProvider.getColor(context, 'text-color')
                          ),
                          axisLabelStyle: TextStyle( 
                            fontFamily: 'Poppins',
                            color: PreferencesProvider.getColor(context, 'placeholder-text-color')
                          ),

                          groups: List<CustomBarGroup>.generate(  
                            summaryReport.sentimentSummaries.length,
                            (index) {
                              SuggestionSentimentSummary sentimentSummary = summaryReport.sentimentSummaries[index];
                              final rod = Rod(y: sentimentSummary.sentimentCount.toDouble(), rodColor: sentimentColors[index]);
                              return CustomBarGroup(x: index+1, label: sentimentSummary.sentiment, rods: [rod]);
                            }
                          ),

                        ),
                      ),


                      Column(
                        mainAxisSize: MainAxisSize.min,
                        spacing: 12,
                        children: [
                          buildSentimentTable(context),

                          buildRatingsTable(context)
                        ],
                      )

                    ],
                  ),

                  const SizedBox(height: 16,),

                  HeaderText('Sample Suggestions'),
                  
                  FractionallySizedBox(
                    widthFactor: 0.6,
                    child: ListView.separated(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: summaryReport.suggestions.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (_, index) => buildSuggestionCell(context, index),
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      )
    );

  }



  Widget buildSentimentTable(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.35,                
      padding: const EdgeInsets.all(12),
    
      decoration: BoxDecoration(  
        borderRadius: BorderRadius.circular(12),
        color: PreferencesProvider.getColor(context, 'alt-primary-color')
      ),
    
      child: Column(  
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        spacing: 8,
        children: [

          Align(
            alignment: Alignment.centerLeft,
            child: HeaderText('Suggestion Sentiment Summary')
          ),


          const SizedBox(height: 2,),

          for(var sentimentSummary  in summaryReport.sentimentSummaries) FractionallySizedBox(
            widthFactor: 0.6,
            child: Row(  
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
            
            
                Container( 
                  height: 25,
                  width: 25, 
                  decoration: BoxDecoration(  
                    color: sentimentColors[summaryReport.sentimentSummaries.indexOf(sentimentSummary)]
                  ),
                ),
            
                Expanded(
                  flex: 2,
                  child: CustomText(  
                    sentimentSummary.sentiment,
                    fontSize: 15,
                  ),
                ),
            
                Expanded(
                  child: CustomText(  
                    sentimentSummary.sentimentCount.toString(),
                    fontSize: 15,
                  ),
                ),
            
            
                Expanded(
                  child: CustomText(   
                    '${formatDecimal(sentimentSummary.sentimentPercent)} %',
                    fontSize: 15,
                  ),
                )
              ],
            ),
          )

          
        ],
      ),
    
    );
  }






  Widget buildRatingsTable(BuildContext context){
    return Container(  
      width: MediaQuery.of(context).size.width * 0.35,
      padding: const EdgeInsets.all(12),

      decoration: BoxDecoration( 
        color: PreferencesProvider.getColor(context, 'alt-primary-color'),
        borderRadius: BorderRadius.circular(12)
      ),

      child: Column(  
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        spacing: 8,
        children: [

          HeaderText('Lecturer Rating Summary'),

          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                flex: 2,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  spacing: 8,
                  children: List<Widget>.generate(
                    lecturerRating.length, (index){
                              
                      return Row(  
                        children: [
                          Expanded(
                            child: buildStars(lecturerRating[index].rating)
                          ),
                                
                          SizedBox(
                            width: 120,
                            child:  CustomText(
                              '${formatDecimal(lecturerRating[index].percentage)} %',
                              fontSize: 15,
                            ),
                          ),
                                
                          SizedBox(
                            width: 120,
                            child:  CustomText(
                                '${lecturerRating[index].ratingCount}',
                              fontSize: 15,
                            ),
                          )
                        ],
                      );
                    }
                  )
                ), 
              ),

              SizedBox(
                width: 180,  
                child: Column(  
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [

                    Stack(
                        alignment: Alignment.center,
                        children: [
                          Icon(
                            Icons.star_rounded,
                            color: Colors.yellow,
                            size: 170,
                          ),

                          CustomText(
                            formatDecimal(courseLRating),
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

        ],
      ),
    );
  }




  Widget buildSuggestionCell(BuildContext context, int index) {

    EvaluationSuggestion suggestion = summaryReport.suggestions[index];

    return Container(
      padding: const EdgeInsets.all(12),

      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.45,
        minWidth: MediaQuery.of(context).size.width * 0.45
      ),

      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: PreferencesProvider.getColor(context, 'primary-color')
      ),

      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [

          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            spacing: 12,
            children: [

              CircleAvatar(
                backgroundColor: Colors.green.shade300,
                radius: 20,
                child: Icon(CupertinoIcons.person, color: Colors.white)
              ),

              RatingStars(
                rating: suggestion.rating,
                transparentBackground: true,
                zeroPadding: true,
                spacing: 1,
              ),

              CustomText('(${formatDecimal(suggestion.rating)})', fontWeight: FontWeight.w600,)
            ],
          ),

          const Divider(),

          CustomText(
            suggestion.suggestion
          )
        ],
      ),

    );
  }
  



  Widget buildStars(int n) => Row(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.center,
    mainAxisAlignment: MainAxisAlignment.start,
    spacing: 3,
    children: List<Widget>.generate(
      n,
      (index) => Icon(Icons.star_rounded, color: Colors.amber, size: 28,)
    )
  );



  Widget buildEmptyPlacehoder() {
    return Expanded(
      child: CollectionPlaceholder(
        detail: 'All students\' suggestions appear here.'
      ),
    );
  }
}

