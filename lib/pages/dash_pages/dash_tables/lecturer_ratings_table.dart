

import 'package:flutter/material.dart';
import 'package:selc_admin/components/text.dart';
import 'package:selc_admin/components/utils.dart';
import 'package:selc_admin/model/models.dart';
import 'package:selc_admin/providers/pref_provider.dart';


//lecturer ratings table
class LecturerRatingsTable extends StatelessWidget {

  final List<ClassCourse> classCourses;

  const LecturerRatingsTable({super.key, required this.classCourses});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      width: double.infinity,

      decoration: BoxDecoration(
          color: PreferencesProvider.getColor(context, 'table-background-color'),
          borderRadius: BorderRadius.circular(12)
      ),

      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 8,
        children: [

          //todo: table header.
          Container(

            padding: const EdgeInsets.all(8),

            decoration: BoxDecoration(
                color: PreferencesProvider.getColor(context, 'table-header-color'),
                borderRadius: BorderRadius.circular(8)
            ),


            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                Expanded(
                  flex: 2,
                  child: CustomText('Lecturer'),
                ),

                Expanded(
                  flex: 1,
                  child: CustomText('Course Title'),
                ),


                SizedBox(
                  width: 150,
                  child: CustomText('Course Code'),
                ),


                SizedBox(
                  width: 170,
                  child: CustomText('No. of Respondents'),
                ),


                SizedBox(
                  width: 170,
                  child: CustomText('Average rating'),
                ),


                SizedBox(
                    width: 200,
                    child: CustomText('Remarks')
                )

              ],
            ),

          ),



          //todo: table items
          if(classCourses.isEmpty) Expanded(
            child: CollectionPlaceholder(
                title: 'No Data!',
                detail: 'Lecturers ratings for their course taught this semester and academic year appears here'
            ),
          )
          else Expanded(
              child: ListView.builder(
                  itemCount: classCourses.length,
                  itemBuilder: (_, index) => LecturerRatingCell(classCourse: classCourses[index])
              )
          )

        ],
      ),
    );
  }

}





//lecturer ratings cell
class LecturerRatingCell extends StatefulWidget {

  final ClassCourse classCourse;

  const LecturerRatingCell({super.key, required this.classCourse});

  @override
  State<LecturerRatingCell> createState() => _LecturerRatingCellState();
}

class _LecturerRatingCellState extends State<LecturerRatingCell> {

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

                Expanded(
                  flex: 2,
                  child: CustomText(widget.classCourse.lecturer.name),
                ),

                Expanded(
                  flex: 1,
                  child: CustomText(widget.classCourse.course.title),
                ),


                SizedBox(
                  width: 150,
                  child: CustomText(widget.classCourse.course.courseCode),
                ),


                SizedBox(
                  width: 170,
                  child: CustomText(widget.classCourse.evaluatedStudentsCount.toString()),
                ),


                SizedBox(
                  width: 170,
                  child: CustomText(formatDecimal(widget.classCourse.lecturerRating)),
                ),


                SizedBox(
                    width: 200,
                    child: CustomText('Remarks') //remark corresponding the the lecturer's average rating
                )

              ],
            )
        )
    );
  }
}

