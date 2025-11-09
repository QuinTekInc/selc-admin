
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:selc_admin/components/alert_dialog.dart';
import 'package:selc_admin/components/text.dart';
import 'package:selc_admin/model/models.dart';
import 'package:selc_admin/pages/department_management/department_profile.dart';
import 'package:selc_admin/providers/selc_provider.dart';

import '../../providers/page_provider.dart';


class DepartmentsPage extends StatefulWidget {
  const DepartmentsPage({super.key});

  @override
  State<DepartmentsPage> createState() => _DepartmentsPageState();
}

class _DepartmentsPageState extends State<DepartmentsPage> {

  final searchController = TextEditingController();

  List<Department> filteredDepartments = [];

  bool isLoading = false;

  @override
  void initState() {
    // TODO: implement initState

    filteredDepartments = Provider.of<SelcProvider>(context, listen: false).departments;

    super.initState();
  }



  void loadData() async {
    setState(() => isLoading = true);

    try{

      await Provider.of<SelcProvider>(context, listen: false).getDepartments();
      filteredDepartments = Provider.of<SelcProvider>(context, listen: false).departments;

    }on SocketException{
      showNoConnectionAlertDialog(context);
    }on Exception{
      showCustomAlertDialog(context, title: 'Error', contentText: 'An unexpected error occurred. Please try again');
    }


    setState(() => isLoading = false);
  }



  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 12,

        children: [

          //Header
          Row(
            children: [
              HeaderText('Departments', fontSize: 25,),

              Spacer(),


              TextButton.icon(
                onPressed: loadData,
                icon: Icon(CupertinoIcons.refresh, color: Colors.green.shade300,),
                label: CustomText('Refresh', textColor: Colors.green.shade300,)
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
              hintText: 'Search department by name...',
              onChanged: (String newValue) => setState(() {

                //todo: code to run if the SearchField values is empty or null

                if(searchController.text.isEmpty){
                  setState(() => filteredDepartments = Provider.of<SelcProvider>(context, listen: false).departments);
                  return;
                }


                //convert the search field to lowercase.
                String searchLower = searchController.text.toLowerCase();

                //todo: code to run when value is found
                filteredDepartments = Provider.of<SelcProvider>(context, listen: false).departments
                                          .where((department) => department.departmentName.toLowerCase().contains(searchLower))
                                          .toList();

                setState(() {});


              })
            ),
          ),



          if(isLoading)Expanded(
            child: CircularProgressIndicator()
          )
          else if(!isLoading && filteredDepartments.isEmpty) Expanded(
            child: CollectionPlaceholder(detail: 'All Departments appear here.'),
          )
          else Expanded(
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                //crossAxisCount: (MediaQuery.of(context).size.width / 200).toInt(),
                  maxCrossAxisExtent: 250,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  mainAxisExtent: 230
              ),

              itemCount: filteredDepartments.length,

              itemBuilder: (_, index){
                return DepartmentCell(department: filteredDepartments[index]);
              }
            ),
          )


        ],
      ),
    );
  }



  void applySearchFilter(){

  }


}




//department cell.
class DepartmentCell extends StatefulWidget {

  final Department department;

  const DepartmentCell({super.key, required this.department});

  @override
  State<DepartmentCell> createState() => _DepartmentCellState();
}

class _DepartmentCellState extends State<DepartmentCell> {

  final hoverColor = Colors.green.shade400;
  Color borderColor = Colors.transparent;

  double elevation = 3;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(

      onHover: (mouseEvent) => setState(() => borderColor = hoverColor),
      onExit: (mouseEvent) => setState(() => borderColor = Colors.transparent),

      child:  Card(
        elevation: elevation,

        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(color: borderColor, width: 1.5)
        ),

        child: GestureDetector(
          onTap: () => Provider.of<PageProvider>(context, listen: false).pushPage(
              DepartmentProfilePage(department: widget.department,),
              'Department Information'
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
                  child: Icon(CupertinoIcons.home, color: Colors.white, size: 50,),
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
                          widget.department.departmentName,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          softwrap: true,
                          maxLines: 3,
                        ),

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
