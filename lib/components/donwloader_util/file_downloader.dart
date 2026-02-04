

import 'package:flutter/material.dart';
import 'package:selc_admin/model/models.dart';

import 'file_downloader_stub.dart' //default
    if(dart.library.io) 'file_downloader_io.dart'
    if(dart.library.html) 'file_downloader_web.dart';



abstract class FileDownloader{
  Future<void> download({required ReportFile reportFile, BuildContext? context,  void Function(double)? onProgress});
}



FileDownloader getDownloader() => createDownloader();