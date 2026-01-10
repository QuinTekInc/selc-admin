

import 'dart:html' as html;

import 'package:flutter/material.dart';
import 'package:selc_admin/model/models.dart';
import '../server_connector.dart' as connector;
import 'file_downloader.dart';


class WebFileDownloader implements FileDownloader{

  @override
  Future<void> download({required ReportFile reportFile, BuildContext? context, void Function(double)? onProgress})async{
    final response = await connector.getRequest(endpoint: reportFile.url);

    final blob = html.Blob([response.bodyBytes]);
    final blobUrl = html.Url.createObjectUrlFromBlob(blob);

    final anchor = html.AnchorElement(href: blobUrl);
    
    anchor.setAttribute('download', '${reportFile.fileName}${reportFile.fileType}');
    anchor.click();

    html.Url.revokeObjectUrl(blobUrl);
  }


}


FileDownloader createDownloader() => WebFileDownloader();