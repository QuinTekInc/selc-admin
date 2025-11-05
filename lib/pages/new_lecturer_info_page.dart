
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:selc_admin/components/alert_dialog.dart';
import 'package:selc_admin/components/button.dart';
import 'package:selc_admin/components/cells.dart';
import 'package:selc_admin/components/text.dart';
import 'package:selc_admin/components/utils.dart';
import 'package:selc_admin/model/models.dart';
import 'package:selc_admin/pages/evaluations/eval_page.dart';
import 'package:selc_admin/providers/page_provider.dart';
import 'package:selc_admin/providers/pref_provider.dart';

import '../providers/selc_provider.dart';
import 'lecturer_info_page.dart';



class NewLecturerInfoPage extends StatefulWidget {

  final Lecturer lecturer;

  const NewLecturerInfoPage({super.key, required this.lecturer});

  @override
  State<NewLecturerInfoPage> createState() => _NewLecturerInfoPageState();
}

class _NewLecturerInfoPageState extends State<NewLecturerInfoPage> {

  late List<dynamic> detailFields;

  List<ClassCourse> lecturerClassCourses = [];
  List<ClassCourse> currentClassCourses = [];

  List<dynamic> yearlyLecturerRatingSummary = [];

  dynamic ratingSummary;


  bool isLoading = false;

  @override
  void initState() {
    // TODO: implement initState

    detailFields = [
      ('Department', widget.lecturer.department, CupertinoIcons.home),
      ('Email', widget.lecturer.email, CupertinoIcons.at),
      ('Average Rating', formatDecimal(widget.lecturer.rating), Icons.star),
    ];


    loadData();


    super.initState();
  }


  void loadData() async {

    setState(() => isLoading = true);

    try{

      //get the yearly lecturer rating summary
      yearlyLecturerRatingSummary  = await Provider.of<SelcProvider>(context, listen: false)
          .getYearlyLecturerRatingSummary(widget.lecturer.username);

      ratingSummary = await Provider.of<SelcProvider>(context, listen: false)
          .getOverallLecturerRatingSummary(widget.lecturer.username);

      lecturerClassCourses = await Provider.of<SelcProvider>(context, listen: false).getLecturerInfo(widget.lecturer.username);

      currentClassCourses = lecturerClassCourses.where((classCourse) => classCourse.year == DateTime.now().year).toList();

    } on SocketException catch(_){
      showNoConnectionAlertDialog(context);

    }on Error catch (err, stackTrace){
      debugPrint(err.toString());
      debugPrint(stackTrace.toString());

      showCustomAlertDialog(
          context,
          title: 'Error',
          contentText: 'An unexepected Error occurred.'
      );
    }on Exception catch (e){
      showCustomAlertDialog(
          context,
          title: 'Error',
          contentText: e.toString()
      );
    }

    setState(() =>isLoading = false);

  }



  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [

          HeaderText('${widget.lecturer.username}\'s Profile', fontSize: 25,),

          NavigationTextButtons(),

          Expanded(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 12,

                children: [

                  const SizedBox(height: 4,),

                  buildLectureNameSection(),


                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 12,

                    children: [

                      buildAdditionInfoSection(),

                      Expanded(
                        child: buildRatingDetailSection()
                      ),

                    ],
                  ),



                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 12,

                    children: [

                      buildCurrentCourseSection(),

                      Expanded(
                        flex: 2,
                        child: buildCummulativeCourseTable(),
                      )

                    ],
                  ),




                ],
              ),
            ),
          )

        ],
      ),
    );
  }



  Widget buildLectureNameSection() => Container(
    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
    decoration: BoxDecoration(
      color: PreferencesProvider.getColor(context, 'alt-primary-color'),
      borderRadius: BorderRadius.circular(12)
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      spacing: 12,
      children: [

        CircleAvatar(
          backgroundColor: Colors.green.shade400,
          radius: 35,
          child: Icon(Icons.person, size: 50, color: Colors.white,),
        ),


        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 3,
          children: [
            HeaderText(widget.lecturer.name),
            CustomText('@${widget.lecturer.username}', padding: EdgeInsets.zero,),
          ],
        )

      ],

    ),
  );





  Widget buildAdditionInfoSection() {


    if(isLoading){
      try{
        detailFields.removeRange(3, detailFields.length - 1);
      }on RangeError catch(_){
        //todo: do nothing here.
      }
    }else{
      detailFields.add(
          ('Total Courses [This Semester]',  lecturerClassCourses.isEmpty ? 0 : '${lecturerClassCourses.length} [${currentClassCourses.length}]', CupertinoIcons.book));
    }


    return Container(
      width: MediaQuery.of(context).size.width * 0.4,
      padding: const EdgeInsets.all(12),

      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: PreferencesProvider.getColor(context, 'alt-primary-color')
      ),

      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          HeaderText('Additional Information'),

          const SizedBox(height: 12,),


          GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 8,
              mainAxisExtent: 70
            ),
            physics: NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: detailFields.length,
            itemBuilder: (_, index) {

              String title = detailFields[index].$1;
              dynamic detail = detailFields[index].$2;
              IconData  icon = detailFields[index].$3;


              if(detail.runtimeType == (1.5).runtimeType){
                detail = formatDecimal(detail);
              }else if(detail.runtimeType == (1).runtimeType){
                detail = detail.toString();
              }

              return Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),

                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: PreferencesProvider.getColor(context, 'alt-primary-color-2')
                ),


                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 12,
                  children: [

                    CircleAvatar(
                      backgroundColor: PreferencesProvider.getColor(context, 'alt-primary-color'),
                      radius: 35,
                      child: Icon(icon, color: Colors.green.shade400, size: 30,)
                    ),

                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        spacing: 5,
                        children: [
                          CustomText(title, fontWeight: FontWeight.w600, fontStyle: FontStyle.italic, maxLines: 1,),


                          CustomText(detail),
                        ],
                      ),
                    ),
                  ]
                )
              );
            }
          )

        ],
      ),
    );
  }



  Widget buildRatingDetailSection(){


    return Container(
      width: double.infinity,
      height: 280,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: PreferencesProvider.getColor(context, 'alt-primary-color-2'),
        borderRadius: BorderRadius.circular(12)
      ),

      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          HeaderText('Overall Rating Summary')
        ],

      )
    );
  }



  Widget buildCurrentCourseSection(){

    return Container(
      width: MediaQuery.of(context).size.width * 0.3,
      height: MediaQuery.of(context).size.height * 0.5,

      padding: const EdgeInsets.all(12),

      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: PreferencesProvider.getColor(context, 'table-background-color')
      ),


      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 12,

        children: [

          HeaderText('Current Class Courses'),
          
          if(currentClassCourses.isEmpty) Expanded(
            child: CollectionPlaceholder(detail: 'All current courses this lecturer appear here.'),
          )
          else Expanded(
            child: ListView.builder(
              itemCount: currentClassCourses.length,

              itemBuilder: (_, index){

                ClassCourse classCourse = currentClassCourses[index];

                return ListTile(
                  hoverColor: Colors.green.shade300,
                  onTap: () => Provider.of<PageProvider>(context, listen: false).pushPage(EvaluationPage(classCourse: classCourse), 'Evaluation'),
                  leading: Container(
                    height: 50,
                    width: 50,
                    color: Colors.green.shade300,
                    child: Icon(CupertinoIcons.book, color: Colors.white,),
                  ),

                  title: CustomText(
                    '${classCourse.course.title}[${classCourse.course.courseCode}]',
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    maxLines: 1,
                  ),
                  subtitle: CustomText('Students [Evaluated]: ${classCourse.registeredStudentsCount} [${classCourse.evaluatedStudentsCount}]'),
                );
              }
            ),
          )


        ],
      )
    );
  }




  Widget buildCummulativeCourseTable(){

    return Container(
      padding: const EdgeInsets.all(8),
      width: double.infinity,
      height: MediaQuery.of(context).size.height * 0.5,


      constraints: BoxConstraints(
          minHeight: MediaQuery.of(context).size.height * 0.4
      ),

      decoration: BoxDecoration(
          color: PreferencesProvider.getColor(context, 'table-background-color'),
          borderRadius: BorderRadius.circular(12)
      ),

      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          HeaderText(
            'Cummulative Courses',
            fontWeight: FontWeight.w600,
          ),


          const SizedBox(height: 8,),

          //todo: table headers.
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(8),


            decoration: BoxDecoration(
                color: PreferencesProvider.getColor(context, 'alt-primary-color'),
                borderRadius: BorderRadius.circular(12)
            ),

            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,

              children: [

                SizedBox(
                    width: 120,
                    child: CustomText(
                      'Year',
                    )
                ),

                const SizedBox(
                    width: 100,
                    child: CustomText(
                      'Semester',
                    )
                ),


                Expanded(
                    child: CustomText(
                      'Course Code',
                    )
                ),


                Expanded(
                    flex: 2,
                    child: CustomText(
                        'Course Title'
                    )
                ),


                SizedBox(
                    width: 120,
                    child: CustomText('Reg. Students')
                ),



                SizedBox(
                    width: 120,
                    child: CustomText('Score')
                ),


                SizedBox(
                    width: 120,
                    child: CustomText('Remarks')
                ),

              ],
            ),
          ),



          if(lecturerClassCourses.isEmpty) Expanded(
            child: CollectionPlaceholder(
              detail: 'All Courses handled by the lecturer appear here.',
            ),
          )
          else Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: List<Widget>.generate(
                lecturerClassCourses.length,
                (int index) => LCummulativeCourseCell(classCourse: lecturerClassCourses[index])
            ),
          )

        ],
      ),
    );
  }

}







