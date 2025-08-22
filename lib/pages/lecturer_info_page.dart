


import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:selc_admin/components/alert_dialog.dart';
import 'package:selc_admin/components/button.dart';
import 'package:selc_admin/components/cells.dart';
import 'package:selc_admin/components/text.dart';
import 'package:selc_admin/model/course.dart';
import 'package:selc_admin/model/lecturer.dart';
import 'package:selc_admin/pages/evaluations/eval_page.dart';
import 'package:selc_admin/providers/page_provider.dart';
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

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    loadData();
  }



  void loadData() async {

    setState(() => isLoading = true);

    try{
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
    return Scaffold(
      backgroundColor: Colors.grey.shade100,

      body: Padding(
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
                  else if(!isLoading && cummulativeClassCourses.isEmpty) Expanded(
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
                  )

                  else Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        
                        children: [
                                    
                          buildCurrentCourseTable(),
                          
                          const SizedBox(height: 12),
                          
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
      ),

    );
  }

  Container buildLecturerInfoSection() {
    return Container(  
      width: MediaQuery.of(context).size.width * 0.25,
      padding: EdgeInsets.all(16),

      decoration: BoxDecoration(  
        color: Colors.grey.shade200,
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


          RatingStars(rating: widget.lecturer.rating!),

          const SizedBox(height: 24,),


          DetailContainer(title: 'Name', detail: widget.lecturer.name!),

          const SizedBox(height: 12,),

          DetailContainer(title: 'E-mail', detail: widget.lecturer.email!),

          const SizedBox(height: 12,),

          DetailContainer(title: 'Department', detail: widget.lecturer.department!),

          const SizedBox(height: 12,),

          DetailContainer(title: 'Rating', detail: widget.lecturer.rating!.toStringAsFixed(2)),

        ],
      ),
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
                widget.lecturer.rating! == 0 ? '0': widget.lecturer.rating!.toStringAsFixed(1), 
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





  //todo: table showing the curren courses handle by the lecturer 
  Widget buildCurrentCourseTable(){

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(8),

      constraints: BoxConstraints(
        minHeight: MediaQuery.of(context).size.height * 0.4,
      ),

      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.grey.shade200
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
              color: Colors.grey.shade300,
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


                //TODO: fix this code later.

                // Expanded(  
                //   child: CustomText(  
                //     'Class'
                //   )
                // )

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
              classCourse.course!.courseCode!
            ),
          ),


          Expanded(  
            flex: 2,
            child: CustomText(  
              classCourse.course!.title!
            ),
          ),

          //TODO: fix this commented code later.
          
          // Expanded(  
          //   child: CustomText(  
          //     classCourse.klass!
          //   ),
          // ),

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
        color: Colors.grey.shade200,
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
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(12)
            ),

            child: Row(  
              mainAxisAlignment: MainAxisAlignment.start,

              children: [

                Expanded(
                  child: CustomText(  
                    'Year',
                  )
                ),

                Expanded(
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
              (int index) => cummulativeCourseCell(cummulativeClassCourses[index])
            ),
          )

        ],
      ),
    );
  }




  //todo: cummulative course cell.
  Widget cummulativeCourseCell(ClassCourse classCourse) => GestureDetector(
    onTap: () => Provider.of<PageProvider>(context, listen: false).pushPage(EvaluationPage(classCourse: classCourse), 'Course Evaluation'),
    child: Container(
      padding: EdgeInsets.all(8),
      margin: const EdgeInsets.only(top: 8),
      child: Row(  
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(  
            child: CustomText(   
              classCourse.year.toString()
            ),
          ),
    
    
          Expanded(  
            child: CustomText(  
              classCourse.semester.toString()
            ),
          ),
    
    
          Expanded(
            child: CustomText(  
              classCourse.course!.courseCode!
            ),
          ),
    
    
          Expanded(
            flex: 2,
            child: CustomText(
              classCourse.course!.title!
            ),
          )
        ],
      ),
    ),
  );

}
