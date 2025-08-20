

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:selc_admin/components/button.dart';
import 'package:selc_admin/components/text.dart';
import 'package:selc_admin/model/course.dart';
import 'package:selc_admin/model/lecturer.dart';
import 'package:selc_admin/providers/selc_provider.dart';


class LecturerRatingsPage extends StatefulWidget {

  const LecturerRatingsPage({super.key});

  @override
  State<LecturerRatingsPage> createState() => _LecturerRatingsPageState();
}

class _LecturerRatingsPageState extends State<LecturerRatingsPage> {

  final searchController = TextEditingController();

  final academicYearController = DropdownController<int>();

  final semesterController = DropdownController<int>();

  final departmentController = DropdownController<Department>();


  bool isLoading = false;
  bool showCurrentSelected = true;
  bool showAllSelected = false;
  bool filterSelected = false;


  @override
  void initState() {
    super.initState();
    academicYearController.value = DateTime.now().year;
    semesterController.value = Provider.of<SelcProvider>(context, listen:false).currentSemester;
  }



  void loadLecturerRatingsData({Map<String, dynamic>? filterMap}) async{
    setState(() => isLoading = true );
    await Provider.of<SelcProvider>(context, listen: false).getLecturerRatingsRank(filterBody: filterMap);
    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {

    List<LecturerRating> lecturersRatings = Provider.of<SelcProvider>(context).lecturersRatings;

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(  
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [

            HeaderText(
              'Lecturer Ratings',
              fontSize: 25,
            ),

            NavigationTextButtons(),

            const SizedBox(height: 12,),

            CustomTextField(
              controller: searchController,
              hintText: 'Search',
              onChanged: (newValue) => setState((){}),
            ),


            const SizedBox(height: 12,),

            //divide the sections into filter console.
            Expanded(
              flex: 2,
              child: Row( 
                crossAxisAlignment: CrossAxisAlignment.start, 
                children: [

                  //todo: filter console.
                  Card(  
                    color: Colors.grey.shade50,
                    elevation: 8,
                    shadowColor: Colors.grey.shade200,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)
                    ),

                    child: Container(
                      padding: const EdgeInsets.all(8),
                      width: MediaQuery.of(context).size.width * 0.22,

                      child: Column(  
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,

                        children: [

                          HeaderText(
                            'Filter',
                            fontSize: 15,
                          ),

                          const SizedBox(height: 8,),


                          CustomCheckBox(
                            value: showCurrentSelected, 
                            text: 'Show Current',
                            onChanged: (newValue){
                              
                              setState((){
                                showCurrentSelected = true;
                                showAllSelected = false;
                                filterSelected = false;
                              });

                              
                              semesterController.value = Provider.of<SelcProvider>(context, listen: false).currentSemester;
                              academicYearController.value = DateTime.now().year;
                              
                              loadLecturerRatingsData(
                                filterMap: {
                                  'year': academicYearController.value,
                                  'semester': semesterController.value
                                }
                              );
                            },
                          ),


                          const SizedBox(height: 8,),


                          CustomCheckBox(
                            value: showAllSelected, 
                            text: 'Show All',
                            onChanged: (newValue){
                              
                              setState((){
                                showAllSelected = true;
                                showCurrentSelected = false;
                                filterSelected = false;
                              });

                              loadLecturerRatingsData();
                            },
                          ),


                          const SizedBox(height: 8,),

                          CustomCheckBox(
                            value: filterSelected, 
                            text: 'Custom Filter',
                            onChanged: (newValue)=> setState((){
                              filterSelected = true;
                              showCurrentSelected = false;
                              showAllSelected = false;
                            })
                          ),

                          Divider(),


                          Padding(
                            padding: const EdgeInsets.only(left: 8),

                            child: IgnorePointer(
                              ignoring: !filterSelected,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                              
                                children: [
                              
                                  CustomText('Academic Year'),
                              
                                  const SizedBox(height: 8),
                              
                                  CustomDropdownButton<int>(
                                    hint: 'Select Year',
                                    controller: academicYearController, 
                                    items: List<int>.generate(DateTime.now().year - 2010, (index) => 2011 + index),
                                    onChanged: (newValue) => onDropDownValueChanged()
                                  ),
                              
                              
                                  const SizedBox(height: 8,),
                              
                              
                                  CustomText('Semester'),
                              
                                  const SizedBox(height: 8),
                              
                                  CustomDropdownButton<int>(
                                    hint: 'Select Semester',
                                    controller: semesterController, 
                                    items: [1, 2],
                                    onChanged: (newValue) => onDropDownValueChanged()
                                  ),
                                  
                              
                                  const SizedBox(height: 8,),
                              
                                  CustomText('Department'),
                              
                                  const SizedBox(height: 8),
                              
                                  //todo: populate with the departments.
                                  CustomDropdownButton<Department>(
                                    hint: 'Select Department',
                                    controller: departmentController, 
                                    items: Provider.of<SelcProvider>(context).departments,
                                    onChanged: (newValue) => onDropDownValueChanged()
                                  ),
                              
                                  Divider(),
                              
                                  CustomButton.withText(
                                    'Clear',
                                    width: double.infinity,
                                    onPressed: () => setState(() {
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



                  const SizedBox(width: 12),


                  //todo: actual table.

                  Expanded(
                    flex: 2,
                    child: Container(  
                      padding: const EdgeInsets.all(8),
                      width: double.infinity,
                      height: double.infinity,

                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12)
                      ),


                      child: Column(  
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,

                        children: [

                          //todo: the table column headers.
                          buildTableHeader(),


                          if(isLoading) Expanded(  
                            child: Center(  
                              child: CircularProgressIndicator(),
                            ),
                          ),

                          if(!isLoading && lecturersRatings.isEmpty) Expanded(
                            child: Center(  
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  CustomText(
                                    'Lecturers Rate Rankings.',
                                    fontWeight: FontWeight.w600,
                                  ),

                                  CustomText(
                                    'The rating rankings of the lecturers appear here.'
                                  )
                                ],
                              ),
                            ),
                          )else Expanded( //todo: table items.
                            child: ListView.builder(  
                              itemCount: searchController.text.isEmpty ? lecturersRatings.length : applySearchFilter(searchController.text, lecturersRatings).length,
                              itemBuilder: (_, index){

                                LecturerRating lRating;

                                if(searchController.text.isEmpty){
                                  lRating = Provider.of<SelcProvider>(context, listen: false).lecturersRatings[index];
                                }else{
                                  lRating = applySearchFilter(searchController.text, lecturersRatings)[index];
                                }

                                return buildTableRow(
                                  rank: 1 + lecturersRatings.indexOf(lRating), 
                                  lecturerRating: lRating
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

  //todo: table header widget function.
  Container buildTableHeader() {
    return Container(  
      padding: const EdgeInsets.all(8),
      width: double.infinity,

      decoration: BoxDecoration(  
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(8)
      ),


      child: Row(  
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [

          SizedBox(
            width: 150,
            child: CustomText(
              'No.',
              textAlignment: TextAlign.center
            ),
          ),

          Expanded(
            flex: 3, 
            child: CustomText(
              'Lecturer',
              textAlignment: TextAlign.left
            ),
          ),


          Expanded(
            flex: 2,
            child: CustomText(
              'Department',
              textAlignment: TextAlign.left
            ),
          ),


          Expanded(
            child: CustomText(
              'No. of Courses',
              textAlignment: TextAlign.center
            ),
          ),


          Expanded(
            child: CustomText(
              'No. of Students',
              textAlignment: TextAlign.center,
            ),
          ), 




          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [

                Icon(Icons.star, color: Colors.green.shade400, size: 20,),

                CustomText(
                  'Rating',
                  textAlignment: TextAlign.center
                )
              ],
            ),
          ), 


        ],
      ),
    );
  }



  Widget buildTableRow({
    required int rank, 
    required LecturerRating lecturerRating}){


    return Container(  
      padding: const EdgeInsets.all(8),
      child: Row(  
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,

        children: [

          SizedBox(
            width: 150,
            child: CustomText(  
              rank.toString(),
              textAlignment: TextAlign.center
            ),
          ),

          // 3
          Expanded(
            flex: 3,
            child: CustomText(
              lecturerRating.lecturer.name!,
              textAlignment: TextAlign.left
            ),
          ),


          //2
          Expanded(
            flex: 3,
            child: CustomText(
              lecturerRating.lecturer.department!,
              textAlignment: TextAlign.left
            ),
          ),


          //1
          Expanded(
            child: CustomText(
              lecturerRating.numberOfCourses.toString(),
              textAlignment: TextAlign.center
            ),
          ),

          //1
          Expanded(
            child: CustomText(
              lecturerRating.numberOfStudents.toString(),
              textAlignment: TextAlign.center
            ),
          ),



          //1
          Expanded(
            child: CustomText(
              lecturerRating.parameterRating.toStringAsFixed(2),
              textAlignment: TextAlign.center
            ),
          ),

        ]
      ),
    );

  }




  List<LecturerRating> applySearchFilter(String searchText, List<LecturerRating> ratings){
    return ratings.where((rating) => rating.lecturer.name!.toLowerCase().contains(searchText.toLowerCase()) ||
          rating.lecturer.department!.toLowerCase().contains(searchText.toLowerCase())).toList();
  }



  void onDropDownValueChanged() async {

    Map<String, dynamic> filterMap = {};

    Department? department = departmentController.value;

    if(department != null){
      filterMap.addAll({'department': department.departmentId});
    }


    int? year = academicYearController.value;

    if(year != null){
      filterMap.addAll({'year': year});
    }


    int? semester = semesterController.value;

    if(semester != null){
      filterMap.addAll({'semester': semester});
    }


    loadLecturerRatingsData(filterMap: filterMap);

  }
}