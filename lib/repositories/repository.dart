import 'dart:io';

import 'package:edu_chatbot/data/subject.dart';
import 'package:edu_chatbot/data/exam_text.dart';
import 'package:edu_chatbot/services/local_data_service.dart';
import 'package:edu_chatbot/util/dio_util.dart';
import 'package:edu_chatbot/util/environment.dart';

import '../data/exam_link.dart';
import '../util/functions.dart';

class Repository {
  final DioUtil dioUtil;
  final LocalDataService localDataService;

  static const mm = '💦💦💦💦 Repository 💦';

  Repository(this.dioUtil, this.localDataService);

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
  Future<List<File>> extractImages(ExamLink link, bool refresh) async {
    pp('$mm extractImages ....');
    var list = <File>[];
    try {
      if (refresh) {
        list = await _downloadImages(link);
        pp("$mm Image files found locally: ${list.length} ");

      } else {
        list = await localDataService.getExamImages(link.id!);
        if (list.isEmpty) {
          list = await _downloadImages(link);
          pp("$mm Image files downloaded: ${list.length} ");

        }
      }


      return list;
    } catch (e) {
      pp(e);
      rethrow;
    }
  }
  Future<String?> extractExamPaperText(int examLinkId, bool refresh) async {
    String? text = '';
    try {
      if (refresh) {
        text = await _downloadText(examLinkId);
      } else {
        text = await localDataService.getExamText(examLinkId);
        text ??= await _downloadText(examLinkId);
      }

      pp("$mm Text found: ${text?.length} bytes");

      return text;
    } catch (e) {
      pp(e);
      rethrow;
    }
  }

  Future<String?> _downloadText(int examLinkId) async {
    pp('$mm ........... downloading exam text: examLinkId: $examLinkId');
    var url = ChatbotEnvironment.getSkunkUrl();
    try {
      var res = await dioUtil.sendGetRequest(
          '${url}data/extractExamPaperText', {
            'examLinkId': examLinkId
      });
      // Assuming the response data is a list of subjects
      String text = res.toString();

      pp("$mm Text found: ${text.length} ");
      if (text.isNotEmpty) {
            await localDataService.addExamText(
                ExamText(examLinkId,text));
          }
      return text;
    } catch (e) {
      pp(e);
    }
    return null;
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

  Future<List<ExamLink>> _downloadExamLinks(int subjectId) async {
    pp('$mm downloading examLinks ...');

    List<ExamLink> examLinks = [];
    var url = ChatbotEnvironment.getSkunkUrl();
    var res = await dioUtil.sendGetRequest(
        '${url}links/getSubjectExamLinks', {
      'subjectId': subjectId
    });
    // Assuming the response data is a list of examLinks

    List<dynamic> responseData = res;
    for (var linkData in responseData) {
      var map = {
        "id": linkData["id"],
        "title": linkData["title"],
        "link": linkData["link"],
        "subjectTitle": linkData["subject"]["title"],
        "subjectId": linkData["subject"]["id"],
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
    var res = await dioUtil.sendGetRequest('${url}links/getSubjects', {
    });
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
  Future<List<File>> _downloadImages(ExamLink examLink) async {
    pp('$mm extract images ...');
    List<File> subjects = [];
    var url = ChatbotEnvironment.getSkunkUrl();
    var res = await dioUtil.sendGetRequest(
        '${url}pdf/createPdfPageImages', {
          'examLinkId': examLink.id!
    });
    // Assuming the response data is a list of subjects
    var newExamLink = ExamLink.fromJson(res);
    pp("$mm ExamLink updated with download url for zipped images : ${newExamLink.toJson()} ");

    var files = await dioUtil.downloadAndUnpackZip(newExamLink);
    pp("$mm Image files found: ${files.length} ");
    return files;
  }
}
