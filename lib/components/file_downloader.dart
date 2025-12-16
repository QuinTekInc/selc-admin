
import 'dart:io';
import 'dart:html' as html;
import 'package:dio/dio.dart';
import 'package:provider/provider.dart';
import 'package:selc_admin/components/utils.dart';
import 'package:flutter/material.dart';
import 'package:selc_admin/model/models.dart';
import 'package:selc_admin/providers/pref_provider.dart';

import 'server_connector.dart' as connector;


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



  static Future<void> webDownload({required ReportFile reportFile}) async {
    final response = await connector.getRequest(endPoint: reportFile.url);

    final blob = html.Blob([response.bodyBytes]);
    final blobUrl = html.Url.createObjectUrlFromBlob(blob);

    final anchor = html.AnchorElement(href: blobUrl)
                  ..setAttribute('download', '${reportFile.fileName}${reportFile.fileType}')
                  ..click();

    html.Url.revokeObjectUrl(blobUrl);


  }
}