
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:selc_admin/components/cells.dart';
import 'package:selc_admin/components/utils.dart';
import 'package:selc_admin/model/models.dart';
import 'package:selc_admin/providers/pref_provider.dart';

import '../../components/text.dart';

class SuggestionsTable extends StatelessWidget {

  final List<EvaluationSuggestion> suggestions;

  const SuggestionsTable({super.key, required this.suggestions});

  @override
  Widget build(BuildContext context) {

    return Container(
      padding: const EdgeInsets.all(8),
      width: double.infinity,

      decoration: BoxDecoration(
          color: PreferencesProvider.getColor(context, 'table-background-color'),
          borderRadius: BorderRadius.circular(12)
      ),



      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [

          HeaderText(
            'Evaluation suggestions',
            fontSize: 18,
          ),

          const SizedBox(height: 8),


          if(suggestions.isEmpty)Expanded(
            child: CollectionPlaceholder(
              detail: 'All students\' suggestions appear here.'
            ),
          )
          else Expanded(
            child: ListView.separated(
              itemCount: suggestions.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),

              itemBuilder: (_, index) => Container(
                padding: const EdgeInsets.all(8),

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
                      children: [

                        CircleAvatar(
                            backgroundColor: Colors.green.shade300,
                            radius: 20,
                            child: Icon(CupertinoIcons.person, color: Colors.white)
                        ),

                        const SizedBox(width: 12,),

                        RatingStars(
                          rating: suggestions[index].rating,
                          transparentBackground: true,
                          zeroPadding: true,
                          spacing: 1,
                        ),

                        const SizedBox(width: 8,),

                        CustomText('(${formatDecimal(suggestions[index].rating)})', fontWeight: FontWeight.w600,)
                      ],
                    ),

                    const Divider(),

                    CustomText(
                        suggestions[index].suggestion
                    )
                  ],
                ),

              ),
            ),
          )
        ],
      )
    );

  }
}

