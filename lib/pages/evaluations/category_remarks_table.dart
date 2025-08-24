
import 'package:flutter/material.dart';
import 'package:selc_admin/components/text.dart';
import 'package:selc_admin/model/models.dart';


class CategoryRemarksTable extends StatelessWidget {

  final List<CategoryRemark> categoryRemarks;

  const CategoryRemarksTable({super.key, required this.categoryRemarks});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      width: double.infinity,
      height: double.infinity,

      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.grey.shade200
      ),

      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,


        children: [

          HeaderText(
              'Category Remarks',
              fontSize: 15
          ),


          const SizedBox(height: 8,),

          //todo: category remarks table headers
          Container(
            padding: const EdgeInsets.all(8),
            width: double.infinity,

            decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(12)
            ),

            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,

              children: [

                Expanded(
                  flex: 2,
                  child: CustomText(
                    'Question Category',
                    fontWeight: FontWeight.w600,
                  ),
                ),


                Expanded(
                  child: CustomText(
                    'Percentage Score(%)',
                    fontWeight: FontWeight.w600,
                    textAlignment: TextAlign.center,
                  ),
                ),



                Expanded(
                  child: CustomText(
                    'Avg. Score',
                    fontWeight: FontWeight.w600,
                    textAlignment: TextAlign.center,
                  ),
                ),


                Expanded(
                  flex: 1,
                  child: CustomText(
                    'Remarks',
                    fontWeight: FontWeight.w600,
                    textAlignment: TextAlign.center,
                  ),
                )
              ],
            ),
          ),


          //todo: category remarks table rows.
          Expanded(
            flex: 2,
            child: ListView.separated(
                itemCount: categoryRemarks.length,
                separatorBuilder: (_, index) => Divider(),

                itemBuilder: (_, index) {
                  CategoryRemark categoryRemark = categoryRemarks[index];
                  return buildCategoryReportRow(categoryRemark);
                }
            ),
          )
        ],
      ),
    );
  }




  Widget buildCategoryReportRow(CategoryRemark categoryRemark){
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [

          Expanded(
            flex: 2,
            child: CustomText(
                categoryRemark.categoryName
            ),
          ),


          Expanded(
            child: CustomText(
              categoryRemark.percentageScore.toString(),
              textAlignment: TextAlign.center,
            )
          ),


          Expanded(
            child: CustomText(
              categoryRemark.averageScore.toString(),
              textAlignment: TextAlign.center,
            ),
          ),


          //todo: perform the calculations and put them here.
          Expanded(
            child: CustomText(
              categoryRemark.remark,
              textAlignment: TextAlign.center,
            ),
          )
        ],
      ),
    );
  }
}
