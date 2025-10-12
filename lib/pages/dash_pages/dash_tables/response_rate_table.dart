
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:selc_admin/components/text.dart';
import 'package:selc_admin/components/utils.dart';
import 'package:selc_admin/model/models.dart';
import 'package:selc_admin/providers/pref_provider.dart';




class ResponseRateTable extends StatelessWidget {

  final List<ClassCourse> classCourses;

  const ResponseRateTable({super.key, required this.classCourses});

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
                  width: 150,
                  child: CustomText('No. of Students'),
                ),


                SizedBox(
                  width: 170,
                  child: CustomText('No. of Respondents'),
                ),


                SizedBox(
                    width: 170,
                    child: CustomText('Response Rate(%)')
                )

              ],
            ),

          ),



          //todo: table items
          if(classCourses.isEmpty)Expanded(
            child: CollectionPlaceholder(
                title: 'No Data!',
                detail: 'Courses and their response rates appear here.'
            ),
          )
          else Expanded(
            child: ListView.builder(
                itemCount: classCourses.length,
                itemBuilder: (_, index) => ResponseRateCell(classCourse: classCourses[index])
            ),
          )

        ],
      ),
    );
  }
}








class ResponseRateCell extends StatefulWidget {

  final ClassCourse classCourse;

  const ResponseRateCell({super.key, required this.classCourse});

  @override
  State<ResponseRateCell> createState() => _ResponseRateCellState();
}

class _ResponseRateCellState extends State<ResponseRateCell> {

  Color hoverColor = Colors.transparent;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
        onHover: (mouseEvent) => setState(() => hoverColor = Colors.green.shade300),
        onExit: (mouseEvent) => setState(() => hoverColor = Colors.transparent),

        child: Container(
          padding: const EdgeInsets.all(8),

          decoration: BoxDecoration(
              color: hoverColor,
              borderRadius: BorderRadius.circular(12)
          ),

          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [

              //lecturer name
              Expanded(
                flex: 2,
                child: CustomText(widget.classCourse.lecturer.name),
              ),

              //course title
              Expanded(
                child: CustomText(widget.classCourse.course.title),
              ),

              //course code
              SizedBox(
                width: 150,
                child: CustomText(widget.classCourse.course.courseCode),
              ),


              //number of students
              SizedBox(
                width: 150,
                child: CustomText(widget.classCourse.registeredStudentsCount.toString()),
              ),



              //number of respondents
              SizedBox(
                width: 170,
                child: CustomText(widget.classCourse.evaluatedStudentsCount.toString()),
              ),


              //response rate(%)
              SizedBox(
                width: 170,
                child: CustomText(formatDecimal(widget.classCourse.calculateResponseRate())),
              )

            ],
          ),
        )
    );
  }
}

