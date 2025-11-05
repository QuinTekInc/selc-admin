

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:selc_admin/components/alert_dialog.dart';
import 'package:selc_admin/components/button.dart';
import 'package:selc_admin/model/models.dart';
import 'package:selc_admin/providers/selc_provider.dart';

import '../../components/text.dart';


class DepartmentProfilePage extends StatefulWidget {

  final Department department;

  const DepartmentProfilePage({super.key, required this.department});

  @override
  State<DepartmentProfilePage> createState() => _DepartmentProfilePageState();
}

class _DepartmentProfilePageState extends State<DepartmentProfilePage> {


  List<Lecturer> lecturers = [];
  List<ClassCourse> classCourses = [];



  bool isLoading = false;

  @override
  void initState() {
    // TODO: implement initState

    //sort the lecturers who are in this department
    lecturers = Provider.of<SelcProvider>(context, listen: false).lecturers
                        .where((lecturer) => lecturer.department == widget.department.departmentName).toList();

    super.initState();
  }



  void loadData() async {

    setState(() => isLoading = true);

    try{

      //todo: load the necessary data here.

    } on SocketException {
      showNoConnectionAlertDialog(context);
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

        children: [

          HeaderText(
            widget.department.departmentName,
            fontSize: 25,
          ),

          const SizedBox(height: 8,),

          NavigationTextButtons(),





        ],
      ),
    );
  }
}
