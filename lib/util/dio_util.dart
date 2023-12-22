import 'dart:io';

import 'package:archive/archive.dart';
import 'package:dio/dio.dart';
import 'package:edu_chatbot/data/exam_image.dart';
import 'package:edu_chatbot/data/exam_link.dart';
import 'package:edu_chatbot/util/functions.dart';
import 'package:path/path.dart' as path;

import '../services/local_data_service.dart';

class DioUtil {
  final Dio dio;
  static const mm = '🥬🥬🥬🥬 DioUtil 🥬';
final LocalDataService localDataService;
  DioUtil(this.dio, this.localDataService);

  Future<List<File>> downloadAndUnpackZip(ExamLink examLink) async {
    pp('$mm Download the zipped exam images file ...');
    if (examLink.pageImageZipUrl == null) {
      throw Exception('url not on examLink');
    }
    Response<List<int>> response = await dio.get<List<int>>(
      examLink.pageImageZipUrl!,
      options: Options(responseType: ResponseType.bytes),
    );

    // Create a temporary directory to extract the zip file
    Directory tempDir = await Directory.systemTemp.createTemp();
    String tempPath = tempDir.path;

    // Save the downloaded zip file to the temporary directory

    String zipFilePath = path.join(tempPath, 'images_"++".zip');
    File zipFile = File(zipFilePath);
    if (response.data != null) {
      await zipFile.writeAsBytes(response.data!, flush: true);
    }

    // Extract the zip file
    pp("$mm  Extract the image files from zipped directory: "
        " 💙 $zipFilePath ${(zipFile.length)} bytes");

    Archive archive = ZipDecoder().decodeBytes(zipFile.readAsBytesSync());
    List<File> extractedFiles = [];

    for (ArchiveFile file in archive) {
      if (file.isFile) {
        String filePath = path.join(tempPath, file.name);
        File extractedFile = File(filePath);
        extractedFile.createSync(recursive: true);
        extractedFile.writeAsBytesSync(file.content);
        extractedFiles.add(extractedFile);
        pp("$mm  File unpacked from zipped directory: "
            "💙$filePath  💙length: ${await extractedFile.length()} ");
      }
    }

    for (var file in extractedFiles) {
      var img = ExamImage(examLink.id, file.path);
      localDataService.addExamImage(img);
    }
    pp("$mm  Files unpacked from zipped directory: "
        " 💙 ${extractedFiles.length} image files");
    return extractedFiles;
  }

  Future<dynamic> sendGetRequest(
      String path, Map<String, dynamic> queryParameters) async {
    try {
      Response response;
      // The below request is the same as above.
      response = await dio.get(
        path,
        queryParameters: queryParameters,
        options: Options(responseType: ResponseType.json),
      );

      pp('$mm network response: 🥬🥬🥬 status code: ${response.statusCode}');
      return response.data;
    } catch (e) {
      pp(e);
      rethrow;
    }
  }

  Future<dynamic> sendPostRequest(String path, dynamic body) async {
    try {
      Response response;
      // The below request is the same as above.
      pp('$mm sendPostRequest: path: $path body: $body');

      response = await dio
          .post(
            path,
            data: body,
            options: Options(responseType: ResponseType.json),
            onReceiveProgress: (count, total) {
              pp('$mm onReceiveProgress: count: $count total: $total');
            },
            onSendProgress: (count, total) {
              pp('$mm onSendProgress: count: $count total: $total');
            },
          )
          .timeout(const Duration(seconds: 60))
          .catchError((error, stackTrace) {
            pp('$mm Error occurred during the POST request: $error');
          });
      pp('$mm .... network POST response, 💚status code: ${response.statusCode} 💚💚');
      return response.data;
    } catch (e) {
      pp('$mm .... network POST error response, '
          '👿👿👿👿 $e 👿👿👿👿');
      pp(e);
      rethrow;
    }
  }
}
