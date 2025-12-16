
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:selc_admin/components/alert_dialog.dart';
import 'package:selc_admin/components/button.dart';
import 'package:selc_admin/components/file_downloader.dart';
import 'package:selc_admin/components/text.dart';
import 'package:selc_admin/components/utils.dart';
import 'package:selc_admin/model/models.dart';
import 'package:selc_admin/providers/pref_provider.dart';



class FilesPage extends StatefulWidget {
  const FilesPage({super.key});

  @override
  State<FilesPage> createState() => _FilesPageState();
}

class _FilesPageState extends State<FilesPage> {


  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    loadData();
  }


  void loadData() async {
    Provider.of<PreferencesProvider>(context, listen: false).loadPreferences();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(  
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          HeaderText('Files', fontSize: 25,),


          const SizedBox(height: 12,),


          SizedBox(
            width: MediaQuery.of(context).size.width * 0.4,
            child: CustomTextField(  
              controller: TextEditingController(),
              hintText: 'Search Files',
              leadingIcon: Icons.search,
            ),
          ),


          const SizedBox(height: 12,),

          Expanded(  
            child: Container(  
              width: double.infinity,
              height: double.infinity,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: PreferencesProvider.getColor(context, 'table-background-color'),
                borderRadius: BorderRadius.circular(12)
              ),
              child: Column(  
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  Container( 
                    padding: const EdgeInsets.all(8), 
                    decoration: BoxDecoration(
                      color: PreferencesProvider.getColor(context, 'table-header-color'),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(  
                          flex: 2,
                          child: CustomText('File Name'),
                        ),


                        SizedBox(
                          width: 200,
                          child: CustomText('File Type'),
                        ),


                        Expanded(  
                          flex: 2,
                          child: CustomText('Directory (Or Url)'),
                        ),



                        SizedBox(
                          width: 145,
                          child: CustomText('Action', textAlignment: TextAlign.center,),
                        ),



                      ],
                    ),
                  ),

                  const SizedBox(height: 8,),


                  if(Provider.of<PreferencesProvider>(context).reportFiles.isEmpty) Expanded(
                    child: CollectionPlaceholder(
                      title: 'No Files!',
                      detail: 'All downloaded and \'yet to download\' files appear here.',
                    )
                  )
                  else Expanded(
                    flex: 2,
                    child: ListView.separated(  
                      itemCount: Provider.of<PreferencesProvider>(context).reportFiles.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8,),
                      itemBuilder: (_, index){
                        
                        ReportFile reportFile = Provider.of<PreferencesProvider>(context, listen: false).reportFiles[index];
                    
                        return ReportFileCell(reportFile: reportFile);
                    
                      }
                    ),
                  )

                ],
              ),
            ),
          )
        ],
      ),
    );
  }


}







class ReportFileCell extends StatefulWidget {
  
  final ReportFile reportFile;
  
  const ReportFileCell({super.key, required this.reportFile});

  @override
  State<ReportFileCell> createState() => _ReportFileCellState();
}

class _ReportFileCellState extends State<ReportFileCell> {


  bool isDownloading = false;

  double progressValue = 0;
  double maxValue = 45;

  @override
  Widget build(BuildContext context) {


    final fileName = widget.reportFile.fileName;
    final fileType = widget.reportFile.fileType;

    String? fileDir = widget.reportFile.localFilePath;


    return Container(
      padding: const EdgeInsets.all(12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [

          //file Name
          Expanded(
            flex: 2,
            child: CustomText(
                fileName
            ),
          ),


          //file type
          SizedBox(
            width: 200,
            child: CustomText(
                fileType
            ),
          ),


          //file file path or url
          Expanded(
            flex: 2,
            child: Tooltip(
              message: fileDir ?? widget.reportFile.url,
              child: CustomText(
                  fileDir ?? widget.reportFile.url,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),


          //related actions
          if(isDownloading) SizedBox(
            width: 145,
            child: LinearProgressIndicator(
              value: progressValue/maxValue,
              minHeight: 8,
              // semanticsLabel: '${formatDecimal((progressValue/maxValue) * 100)} %',
              // semanticsValue: formatDecimal(progressValue / maxValue),
              backgroundColor: Colors.grey.shade300,
              valueColor: AlwaysStoppedAnimation(Colors.green.shade400),
            ),
          )
          else if (fileDir == null) SizedBox(
            width: 145,
            child: TextButton.icon(
                onPressed: handleFileDownload,
                icon: Icon(Icons.download, color: Colors.green.shade400,),
                label: CustomText('Download', textColor: Colors.green.shade400,)
            ),
          )
          else SizedBox(
            width: 145,
            child: Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                  color: PreferencesProvider.getColor(context, 'alt-primary-color'),
                  borderRadius: BorderRadius.circular(12)
              ),

              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [

                  IconButton(
                    onPressed: handleOpenFile,
                    tooltip: 'Open File',
                    icon: Icon(Icons.open_in_new, size: 20,),
                  ),

                  IconButton(
                    onPressed: handleOpenContainingFolder,
                    tooltip: 'Open containing folder',
                    icon: Icon(Icons.folder, size: 20,),
                  ),

                  IconButton(
                    onPressed: handleDeleteFile,
                    tooltip: 'Delete File',
                    icon: Icon(Icons.delete, size: 20, color: Colors.red.shade400,),
                  ),

                ],
              )
            ),
          ),
        ],
      )
    );
  }





  void handleFileDownload() async {

    // final progs = [5, 7, 3, 1, 2, 4, 8, 6, 9];
    //
    // for(var prog in progs){
    //   Future.delayed(Duration(seconds: prog), (){
    //     setState(() {
    //       progressValue += prog;
    //
    //       if(progs.indexOf(prog) == progs.length-1) {
    //         setState(() {
    //           isDownloading = false;
    //           progressValue = 0;
    //         });
    //       }
    //
    //     });
    //   });
    // }


    //first check if we're running on the browser
    if(kIsWeb){
      FileDownloader.webDownload(reportFile: widget.reportFile);
      return;
    }


    setState(() => isDownloading = true);

    try{

      await FileDownloader.downloadFile(
        context: context,
        reportFile: widget.reportFile,
        onProgress: (progress) => setState(() => progressValue = progress)
      );

      setState(() {
        widget.reportFile.localFilePath = Provider.of<PreferencesProvider>(context, listen: false).preferences.defaultDownloadDirectory;
        //todo: save to cached files
        Provider.of<PreferencesProvider>(context, listen: false).addSavedFile(widget.reportFile);
      });

    }on SocketException{
      showNoConnectionAlertDialog(context);
    }on Exception catch(exception, trace){

      debugPrint(exception.toString());
      debugPrintStack(stackTrace: trace);

      showCustomAlertDialog(
        context,
        title: 'Download Error',
        contentText: 'There wan error in downloading ${widget.reportFile.fileName}. Please try again'
      );
    }


    setState(() => isDownloading = false);

  }



  void handleOpenFile() async {

  }


  void handleOpenContainingFolder(){

  }


  void handleDeleteFile(){

  }

}



