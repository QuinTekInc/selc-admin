
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:selc_admin/components/alert_dialog.dart';
import 'package:selc_admin/components/button.dart';
import 'package:selc_admin/components/cells.dart';
import 'package:selc_admin/components/text.dart';
import 'package:selc_admin/model/models.dart';
import 'package:selc_admin/providers/selc_provider.dart';


class CoursesPage extends StatefulWidget {

  const CoursesPage({super.key});

  @override
  State<CoursesPage> createState() => _CoursesPageState();
}

class _CoursesPageState extends State<CoursesPage> {

  final searchController = TextEditingController();
  List<Course> filteredCourses = [];

  bool isLoading = false;
  //bool isSuperuser = false;

  SelcProvider? selcProvider;

  

  @override
  void initState() {
    // TODO: implement initState

    selcProvider = Provider.of<SelcProvider>(context, listen: false);

    //isSuperuser = selcProvider!.user.isSuperuser;

    loadCourseData();

    super.initState();
  }


  void loadCourseData() async{ 

    setState(()=> isLoading = true);

    try{
      await selcProvider!.getCourses();

      filteredCourses = selcProvider!.courses;
    }on Error catch(_){

    }on SocketException catch(_){
      
      showCustomAlertDialog(
        context, 
        title: 'Not Connected', 
        contentText: 'Make sure you are not connected'
      );
    }
    
    setState(()=> isLoading = false);

  }

  @override
  Widget build(BuildContext context) {
    return Padding(

      padding: EdgeInsets.all(16),

      child: Column(

        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              HeaderText(
                'Courses',
                fontSize: 25,
              ),


              //todo: refresh button.
              IconButton(
                
                onPressed: loadCourseData, 
                icon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [

                    Icon(CupertinoIcons.arrow_2_circlepath, color: Colors.green.shade400,),

                    const SizedBox(width: 8,),

                    CustomText(
                      'Refresh',
                      fontWeight: FontWeight.w600,
                      textColor: Colors.green.shade400,
                    )
                  ],
                )
              )
            ],
          ),


          const SizedBox(height: 12),


          Row(

            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,

            children: [

              SizedBox(
                width: MediaQuery.of(context).size.width * 0.45,
                height: 40,
                child: CustomTextField(
                  controller: searchController,
                  leadingIcon: CupertinoIcons.search,
                  hintText: 'Search Courses...course code and course titles.',
                  onChanged: (newValue) => handleSearchFilter(),
                ),
              ),


              Spacer(),


              // if(isSuperuser) CustomButton.withIcon(
              //   'Add Course',
              //   icon: CupertinoIcons.add,
              //   forceIconLeading: true,
              //   onPressed: () => showModalBottomSheet(
              //     context: context, 
              //     backgroundColor: Colors.transparent,
              //     constraints: BoxConstraints(
              //       minWidth: double.infinity,
              //       minHeight: double.infinity
              //     ),
              //     builder: (_) => Container(
              //       height: MediaQuery.of(context).size.height,
              //       width: MediaQuery.of(context).size.width,
              //       alignment: Alignment.bottomRight,

              //       child: AddCoursePage()
              //     )
              //   ),
              // )

            ],
          ),

          const SizedBox(height: 12,),

          Expanded(  
            flex: 2,
            child: isLoading ? Center(child: CircularProgressIndicator(),) : 
            buildCoursesView()
          )
          
        ],

      ),

    );
  }

  Widget buildCoursesView() {

    if(filteredCourses.isEmpty){
      return Center(
        child: CustomText('Courses are empty. Click on the add button to add courses'),
      );
    }

    return GridView.builder(

      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 240,
        mainAxisExtent: 250,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8
      ),

      itemCount: filteredCourses.length,
      itemBuilder: (_, int index) {
        Course course = filteredCourses[index];
        return CourseCell(course: course);
      } ,
    );
  }






  void handleSearchFilter(){

    String newValue = searchController.text.toLowerCase();
    
    if(newValue.isEmpty){
      setState(() => filteredCourses = selcProvider!.courses);
      return;
    }


    filteredCourses = selcProvider!.courses.where(
      (course) => course.courseCode!.toLowerCase().contains(newValue) || course.title!.toLowerCase().contains(newValue)).toList();

    setState((){});

  }
}




class AddCoursePage extends StatefulWidget {
  const AddCoursePage({super.key});

  @override
  State<AddCoursePage> createState() => _AddCoursePageState();
}

class _AddCoursePageState extends State<AddCoursePage> {

 final codeController = TextEditingController();
 final titleController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(8),
      padding: EdgeInsets.all(16),
      width: MediaQuery.of(context).size.width * 0.25,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12)
      ),

      child: Column(

        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,

        children: [

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              HeaderText('Add Course'),

              IconButton(
                onPressed: () => Navigator.of(context).pop(), 
                icon: Icon(CupertinoIcons.clear, color: Colors.red, size: 25),
              )
            ],
          ),

          const SizedBox(height: 12),

          CustomText(
            'Course Code',
            fontWeight: FontWeight.w600,
          ),

          CustomText('NOTE: The course code must be unique.'),

          const SizedBox(height: 8,),

          CustomTextField(
            controller: codeController,
            hintText: 'Example: COMP164',
          ),


          const SizedBox(height: 12,),


          CustomText(
            'Course Title',
            fontWeight: FontWeight.w600,
          ),

          const SizedBox(height: 8,),

          CustomTextField(
            controller: titleController,
            hintText: 'Title of course here....',
          ),


          const SizedBox(height: 16,),


          CustomButton.withText(
            'Add', 
            width: double.infinity,
            onPressed: handleAddCourse
          )
        ],
      )
    );

  }


  void handleAddCourse() async {

    Map<String, String> questionMap = {
      'course_code': codeController.text,
      'course_title': titleController.text
    };


    try{
      

      await Provider.of<SelcProvider>(context, listen: false).addCourse(questionMap);
      
      Navigator.pop(context);

    }on SocketException catch(_){
      showNoConnectionAlertDialog(context);
    }

  }

}