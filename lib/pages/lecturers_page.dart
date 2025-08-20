

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:selc_admin/components/text.dart';
import 'package:selc_admin/model/lecturer.dart';
import 'package:selc_admin/pages/lecturer_info_page.dart';
import 'package:selc_admin/providers/page_provider.dart';
import 'package:selc_admin/providers/selc_provider.dart';


class LecturersPage extends StatefulWidget {
  const LecturersPage({super.key});

  @override
  State<LecturersPage> createState() => _LecturersPageState();
}

class _LecturersPageState extends State<LecturersPage> {


  final searchController = TextEditingController();


  bool isLoading = false;
  List<Lecturer> filteredLecturer = [];


  @override
  void initState() {
    // TODO: implement initState

    super.initState();
    loadLecturersData();
  }

  void loadLecturersData() async{

    setState(() => isLoading = true);
    
    await Provider.of<SelcProvider>(context, listen: false).getLecturers();

    setState((){
      isLoading = false;
      filteredLecturer = Provider.of<SelcProvider>(context, listen: false).lecturers;
    });

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [


          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,  
              crossAxisAlignment: CrossAxisAlignment.center,
            
            
              children: [
            
                HeaderText(
                  'Lecturers',
                  fontSize: 25,
                ),


                Spacer(),

                //todo: refresh button.
                IconButton(
                  
                  onPressed: () => loadLecturersData(), 
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
          ),


          Container(
            width: MediaQuery.of(context).size.width * 0.45,
            alignment: Alignment.centerLeft,
            padding: EdgeInsets.symmetric(vertical: 8),
            child: CustomTextField(
              controller: searchController,
              leadingIcon: CupertinoIcons.search,
              useLabel: false,
              hintText: 'Search by name or dept....',
              onChanged: (String newValue) => setState(() {
                
                if(newValue.isEmpty) {
                  filteredLecturer = Provider.of<SelcProvider>(context, listen: false).lecturers;
                  return;
                }


                filteredLecturer = Provider.of<SelcProvider>(context, listen: false).lecturers.where((lecturer){
                  return lecturer.name!.toLowerCase().contains(newValue.toLowerCase()) || 
                          lecturer.department!.toLowerCase().contains(newValue.toLowerCase());
                }).toList();

              })
            ),
          ),



          if(isLoading) const Expanded(   
            child: Center(child: CircularProgressIndicator(),),
          ),


          if(filteredLecturer.isEmpty && !isLoading) Expanded(  
            child: Center(  
              child: Column(  
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,

                children: [

                  CustomText(
                    'No Lecturer Data',
                    fontWeight: FontWeight.bold,
                    textAlignment: TextAlign.center,
                  ),

                  CustomText(  
                    'The list of lecturers appear here.',
                    textAlignment: TextAlign.center,
                  )
                ]
              ),
            ),
          )else Expanded(  
            child: buildLecturersGridView(context, filteredLecturer),
          ),

        ],
      ),
    );
  }

  Widget buildLecturersGridView(BuildContext context, List<Lecturer> lecturers) {

    return Padding(
      padding: const EdgeInsets.only(  
        left: 8,
        right: 8, 
        bottom: 8
      ),

      child: GridView.builder(
        
        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
          //crossAxisCount: (MediaQuery.of(context).size.width / 200).toInt(),
          maxCrossAxisExtent: 250,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          mainAxisExtent: 230
        ),
      
        itemCount: lecturers.length,
        itemBuilder: (_, index) {

          Lecturer lecturer = lecturers[index];

          return Card( 
            elevation: 5, 
                
            shape: RoundedRectangleBorder(  
              borderRadius: BorderRadius.circular(8)
            ),
                
            child: GestureDetector(
              onTap: () => Provider.of<PageProvider>(context, listen: false).pushPage(
                LecturerInfoPage(lecturer: lecturer,),
                'Lecturer Information'
              ),
              child: Container(  
                height: 200,
                width: 200,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                ),
              
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(  
                      height: 150,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.green.shade300,
                        borderRadius: BorderRadius.vertical(top: Radius.circular(8))
                      ),
                      child: Icon(CupertinoIcons.person, color: Colors.white, size: 50,),
                    ),
              
                    Expanded(
                      child: Container(
                        alignment: Alignment.topLeft,
                        width: double.maxFinite,
                        height: double.maxFinite,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,  
                          children: [
          
                            CustomText(
                              lecturer.name!, 
                              fontSize: 16, 
                              fontWeight: FontWeight.w600,
                              softwrap: true,
                              maxLines: 1,
                            ),
                            
                            Expanded(
                              child: CustomText(
                                lecturer.department!, 
                                fontSize: 14, 
                                fontWeight: FontWeight.w500,
                                softwrap: true,
                                maxLines: 2,
                              ),
                            )
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          );
        }
      ),
    );
  }
}