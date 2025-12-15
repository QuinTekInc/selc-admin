
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:provider/provider.dart';
import 'package:selc_admin/components/utils.dart';
import 'package:flutter/material.dart';
import 'package:selc_admin/model/models.dart';
import 'package:selc_admin/providers/pref_provider.dart';



class FileDownloader {

  static Future<void> downloadFile({
    required BuildContext context,
    required ReportFile reportFile,
    required Function(double progress) onProgress,
  }) async {

    final dio = Dio();

    final dirPath = Provider.of<PreferencesProvider>(context, listen: false).preferences.defaultDownloadDirectory;

    final filePath = '$dirPath/${reportFile.fileName}';



    await dio.download(
      reportFile.url,
      filePath,
      onReceiveProgress: (received, total) {
        if (total != -1) {
          onProgress(received / total);
        }
      },
    );


  }
}