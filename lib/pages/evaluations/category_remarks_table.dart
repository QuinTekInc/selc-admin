
import 'package:flutter/material.dart';
import 'package:selc_admin/components/text.dart';
import 'package:selc_admin/components/utils.dart';
import 'package:selc_admin/model/models.dart';


class CategoryRemarksTable extends StatelessWidget {

  final List<CategoryEvaluation> categoryRemarks;

  const CategoryRemarksTable({
    super.key,
    required this.categoryRemarks,
  });

  @override
  Widget build(BuildContext context) {

    return TableContainer(
      
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,


        children: [

          const SizedBox(height: 8,),

          //todo: category remarks table headers
          TableHeaderContainer(
            headerChildren: [

              Expanded(
                flex: 2,
                child: CustomText(
                  'Question Category',
                  fontWeight: FontWeight.w600,
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
                child: CustomText(
                  'Percentage Score(%)',
                  fontWeight: FontWeight.w600,
                  textAlignment: TextAlign.center,
                ),
              ),


              Expanded(
                flex: 1,
                child: CustomText(
                  'Remarks',
                  fontWeight: FontWeight.w600,
                ),
              )
            ],
          ),
        

          //todo: category remarks table rows.
          Expanded(
            flex: 2,
            child: ListView.separated(
                itemCount: categoryRemarks.length,
                separatorBuilder: (_, index) => Divider(),

                itemBuilder: (_, index) {
                  CategoryEvaluation categoryRemark = categoryRemarks[index];
                  return buildCategoryReportRow(categoryRemark);
                }
            ),
          )
        ],
      ),
    );
  }




  Widget buildCategoryReportRow(CategoryEvaluation categoryRemark){
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



          //todo: average or mean score
          Expanded(
            child: CustomText(
              formatDecimal(categoryRemark.meanScore),
              textAlignment: TextAlign.center,
            ),
          ),

          //todo: percentage score
          Expanded(
            child: CustomText(
              formatDecimal(categoryRemark.percentageScore),
              textAlignment: TextAlign.center,
            )
          ),


          //todo: perform the calculations and put them here.
          Expanded(
            child: CustomText(
              categoryRemark.remark,
            ),
          )
        ],
      ),
    );
  }
}
