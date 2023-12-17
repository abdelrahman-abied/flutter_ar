// create download helper class to download file from url and save to local storage using dio package

import 'dart:io';

import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';

class DownloadHelper {
  static Future<String> downloadFile(String url) async {
    final dir = await getApplicationDocumentsDirectory();
    final fileName = url.split('/').last;
    final file = File('${dir.path}/$fileName');
    if (await file.exists()) {
      return file.path;
    }
    final dio = Dio();
    await dio.download(url, file.path);
    return file.path;
  }
}
