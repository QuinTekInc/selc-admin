
import 'file_downloader.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:provider/provider.dart';
import 'package:selc_admin/model/models.dart' show ReportFile;
import 'package:selc_admin/providers/pref_provider.dart';

class IOFileDownloader implements FileDownloader {

  @override
  Future<void> download({
    required ReportFile reportFile,
    BuildContext? context,
    Function(double progress)? onProgress,
  }) async {

    final dio = Dio();

    final dirPath = Provider.of<PreferencesProvider>(context!, listen: false).preferences.defaultDownloadDirectory;

    final filePath = '$dirPath/${reportFile.fileName}';



    await dio.download(
      reportFile.url,
      filePath,
      onReceiveProgress: (received, total) {
        if (total != -1) {
          onProgress!(received / total);
        }
      },
    );


  }
}



FileDownloader createDownloader() => IOFileDownloader();

