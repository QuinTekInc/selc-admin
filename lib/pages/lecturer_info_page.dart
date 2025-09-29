


import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:selc_admin/components/alert_dialog.dart';
import 'package:selc_admin/components/button.dart';
import 'package:selc_admin/components/cells.dart';
import 'package:selc_admin/components/charts/bar_chart.dart';
import 'package:selc_admin/components/charts/line_chart.dart';
import 'package:selc_admin/components/text.dart';
import 'package:selc_admin/components/utils.dart' show formatDecimal;
import 'package:selc_admin/model/models.dart';
import 'package:selc_admin/pages/evaluations/eval_page.dart';
import 'package:selc_admin/providers/page_provider.dart';
import 'package:selc_admin/providers/pref_provider.dart';
import 'package:selc_admin/providers/selc_provider.dart';


class LecturerInfoPage extends StatefulWidget {

  final Lecturer lecturer;

  const LecturerInfoPage({super.key, required this.lecturer});

  @override
  State<LecturerInfoPage> createState() => _LecturerInfoPageState();
}

class _LecturerInfoPageState extends State<LecturerInfoPage> {

  List<ClassCourse> cummulativeClassCourses = [];
  List<ClassCourse> currentClassCourses = [];
  List<EvalLecturerRatingSummary> ratingSummary = [];

  List<dynamic> yearlyLecturerRatingSummary = [];

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    loadData();
  }



  void loadData() async {

    setState(() => isLoading = true);

    try{

      //get the yearly lecturer rating summary
      yearlyLecturerRatingSummary  = await Provider.of<SelcProvider>(context, listen: false)
                          .getYearlyLecturerRatingSummary(widget.lecturer.username);

      ratingSummary = await Provider.of<SelcProvider>(context, listen: false)
                          .getOverallLecturerRatingSummary(widget.lecturer.username);

      cummulativeClassCourses = await Provider.of<SelcProvider>(context, listen: false).getLecturerInfo(widget.lecturer.username);

      currentClassCourses = cummulativeClassCourses.where((classCourse) => classCourse.year == DateTime.now().year).toList();
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
        mainAxisSize: MainAxisSize.min,


        children: [

          HeaderText(
            '${widget.lecturer.name}\'s profile',
            fontSize: 25,
          ),

          //todo: navigator buttons.
          NavigationTextButtons(),


          const SizedBox(height: 8,),

          Expanded(

            child: Row(

              crossAxisAlignment: CrossAxisAlignment.start,

              children: [

                //todo: top banner displaying the lectuer's name, email and department.
                buildLecturerInfoSection(),


                const SizedBox(width: 12),


                if(isLoading) Expanded(
                  child: Container(
                    alignment: Alignment.center,
                    margin: EdgeInsets.symmetric(vertical: 150),
                    child: CircularProgressIndicator(),
                  ),
                )
                else if(!isLoading && cummulativeClassCourses.isEmpty) buildNoInfoPlaceholder()

                else Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      spacing: 12,

                      children: [


                        //lecturer yearly average rating line chart
                        CustomLineChart(
                          chartTitle: 'Yearly Average Rating trend',
                          width: double.infinity,
                          leftAxisTitle: 'Rating',
                          bottomAxisitle: 'Years',
                          maxY: 5,
                          titleStyle: TextStyle( 
                            color: PreferencesProvider.getColor(context, 'text-color'),
                            fontWeight: FontWeight.bold,
                            fontSize: 17,
                            fontFamily: 'Poppins'
                          ),
                          axisLabelStyle: TextStyle(
                            color: PreferencesProvider.getColor(context,'placeholder-text-color'),
                            fontFamily: 'Poppins',
                          ),
                          axisNameStyle: TextStyle(  
                            color: PreferencesProvider.getColor(context,'text-color'),
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w600
                          ),


                          spotData: List<CustomLineChartSpotData>.generate(
                            yearlyLecturerRatingSummary.length, 
                            (index) => CustomLineChartSpotData(
                              x: (index).toDouble(), 
                              label: yearlyLecturerRatingSummary[index].$1.toString(),
                              y: yearlyLecturerRatingSummary[index].$2,
                            )
                          ),
                        ),


                        //todo: lecturer ratings bar chart
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          spacing: 12,
                          children: [


                            Expanded(
                              flex: 2,
                              child: CustomBarChart(
                                containerBackgroundColor: PreferencesProvider.getColor(context, 'alt-primary-color'),
                                width: double.infinity,
                                chartTitle: 'Overall Rating Summary',
                                leftAxisTitle: 'Frequency(number of students)',
                                bottomAxisTitle: 'Stars',
                                groups: List<CustomBarGroup>.generate(  
                                  ratingSummary.length,
                                  (int index) => CustomBarGroup(
                                    x: index,
                                    label: ratingSummary[index].rating.toString(),
                                    rods: [
                                      Rod(
                                        y: ratingSummary[index].ratingCount.toDouble(), 
                                        rodColor: [Colors.green, Colors.green.shade300, Colors.amber, Colors.amber.shade300, Colors.red][index]
                                      )
                                    ]
                                  )
                                )
                              )
                            ),

                            Expanded(  
                              child: buildRatingSummarySection(context),
                            )

                          ],
                        ),

                        buildCurrentCourseTable(),

                        buildCummulativeCourseTable(),
                      ],
                    ),
                  ),
                )

              ],
            ),
          ),
        ],
      ),
    );
  }

  Expanded buildNoInfoPlaceholder() {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 150),
        alignment: Alignment.center,

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,

          children: [

            CustomText(
              'No Data',
              textAlignment: TextAlign.center,
              fontWeight: FontWeight.w700,
            ),


            CustomText('Lecturer may not have any courses yet'),

            const SizedBox(height: 8,),


            CustomButton.withText('Click to reload', onPressed: () => loadData())

          ],
        ),
      ),
    );
  }

  Container buildRatingSummarySection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      //height: 400,
      decoration: BoxDecoration(
        color: PreferencesProvider.getColor(context, 'alt-primary-color'),
        borderRadius: BorderRadius.circular(12)
      ),
      child: Column(  
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          HeaderText('Lecturer Ratings Summary'),
          
          const SizedBox(height: 12,),

          //todo: the actual stars
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            spacing: 8,
            children: List<Widget>.generate(
              ratingSummary.length, (index){
                        
                return Row(  
                  children: [
                    Expanded(
                      flex: 2,
                      child: buildStars(ratingSummary[index].rating)
                    ),
                          
                    SizedBox(
                      width: 120,
                      child:  CustomText(
                        '${formatDecimal(ratingSummary[index].percentage)} %',
                        fontSize: 15,
                      ),
                    ),
                          
                    SizedBox(
                      width: 120,
                      child:  CustomText(
                          '${ratingSummary[index].ratingCount}',
                        fontSize: 15,
                      ),
                    )
                  ],
                );
              }
            )
          ),
        ],
      )
    );
  }




  Widget buildStars(int n) => Row(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.center,
    mainAxisAlignment: MainAxisAlignment.start,
    spacing: 3,
    children: List<Widget>.generate(
      n,
      (index) => Icon(Icons.star_rounded, color: Colors.amber, size: 28,)
    )
  );



  Container buildLecturerInfoSection() {
    return Container(  
      width: MediaQuery.of(context).size.width * 0.25,
      padding: EdgeInsets.all(16),

      decoration: BoxDecoration(  
        color: PreferencesProvider.getColor(context, 'alt-primary-color'),
        borderRadius: BorderRadius.circular(12)
      ),

      child: Column(  
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [

          CircleAvatar(
            backgroundColor: Colors.green.shade400,
            radius: 65,
            child: const Icon(CupertinoIcons.person, color: Colors.white, size: 70,),
          ),

          const SizedBox(
            height: 12,
          ),


          RatingStars(rating: widget.lecturer.rating),

          const SizedBox(height: 24,),


          DetailContainer(title: 'Name', detail: widget.lecturer.name),

          const SizedBox(height: 12,),

          DetailContainer(title: 'E-mail', detail: widget.lecturer.email),

          const SizedBox(height: 12,),

          DetailContainer(title: 'Department', detail: widget.lecturer.department),

          const SizedBox(height: 12,),

          DetailContainer(title: 'Rating', detail: widget.lecturer.rating.toStringAsFixed(2)),

        ],
      )
    );
  }


  Center buildDetailsCard() {
    return Center(
      child: Card(
        elevation: 8,
        margin: EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8)
        ),

        child: Container(
          padding: EdgeInsets.all(16),
          //width: MediaQuery.of(context).size.width * 0.4,
          height: 100,
          decoration: BoxDecoration( 
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(8)
          ),

          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [


              buildCardDetailCol(
                CupertinoIcons.star_fill, 
                widget.lecturer.rating == 0 ? '0': widget.lecturer.rating.toStringAsFixed(1), 
                iconColor: const Color.fromARGB(255, 236, 219, 67)
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8),
                child: VerticalDivider(
                  thickness: 1.5,
                ),
              ),

              buildCardDetailCol(Icons.school, 'Ph. D', iconColor: Colors.green.shade400),


              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8),
                child: VerticalDivider(
                  thickness: 1.5,
                ),
              ),


              buildCardDetailCol(CupertinoIcons.person_solid, 'Male', iconColor: Colors.blue.shade400),

            ],
          ),
        ),
      ),
    );
  }





  Widget buildCardDetailCol(IconData icon, String value, {Color? iconColor}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          icon,
          color: iconColor,
          size: 30,
        ),

        SizedBox(height: 8,),

        CustomText(value, fontSize: 18,)
      ],
    );
  }




  //todo: table showing the current courses handle by the lecturer
  Widget buildCurrentCourseTable(){

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(8),

      constraints: BoxConstraints(
        minHeight: MediaQuery.of(context).size.height * 0.4,
      ),

      decoration: BoxDecoration(
        color: PreferencesProvider.getColor(context, 'table-background-color'),
        borderRadius: BorderRadius.circular(12),
      ),


      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [


          CustomText(
            'Current Courses',
            fontWeight: FontWeight.w600,
          ),


          const SizedBox(height: 8),

          //todo: table column headers.
          Container(
            padding: const EdgeInsets.all(8),
            width: double.infinity,

            decoration: BoxDecoration(
              color: PreferencesProvider.getColor(context, 'alt-primary-color'),
              borderRadius: BorderRadius.circular(12)
            ),

            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,

              children: [

                Expanded(
                  child: CustomText(
                    'Course Code'
                  ),
                ),


                Expanded(
                  flex: 2,
                  child: CustomText(
                    'Course Title'
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

              ],
            ),
          ),



          if(currentClassCourses.isEmpty) Container(
            alignment: Alignment.center,
            padding: EdgeInsets.symmetric(vertical: 24),
            child: CollectionPlaceholder(
              title: 'No Data',
              detail: 'Courses handled by lecturer in this academic year appear here.',
            )
          )
          else Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: List<Widget>.generate(
              currentClassCourses.length,
              (int index) => currentCourseCell(currentClassCourses[index])
            ),
          )

        ],
      ),
    );
  }


  //todo: current course table cell.

  Widget currentCourseCell(ClassCourse classCourse){

    return Container(  
      width: double.infinity,
      padding: const EdgeInsets.all(8),
      margin: const EdgeInsets.only(top: 8),

      child: Row(  
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,

        children: [

          Expanded(  
            child: CustomText(  
              classCourse.course.courseCode
            ),
          ),


          Expanded(  
            flex: 2,
            child: CustomText(  
              classCourse.course.title
            ),
          ),

          //TODO: fix this commented code later.
          
          SizedBox(  
            width: 120,
            child: CustomText(  
              classCourse.registeredStudentsCount.toString()
            ),
          ),


          SizedBox(  
            width: 120,
            child: CustomText(  
              classCourse.evaluatedStudentsCount.toString()
            ),
          ),

        ],
      ),
    );

  }



  //todo: table showing the cummlative of all courses taught by the lecturer.
  Widget buildCummulativeCourseTable(){
    return Container(  
      padding: const EdgeInsets.all(8),
      width: double.infinity,


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
          CustomText(  
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



          if(cummulativeClassCourses.isEmpty) Container(
            alignment: Alignment.center,
            margin: const EdgeInsets.only(top: 20),
            child: CollectionPlaceholder(  
              detail: 'All Courses handled by the lecturer appear here.',
            ),
          )
          else Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: List<Widget>.generate(
              cummulativeClassCourses.length,
              (int index) => LCummulativeCourseCell(classCourse: cummulativeClassCourses[index])
            ),
          )

        ],
      ),
    );
  }
  

}




class LCummulativeCourseCell extends StatefulWidget {
  
  final ClassCourse classCourse;
  
  const LCummulativeCourseCell({super.key, required this.classCourse});

  @override
  State<LCummulativeCourseCell> createState() => _LCummulativeCourseCellState();
}


class _LCummulativeCourseCellState extends State<LCummulativeCourseCell> {

  Color backgroundColor = Colors.transparent;
  
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onHover: (mouseEvent ) => setState(() => backgroundColor = Colors.green.shade300),
      onExit: (mouseEvent) => setState(() => backgroundColor = Colors.transparent),

      child: GestureDetector(
        onTap: () => Provider.of<PageProvider>(context, listen: false)
            .pushPage(EvaluationPage(classCourse: widget.classCourse), 'Course Evaluation'),

        child: Container(
          padding: EdgeInsets.all(8),
          margin: const EdgeInsets.only(top: 8),
          
          decoration: BoxDecoration(  
            borderRadius: BorderRadius.circular(12),
            color: backgroundColor
          ),
          
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              
              SizedBox(
                width: 120,
                child: CustomText(
                  widget.classCourse.year.toString()
                ),
              ),


              //todo: semester
              SizedBox(
                width: 100,
                child: CustomText(
                  widget.classCourse.semester.toString()
                ),
              ),

              //todo: course code
              Expanded(
                child: CustomText(
                  widget.classCourse.course.courseCode
                ),
              ),

              //todo: course title
              Expanded(
                flex: 2,
                child: CustomText(
                  widget.classCourse.course.title
                ),
              ),


              SizedBox(
                width: 120,
                child: CustomText(widget.classCourse.registeredStudentsCount.toString())
              ),



              SizedBox(
                width: 120,
                child: CustomText(formatDecimal(widget.classCourse.grandMeanScore))
              ),


              SizedBox(
                width: 120,
                child: CustomText(widget.classCourse.remark!)
              ),


            ],
          ),
        ),
      )
    );
  }
}

