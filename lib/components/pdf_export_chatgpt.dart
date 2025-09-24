

import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:selc_admin/components/utils.dart';

import 'package:selc_admin/model/models.dart'; // keep your models


final headerDecoration = pw.BoxDecoration(color: PdfColors.grey200,);

Future<void> generateReportPdf({
  required ClassCourse classCourse,
  required List<CourseEvaluationSummary> evaluationSummaries,
  required List<CategoryRemark> categoryRemarks,
  required List<EvalLecturerRatingSummary> ratingSummary,
  required List<SuggestionSentimentSummary> sentimentSummary,
}) async {
  final pdf = pw.Document();

  pdf.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(16),
      build: (context) => [

        // 🔹 Report Header
        buildReportHeader(),

        pw.SizedBox(height: 16),

        // 🔹 Course & Lecturer Info
        buildCourseInformationSection(classCourse),

        pw.SizedBox(height: 16),

        buildSectionTitle('Questionnaire Summary'),
        pw.Text('Summary information on how students answered the evaluation questionnaire.'),
        pw.SizedBox(height: 8),
        //buildQuestionnaireTable(evaluationSummaries),
        gpt2BuildQuestionnaireTable(evaluationSummaries),

        pw.SizedBox(height: 16),

        buildSectionTitle('Summary Report'),
        pw.Text('The table below shows the categorical (core area) summary of the questionnaire.'),
        pw.SizedBox(height: 8),
        buildCategoryTable(categoryRemarks),

        pw.SizedBox(height: 16),

        buildSectionTitle('Remarks Reference'),
        pw.Text('This table shows the range of mean/average scores and their corresponding remarks.'),
        pw.SizedBox(height: 8),
        buildScoringTable(),

        pw.SizedBox(height: 16),

        buildSectionTitle('Lecturer Rating Summary'),
        pw.Text('This table shows the rating summary of the lecturer for this course.'),
        pw.SizedBox(height: 8),
        buildLRatingTable(ratingSummary, classCourse),

        pw.SizedBox(height: 16),

        buildSectionTitle('Suggestion Sentiment Summary'),
        pw.Text(
          'This shows the summary of sentiments of students regarding this course and lecturer.\n'
          'NB: For the actual suggestions, check the evaluation report in your portal.',
        ),
        pw.SizedBox(height: 8),
        buildSentimentTable(sentimentSummary),
      ],
    ),
  );

  final file = File('report.pdf');
  await file.writeAsBytes(await pdf.save());
}

//
// 🔹 Helper Widgets (PDF version)
//

pw.Widget buildReportHeader() {
  return pw.Row(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      pw.Container(
        height: 80,
        width: 80,
        child: pw.Image(
          pw.MemoryImage(File('lib/assets/imgs/UENR-Logo.png').readAsBytesSync()),
          fit: pw.BoxFit.contain,
        ),
      ),
      pw.SizedBox(width: 12),
      pw.Expanded(
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('University of Energy and Natural Resources',
                style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
            pw.Text('Quality Assurance and Academic Planning Directorate',
                style: pw.TextStyle(fontSize: 18)),
            pw.Text('Students Evaluation of Lecturers and Courses (SELC)',
                style: pw.TextStyle(fontSize: 16)),
          ],
        ),
      ),
    ],
  );
}




pw.Widget buildSectionTitle(String title) {
  return pw.Container(
    padding: const pw.EdgeInsets.all(8),
    decoration: pw.BoxDecoration(
      border: pw.Border.all(color: PdfColors.grey300),
      borderRadius: pw.BorderRadius.circular(12),
    ),
    child: pw.Text(
      title,
      style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14),
    ),
  );
}




pw.Widget buildCourseInformationSection(ClassCourse classCourse) {
  final lecturer = classCourse.lecturer;
  final course = classCourse.course;

  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      buildSectionTitle('Information'),
      pw.SizedBox(height: 6),
      pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                buildDetailField('Lecturer:', lecturer.name),
                buildDetailField('Email:', lecturer.email),
                buildDetailField('Department:', lecturer.department),
              ],
            ),
          ),
          pw.SizedBox(width: 16),
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                buildDetailField('Course Code:', course.courseCode),
                buildDetailField('Course Title:', course.title),
                buildDetailField('No. on roll:', classCourse.registeredStudentsCount.toString()),
                buildDetailField('Academic Year:', classCourse.year.toString()),
                buildDetailField('Semester:', classCourse.semester.toString()),
              ],
            ),
          ),
        ],
      ),
    ],
  );
}



pw.Widget buildDetailField(String title, String detail) {
  return pw.Row(
    children: [
      pw.Text('$title ', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
      pw.Text(detail),
    ],
  );
}




// pw.Widget gptBuildQuestionnaireTable(List<CourseEvaluationSummary> summaries){

//   return pw.TableHelper.fromTextArray(
//     headers: ['Questions', 'Answers', 'Mean Score', 'Percentage Score(%)', 'Remark'],
//     data: summaries.map((s) => [
//       s.question,
//       s.answerSummary!.entries.map((e) => '${e.key}: ${e.value}').join('\n'),
//       s.meanScore.toStringAsFixed(2),
//       s.percentageScore.toStringAsFixed(2),
//       s.remark,
//     ]).toList(),
//     cellStyle: const pw.TextStyle(fontSize: 10),
//     headerStyle: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold),
//     border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
//   );
// }






pw.Widget gpt2BuildQuestionnaireTable(List<CourseEvaluationSummary> summaries) {
  return pw.Table(
    border: pw.TableBorder.all(
      color: PdfColors.grey300,
      width: 0.5,
    ),
    columnWidths: {
      0: const pw.FlexColumnWidth(2),   // Question
      1: const pw.FlexColumnWidth(2),   // Answers
      2: const pw.FixedColumnWidth(60), // Mean Score
      3: const pw.FixedColumnWidth(80), // Percentage Score
      4: const pw.FlexColumnWidth(1),   // Remark
    },
    children: [
      // Header Row
      pw.TableRow(
        decoration: const pw.BoxDecoration(color: PdfColors.grey200),
        children: [
          pw.Padding(
            padding: const pw.EdgeInsets.all(6),
            child: pw.Text('Question',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          ),
          pw.Padding(
            padding: const pw.EdgeInsets.all(6),
            child: pw.Text('Answers',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          ),
          pw.Padding(
            padding: const pw.EdgeInsets.all(6),
            child: pw.Text('Mean',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          ),
          pw.Padding(
            padding: const pw.EdgeInsets.all(6),
            child: pw.Text('Percentage(%)',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          ),
          pw.Padding(
            padding: const pw.EdgeInsets.all(6),
            child: pw.Text('Remark',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          ),
        ],
      ),

      // Data Rows
      ...summaries.map((summary) {
        return pw.TableRow(
          children: [
            // Question
            pw.Padding(
              padding: const pw.EdgeInsets.all(6),
              child: pw.Text(summary.question),
            ),

            // Answers
            pw.Padding(
              padding: const pw.EdgeInsets.all(6),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: summary.answerSummary!.entries.map((entry) {
                  return pw.Row(
                    children: [
                      pw.Text('${entry.key}: '),
                      pw.Spacer(),
                      pw.Text(entry.value.toString()),
                    ],
                  );
                }).toList(),
              ),
            ),

            // Mean Score
            pw.Padding(
              padding: const pw.EdgeInsets.all(6),
              child: pw.Text(summary.meanScore.toStringAsFixed(2)),
            ),

            // Percentage Score
            pw.Padding(
              padding: const pw.EdgeInsets.all(6),
              child: pw.Text(summary.percentageScore.toStringAsFixed(2)),
            ),

            // Remark
            pw.Padding(
              padding: const pw.EdgeInsets.all(6),
              child: pw.Text(summary.remark),
            ),
          ],
        );
      }),
    ],
  );
}




// pw.Widget buildQuestionnaireTable(List<CourseEvaluationSummary> summaries) {


//   final headerStyle = pw.TextStyle(  
//     fontWeight: pw.FontWeight.bold,
//     fontSize: 11
//   );

//   return pw.Column(
//     mainAxisAlignment: pw.MainAxisAlignment.start,
//     crossAxisAlignment: pw.CrossAxisAlignment.start,
//     mainAxisSize: pw.MainAxisSize.min,
//     children: [

//       //todo: table headers
//       pw.Container(
//         padding: const pw.EdgeInsets.all(8),
//         decoration: pw.BoxDecoration(
//           color: PdfColors.grey200,
//           borderRadius: pw.BorderRadius.circular(12)
//         ),

//         child: pw.Row(  
//           mainAxisAlignment: pw.MainAxisAlignment.start,
//           crossAxisAlignment: pw.CrossAxisAlignment.center,
//           children: [

//             pw.Expanded(
//               flex: 3,
//               child: pw.Text(  
//                 'Question',
//                 textAlign: pw.TextAlign.center,
//                 style: headerStyle
//               )
//             ),

//             //pw.VerticalDivider(),

//             pw.Expanded(
//               flex: 2,
//               child: pw.Text(  
//                 'Answers',
//                 textAlign: pw.TextAlign.center,
//                 style: headerStyle
//               )
//             ),

//             //pw.VerticalDivider(),

//             pw.Expanded(
//               flex: 1,
//               child: pw.Text(  
//                 'Mean Score',
//                 textAlign: pw.TextAlign.center,
//                 style: headerStyle
//               )
//             ),

//             //pw.VerticalDivider(),

//             pw.Expanded(
//               flex: 1,
//               child: pw.Text(  
//                 'Percentage Score(%)',
//                 textAlign: pw.TextAlign.center,
//                 style: headerStyle
//               )
//             ),

//             //pw.VerticalDivider(),

//             pw.Expanded(
//               flex: 2,
//               child: pw.Text(  
//                 'Remark',
//                 textAlign: pw.TextAlign.center,
//                 style: headerStyle
//               )
//             )

//           ]
//         )
//       ),



//       //todo: the actual question items here
//       for(int i = 0; i < summaries.length; i++)  pw.DecoratedBox(  
//         decoration: pw.BoxDecoration(  
//           border: pw.Border(
//             bottom: pw.BorderSide(color: PdfColors.grey300, width: 1.5)
//           )
//         ),

//         child: buildQuestionnaireTableCell(summaries[i])
//       )

//     ]
//   );

// }



 //create some mandatory cells.
pw.Widget buildQuestionnaireTableCell(CourseEvaluationSummary summary){

  final rightBorder = pw.Border(right: pw.BorderSide(color: PdfColors.grey300, width: 1.5));

  return pw.Row(
    crossAxisAlignment: pw.CrossAxisAlignment.start,  
    children: [
      
      //todo: question
      pw.Expanded(
        flex: 3,
        child: pw.Container(  
          padding: const pw.EdgeInsets.all(8),
          decoration: pw.BoxDecoration(  
            border: rightBorder
          ),
          child: pw.Text(  
            summary.question
          ),
        ),
      ),
  

      //todo: answers
      pw.Expanded(
        flex: 2,
        child: pw.Container(
          padding: const pw.EdgeInsets.all(8.0),
          decoration: pw.BoxDecoration(  
            border: rightBorder
          ),
          child: pw.Column(
            mainAxisSize: pw.MainAxisSize.min,
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            mainAxisAlignment: pw.MainAxisAlignment.start,
            children: List<pw.Widget>.generate(
              summary.answerSummary!.length,
              (index) {
  
                String answerKey = summary.answerSummary!.keys.elementAt(index);
  
                int answerFrequency = summary.answerSummary![answerKey];
  
                return pw.Row(
                  children: [
                    pw.Text('$answerKey :'),
                    pw.Spacer(),
                    pw.Text(answerFrequency.toString())
                  ],
                );
              }
            )
          ),
        )
      ),


      //todo: mean score
      pw.Expanded(
        flex: 1,
        child: pw.Container(
          padding: const pw.EdgeInsets.all(8),
          decoration: pw.BoxDecoration(  
            border: rightBorder
          ),
          child: pw.Text(formatDecimal(summary.meanScore))
        )
      ),


  
  
      //todo: percentage score
      pw.Expanded(
        flex: 1,
        child: pw.Container(
          padding: const pw.EdgeInsets.all(8.0),
          decoration: pw.BoxDecoration(  
            border: rightBorder
          ),
          child: pw.Text(formatDecimal(summary.percentageScore)),
        )
      ),
  

      //todo: remark  
      pw.Expanded(
        flex: 2,
        child: pw.Container(
          padding: const pw.EdgeInsets.all(8.0),
          child: pw.Text(summary.remark)
        )
      )
    ],
  );
}






pw.Widget buildCategoryTable(List<CategoryRemark> remarks) {
  return pw.TableHelper.fromTextArray(
    headers: ['Core Area (Category)', 'Mean Score', 'Percentage Score', 'Remarks'],
    data: remarks.map((r) => [
      r.categoryName,
      r.meanScore.toStringAsFixed(2),
      r.percentageScore.toStringAsFixed(2),
      r.remark,
    ]).toList(),
    cellStyle: const pw.TextStyle(fontSize: 10),
    headerStyle: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold),
    border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
    headerDecoration: headerDecoration,
  );
}





pw.Widget buildScoringTable() {
  final remarkInfo = [
    ['4.6 - 5.0', '90-100', 'Excellent'],
    ['4.0 - 4.59', '60-89', 'Very Good'],
    ['3.0 - 3.99', '40-59', 'Good'],
    ['2.0 - 2.99', '20-39', 'Average'],
    ['0.0 - 1.9', '0-19', 'Poor'],
  ];

  return pw.TableHelper.fromTextArray(
    headers: ['Score Range', 'Percentage Range', 'Remark'],
    data: remarkInfo,
    cellStyle: const pw.TextStyle(fontSize: 10),
    headerStyle: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold),
    border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
    headerDecoration: headerDecoration
  );
}




pw.Widget buildLRatingTable(List<EvalLecturerRatingSummary> ratings, ClassCourse course) {
  final rows = ratings.map((r) => [
    r.rating.toString(),
    r.ratingCount.toString(),
    r.percentage.toStringAsFixed(2),
  ]).toList();

  rows.add(['', 'Average Rating', course.lecturerRating.toStringAsFixed(2)]);

  return pw.TableHelper.fromTextArray(
    headers: ['Rating', 'Count', 'Percentage'],
    data: rows,
    cellStyle: const pw.TextStyle(fontSize: 10),
    headerStyle: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold),
    border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
    headerDecoration: headerDecoration,
  );
}





pw.Widget buildSentimentTable(List<SuggestionSentimentSummary> sentiments) {
  return pw.TableHelper.fromTextArray(
    headers: ['Sentiment', 'Count', 'Percentage'],
    data: sentiments.map((s) => [
      s.sentiment,
      s.sentimentCount.toString(),
      s.sentimentPercent.toStringAsFixed(2),
    ]).toList(),
    cellStyle: const pw.TextStyle(fontSize: 10),
    headerStyle: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold),
    border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
    headerDecoration: headerDecoration,
  );
}




