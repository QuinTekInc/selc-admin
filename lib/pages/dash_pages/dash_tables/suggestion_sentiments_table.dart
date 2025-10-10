

import 'package:flutter/material.dart';
import 'package:selc_admin/components/text.dart';
import 'package:selc_admin/components/utils.dart';
import 'package:selc_admin/model/models.dart';
import 'package:selc_admin/providers/pref_provider.dart';




class SuggestionSentimentsTable extends StatelessWidget {

  final List<DashboardSuggestionSentiment> sentiments;
  
  const SuggestionSentimentsTable({super.key, required this.sentiments});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(8),

      decoration: BoxDecoration(
        color: PreferencesProvider.getColor(context, 'table-background-color'),
        borderRadius: BorderRadius.circular(12),
      ),

      child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            //todo: table header
            Container(
                padding: const EdgeInsets.all(8),

                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: PreferencesProvider.getColor(context, 'table-header-color')
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    Expanded(
                        flex: 2,
                        child: CustomText('Lecturer')
                    ),

                    Expanded(
                        child: CustomText('Course Title')
                    ),

                    SizedBox(
                        width: 120,
                        child: CustomText('Course Code')
                    ),


                    SizedBox(
                        width: 170,
                        child: CustomText('Negative')
                    ),

                    SizedBox(
                        width: 170,
                        child: CustomText('Neutral')
                    ),


                    SizedBox(
                        width: 170,
                        child: CustomText('Positive')
                    )
                  ],
                )
            ),


            //todo: table items
            //todo: table items
            if(sentiments.isEmpty) Expanded(
              child: CollectionPlaceholder(
                  title: 'No Data!',
                  detail: 'Suggestion sentiments of evaluated courses appear here'
              ),
            )
            else Expanded(
                child: ListView.builder(
                    itemCount: sentiments.length,
                    itemBuilder: (_, index) => SuggestionSentimentCell(sentiment: sentiments[index],)
                )
            )

          ]
      ),
    );
  }
}






class SuggestionSentimentCell extends StatefulWidget {

  final DashboardSuggestionSentiment sentiment;

  const SuggestionSentimentCell({super.key, required this.sentiment});

  @override
  State<SuggestionSentimentCell> createState() => _SuggestionSentimentCellState();
}

class _SuggestionSentimentCellState extends State<SuggestionSentimentCell> {

  Color hoverColor = Colors.transparent;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
        onHover: (mouseEvent) => setState(() => hoverColor = Colors.green.shade300),
        onExit: (mouseEvent) => setState(() => hoverColor = Colors.transparent),

        child: Container(
            padding: const EdgeInsets.all(8),

            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: hoverColor
            ),

            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                //lecturer name
                Expanded(
                  flex: 2,
                  child: CustomText(widget.sentiment.lecturerName),
                ),


                //course title
                Expanded(
                  flex: 1,
                  child: CustomText(widget.sentiment.course.title),
                ),


                //course code
                SizedBox(
                  width: 120,
                  child: CustomText(widget.sentiment.course.courseCode),
                ),


                //
                // SizedBox(
                //   width: 150,
                //   child: CustomText('negative sentiment'),
                // ),
                //
                //
                // SizedBox(
                //   width: 150,
                //   child: CustomText('Netural'),
                // ),
                //
                //
                // SizedBox(
                //     width: 150,
                //     child: CustomText('Positive') //remark corresponding the the lecturer's average rating
                // )


                for(SuggestionSentimentSummary s in widget.sentiment.sentimentSummary) SizedBox(
                  width: 170,
                  child: CustomText('${s.sentimentCount} (${formatDecimal(s.sentimentPercent)} %)'),
                )


              ],
            )
        )
    );
  }
}

