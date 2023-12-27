import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:edu_chatbot/data/subject.dart';
import 'package:edu_chatbot/services/local_data_service.dart';
import 'package:edu_chatbot/util/dio_util.dart';
import 'package:edu_chatbot/util/environment.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;

import '../data/exam_link.dart';
import '../data/exam_page_image.dart';
import '../util/functions.dart';

class Repository {
  final DioUtil dioUtil;

  final Dio dio;
  final LocalDataService localDataService;

  static const mm = '💦💦💦💦 Repository 💦';

  Repository(this.dioUtil, this.localDataService, this.dio);

  Future<List<ExamPageImage>> getExamImages(int examLinkId) async {
    pp('$mm ... getExamPageImages ....');
    List<ExamPageImage> images = [];
    try {
      images = await localDataService.getExamImages(examLinkId);
      if (images.isNotEmpty) {
        pp('$mm ... getExamPageImages .... from local store: ${images.length}');
        return images;
      }
      String urlPrefix = ChatbotEnvironment.getSkunkUrl();
      var path = '${urlPrefix}links/getExamPageImages';
      List res = await dioUtil.sendGetRequest(path, {'examLinkId': examLinkId});
      for (var r in res) {
        var map = {
          'examLinkId': r['examLink']['id'],
          'downloadUrl': r['downloadUrl'],
          'pageIndex': r['pageIndex'],
          'mimeType': r['mimeType'],
          'id': r['id']
        };
        images.add(ExamPageImage.fromJson(map));
      }
      int index = 1;
      for (var img in images) {
        img.bytes = await downloadFile(img.downloadUrl!);
        await localDataService.addExamImage(img);
        _streamController.sink.add(index);
        index++;
      }
      pp('$mm ... getExamPageImages .... from remote store: ${images.length}');

      return images;
    } catch (e) {
      // Handle any errors
      pp('Error calling addExamImage API: $e');
      rethrow;
    }
  }
  final StreamController<int> _streamController = StreamController.broadcast();
  Stream<int> get pageStream => _streamController.stream;
  static Future<List<int>> downloadFile(String url) async {
    pp('$mm downloading file from ... $url');
    try {
      var response = await http.get(Uri.parse(url));
      var bytes = response.bodyBytes;
      return bytes;
    } catch (e) {
      pp('Error downloading file: $e');
      rethrow;
    }
  }

  Future<List<Subject>> getSubjects(bool refresh) async {
    var list = <Subject>[];
    try {
      if (refresh) {
        list = await _downloadSubjects();
      } else {
        list = await localDataService.getSubjects();
        if (list.isEmpty) {
          list = await _downloadSubjects();
        }
      }

      pp("$mm Subjects found: ${list.length} ");

      return list;
    } catch (e) {
      pp(e);
      rethrow;
    }
  }

  Future<List<ExamLink>> getExamLinks(int subjectId, bool refresh) async {
    List<ExamLink> list = [];
    try {
      if (refresh) {
        list = await _downloadExamLinks(subjectId);
      } else {
        list = await localDataService.getExamLinksBySubject(subjectId);
        if (list.isEmpty) {
          list = await _downloadExamLinks(subjectId);
        }
      }

      pp("$mm  Exam links found: ${list.length}, "
          "subjectId: $subjectId ");

      return list;
    } catch (e) {
      pp(e);
      rethrow;
    }
  }

  // Future<List<ExamPageImage>> getExamImages(ExamLink examLink) async {
  //   List<ExamPageImage> examImages = [];
  //
  //   var localImages = await localDataService.getExamImages(examLink.id!);
  //   if (localImages.isNotEmpty) {
  //     return localImages;
  //   }
  //   pp('$mm getExamImages: starting image file download ...');
  //   examImages = await _downloadImages(examLink);
  //
  //   pp('$mm getExamImages: image file downloaded: ${examImages.length} ...');
  //   return examImages;
  // }

  Future<List<ExamLink>> _downloadExamLinks(int subjectId) async {
    pp('$mm downloading examLinks ...');

    List<ExamLink> examLinks = [];
    var url = ChatbotEnvironment.getSkunkUrl();
    var res = await dioUtil.sendGetRequest(
        '${url}links/getSubjectExamLinks', {'subjectId': subjectId});
    // Assuming the response data is a list of examLinks

    List<dynamic> responseData = res;
    for (var linkData in responseData) {
      var map = {
        "id": linkData["id"],
        "title": linkData["title"],
        "link": linkData["link"],
        "subjectTitle": linkData["subject"]["title"],
        "subjectId": linkData["subject"]["id"],
        "examText": linkData["examText"],
        "pageImageZipUrl": linkData["pageImageZipUrl"],
        "documentTitle": linkData["examDocument"]["title"]
      };
      ExamLink examLink = ExamLink.fromJson(map);
      examLinks.add(examLink);
    }

    pp("$mm  Exam links found: ${examLinks.length}, "
        "subjectId: $subjectId ");
    if (examLinks.isNotEmpty) {
      localDataService.addExamLinks(examLinks);
    }
    return examLinks;
  }

  Future<List<Subject>> _downloadSubjects() async {
    pp('$mm downloading subjects ...');
    List<Subject> subjects = [];
    var url = ChatbotEnvironment.getSkunkUrl();
    var res = await dioUtil.sendGetRequest('${url}links/getSubjects', {});
    // Assuming the response data is a list of subjects

    List<dynamic> responseData = res;
    for (var linkData in responseData) {
      Subject examLink = Subject.fromJson(linkData);
      subjects.add(examLink);
    }

    pp("$mm  Subjects links found: ${subjects.length}, ");
    if (subjects.isNotEmpty) {
      localDataService.addSubjects(subjects);
    }
    return subjects;
  }

  Future<File> downloadOriginalExamPDF(ExamLink examLink) async {
    //todo - check if exists
    Response<List<int>> response = await dio.get<List<int>>(
      examLink.link!,
      options: Options(responseType: ResponseType.bytes),
    );

    // Create a temporary directory to extract the zip file
    Directory tempDir = await Directory.systemTemp.createTemp();
    String tempPath = tempDir.path;

    // Save the downloaded zip file to the temporary directory

    String pdfPath = path.join(tempPath, 'exam_${examLink.id}.pdf');
    File pdfFile = File(pdfPath);
    if (response.data != null) {
      await pdfFile.writeAsBytes(response.data!, flush: true);
    }

    // Extract the zip file
    pp("$mm  Exam pdf file saved "
        " 💙 $pdfPath length: ${(pdfFile.length)} bytes");
    return pdfFile;
  }
}
