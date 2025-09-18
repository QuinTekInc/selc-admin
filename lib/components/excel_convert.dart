

import 'dart:io';
import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:selc_admin/model/models.dart';
import 'package:selc_admin/providers/pref_provider.dart';



class ExcelExporter{

  final ClassCourse classCourse;
  final List<CourseEvaluationSummary> questionnaireData;
  final List<Map<String, dynamic>> categoryData;
  final List<LecturerRating> ratingSummary;
  final List<SuggestionSentimentSummary> sentimentSummary;

  late final Excel _excel;


  ExcelExporter({
    required this.classCourse,
    required this.questionnaireData,
    required this.categoryData,
    required this.ratingSummary,
    required this.sentimentSummary
  }){

    _excel = Excel.createExcel();

    _populateQuestionnaireSheet();
    _populateCategorySheet();
    _populateSuggestionSentimentSummary();
  }


  void _populateQuestionnaireSheet() {

    //todo: sample for testing purposes
    /*final data = [
    {
      'question': 'Coverage of course content by lecturer',
      'answer_type': 'performance',
      'answer_summary': {
        'Poor': 0,
        'Average': 0,
        'Good': 0,
        'Very Good': 1,
        'Excellent': 0,
      },
      'percentage_score': 80.0,
      'average_score': 4.0,
      'remark': 'Very Good'
    },
    {
      'question': 'Communication of objectives of the course',
      'answer_type': 'performance',
      'answer_summary': {
        'Poor': 0,
        'Average': 0,
        'Good': 0,
        'Very Good': 1,
        'Excellent': 0,
      },
      'percentage_score': 80.0,
      'average_score': 4.0,
      'remark': 'Very Good'
    }
  ];*/

    final sheet = _excel['Questionnaire Summary']; //creates a work sheet called "Questionnaire Summary"
    _excel.setDefaultSheet('Questionnaire Summary'); //Makes the questionnaire summary the default work sheet.

    // Headers
    final headers = [
      "Question",
      "Answer Type",
      "Option",
      "Count",
      "Average Score",
      "Percentage Score(%)",
      "Remark"
    ];

    //todo: add the headers to the table.
    sheet.appendRow(
        List<CellValue>.from(headers.map((value) => TextCellValue(value))
            .toList()));

    int rowIndex = 1; // Because row 0 is headers

    for (var questionEval in questionnaireData) {

      final options = questionEval.answerSummary as Map<String, dynamic>;
      final numOptions = options.length;

      int startRow = rowIndex;
      int endRow = rowIndex + numOptions - 1; //calculate the number of spans

      //todo: Fill answer_summary cols and row.
      options.forEach((option, count) {
        sheet
            .cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: rowIndex))
            .value = TextCellValue(option);
        sheet
            .cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: rowIndex))
            .value = IntCellValue(count);

        rowIndex++;
      });


      //todo: Merge and fill question
      //Make rows of the question to to span according ot the number
      //of rows taken by the answer summary of the question item
      sheet.merge(
          CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: startRow),
          CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: endRow));

      //populate the merged rows with the actual question
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: startRow))
          .value = TextCellValue(questionEval.question.toString());


      //todo: Merge and fill Answer Type
      sheet.merge(
          CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: startRow),
          CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: endRow));

      //populate the answer type
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: startRow))
          .value = TextCellValue(questionEval.answerType.typeString);

      //todo: Merge and fill Average Score
      sheet.merge(
          CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: startRow),
          CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: endRow));

      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: startRow))
          .value = DoubleCellValue((questionEval.meanScore as num).toDouble());

      //todo: Merge and fill Percentage Score
      sheet.merge(
          CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: startRow),
          CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: endRow));

      //fill with the percentage score
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: startRow))
          .value = DoubleCellValue((questionEval.percentageScore as num).toDouble());

      //todo: Merge and fill Remark
      sheet.merge(
          CellIndex.indexByColumnRow(columnIndex: 6, rowIndex: startRow),
          CellIndex.indexByColumnRow(columnIndex: 6, rowIndex: endRow));

      //fill with the remark
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 6, rowIndex: startRow))
          .value = TextCellValue(questionEval.remark);
    }


  }



  void _populateCategorySheet(){

    final sheet = _excel['Category Summary'];
    _excel.setDefaultSheet(sheet.sheetName);

    final List<String> headers = [
      'Core Area (Category)',
      'Questions',
      'Mean Score',
      'Percentage Score(%)',
      'Remark'
    ];


    sheet.appendRow(
        List<CellValue>.from(
            headers.map((header) => TextCellValue(header)).toList())
    );


    int rowIndex = 1; //because the first row has been populated with the headers

    for(var entry in categoryData){

      String categoryName = entry['category'];
      List<String> questions = entry['questions'];
      double meanScore = entry['mean_score'].toDouble();
      double percentage = entry['percentage_score'].toDouble();
      String remark = entry['remark'];

      int startRow = rowIndex;
      int endRow = startRow + questions.length - 1; //calculate the number of spans


      //to be able to merge the rows we must first work on the questions' rows
      questions.forEach((question) {
        sheet.cell(
            CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: rowIndex))
            .value = TextCellValue(question);

        rowIndex++;
      });


      //merge the category
      sheet.merge(
          CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: startRow),
          CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: endRow)
      );

      //fill category
      sheet.cell(
          CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: startRow))
          .value = TextCellValue(categoryName);



      //merge the mean score rows
      sheet.merge(
          CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: startRow),
          CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: endRow)
      );

      //fill mean score
      sheet.cell(
          CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: startRow))
          .value = DoubleCellValue(meanScore);


      //merge the percentage rows
      sheet.merge(
          CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: startRow),
          CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: endRow)
      );

      //fill percentage
      //fill mean score
      sheet.cell(
          CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: startRow))
          .value = DoubleCellValue(percentage);


      //merge remark rows
      sheet.merge(
          CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: startRow),
          CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: endRow)
      );

      //fill remark
      //fill mean score
      sheet.cell(
          CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: startRow))
          .value = TextCellValue(remark);

    }

  }




  void _populateSuggestionSentimentSummary(){

    final sheet = _excel['suggestion_summary'];

    sheet.toString();

  }



  void save(BuildContext context){
    // Save file
    final fileBytes = _excel.save();

    int academicYear = classCourse.year;
    int semester = classCourse.semester;
    String lecturerName = classCourse.lecturer.name;
    String courseCode = classCourse.course.courseCode;


    final fileName = '${academicYear}_${semester}_${lecturerName}_$courseCode.xlsx';

    final downloadPath = Provider.of<PreferencesProvider>(context, listen: false).preferences.defaultDownloadDirectory;

    final fullFilePath = '$downloadPath/$fileName';

    File(fullFilePath)
      ..createSync(recursive: true)
      ..writeAsBytesSync(fileBytes!);


    
    //if the file is saved succesfully, 
    Provider.of<PreferencesProvider>(context, listen: false).preferences.savedFiles.add(fullFilePath);
    //it must be registered in the files section


  }

}




