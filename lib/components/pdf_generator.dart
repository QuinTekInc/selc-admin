
import 'dart:typed_data';

import 'package:pdf/pdf.dart' as pdf;
import 'package:pdf/widgets.dart' as pw;
import 'package:selc_admin/model/course.dart';
import 'package:flutter/services.dart' show rootBundle;


class CourseReportGenerator{
  

  static Future<pw.Document> generatePDF() async {


    Uint8List logo = await loadAsset('lib/assets/imgs/UENR-Logo.png');


    final document = pw.Document();


    document.addPage(  
      pw.Page(
        build: (context) => pw.Container(  
          child: pw.Column(
            
            children: [  
              //header of the papper.
              buildHeader(logo),

              pw.Divider(),

              //todo: build course and lecturer information

            ]
          )
        )
      )
    );


    return document;

  }


  static Future<Uint8List> loadAsset(String path) async {
    final ByteData data = await rootBundle.load(path);
    return data.buffer.asUint8List();
  }



  static pw.Widget buildHeader(Uint8List logoImageData) {

    final memoryImage =  pw.MemoryImage(logoImageData);


    return pw.Container(  
      padding: pw.EdgeInsets.all(8),
      alignment: pw.Alignment.topCenter,

      child: pw.Row(  
        mainAxisAlignment: pw.MainAxisAlignment.start,
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [ 

          //todo: the uenr logo on the top left of the application
          pw.Image(memoryImage, height: 120, width: 120),
          

          //todo: the header details.
          pw.Expanded(  
            child: pw.Column(  
              mainAxisAlignment: pw.MainAxisAlignment.start,
              crossAxisAlignment: pw.CrossAxisAlignment.start,

              children: [  
                pw.Text(  
                  'UNIVERSITY OF ENERGY AND NATURAL RESOURCES'
                ),

                pw.Text(  
                  'QUALITY ASSURANCE AND ACADEMIC PLANNING DIRECTORATE(QAAPD)'
                ),


                pw.Text(  
                  'STUDENT EVALUATION OF LECTURERS AND COURSES (SELC)'
                )
              ]
            )
          )
        ]
      )
    );
  }


  static pw.Widget buildLecturerInformationSection(ClassCourse classCourse){

    return pw.Container(  
      padding: const pw.EdgeInsets.all(8),
      decoration: pw.BoxDecoration(  
        border: pw.Border.all()
      ),

      child: pw.Column( 

        mainAxisAlignment: pw.MainAxisAlignment.start,
        crossAxisAlignment: pw.CrossAxisAlignment.start,

        children: [ 
        
          //title of the current section
          pw.Text(
            'Detials',
            style: pw.TextStyle(  
              fontWeight: pw.FontWeight.bold,
              decoration: pw.TextDecoration.underline
            )
          ),


          //todo: show the various informations here.
          pw.Row( 
            mainAxisAlignment: pw.MainAxisAlignment.start,
            crossAxisAlignment: pw.CrossAxisAlignment.start, 
            children: [

            ]
          ),



          //todo: another row of the details.
          pw.Row( 
            mainAxisAlignment: pw.MainAxisAlignment.start, 
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [ 
              
            ]
          )

        ]
      )
    );

  }


  static pw.Widget buildDetailField({required String field, required String detail}){
    return pw.Column(
      mainAxisSize: pw.MainAxisSize.min, 
      mainAxisAlignment: pw.MainAxisAlignment.start,
      crossAxisAlignment: pw.CrossAxisAlignment.start,

      children: [ 

        pw.Text(  
          field,
          style: pw.TextStyle(
            fontWeight: pw.FontWeight.bold,
            fontStyle: pw.FontStyle.italic
          )
        ),

        pw.Text(  
          detail, 
        ),

      ]
    );
  }


  


  //todo: the table. 
  static pw.Widget buildQuestionnaireTable(){
    return pw.Table(
      border: pw.TableBorder.all(
        width: 1.5,
        color: pdf.PdfColors.black,
      ),


      children: [

        //todo: table header.
        pw.TableRow(
          children: [
            pw.Text(  
              'Category'
            ),


            pw.Text('Question'),

            pw.Text('Answer Type')
          ]
        )
      ]
    );
  }


  static pw.Widget buildCategoryRemarksTable(){
    return pw.Table(

      children: [  
        //todo: table header.
      ]

    );
  }

  

}