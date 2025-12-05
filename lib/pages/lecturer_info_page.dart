
import 'dart:io';
import 'dart:math';

import 'package:animations/animations.dart';
import 'package:contextmenu/contextmenu.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:selc_admin/components/alert_dialog.dart';
import 'package:selc_admin/components/button.dart';
import 'package:selc_admin/components/cells.dart';
import 'package:selc_admin/components/charts/bar_chart.dart';
import 'package:selc_admin/components/text.dart';
import 'package:selc_admin/components/utils.dart';
import 'package:selc_admin/model/models.dart';
import 'package:selc_admin/pages/evaluations/eval_page.dart';
import 'package:selc_admin/providers/page_provider.dart';
import 'package:selc_admin/providers/pref_provider.dart';

import '../components/charts/line_chart.dart';
import '../components/charts/pie_chart.dart';
import '../providers/selc_provider.dart';



class LecturerInfoPage extends StatefulWidget {

  final Lecturer lecturer;

  const LecturerInfoPage({super.key, required this.lecturer});

  @override
  State<LecturerInfoPage> createState() => _LecturerInfoPageState();
}

class _LecturerInfoPageState extends State<LecturerInfoPage> {

  List<dynamic> detailFields = [];

  List<ClassCourse> lecturerClassCourses = [];
  List<ClassCourse> currentClassCourses = [];

  List<dynamic> yearlyLecturerRatingSummary = [];

  dynamic ratingSummary;
  int totalRatingCount = 0;


  bool isLoading = false;
  bool isShowRatingBarChart = true;
  
  int selectedRatingViewIndex = 0;

  @override
  void initState() {
    // TODO: implement initState

    loadData();

    super.initState();
  }



  List<dynamic> initDetailFields(){

    final detailFields = [
      ('Department', widget.lecturer.department, CupertinoIcons.home),
      ('Email', widget.lecturer.email, CupertinoIcons.at),
      ('Total Courses',  lecturerClassCourses.isEmpty ? 0 : '${lecturerClassCourses.length}', CupertinoIcons.book),
      ('Average Rating', formatDecimal(widget.lecturer.rating), Icons.star),
      ('Rating Count', totalRatingCount, Icons.person),
      ('Overall Remark', widget.lecturer.remark, CupertinoIcons.check_mark),
      ('Courses This semester', currentClassCourses.length, CupertinoIcons.book_solid)
    ];


    return detailFields;
  }


  void loadData() async {

    setState(() => isLoading = true);

    try{

      //get the yearly lecturer rating summary
      yearlyLecturerRatingSummary  = await Provider.of<SelcProvider>(context, listen: false)
          .getYearlyLecturerRatingSummary(widget.lecturer.username);

      ratingSummary = await Provider.of<SelcProvider>(context, listen: false)
          .getOverallLecturerRatingSummary(widget.lecturer.username);

      ratingSummary.forEach((summary)=> totalRatingCount += (summary.ratingCount as num).toInt()); // counts number of people who have rated this lecturer

      lecturerClassCourses = await Provider.of<SelcProvider>(context, listen: false).getLecturerInfo(widget.lecturer.username);

      currentClassCourses = lecturerClassCourses.where((classCourse) => classCourse.year == DateTime.now().year).toList();


      detailFields = initDetailFields();

    } on SocketException catch(_){
      showNoConnectionAlertDialog(context);

    }on Error catch (err, stackTrace){

      debugPrint(err.toString());
      debugPrint(stackTrace.toString());

      showCustomAlertDialog(
        context,
        title: 'Error',
        contentText: 'An unexpected error occurred.'
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

                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 12,
                    children: [

                      buildLectureNameSection(),

                      Expanded(child: buildAdditionInfoSection()),

                      buildRatingDetailSection(),
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
    width: MediaQuery.of(context).size.width * 0.2,
    height: MediaQuery.of(context).size.height * 0.35,
    decoration: BoxDecoration(
      color: PreferencesProvider.getColor(context, 'alt-primary-color'),
      borderRadius: BorderRadius.circular(12)
    ),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      spacing: 12,
      children: [

        CircleAvatar(
          backgroundColor: Colors.green.shade400,
          radius: 60,
          child: Icon(Icons.person, size: 50, color: Colors.white,),
        ),


        HeaderText(
          widget.lecturer.name,
          textAlignment: TextAlign.center,
          maxLines: 2,
        ),

        CustomText(
          '@${widget.lecturer.username}',
          padding: EdgeInsets.zero,
          maxLines: 1,
        ),


        RatingStars(rating: widget.lecturer.rating)

      ],

    ),
  );





  Widget buildAdditionInfoSection() {


    return Container(
      //width: MediaQuery.of(context).size.width * 0.4,
      height: MediaQuery.of(context).size.height * 0.35,
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

          const SizedBox(height: 8,),


          GridView.builder(
            gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 350,
              mainAxisExtent: 92,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8
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
                height: 90,

                constraints: BoxConstraints(minHeight: 90, maxHeight: 90, maxWidth: 300),

                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: PreferencesProvider.getColor(context, 'alt-primary-color')
                ),


                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 12,
                  children: [

                    CircleAvatar(
                      backgroundColor: PreferencesProvider.getColor(context, 'primary-color'),
                      radius: 30,
                      child: Icon(icon, color: Colors.green.shade400, size: 25,)
                    ),

                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        spacing: 3,
                        children: [

                          CustomText(
                            title,
                            fontWeight: FontWeight.w600,
                            fontStyle: FontStyle.italic,
                            fontSize: 13,
                            maxLines: 1,
                            textColor: PreferencesProvider.getColor(context, 'placeholder-text-color'),
                          ),

                          CustomText(detail, maxLines: 2, overflow: TextOverflow.ellipsis,),
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
    
    
    final ratingSummaryViews = [buildRatingCustomBarChart(), buildRatingPieChart(), buildRatingStarsDetail(), buildYearlyRatingLineChart()];


    return Container(
      height: MediaQuery.of(context).size.height * 0.35,
      width: MediaQuery.of(context).size.width * 0.25,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: PreferencesProvider.getColor(context, 'alt-primary-color'),
        borderRadius: BorderRadius.circular(12)
      ),

      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Row(
            children: [

              HeaderText(
                 selectedRatingViewIndex < 3 ? 'Overall Rating Summary' : 'Yearly Rating Summary'
              ),

              Spacer(),

              //make a button to switch to the next page
              IconButton(
                onPressed: () => setState(() {
                  selectedRatingViewIndex -= 1;

                  if(selectedRatingViewIndex == -1) selectedRatingViewIndex = ratingSummaryViews.length - 1;
                }),
                icon: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: PreferencesProvider.getColor(context, 'primary-color')
                  ),
                  child: Icon(Icons.navigate_before, size: 25,)
                ),
              ),


              for(int i=0; i < ratingSummaryViews.length; i++) GestureDetector(
                onTap: () => setState(() => selectedRatingViewIndex = i),
                child: Container(
                  margin: const EdgeInsets.only(left: 3),
                  height: 15,
                  width: 15,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: selectedRatingViewIndex == i ? Colors.green.shade400 : PreferencesProvider.getColor(context, 'placeholder-text-color'), //or placeholder text color
                  )
                ),
              ),


              IconButton(
                onPressed: () => setState(() {
                  selectedRatingViewIndex += 1;

                  if(selectedRatingViewIndex == ratingSummaryViews.length) selectedRatingViewIndex = 0;
                }),
                icon: Container(
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: PreferencesProvider.getColor(context, 'primary-color')
                    ),
                    child: Icon(Icons.navigate_next, size: 25,)
                ),
              ),

            ],
          ),
          
          
          Expanded(
            child: PageTransitionSwitcher(

              duration: Duration(milliseconds: 500),

              transitionBuilder: (child, animation, secondaryAnimation ) => FadeThroughTransition(
                animation: animation,
                secondaryAnimation: secondaryAnimation,
                fillColor: Colors.transparent,
                child: child,
              ),

              child: ratingSummaryViews[selectedRatingViewIndex],
            ),
          ),

        ],

      )
    );
  }


  CustomBarChart buildRatingCustomBarChart() {

    List<Color> colors = [Colors.green.shade600, Colors.blue.shade400, Colors.purple.shade400, Colors.amber, Colors.red.shade400];

    return CustomBarChart(
      containerBackgroundColor: PreferencesProvider.getColor(context, 'alt-primary-color'),
      width: double.infinity,
      //chartTitle: 'Overall Rating Summary',
      leftAxisTitle: 'Frequency(number of students)',
      bottomAxisTitle: 'Stars',
      showYaxisLabels: false,
      showGrid: false,
      rodWidth: 50,
      rodBorderRadius: BorderRadius.zero,
      groups: List<CustomBarGroup>.generate(
        ratingSummary != null ? ratingSummary.length : 0,
          (int index) => CustomBarGroup(
          x: index,
          label: ratingSummary[index].rating.toString(),
          rods: [
            Rod(
                y: ratingSummary[index].ratingCount.toDouble(),
                rodColor: colors[index]
            )
          ]
        )
      )
    );
  }



  Widget buildRatingPieChart(){

    return CustomPieChart(

      backgroundColor: PreferencesProvider.getColor(context, 'alt-primary-color'),
      width: double.infinity,
      showKeys: true,

      pieSections: List<CustomPieSection>.generate(
        ratingSummary == null ? 0 : ratingSummary.length,
        (index){

          EvalLecturerRatingSummary ratingSum = ratingSummary[index];

          String sectionTitle = '${ratingSum.rating} [${ratingSum.percentage}%]';
          double value = (ratingSum.ratingCount / totalRatingCount) * 360;

          return CustomPieSection(value: value, title: sectionTitle);
        }
      ),
    );
  }




  Widget buildRatingStarsDetail(){
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      //mainAxisSize: MainAxisSize.min,
      spacing: 8,
      children: <Widget>[

        //header row
        Container(
          padding: const EdgeInsets.all(8),
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: PreferencesProvider.getColor(context, 'table-header-color')
          ),

          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                flex: 2,
                child: CustomText('Stars')
              ),

              SizedBox(
                width: 120,
                child: CustomText('Students'),
              ),

              SizedBox(
                width: 120,
                child: CustomText('Percentage')
              )
            ],
          ),
        )


      ] +
      List<Widget>.generate(
        ratingSummary == null ? 0 : ratingSummary.length, (index){
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
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
            ),
          );
      })
    );
  }




  Widget buildStars(int n) => Row(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.center,
    mainAxisAlignment: MainAxisAlignment.start,
    spacing: 3,
    children: List<Widget>.generate(
      n,
      (index) => Icon(Icons.star, color: Colors.amber, size: 30,)
    )
  );


  Widget buildYearlyRatingLineChart(){

    return CustomLineChart(
      width: double.infinity,
      showXLabels: false,
      showYLabels: false,
      containerBackgroundColor: PreferencesProvider.getColor(context, 'alt-primary-color'),
      leftAxisTitle: 'Rating',
      bottomAxisitle: 'Years',
      maxY: 5,
      spotData: List<CustomLineChartSpotData>.generate(
          yearlyLecturerRatingSummary.length,
            (index) {

              double x = index.toDouble();

              int year = yearlyLecturerRatingSummary[index].$1;

              //now the actual rating
              double y = yearlyLecturerRatingSummary[index].$2;


              final label = 'Year: $year\nAvg Rating: ${formatDecimal(y)}';

              return CustomLineChartSpotData( x: x, y: y, label: label,);
            }
      ) + List.generate(
          20,
          (index) {

            double rating =  [1, 1.7, 2, 2.1, 2.5, 2, 3.2, 3.6, 4, 4.3, 4.8, 5][Random().nextInt(12)].toDouble();

            return CustomLineChartSpotData(
              x: (1+index).toDouble(),
              y: rating,
              label: 'Year: ${2026+index}\nAvg Rating: ${rating}'
            );
          }
      ),
      

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

                return LCurrentCourseCell(classCourse: classCourse);
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




//============================================================
//LIST CELLS FOR CURRENT CLASS COURSES
//===========================================================

class LCurrentCourseCell extends StatefulWidget {

  final ClassCourse classCourse;
  final useLecturerName;

  const LCurrentCourseCell({super.key, required this.classCourse, this.useLecturerName = false});

  @override
  State<LCurrentCourseCell> createState() => _LCurrentCourseCellState();
}

class _LCurrentCourseCellState extends State<LCurrentCourseCell> {

  Color backgroundColor = Colors.transparent;

  @override
  Widget build(BuildContext context) {


    String courseCode = widget.classCourse.course.courseCode;
    String title = widget.classCourse.course.title;
    int studentsCount = widget.classCourse.registeredStudentsCount;
    int evaluatedStudents = widget.classCourse.evaluatedStudentsCount;

    return MouseRegion(
      onHover: (mouseEvent) => setState(() => backgroundColor = Colors.green.shade200),
      onExit: (mouseEvent) => setState(() => backgroundColor = Colors.transparent),

      child: GestureDetector(
        onSecondaryTapDown: (details) => showContextMenu(
          details.globalPosition,
          context,
          (_) => [

            ListTile(
              leading: Icon(CupertinoIcons.info),
              title: CustomText('View Info'),
              onTap: openClassCourseInfo,
            ),

            ListTile(
                leading: Icon(CupertinoIcons.graph_square),
                title: CustomText('View Evaluation'),
                onTap: openEvaluation
            ),

          ],
          12.0,
          300.0
        ),

        child: Container(

          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: backgroundColor
          ),

          child: ListTile(
            onTap: openClassCourseInfo,

            contentPadding: EdgeInsets.symmetric(horizontal: 12),

            leading: Container(
              height: 50,
              width: 50,
              color: Colors.green.shade300,
              child: Icon(CupertinoIcons.book, color: Colors.white,),
            ),

            title: CustomText(
              widget.useLecturerName ? widget.classCourse.lecturer.name : '$title[$courseCode]',
              fontSize: 15,
              fontWeight: FontWeight.w600,
              maxLines: 2,
            ),
            subtitle: CustomText('Students [Evaluated]: $studentsCount [$evaluatedStudents]'),
          ),
        ),
      ),
    );
  }


  void openEvaluation() => Provider.of<PageProvider>(context, listen: false)
        .pushPage(EvaluationPage(classCourse: widget.classCourse), 'Evaluation');

  void openClassCourseInfo() => showCustomModalBottomSheet(
    context: context,
    isScrollControlled: true,
    child: ClassCourseInfoModalSheet(classCourse: widget.classCourse)
  );
}





//======================================================================
//CUMMULATIVE COURSE CELL FOR LECTURER
//======================================================================

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

          onTap: openEvaluation,

          onDoubleTap: openClassCourseInfo,


          onSecondaryTapDown: (details) => showContextMenu(
            details.globalPosition,
            context,
                (_) => [

              ListTile(
                leading: Icon(CupertinoIcons.info),
                title: CustomText('View Info'),
                onTap: openClassCourseInfo,
              ),

              ListTile(
                  leading: Icon(CupertinoIcons.graph_square),
                  title: CustomText('View Evaluation'),
                  onTap: openEvaluation
              ),

              ListTile(
                  leading: Icon(Icons.grid_on_outlined),
                  title: CustomText('Generate Excel Report'),
                  onTap: generalExcelReport
              ),

              ListTile(
                leading: Icon(Icons.file_copy_outlined),
                title: CustomText('Generate PDF report'),
              )
            ],
            12.0,
            300.0
          ),

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



  void openEvaluation() => Provider.of<PageProvider>(context, listen: false)
      .pushPage(EvaluationPage(classCourse: widget.classCourse), 'Course Evaluation');



  void openClassCourseInfo() => showCustomModalBottomSheet(
      context: context,
      child: ClassCourseInfoModalSheet(classCourse: widget.classCourse),
      isScrollControlled: true
  );


  
  //todo: implement this function later.
  void generalExcelReport() async {
    showToastMessage(context, 'This feature will be implemented later');
  }
}







class ClassCourseInfoModalSheet extends StatelessWidget {
  
  final ClassCourse classCourse;
  
  const ClassCourseInfoModalSheet({super.key, required this.classCourse});

  @override
  Widget build(BuildContext context) {
    
    
    final detailFields = [

      ('Lecturer', classCourse.lecturer.name),
      ('Department', classCourse.lecturer.department),
      ('Course Code', classCourse.course.courseCode),
      ('Course Title', classCourse.course.title),

      [
        ('Credits', classCourse.credits.toString()),
        ('Year', classCourse.year.toString()),
        ('Semester', classCourse.semester.toString()),
      ],

      ('Number on roll', classCourse.registeredStudentsCount.toString()),

      [
        ('Evaluated Students', classCourse.evaluatedStudentsCount.toString()),
        ('Response Rate(%)', formatDecimal(classCourse.calculateResponseRate())),
      ],

      [
        ('Mean Score', formatDecimal(classCourse.grandMeanScore)),
        ('Percentage Score', formatDecimal(classCourse.grandPercentageScore)),
      ],

      ('Remark', classCourse.remark),
      ('Lecturer Rating for this course', formatDecimal(classCourse.lecturerRating))
    ];


    final List<Widget> colChildren = [];

    for(dynamic field in detailFields){


      if(field is List<(String, String)>){

        colChildren.add(
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            spacing: 8,
            children: List.generate(
              field.length,
              (index) => Expanded(
                child: DetailContainer(
                  title: field[index].$1,
                  detail: field[index].$2,
                )
              )
            ),
          )
        );


        continue;
      }

      colChildren.add(
        DetailContainer(
          title: field.$1,
          detail: field.$2
        )
      );

    }
    
    
    return Container( 
      padding: const EdgeInsets.all(16),
      width: 450,
      decoration: BoxDecoration( 
        borderRadius: BorderRadius.circular(12),
        color: PreferencesProvider.getColor(context, 'alt-primary-color'),
        border: Border.all(color: Colors.green.shade200)
      ),
      
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start, 
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        spacing: 8,
        children: <Widget>[

          Row(
            children: [
              HeaderText('Class Course information'),

              Spacer(),

              IconButton(
                color: Colors.red.shade400,
                onPressed: () => Navigator.pop(context),
                icon: Icon(CupertinoIcons.xmark),
              )

            ],
          ),

          const SizedBox()
        ] + colChildren,
      )
    );
  }
}


