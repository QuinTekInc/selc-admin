

import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:selc_admin/components/alert_dialog.dart';
import 'package:selc_admin/components/text.dart';
import 'package:selc_admin/model/models.dart';
import 'package:selc_admin/pages/lecturer_info_page.dart';
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
    filteredLecturer = Provider.of<SelcProvider>(context, listen: false).lecturers;
  }


  void loadData() async{

    setState(() => isLoading = true);


    try{
      await Provider.of<SelcProvider>(context, listen: false).getLecturers();
    }on SocketException{
      showNoConnectionAlertDialog(context);
    }on Error{
      showCustomAlertDialog(context, title: 'Error', contentText: 'An unexpected error occurred please try again');
    }



    setState((){
      isLoading = false;
      filteredLecturer = Provider.of<SelcProvider>(context, listen: false).lecturers;
    });

  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [


          Row(
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

                onPressed: () => loadData(),
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



          //search text field
          Container(
            width: MediaQuery.of(context).size.width * 0.45,
            alignment: Alignment.centerLeft,
            padding: EdgeInsets.symmetric(vertical: 8),
            child: CustomTextField(
              controller: searchController,
              leadingIcon: CupertinoIcons.search,
              useLabel: false,
              hintText: 'Search by name or department...',
              onChanged: (String newValue) => setState(() {

                if(newValue.isEmpty) {
                  filteredLecturer = Provider.of<SelcProvider>(context, listen: false).lecturers;
                  return;
                }


                filteredLecturer = Provider.of<SelcProvider>(context, listen: false).lecturers.where((lecturer){
                  return lecturer.name.toLowerCase().contains(newValue.toLowerCase()) ||
                          lecturer.department.toLowerCase().contains(newValue.toLowerCase());
                }).toList();

              })
            ),
          ),




          const SizedBox(height: 8),



          if(isLoading) const Expanded(
            child: Center(child: CircularProgressIndicator(),),
          )
          else if(!isLoading && filteredLecturer.isEmpty) Expanded(
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
          )
          else Expanded(
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

          return LecturerCell(lecturer: lecturer);
        }
      ),
    );
  }
}





//todo: the lecturer cell.
class LecturerCell extends StatefulWidget {
  final Lecturer lecturer;

  const LecturerCell({super.key, required this.lecturer});

  @override
  State<LecturerCell> createState() => _LecturerCellState();
}

class _LecturerCellState extends State<LecturerCell> {

  final Color transparentColor = Colors.transparent;
  final Color hoverColor = Colors.green.shade400;

  Color borderColor = Colors.transparent;
  double elevation = 3;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onHover: (_) => setState(() {
        borderColor = hoverColor;
        elevation = 10;
      }),
      
      onExit: (_) => setState(() {
        borderColor = transparentColor;
        elevation = 3;
      }),

      child: Card( 
        elevation: elevation, 
            
        shape: RoundedRectangleBorder(  
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: borderColor, width: 1.5)
        ),
            
        child: GestureDetector(
          onTap: () {
            Provider.of<PageProvider>(context, listen: false).pushPage(
              LecturerInfoPage(lecturer: widget.lecturer,),//LecturerInfoPage(lecturer: widget.lecturer,),
              'Lecturer Information'
            );
          },
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
                          widget.lecturer.name, 
                          fontSize: 16, 
                          fontWeight: FontWeight.w600,
                          softwrap: true,
                          maxLines: 1,
                        ),
                        
                        Expanded(
                          child: CustomText(
                            widget.lecturer.department, 
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
      ),
    );
  }
}