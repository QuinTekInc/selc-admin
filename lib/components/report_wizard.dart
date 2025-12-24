
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:selc_admin/components/alert_dialog.dart';
import 'package:selc_admin/components/button.dart';
import 'package:selc_admin/components/donwloader_util/file_downloader.dart';
import 'package:selc_admin/components/text.dart';
import 'package:selc_admin/model/models.dart';
import 'package:selc_admin/providers/pref_provider.dart';
import 'package:selc_admin/providers/selc_provider.dart';


class ReportWizard extends StatefulWidget {

  const ReportWizard({super.key,});

  @override
  State<ReportWizard> createState() => _ReportWizardState();

}

class _ReportWizardState extends State<ReportWizard> {

  final reportTypeController = DropdownController<String>();

  final fileTypeController = DropdownController<String>();
  
  final departmentController = DropdownController<Department>();

  final classCourseController = DropdownController<ClassCourse>();

  final semesterController = DropdownController<int>();
  final yearController = DropdownController<int>();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    return Container(
      padding: const EdgeInsets.all(16),
      width: MediaQuery.of(context).size.width * 0.25,
      margin: const EdgeInsets.fromLTRB(0, 12, 0, 12),

      decoration: BoxDecoration(
        color: PreferencesProvider.getColor(context, 'primary-color'),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.shade400, width: 1.5)
      ),

      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [

          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              HeaderText('Report Wizard'),

              Spacer(),

              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Icon(CupertinoIcons.xmark, color: Colors.red.shade400,),
              )
            ],
          ),

          const SizedBox(height: 16,),


          //todo: report_type

          CustomText('Report Type: '),

          const SizedBox(height: 8,),

          CustomDropdownButton<String>(
            controller: reportTypeController,
            hint: 'Select Report Type',
            items: ['Admin', 'Department', 'Class Course'],
            onChanged: (newValue) => setState(() {})
          ),


          const SizedBox(height: 12,),



          //todo: file_extension
          CustomText('File Type: '),

          const SizedBox(height: 8,),

          CustomDropdownButton<String>(
            controller: fileTypeController,
            hint: 'Select File Type',
            items: ['.xlsx', '.pdf'],
            onChanged: (newValue) => setState(() {})
          ),


          if(reportTypeController.value != null) const SizedBox(height: 12,),


          if(reportTypeController.value == 'Department') buildDepartmentDropdown(),

          if(reportTypeController.value == 'Class Course') buildClassCourseDropDown(),


          if(["Department", "Admin"].contains(reportTypeController.value))const SizedBox(height: 12,),

          if(["Department", "Admin"].contains(reportTypeController.value)) buildYearSemesterDropdown(),


          const SizedBox(height: 16,),


          CustomButton.withText(
            'Generate / Download',
            width: double.infinity,
            onPressed: handleGenerateReport
          )


        ]
      ),
    );
  }
  
  
  Widget buildDepartmentDropdown() => Column(  
    mainAxisAlignment: MainAxisAlignment.start,
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisSize: MainAxisSize.min,
    spacing: 8,
    children: [
      
      CustomText('Department: '),
      
      
      CustomDropdownButton<Department>(
        controller: departmentController,
        hint: 'Select Department',
        items: Provider.of<SelcProvider>(context).departments, 
        onChanged: (newValue) => setState(() {})
      )
      
    ],
  );



  Widget buildClassCourseDropDown() => Column(
    mainAxisAlignment: MainAxisAlignment.start,
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisSize: MainAxisSize.min,
    spacing: 8,
    children: [

      CustomText('Class Course: '),


      CustomDropdownButton<ClassCourse>(
        controller: classCourseController,
        hint: 'Select ClassCourse',
        items: Provider.of<SelcProvider>(context).classCourses,
        onChanged: (newValue) => setState(() {})
      )

    ],
  );



  Widget buildYearSemesterDropdown() => Column(
    mainAxisAlignment: MainAxisAlignment.start,
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisSize: MainAxisSize.min,
    spacing: 8,
    children: [

      //todo: Academic Year
      CustomText('Academic Year: '),

      CustomDropdownButton<int>(
        controller: yearController,
        hint: 'Select Academic Year',
        items: List<int>.generate(DateTime.now().year - 2011, (index) => DateTime.now().year - index),
        onChanged: (newValue){}
      ),


      const SizedBox(),


      CustomText('Semester: '),

      CustomDropdownButton<int>(
          controller: semesterController,
          hint: 'Select Semester',
          items: [1, 2],
          onChanged: (newValue){}
      ),


    ],
  );




  void handleGenerateReport() async {

    String reportType = formatReportTypeStr(reportTypeController.value ?? '');

    final Map<String, dynamic> reportParams = {
      'report_type': reportType,
    };

    if(['admin', 'department'].contains(reportTypeController.value)){
      reportParams.addAll({
        'semester': semesterController.value,
        'year': yearController.value,
      });
    }


    if(reportType == 'department'){
      reportParams.addAll({'id': departmentController.value!.departmentId});
    }else if(reportType == 'class_course'){
      reportParams.addAll({'id': classCourseController.value!.classCourseId});
    }


    ReportFile? reportFile;

    try {
      reportFile = await Provider.of<PreferencesProvider>(
          context, listen: false).generateReportFile(reportParams);
    } on SocketException{
      showNoConnectionAlertDialog(context);
      return;
    }on Error{
      showCustomAlertDialog(context, title: 'Error', contentText: 'Could not generate report. An unknown error occurred.');
      return;
    }


    if(reportFile == null){
      showCustomAlertDialog(context, title: 'Error', contentText: 'Could not generate report. An unknown error occurred.');
    }

    //download the file immediately after generation
    FileDownloader downloader = getDownloader();

    downloader.download(context: context, reportFile: reportFile!);

  }


  String formatReportTypeStr(String typeStr){
    //replace whitespace with underscore
    typeStr = typeStr.toLowerCase().replaceAll(' ', '_');

    return typeStr;
  }


}
