

import 'dart:io';
import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:selc_admin/model/models.dart';
import 'package:selc_admin/providers/pref_provider.dart';



class ExcelExporter{

  final ClassCourse classCourse;
  final List<CourseEvaluationSummary> questionnaireData;
  final List<CategoryEvaluation> categoryData;
  final List<EvalLecturerRatingSummary> ratingSummary;
  final List<SuggestionSentimentSummary> sentimentSummary;

  late final Excel _excel;


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
    _populateLecturerRatingSheet();
    _populateSuggestionSentimentSummary();
  }


  void _buildWorkSheetHeader({required List<String>headers, required Sheet sheet}){

    int colIndex = 0;

    for(String header in headers){
      sheet.cell(
        CellIndex.indexByColumnRow(columnIndex: colIndex, rowIndex: 0))
          ..value = TextCellValue(header)
          ..cellStyle = headerCellStyle;
      
      colIndex++;
    }

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


    // sheet.appendRow(
    //   headers.map((header) => TextCellValue(header)).toList(),
    // );

    _buildWorkSheetHeader(headers: headers, sheet: sheet);

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
        sheet.cell(
          CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: rowIndex))
            ..value = TextCellValue(option)
            ..cellStyle = textCellStyle;


        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: rowIndex))
            ..value = IntCellValue(count)
            ..cellStyle = numberCellStyle;

        rowIndex++;
      });


      //todo: Merge and fill question
      //Make rows of the question to to span according ot the number
      //of rows taken by the answer summary of the question item
      sheet.merge(
          CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: startRow),
          CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: endRow));

      //populate the merged rows with the actual question
      sheet.cell(
        CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: startRow))
          ..value = TextCellValue(questionEval.question.toString())
          ..cellStyle = textCellStyle;


      //todo: Merge and fill Answer Type
      sheet.merge(
          CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: startRow),
          CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: endRow));

      //populate the answer type
      sheet.cell(
        CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: startRow))
          ..value = TextCellValue(questionEval.answerType.typeString)
          ..cellStyle = textCellStyle;

      //todo: Merge and fill Average Score
      sheet.merge(
          CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: startRow),
          CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: endRow));

      sheet.cell(
        CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: startRow))
          ..value = DoubleCellValue((questionEval.meanScore as num).toDouble())
          ..cellStyle = numberCellStyle;

      //todo: Merge and fill Percentage Score
      sheet.merge(
          CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: startRow),
          CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: endRow));

      //fill with the percentage score
      sheet.cell(
        CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: startRow))
          ..value = DoubleCellValue((questionEval.percentageScore as num).toDouble())
          ..cellStyle = numberCellStyle;

      //todo: Merge and fill Remark
      sheet.merge(
          CellIndex.indexByColumnRow(columnIndex: 6, rowIndex: startRow),
          CellIndex.indexByColumnRow(columnIndex: 6, rowIndex: endRow));

      //fill with the remark
      sheet.cell(
        CellIndex.indexByColumnRow(columnIndex: 6, rowIndex: startRow))
          ..value = TextCellValue(questionEval.remark)
          ..cellStyle = textCellStyle;
    }


  }




  void _populateCategorySheet() {
    final sheet = _excel['Category Summary'];
    _excel.setDefaultSheet(sheet.sheetName);

    // category headers
    final List<String> headers = [
      'Core Area (Category)',
      'Questions',
      'Mean Score',
      'Percentage Score(%)',
      'Remark'
    ];

    // sheet.appendRow(
    //   headers.map((header) => TextCellValue(header)).toList(),
    // );

    _buildWorkSheetHeader(headers: headers, sheet: sheet);


    int rowIndex = 1; // because row 0 = headers

    for (CategoryEvaluation entry in categoryData) {

      String categoryName = entry.categoryName;
      List<String> questions = entry.questions; // <-- use actual questions
      double meanScore = entry.meanScore;
      double percentage = entry.percentageScore;
      String remark = entry.remark;

      // Handle empty category gracefully
      if (questions.isEmpty) {
        questions = ['-'];
      }

      int startRow = rowIndex;
      int endRow = startRow + questions.length - 1;

      // fill questions
      for (final question in questions) {
        sheet
            .cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: rowIndex))
            .value = TextCellValue(question);
        rowIndex++;
      }

      // category column
      sheet.merge(
        CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: startRow),
        CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: endRow),
      );
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: startRow))
          .value = TextCellValue(categoryName);

      // mean score
      sheet.merge(
        CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: startRow),
        CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: endRow),
      );
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: startRow))
          .value = DoubleCellValue(meanScore);

      // percentage
      sheet.merge(
        CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: startRow),
        CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: endRow),
      );
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: startRow))
          .value = DoubleCellValue(percentage);

      // remark
      sheet.merge(
        CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: startRow),
        CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: endRow),
      );
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: startRow))
          .value = TextCellValue(remark);
    }
  }



  void _populateLecturerRatingSheet(){

    final sheet = _excel['lecturer_ratings'];


    final List<String> headers = [
      'Rating',
      'Percentage Score(%)',
      'Remark'
    ];


    //todo: add the headers to the table.
    // sheet.appendRow(
    //   headers.map((header) => TextCellValue(header)).toList(),
    // );


    _buildWorkSheetHeader(headers: headers, sheet: sheet);


    //we start adding the actual data from row 1
    int rowIndex = 1;


    //todo: populate the actual rating data
    for(EvalLecturerRatingSummary lecturerRating in ratingSummary){
      int rating = lecturerRating.rating;
      int count = lecturerRating.ratingCount;
      double percentage = lecturerRating.percentage;


      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: rowIndex))
        ..value = IntCellValue(rating)
        ..cellStyle = numberCellStyle;

      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: rowIndex))
        ..value = IntCellValue(count)
        ..cellStyle = numberCellStyle;


      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: rowIndex))
        ..value = DoubleCellValue(percentage)
        ..cellStyle = textCellStyle;


      rowIndex++;
    }

  }






  void _populateSuggestionSentimentSummary(){

    final sheet = _excel['suggestion_summary'];

    final headers = ['Sentiment', 'Count', 'Percentage(%)'];

    _buildWorkSheetHeader(headers: headers, sheet: sheet);


    int rowIndex = 1;

    for(var summary in sentimentSummary){
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: rowIndex))
        ..value = TextCellValue(summary.sentiment)
        ..cellStyle = textCellStyle;

      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: rowIndex))
        ..value = IntCellValue(summary.sentimentCount)
        ..cellStyle = textCellStyle;

      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: rowIndex))
        ..value = DoubleCellValue(summary.sentimentPercent)
        ..cellStyle = textCellStyle;

      rowIndex++;
    }

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
    //todo fix this later
    // try{
    //   Provider.of<PreferencesProvider>(context, listen: false).addSavedFile(fullFilePath);
    // }on Exception catch(_){
    //   //do nothing here
    // }
    
    //it must be registered in the files section


  }

}




