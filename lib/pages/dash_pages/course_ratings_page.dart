

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:selc_admin/components/button.dart';
import 'package:selc_admin/components/text.dart';
import 'package:selc_admin/model/models.dart';
import 'package:selc_admin/providers/selc_provider.dart';



class CourseRatingsPage extends StatefulWidget {


  const CourseRatingsPage({super.key});

  @override
  State<CourseRatingsPage> createState() => _CourseRatingsPageState();
}

class _CourseRatingsPageState extends State<CourseRatingsPage> {


  final searchController = TextEditingController();

  final semesterController = DropdownController<int>();
  final academicYearController = DropdownController<int>();
  final departmentController = DropdownController<Department>();


  bool showCurrentSelected = true;
  bool showAllSelected = false;
  bool filterSelected = false;

  bool isLoading = false;


  @override
  void initState() {
    super.initState();
    
    semesterController.value = Provider.of<SelcProvider>(context, listen: false).currentSemester;
    academicYearController.value = DateTime.now().year;
  }


  void loadCourseRankingsData({Map<String, dynamic>? filterMap}) async {
    setState(() => isLoading = true);

    //todo: use the provider to load the course rankings.
    Provider.of<SelcProvider>(context, listen: false).getCourseRatingsRank(filterBody: filterMap);

    setState(() => isLoading = false);
  }


  @override
  Widget build(BuildContext context) {

    List<CourseRating> coursesRatings = Provider.of<SelcProvider>(context).coursesRatings;


    return Scaffold(
      body: Padding(  
        padding: const EdgeInsets.all(16),

        child: Column(  
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [

            HeaderText(
              'Course Ratings',
              fontSize: 25,
            ),

            NavigationTextButtons(),

            const SizedBox(height: 12,),


            CustomTextField(
              controller: searchController,
              hintText: 'Search courses',
              onChanged: (newValue) => setState((){}),
            ),


            const SizedBox(height: 12,),


            Expanded(
              child: Row(  
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
              
                  Card(  
              
                    color: Colors.white,
                    shape: RoundedRectangleBorder(  
                      borderRadius: BorderRadius.circular(12)
                    ),
              
              
                    child: Container(  
                      width: MediaQuery.of(context).size.width * 0.22,
                      padding: const EdgeInsets.all(8),

                      decoration: BoxDecoration( 
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.white
                      ),
              
                      child: Column(  
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
              
                        children: [
                          HeaderText(  
                            'Filter',
                            fontSize: 15,
                          ),
              
                          const SizedBox(height: 8),

                          CustomCheckBox(
                            value: showCurrentSelected, 
                            text: 'Show Current',
                            onChanged: (newValue){

                              setState(() {
                                showCurrentSelected = true;
                                showAllSelected = false;
                                filterSelected = false;
                              });

                              semesterController.value = Provider.of<SelcProvider>(context, listen: false).currentSemester;
                              academicYearController.value = DateTime.now().year;

                              loadCourseRankingsData(filterMap: {
                                'year': academicYearController.value,
                                'semester': semesterController.value
                              });
                            },
                          ),
              
              
                          const SizedBox(height: 8,),
              
                          CustomCheckBox(
                            value: showAllSelected, 
                            text: 'Show All',
                            onChanged: (newValue){
                              setState(() {
                                showAllSelected = true;
                                showCurrentSelected = false;
                                filterSelected = false;
                              });

                              if(newValue!) loadCourseRankingsData();
                            },
                          ),
              
              
                          const SizedBox(height: 8,),
              
                          CustomCheckBox(  
                            value: filterSelected,
                            text: 'Custom Filter',
                            onChanged: (newValue)=> setState(() {
                              filterSelected = true;
                              showCurrentSelected = false;
                              showAllSelected = false;
                            })
                          ),
              
                          Divider(),
              
                          Padding(  
                            padding: const EdgeInsets.only(left:8),
                            child: IgnorePointer(
                              ignoring: !filterSelected,
                              child: Column(  
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                            
                                children: [
                                            
                                  CustomText('Academic year'),
                                  
                                  const SizedBox(height: 8),
                                            
                                  CustomDropdownButton<int>(  
                                    controller: academicYearController,
                                    hint: 'Select Academic year',
                                    items: List<int>.generate(DateTime.now().year - 2010, (index) => 2011+index),
                                    onChanged: (newValue) => onDropdownValueChange()
                                  ),
                                            
                                            
                                  const SizedBox(height: 8,),
                                            
                                            
                                  CustomText('Semester'),
                                  
                                  const SizedBox(height: 8),
                                            
                                  CustomDropdownButton<int>(  
                                    controller: semesterController,
                                    hint: 'Select semester',
                                    items: [1, 2],
                                    onChanged: (newValue) => onDropdownValueChange()
                                  ),
                                            
                                            
                                            
                                  const SizedBox(height: 8,),
                                            
                                            
                                  CustomText('Department'),
                                  
                                  const SizedBox(height: 8),
                                            
                                            
                                  //todo: fix this later with the list of all the departments 
                                  CustomDropdownButton<Department>(  
                                    controller: departmentController,
                                    hint: 'Select department',
                                    items: Provider.of<SelcProvider>(context).departments,
                                    onChanged: (newValue) => onDropdownValueChange()
                                  ),
                                            
                                            
                                  Divider(),
                                            
                                            
                                  CustomButton.withText(
                                    'Clear', 
                                    width: double.infinity,
                                    onPressed: () => setState((){
                                      academicYearController.reset();
                                      semesterController.reset();
                                      departmentController.reset();
                                    })
                                  )
                                                      
                                            
                                ],
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
              
              
                  const SizedBox(width: 12,),
              
                  //todo: the course ratings table.
              
                  Expanded(  
                  flex: 2,
                    child: Container(  
                      width: double.infinity,
                      height: double.infinity,
                      padding: const EdgeInsets.all(8),
              
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.white
                      ),
              
                      child: Column(  
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [

                          //todo: table rows/column headers.
              
                          Container(
                            padding: const EdgeInsets.all(8),
                            width: double.infinity,
              
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(12)
                            ),
              
                            child: Row(
                              children: [

                                SizedBox(
                                  width: 150,
                                  child: CustomText(  
                                    'No.'
                                  ),
                                ),


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



                                Expanded(
                                  child: CustomText(  
                                    'Eval. Count'
                                  ),
                                ),

                                SizedBox(
                                  width: 150,
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [

                                      Icon(Icons.star, color: Colors.green.shade300, size: 20,),

                                      CustomText(  
                                        'Rating',
                                        textAlignment: TextAlign.center,
                                      )
                                    ],
                                  ),
                                ),

                              ],
                            ),
                          ),


                          //todo: the content of the table

                          if(isLoading) Expanded(  
                            child: Center(  
                              child: CircularProgressIndicator(),
                            ),
                          ),

                          if(!isLoading && coursesRatings.isEmpty) Expanded(
                            child: Center(  
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  CustomText(
                                    'Course Rate Rankings.',
                                    fontWeight: FontWeight.w600,
                                  ),

                                  CustomText(
                                    'The rating rankings of the courses appear here.'
                                  )
                                ],
                              ),
                            ),
                          )
                          else Expanded(
                            child: ListView.builder(  
                              itemCount: searchController.text.isEmpty ? coursesRatings.length : applySearchFilter(searchController.text, coursesRatings).length,
                              itemBuilder: (_, index){
                                CourseRating cRating;

                                if(searchController.text.isEmpty){
                                  cRating = coursesRatings[index];
                                }else{
                                  cRating = applySearchFilter(searchController.text, coursesRatings)[index];
                                }


                                return Container(
                                  padding: const EdgeInsets.all(8),
                                  child: Row(  
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [

                                      SizedBox(
                                        width: 150,
                                        child: CustomText(  
                                          (1+coursesRatings.indexOf(cRating)).toString()
                                        ),
                                      ),


                                      Expanded(
                                        child: CustomText(  
                                          cRating.course.courseCode!
                                        ),
                                      ),


                                      Expanded(
                                        flex: 2,
                                        child: CustomText(  
                                          cRating.course.title!
                                        ),
                                      ),



                                      Expanded(
                                        child: CustomText(  
                                          cRating.numberOfStudents.toString()
                                        ),
                                      ),


                                      SizedBox(  
                                        width: 150,
                                        child: CustomText(
                                          cRating.parameterRating.toStringAsFixed(3),
                                          textAlignment: TextAlign.center,
                                        ),
                                      )


                                    ],
                                  ),
                                );
                              },
                            ),
                          )
                        ],
                      ),
                    ),
                  )
              
                ],
              ),
            )
          ],
        ),
      ),
    );
  }


  List<CourseRating> applySearchFilter(String searchText, List<CourseRating> ratings){
    return ratings.where((rating) => rating.course.title!.toLowerCase().contains(searchText.toLowerCase()) ||
          rating.course.courseCode!.toLowerCase().contains(searchText.toLowerCase())).toList();
  }

  void onDropdownValueChange(){
    Map<String, dynamic> filterMap = {};

    Department? department = departmentController.value;

    if(department != null) filterMap.addAll({'department': department.departmentId});

    int? year = academicYearController.value;

    if(year != null) filterMap.addAll({'year': year});
    
    int? semester = semesterController.value;

    if(semester != null) filterMap.addAll({'semester': department!.departmentId});

    loadCourseRankingsData(filterMap: filterMap);
  }
}