import 'dart:io';

import 'package:archive/archive.dart';

import '../data/exam_link.dart';
import 'package:http/http.dart' as http;

import 'functions.dart';

class ImageFileUtil {
  static const mm = '🌿🌿🌿 ImageFileUtil 💦';

  static Future<List<File>> getFiles(ExamLink examLink) async {
    return await downloadFile(examLink.pageImageZipUrl!);

  }
  static Future<List<File>> downloadFile(String url) async {
    pp('$mm .... downloading file .......................... ');
    try {
      var response = await http.get(Uri.parse(url));
      var bytes = response.bodyBytes;
      Directory tempDir = Directory.systemTemp;
      var mFile = File('${tempDir.path}/someFile.zip');
      mFile.writeAsBytesSync(bytes);
      return unpackZipFile(mFile);
    } catch (e) {
      pp('Error downloading file: $e');
      rethrow;
    }
  }  static List<File> unpackZipFile(File zipFile) {
    Directory destinationDirectory = Directory.systemTemp;

    if (!zipFile.existsSync()) {
      throw Exception('Zip file does not exist');
    }

    if (!destinationDirectory.existsSync()) {
      destinationDirectory.createSync(recursive: true);
    }

    final archive = ZipDecoder().decodeBytes(zipFile.readAsBytesSync());

    final files = <File>[];

    for (final file in archive) {
      final filePath = '${destinationDirectory.path}/${file.name}';
      final outputFile = File(filePath);

      if (file.isFile) {
        outputFile.createSync(recursive: true);
        outputFile.writeAsBytesSync(file.content as List<int>);
        files.add(outputFile);
      } else {
        outputFile.createSync(recursive: true);
        files.add(outputFile);
      }
    }
    pp('$mm .... files unpacked: ${files.length} ');

    return files;
  }


}
