

import 'package:flutter/material.dart';
import 'package:selc_admin/components/text.dart';
import 'package:selc_admin/components/utils.dart';
import 'package:selc_admin/model/models.dart';
import 'package:selc_admin/providers/pref_provider.dart';



//category summary
class CoursePerformanceTable extends StatelessWidget {

  final List<ClassCourse> classCourses;

  const CoursePerformanceTable({super.key, required this.classCourses});

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
                    width: 150,
                    child: CustomText('Evaluation Score')
                ),

                SizedBox(
                    width: 175,
                    child: CustomText('Percentage (%)')
                ),


                SizedBox(
                    width: 200,
                    child: CustomText('Remark')
                )
              ],
            )
          ),


          //todo: table items
          //todo: table items
          if(classCourses.isEmpty) Expanded(
            child: CollectionPlaceholder(
                title: 'No Data!',
                detail: 'Course performances appear here.'
            ),
          )
          else Expanded(
              child: ListView.builder(
                  itemCount: classCourses.length,
                  itemBuilder: (_, index) => CoursePerformanceCell(classCourse: classCourses[index])
              )
          )

        ]
      ),
    );
  }
}



//lecturer ratings cell
class CoursePerformanceCell extends StatefulWidget {

  final ClassCourse classCourse;

  const CoursePerformanceCell({super.key, required this.classCourse});

  @override
  State<CoursePerformanceCell> createState() => _CoursePerformanceCellState();
}

class _CoursePerformanceCellState extends State<CoursePerformanceCell> {

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
              child: CustomText(widget.classCourse.lecturer.name),
            ),


            //course title
            Expanded(
              flex: 1,
              child: CustomText(widget.classCourse.course.title),
            ),


            //course code
            SizedBox(
              width: 120,
              child: CustomText(widget.classCourse.course.courseCode),
            ),


            //
            SizedBox(
              width: 150,
              child: CustomText(formatDecimal(widget.classCourse.grandMeanScore)),
            ),


            SizedBox(
              width: 170,
              child: CustomText(formatDecimal(widget.classCourse.grandPercentageScore)),
            ),


            SizedBox(
                width: 200,
                child: CustomText(widget.classCourse.remark!) //remark corresponding the the lecturer's average rating
            )

          ],
        )
      )
    );
  }
}
