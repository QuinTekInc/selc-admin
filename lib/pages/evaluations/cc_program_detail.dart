
import 'package:flutter/material.dart';
import 'package:selc_admin/components/text.dart';
import 'package:selc_admin/components/utils.dart';
import 'package:selc_admin/model/models.dart';


class CCProgramDetailSection extends StatelessWidget {

  final List<CCProgramInfo> programDetail;

  const CCProgramDetailSection({super.key, required this.programDetail});

  @override
  Widget build(BuildContext context) {
    return TableContainer(
      child: Column(  
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        
        children: [

          //todo: table header
          TableHeaderContainer(  
            headerChildren: [
              Expanded(  
                flex: 2,
                child: CustomText(  
                  'Program'
                ),
              ), 

              SizedBox(  
                width: 120,
                child: CustomText(  
                  'Reg. Students'
                ),
              ), 

              SizedBox(  
                width: 120,
                child: CustomText(  
                  'Eval. Students'
                ),
              ),

              SizedBox(  
                width: 140,
                child: CustomText(
                  'Response Rate(%)'
                ),
              ),


              SizedBox(  
                width: 120,
                child: CustomText(  
                  'Mean Score'
                ),
              ), 

              SizedBox(  
                width: 140,
                child: CustomText(  
                  'Percentage'
                ),
              ),

              Expanded(  
                child: CustomText(
                  'Remark'
                ),
              ),


              Expanded(  
                child: CustomText(  
                  'Lecturer Rating'
                ),
              )
            ],
          ),



          //todo: table items/rows
          if(programDetail.isEmpty) Expanded(  
            child: CollectionPlaceholder(  
              title: 'No Data',
              detail: 'Data about individual programs in this class course appear here'
            )
          )
          else Expanded(  
            child: ListView.separated(  
              itemCount: programDetail.length,
              separatorBuilder: (_, __) => Divider(),
              itemBuilder: (_, index) => buildInfoRow(programDetail[index]),
            ),
          )

        ]
      ),
    );
  }





  Widget buildInfoRow(CCProgramInfo programInfo) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(  
        children: [
          Expanded(  
            flex: 2,
            child: CustomText(  
              programInfo.program
            ),
          ), 
      
          SizedBox(  
            width: 120,
            child: CustomText(  
              programInfo.registeredStudentsCount.toString()
            ),
          ), 
      
          SizedBox(  
            width: 120,
            child: CustomText(  
              programInfo.evaluatedStudentsCount.toString()
            ),
          ),
      
          SizedBox(  
            width: 140,
            child: CustomText(
              '${formatDecimal(programInfo.responseRate)} %'
            ),
          ),
      
      
      
      
          SizedBox(  
            width: 120,
            child: CustomText(  
              formatDecimal(programInfo.meanScore)
            ),
          ), 
      
          SizedBox(  
            width: 140,
            child: CustomText(  
              '${formatDecimal(programInfo.percentageScore)} %'
            ),
          ),
      
          Expanded(  
            child: CustomText(
              programInfo.remark
            ),
          ),
      
      
          Expanded(  
            child: CustomText(  
              formatDecimal(programInfo.lecturerRating)
            ),
          )
        ]
      ),
    );

  }
}