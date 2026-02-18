
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:selc_admin/components/button.dart';
import 'package:selc_admin/components/text.dart';
import 'package:selc_admin/components/utils.dart';
import 'package:selc_admin/model/models.dart';
import 'package:selc_admin/pages/course_profile_page.dart';
import 'package:selc_admin/pages/evaluations/eval_page.dart';
import 'package:selc_admin/pages/lecturer_management/lecturer_info_page.dart';
import 'package:selc_admin/providers/page_provider.dart';
import 'package:selc_admin/providers/pref_provider.dart';
import 'package:selc_admin/providers/selc_provider.dart';





Widget buildField(BuildContext context, {required String title, String value = '', int titleSpan=2, int valueSpan=1}){
  return Row(
    children: [
      Expanded(
        flex: titleSpan,
        child: CustomText(
          title,
          textColor: PreferencesProvider.getColor(context, 'placeholder-text-color'),
          fontWeight: FontWeight.w600,
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

  final Map<String, dynamic> lecturerRatingMap;

  const BestLecturerCard({super.key, required this.lecturerRatingMap});


  @override
  Widget build(BuildContext context) {

    final lecturerName = lecturerRatingMap['lecturer_name'];
    final departmentName = lecturerRatingMap['department'];
    final numberOfCourses = lecturerRatingMap['number_of_courses'];
    final studentsCount = lecturerRatingMap['students_count'];
    final lecturerRating = lecturerRatingMap['rating'];


    return Container(
      //height: MediaQuery.of(context).size.height * 0.6,
      width: 500,
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

              HeaderText('Highest Rated Lecturer')
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
            title: CustomText(lecturerName),

            //lecturer department
            subtitle: CustomText(
              'Department of $departmentName',
              textColor: PreferencesProvider.getColor(context, 'placeholder-text-color'),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),



          //number of courses taught and his rating summary,
          buildField(
            context,
            title: 'No. of Courses',
            value: numberOfCourses.toString()
          ),


          //number of students who have rated the lecturer this semester
          buildField(
            context,
            title: 'No. Students (in rating)',
            value: studentsCount.toString() //todo: fix this later.
          ),


          //average rating
          buildField(
            context,
            title: 'Average Rating',
            value: formatDecimal(lecturerRating)
          ),



          //HeaderText('Rating Summary', fontSize: 15,),
          CustomButton.withText(
            'View profile',
            onPressed: () => Provider.of<PageProvider>(context, listen: false).pushPage(LecturerInfoPage(lecturer: lecturerRating!.lecturer), 'Lecturer Info'),
          )

        ],
      ),
    );
  }

}





//best course card.
class BestCourseCard extends StatelessWidget {

  final ClassCourse classCourse;

  const BestCourseCard({super.key,  required this.classCourse});

  @override
  Widget build(BuildContext context) {

    return Container(
      //height: MediaQuery.of(context).size.height * 0.6,
      width: 500,
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

              HeaderText('Highest Rated Course'),

              Spacer(),


              TextButton(
                child: CustomText(
                  'View Evaluation',
                  textColor: Colors.green.shade400,
                ),
                onPressed: () => Provider.of<PageProvider>(context, listen: false).pushPage(
                  EvaluationPage(classCourse: classCourse),
                  "Evaluation"
                ),
              )


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
            title: CustomText(classCourse.course.title),

            //lecturer department
            subtitle: CustomText(classCourse.course.courseCode, textColor: PreferencesProvider.getColor(context, 'placeholder-text-color'),),
          ),



          //lecturer
          buildField(
            context,
            title: 'Lecturer',
            value: classCourse.lecturer.name,
            titleSpan: 1,
            valueSpan: 2
          ),


          //number of students
          buildField(
            context,
            title: 'Students[Evaluated]',
            value: '${classCourse.registeredStudentsCount} [${classCourse.evaluatedStudentsCount}]'
          ),


          //response
          buildField(
            context,
            title: 'Response rate(%)',
            value: '${formatDecimal(classCourse.calculateResponseRate())} %'
          ),


          //evaluation score rating
          buildField(
            context,
            title: 'Score [% score]',
            value: '${formatDecimal(classCourse.grandMeanScore)} ' //change this.
              '[${formatDecimal(classCourse.grandPercentageScore)} %]'
          ),

          //Remark
          buildField(
            context,
            title: 'Remark',
            value: classCourse.remark!
          ),

        ],
      ),
    );
  }

}



