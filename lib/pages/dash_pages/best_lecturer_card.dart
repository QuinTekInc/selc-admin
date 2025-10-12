
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:selc_admin/components/button.dart';
import 'package:selc_admin/components/text.dart';
import 'package:selc_admin/providers/pref_provider.dart';





Widget buildField(BuildContext context, {required String title, String value = '', int titleSpan=2, int valueSpan=1}){
  return Row(
    children: [
      Expanded(
        flex: titleSpan,
        child: CustomText(
          title,
          textColor: PreferencesProvider.getColor(context!, 'placeholder-text-color'),
        ),

      ),


      Expanded(
        flex: valueSpan,
        child: CustomText(value),
      )
    ],
  );
}


class BestLecturerCard extends StatelessWidget {

  //todo: this class will require a Custom class to accommodate the required paramters

  BestLecturerCard({super.key});


  @override
  Widget build(BuildContext context) {


    return Container(
      //height: MediaQuery.of(context).size.height * 0.6,
      width: double.infinity,
      padding: const EdgeInsets.all(8),

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

          //top section showing the title
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 5,
            children: [
              Icon(Icons.ac_unit_outlined, size: 25,),

              HeaderText('Best Lecturer')
            ],
          ),


          //show the lecturer's name

          ListTile(
            leading: CircleAvatar(
              radius: 28,
              backgroundColor: Colors.green.shade400,
              child: Icon(CupertinoIcons.person, color: Colors.white),
            ),

            //lecturer name
            title: CustomText('Best Lecturer\'s name appear here.'),

            //lecturer department
            subtitle: CustomText('His/Her department', textColor: PreferencesProvider.getColor(context, 'placeholder-text-color'),),
          ),



          //number of courses taught and his rating summary,
          buildField(context, title: 'No. of Courses', value: '1'),


          //number of students
          buildField(context, title: 'No. Students [Evaluated]', value: '215 [160]'),


          //average rating
          buildField(context, title: 'Average Rating', value: '4.5'),



          //HeaderText('Rating Summary', fontSize: 15,),


          CustomButton.withText(
            'View profile',
            onPressed: (){},
          )

        ],
      ),
    );
  }

}










class BestCourseCard extends StatelessWidget {

  //todo: this widget will require the ClassCourse object to work

  const BestCourseCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      //height: MediaQuery.of(context).size.height * 0.6,
      width: double.infinity,
      padding: const EdgeInsets.all(8),

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

          //top section showing the title
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 5,
            children: [
              Icon(Icons.ac_unit_outlined, size: 25,),

              HeaderText('Best Course')
            ],
          ),


          //show the lecturer's name

          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(12),

              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.green.shade400,
              ),

              child: Icon(CupertinoIcons.book, color: Colors.white,),
            ),

            //lecturer name
            title: CustomText('Best Course\'s title'),

            //lecturer department
            subtitle: CustomText('Course Code', textColor: PreferencesProvider.getColor(context, 'placeholder-text-color'),),
          ),



          //lecturer
          buildField(context, title: 'Lecturer', value: 'Lecturer name appears hear', titleSpan: 1, valueSpan: 2),


          //number of students
          buildField(context, title: 'No. Students [Evaluated]', value: '215 [160]'),

          //response
          buildField(context, title: 'Response rate(%)', value: '65%'),


          //evaluation score rating
          buildField(context, title: 'Evaluation Score [% score]', value: '4.5 [85%]'),

          //Remark
          buildField(context, title: 'Remark', value: 'Excellent'),



          CustomButton.withText(
            'View Evaluation',
            onPressed: (){},
          )

        ],
      ),
    );
  }
}



