
//export evaluation information to microsoft excel file at the admin level

import 'dart:io';

import 'package:excel/excel.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:selc_admin/model/models.dart';
import 'package:selc_admin/providers/selc_provider.dart';

import '../providers/pref_provider.dart';



class AdminReportExcelExport{

  final BuildContext context;

  late final Excel _excel;

  final List<ClassCourse> classCourses;

  final List<DashboardCategoriesSummary> categoriesSummary;

  final List<DashboardSuggestionSentiment> suggestionSentiments;



  final headerCellStyle = CellStyle(
      bold: true,
      fontSize: 12,
      horizontalAlign: HorizontalAlign.Center,
      verticalAlign: VerticalAlign.Center,
      textWrapping: TextWrapping.WrapText
  );


  final CellStyle textCellStyle = CellStyle(
      verticalAlign: VerticalAlign.Top,
      horizontalAlign: HorizontalAlign.Left,
      textWrapping: TextWrapping.WrapText
  );


  final CellStyle numberCellStyle = CellStyle(
      verticalAlign: VerticalAlign.Top,
      horizontalAlign: HorizontalAlign.Right,
      textWrapping: TextWrapping.WrapText
  );



  AdminReportExcelExport({
    required this.context, required this.classCourses, required this.categoriesSummary, required this.suggestionSentiments}){

    _excel = Excel.createExcel();

    buildCourseScoresSheet();
    buildCoreAreaSheet();
    buildResponseRateSheet();
    buildLecturerRatingSheet();
    buildSuggestionSentimentSheet();
  }



  void _buildWorkSheetHeader({rowIndex = 0, required List<String>headers, required Sheet sheet}){

    int colIndex = 0;

    for(String header in headers){
      sheet.cell(
          CellIndex.indexByColumnRow(columnIndex: colIndex, rowIndex: rowIndex))
        ..value = TextCellValue(header)
        ..cellStyle = headerCellStyle;

      colIndex++;
    }

  }




  void buildResponseRateSheet(){

    final sheet = _excel['Response Rates'];


    //title the current sheet.
    sheet.cell(
        CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0))
    ..value = TextCellValue('Response Rates')
    ..cellStyle = headerCellStyle;


    //create the cell headers.
    List<String> headers = [
      'Lecturer',
      'Department',
      'Course Title',
      'Course Code',
      'Number of Students',
      'Evaluated Students',
      'Response Rate (%)'
    ];


    //span the title rows to extend to the last col index of the headers row.
    sheet.merge(
      CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0),
      CellIndex.indexByColumnRow(columnIndex: headers.length - 1, rowIndex: 0)
    );

    //create the table headers with row index starting from 1
    _buildWorkSheetHeader(rowIndex: 1, headers: headers, sheet: sheet);


    //start from the third row
    int rowIndex = 2;


    for(ClassCourse classCourse in classCourses){

      //lecturer name
      sheet.cell(
          CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: rowIndex))
      ..value = TextCellValue(classCourse.lecturer.name)
      ..cellStyle = textCellStyle;

      //department
      sheet.cell(
          CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: rowIndex))
        ..value = TextCellValue(classCourse.lecturer.department)
        ..cellStyle = textCellStyle;


      //course title
      sheet.cell(
          CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: rowIndex))
        ..value = TextCellValue(classCourse.course.title)
        ..cellStyle = textCellStyle;


      //course code
      sheet.cell(
          CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: rowIndex))
        ..value = TextCellValue(classCourse.course.courseCode)
        ..cellStyle = textCellStyle;


      //number of students who have registered for this courses.
      sheet.cell(
          CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: rowIndex))
        ..value = IntCellValue(classCourse.registeredStudentsCount)
        ..cellStyle = numberCellStyle;


      //number of students who have evaluated this course.
      sheet.cell(
          CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: rowIndex))
        ..value = IntCellValue(classCourse.evaluatedStudentsCount)
        ..cellStyle = numberCellStyle;


      //response rate.
      sheet.cell(
          CellIndex.indexByColumnRow(columnIndex: 6, rowIndex: rowIndex))
        ..value = DoubleCellValue(classCourse.calculateResponseRate())
        ..cellStyle = numberCellStyle;

      rowIndex++;
    }

  }




  //generate the core area stuff.
  void buildCoreAreaSheet(){

    final sheet = _excel['Core Area'];

    sheet.cell(
        CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0))
      ..value = TextCellValue('Thematic Areas of Evaluation (Core Areas or Categories)')
      ..cellStyle = headerCellStyle;

    //todo: here wee have to write the headers by hand


    //lecturer header cell
    sheet.cell(
      CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 1))
      ..value = TextCellValue('Lecturer')
      ..cellStyle = headerCellStyle;

    //department header cell
    sheet.cell(
        CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: 1))
      ..value = TextCellValue('Department')
      ..cellStyle = headerCellStyle;

    //Course title header cell
    sheet.cell(
        CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: 1))
      ..value = TextCellValue('Course Title')
      ..cellStyle = headerCellStyle;



    //Course code header cell
    sheet.cell(
        CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: 1))
      ..value = TextCellValue('Course Code')
      ..cellStyle = headerCellStyle;


    //Core Area header cell
    sheet.cell(
        CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: 1))
      ..value = TextCellValue('Core Areas (Categories)')
      ..cellStyle = headerCellStyle;


    //todo: span the rows of lecturer department, course title, and course code
    //lecturer
    sheet.merge(
        CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 1),
        CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 2)
    );


    //department
    sheet.merge(
        CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: 1),
        CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: 2)
    );


    //course title
    sheet.merge(
        CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: 1),
        CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: 2)
    );


    //course code
    sheet.merge(
        CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: 1),
        CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: 2)
    );

    //the categories will be the sub headers of the core areas.
    List<String> categories = Provider.of<SelcProvider>(context, listen: false)
                              .categories.map((cat) => cat.categoryName).toList();

    int columnIndex = 4;
    //we start the current index from
    for(String category in categories){
      sheet.cell(
          CellIndex.indexByColumnRow(columnIndex: columnIndex, rowIndex: 2))
        ..value = TextCellValue(category)
        ..cellStyle = headerCellStyle;

      //todo: should I add categories percentage scores to it?

      columnIndex++;
    }


    //todo: span the columns of the overall sheet header.
    sheet.merge(
      CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0),
      CellIndex.indexByColumnRow(columnIndex: 4 + categories.length - 1, rowIndex: 0)
    );


    //todo: span the cols of the "Core areas" headers to have the same width as the combined cells of the subheaders
    sheet.merge(
      CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: 1),
      CellIndex.indexByColumnRow(columnIndex: 4 + categories.length - 1, rowIndex: 1)
    );




    //now to populate the actual data corresponding to the headers
    int rowIndex = 3; //after populating the headers, the next rowIndex start data population is row 3, (4th row)


    for(DashboardCategoriesSummary catSummary in categoriesSummary){

      //lecturer name
      sheet.cell(
        CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: rowIndex))
        ..value = TextCellValue(catSummary.lecturerName)
        ..cellStyle = textCellStyle;

      //lecturer department
      sheet.cell(
          CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: rowIndex))
        ..value = TextCellValue(catSummary.department)
        ..cellStyle = textCellStyle;

      //course title
      sheet.cell(
          CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: rowIndex))
        ..value = TextCellValue(catSummary.course.title)
        ..cellStyle = textCellStyle;

      //course code
      sheet.cell(
          CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: rowIndex))
        ..value = TextCellValue(catSummary.course.courseCode)
        ..cellStyle = textCellStyle;


      //now to populate the values for the various categories.
      int colIndex = 4;

      for(CategoryRemark catRemark in catSummary.categoryRemarks){

        sheet.cell(
          CellIndex.indexByColumnRow(columnIndex: colIndex, rowIndex: rowIndex))
          ..value = DoubleCellValue(catRemark.meanScore)
          ..cellStyle = numberCellStyle;

        colIndex++;
      }


      rowIndex++;
    }

  }



  //average scores for each ClassCourse after the course evaluation
  void buildCourseScoresSheet(){


    final sheet = _excel['Course Scores'];

    //title of the current sheet.
    sheet.cell(
      CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0))
      ..value = TextCellValue('Courses and their scores')
      ..cellStyle = headerCellStyle;


    final List<String> headers = [
      'Lecturer',
      'Department',
      'Course Title',
      'Course Code',
      'Average Score',
      'Percentage Score',
      'Remark'
    ];

    //merge the rows of the current sheet.
    sheet.merge(
      CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0),
      CellIndex.indexByColumnRow(columnIndex: headers.length - 1, rowIndex: 0));


    //build the headers.
    _buildWorkSheetHeader(rowIndex: 1,headers: headers, sheet: sheet);


    int rowIndex = 2;

    for(ClassCourse classCourse in classCourses){

      //lecturer name
      sheet.cell(
          CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: rowIndex))
        ..value = TextCellValue(classCourse.lecturer.name)
        ..cellStyle = textCellStyle;

      //department
      sheet.cell(
          CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: rowIndex))
        ..value = TextCellValue(classCourse.lecturer.department)
        ..cellStyle = textCellStyle;


      //course title
      sheet.cell(
          CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: rowIndex))
        ..value = TextCellValue(classCourse.course.title)
        ..cellStyle = textCellStyle;


      //course code
      sheet.cell(
          CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: rowIndex))
        ..value = TextCellValue(classCourse.course.courseCode)
        ..cellStyle = textCellStyle;


      //average score
      sheet.cell(
          CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: rowIndex))
        ..value = DoubleCellValue(classCourse.grandMeanScore)
        ..cellStyle = numberCellStyle;


      //percentage score
      sheet.cell(
          CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: rowIndex))
        ..value = DoubleCellValue(classCourse.grandPercentageScore)
        ..cellStyle = numberCellStyle;


      //response rate.
      sheet.cell(
          CellIndex.indexByColumnRow(columnIndex: 6, rowIndex: rowIndex))
        ..value = TextCellValue(classCourse.remark ?? 'N/A')
        ..cellStyle = textCellStyle;

      rowIndex++;

    }

  }





  void buildLecturerRatingSheet(){

    final sheet = _excel['Lecturer Ratings'];

    //title of the current sheet.
    sheet.cell(
        CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0))
      ..value = TextCellValue('Courses and their scores')
      ..cellStyle = headerCellStyle;


    final List<String> headers = [
      'Lecturer',
      'Department',
      'Course Title',
      'Course Code',
      'Number of Respondents(Students)',
      'Average Rating',
      'Remark'
    ];

    //merge the rows of the current sheet.
    sheet.merge(
        CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0),
        CellIndex.indexByColumnRow(columnIndex: headers.length - 1, rowIndex: 0));


    _buildWorkSheetHeader(rowIndex: 1, headers: headers, sheet: sheet);

    //start from the third row.
    int rowIndex = 2;

    for(ClassCourse classCourse in classCourses){

      //lecturer name
      sheet.cell(
          CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: rowIndex))
        ..value = TextCellValue(classCourse.lecturer.name)
        ..cellStyle = textCellStyle;

      //department
      sheet.cell(
          CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: rowIndex))
        ..value = TextCellValue(classCourse.lecturer.department)
        ..cellStyle = textCellStyle;


      //course title
      sheet.cell(
          CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: rowIndex))
        ..value = TextCellValue(classCourse.course.title)
        ..cellStyle = textCellStyle;


      //course code
      sheet.cell(
          CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: rowIndex))
        ..value = TextCellValue(classCourse.course.courseCode)
        ..cellStyle = textCellStyle;


      //number of respondents (or students who have rated this lecturer for this course)
      sheet.cell(
          CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: rowIndex))
        ..value = IntCellValue(classCourse.evaluatedStudentsCount)
        ..cellStyle = numberCellStyle;


      //average rating
      sheet.cell(
          CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: rowIndex))
        ..value = DoubleCellValue(classCourse.lecturerRating)
        ..cellStyle = numberCellStyle;


      //remark rate.
      sheet.cell(
          CellIndex.indexByColumnRow(columnIndex: 6, rowIndex: rowIndex))
        ..value = TextCellValue(classCourse.remark ?? 'N/A')
        ..cellStyle = textCellStyle;

      rowIndex++;


    }


  }



  void buildSuggestionSentimentSheet(){

    final sheet = _excel['Suggestion Sentiments'];



    //title of the current sheet.
    sheet.cell(
        CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0))
      ..value = TextCellValue('Suggestion Sentiments for each course and lecturer analysis')
      ..cellStyle = headerCellStyle;



    final List<String> headers = [
      'Lecturer',
      'Course Title',
      'Course Code',
      'Negative',
      'Neg (%)',
      'Neutral',
      'Neu (%)',
      'Positive',
      'Pos (%)'
    ];



    //merge the rows of the current sheet.
    sheet.merge(
        CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0),
        CellIndex.indexByColumnRow(columnIndex: headers.length - 1, rowIndex: 0));


    //build the table headers.
    _buildWorkSheetHeader(rowIndex: 1, headers: headers, sheet: sheet);


    int rowIndex = 2;
    

    for(DashboardSuggestionSentiment dss in suggestionSentiments){

      //lecturer name
      sheet.cell(
          CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: rowIndex))
        ..value = TextCellValue(dss.lecturerName)
        ..cellStyle = textCellStyle;


      //course title
      sheet.cell(
          CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: rowIndex))
        ..value = TextCellValue(dss.course.title)
        ..cellStyle = textCellStyle;


      //course code
      sheet.cell(
          CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: rowIndex))
        ..value = TextCellValue(dss.course.courseCode)
        ..cellStyle = textCellStyle;


      int colIndex = 2;

      for(var sentimentObj in dss.sentimentSummary){

        //sentiment count
        sheet.cell(
            CellIndex.indexByColumnRow(columnIndex: colIndex, rowIndex: rowIndex))
          ..value = IntCellValue(sentimentObj.sentimentCount)
          ..cellStyle = numberCellStyle;


        //sentiment percentage count
        sheet.cell(
            CellIndex.indexByColumnRow(columnIndex: colIndex + 1, rowIndex: rowIndex))
          ..value = DoubleCellValue(sentimentObj.sentimentPercent)
          ..cellStyle = numberCellStyle;


        colIndex += 2;
      }


      rowIndex++;
    }




  }



  void save(){


    final fileBytes = _excel.save();


    final fileName = 'selc_admin_${classCourses[0].year}_${classCourses[0].semester}.xlsx';

    final downloadPath = Provider.of<PreferencesProvider>(context, listen: false).preferences.defaultDownloadDirectory;

    final fullFilePath = '$downloadPath/$fileName';

    final file = File(fullFilePath);

    if(!file.existsSync()){
      file.createSync(recursive: true);
    }


    file.writeAsBytesSync(fileBytes!);


    //if the file is saved successfully,
    if(!file.existsSync()){

      try{
        //Provider.of<PreferencesProvider>(context, listen: false).addSavedFile(fullFilePath);
      }on Exception catch(_){
        //do nothing here
      }

    }

    //it must be registered in the files section


  }

}