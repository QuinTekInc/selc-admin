
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:selc_admin/components/button.dart';
import 'package:selc_admin/components/text.dart';
import 'package:selc_admin/components/utils.dart';
import 'package:selc_admin/model/models.dart';
import 'package:selc_admin/pages/evaluations/eval_page.dart';
import 'package:selc_admin/pages/lecturer_info_page.dart';
import 'package:selc_admin/providers/page_provider.dart';
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

  LecturerRating? lecturerRating;
  bool isLoading;

  BestLecturerCard({super.key, required this.lecturerRating, this.isLoading = false});


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
            title: CustomText(
                inflateValue(lecturerRating!.lecturer.name)
            ),

            //lecturer department
            subtitle: CustomText(
              inflateValue(lecturerRating!.lecturer.department),
              textColor: PreferencesProvider.getColor(context, 'placeholder-text-color'),
            ),
          ),



          //number of courses taught and his rating summary,
          buildField(
            context,
            title: 'No. of Courses',
            value: inflateValue(lecturerRating!.numberOfCourses.toString())
          ),


          //number of students
          buildField(
            context,
            title: 'No. Students [Evaluated]',
            value: inflateValue('${lecturerRating!.numberOfStudents} [N/A]') //todo: fix this later.
          ),


          //average rating
          buildField(
            context,
            title: 'Average Rating',
            value: inflateValue(formatDecimal(lecturerRating!.parameterRating).toString())
          ),



          //HeaderText('Rating Summary', fontSize: 15,),


          if(lecturerRating != null)CustomButton.withText(
            'View profile',
            disable: isLoading,
            onPressed: () => Provider.of<PageProvider>(context, listen: false).pushPage(LecturerInfoPage(lecturer: lecturerRating!.lecturer), 'Lecturer Info'),
          )

        ],
      ),
    );
  }



  String inflateValue(String? value){

    if(isLoading) return 'Loading...';

    if(lecturerRating == null) return 'N/A';

    return value!;
  }


}










class BestCourseCard extends StatelessWidget {

  //todo: this widget will require the ClassCourse object to work

  ClassCourse? classCourse;
  bool isLoading;

  BestCourseCard({super.key, this.classCourse, this.isLoading = false});

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
            title: CustomText(inflateValue(classCourse!.course.title)),

            //lecturer department
            subtitle: CustomText(classCourse!.course.courseCode, textColor: PreferencesProvider.getColor(context, 'placeholder-text-color'),),
          ),



          //lecturer
          buildField(
            context,
            title: 'Lecturer',
            value: classCourse!.lecturer.name,
            titleSpan: 1,
            valueSpan: 2
          ),


          //number of students
          buildField(
            context,
            title: 'No. Students [Evaluated]',
            value: inflateValue('${classCourse!.registeredStudentsCount} [${classCourse!.evaluatedStudentsCount}]')
          ),


          //response
          buildField(
            context,
            title: 'Response rate(%)',
            value: inflateValue('${formatDecimal(classCourse!.calculateResponseRate())} %')
          ),


          //evaluation score rating
          buildField(
            context,
            title: 'Evaluation Score [% score]',
            value: inflateValue(
              '${formatDecimal(classCourse!.grandMeanScore)} '
              '[${formatDecimal(classCourse!.grandPercentageScore)} %]'
            )
          ),

          //Remark
          buildField(
            context,
            title: 'Remark',
            value: inflateValue(classCourse!.remark!)
          ),



          if(classCourse != null) CustomButton.withText(
            'View Evaluation',
            disable: isLoading,
            onPressed: () => Provider.of<PageProvider>(context, listen: false).pushPage(
                EvaluationPage(classCourse: classCourse!), 'Course Evaluation'),
          )

        ],
      ),
    );
  }



  String inflateValue(String? value){

    if(isLoading) return 'Loading...';

    if(classCourse == null) return 'N/A';

    return value!;
  }
}



