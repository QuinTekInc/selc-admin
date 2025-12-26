
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

  //todo: this class will require a Custom class to accommodate the required paramters

  LecturerRating? lecturerRating;
  bool isLoading;

  BestLecturerCard({super.key, this.isLoading = false});


  @override
  Widget build(BuildContext context) {


    if(Provider.of<SelcProvider>(context).lecturersRatings.isEmpty){

      return Container(
        height: 120,
        width: double.infinity,
        alignment: Alignment.center,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: PreferencesProvider.getColor(context, 'alt-primary-color')
        ),
        child: CircularProgressIndicator(),
      );
    }



    lecturerRating = Provider.of<SelcProvider>(context).lecturersRatings.first;


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


          //number of students who have rated the lecturer this semester
          buildField(
            context,
            title: 'No. Students (in rating)',
            value: inflateValue('${lecturerRating!.numberOfStudents}') //todo: fix this later.
          ),


          //average rating
          buildField(
            context,
            title: 'Average Rating',
            value: inflateValue(formatDecimal(lecturerRating!.parameterRating).toString())
          ),



          //HeaderText('Rating Summary', fontSize: 15,),
          if(lecturerRating != null) CustomButton.withText(
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

  CourseRating? courseRating;
  bool isLoading;

  BestCourseCard({super.key, this.isLoading = false});

  @override
  Widget build(BuildContext context) {


    if(Provider.of<SelcProvider>(context).coursesRatings.isEmpty){
      return Container(
        height: 120,
        width: double.infinity,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: PreferencesProvider.getColor(context, 'alt-primary-color')
        ),
        child: CircularProgressIndicator(),
      );
    }


    courseRating = Provider.of<SelcProvider>(context).coursesRatings.first;

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

              HeaderText('Highest Rated Course')
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
            title: CustomText(inflateValue(courseRating!.course.title)),

            //lecturer department
            subtitle: CustomText(courseRating!.course.courseCode, textColor: PreferencesProvider.getColor(context, 'placeholder-text-color'),),
          ),



          //lecturer
          buildField(
            context,
            title: 'Number of Lecturers',
            value: inflateValue(courseRating!.numberOfLecturers.toString()),
          ),


          //number of students
          buildField(
            context,
            title: 'No. Students [Evaluated]',
            value: inflateValue('${courseRating!.numberOfStudents} [${courseRating!.evaluatedStudents}]')
          ),


          //response
          buildField(
            context,
            title: 'Response rate(%)',
            value: inflateValue('${formatDecimal(courseRating!.calculateResponseRate())} %')
          ),


          //evaluation score rating
          buildField(
            context,
            title: 'Evaluation Score [% score]',
            value: inflateValue(
              '${formatDecimal(courseRating!.parameterMeanScore)} ' //change this.
              '[${formatDecimal(courseRating!.percentageScore)} %]'
            )
          ),

          //Remark
          buildField(
            context,
            title: 'Remark',
            value: inflateValue(courseRating!.remark)
          ),



          if(courseRating != null) CustomButton.withText(
            'View Course Profile',
            disable: isLoading,
            onPressed: () => Provider.of<PageProvider>(context, listen: false).pushPage(
                CourseProfilePage(course: courseRating!.course,), 'Course Profile'),
          )

        ],
      ),
    );
  }



  String inflateValue(String? value){

    if(isLoading) return 'Loading...';

    if(courseRating == null) return 'N/A';

    return value!;
  }
}



