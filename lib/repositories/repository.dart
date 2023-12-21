import 'package:edu_chatbot/data/Subject.dart';
import 'package:edu_chatbot/services/local_data_service.dart';
import 'package:edu_chatbot/util/dio_util.dart';
import 'package:edu_chatbot/util/environment.dart';
import 'package:get_it/get_it.dart';

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
        list = await _readSubjects();
      } else {
        list = await localDataService.getSubjects();
        if (list.isEmpty) {
          list = await _readSubjects();
        }
      }

      pp("$mm Subjects found: ${list.length} ");

      return list;
    } catch (e) {
      pp(e);
      rethrow;
    }
  }

  Future<List<Subject>> _readSubjects() async {
    var url = ChatbotEnvironment.getSkunkUrl();
    var res = await dioUtil.sendGetRequest('${url}links/getSubjects', {});
    // Assuming the response data is a list of subjects
    pp(res);
    List<dynamic> responseData = res;
    List<Subject> subjects = [];

    for (var subjectData in responseData) {
      Subject subject = Subject.fromJson(subjectData);
      subjects.add(subject);
    }
    pp("$mm Subjects found: ${subjects.length} ");
    if (subjects.isNotEmpty) {
      await localDataService.addSubjects(subjects);
    }
    return subjects;
  }

  Future<List<ExamLink>> getExamLinks(int subjectId, bool refresh) async {
    List<ExamLink> list = [];
    try {
      if (refresh) {
        list = await _read(subjectId);
      } else {
        list = await localDataService.getExamLinksBySubject(subjectId);
        if (list.isEmpty) {
          list = await _read(subjectId);
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

  Future<List<ExamLink>> _read(int subjectId) async {
    List<ExamLink> examLinks = [];
    var url = ChatbotEnvironment.getSkunkUrl();
    var res = await dioUtil.sendGetRequest('${url}links/getSubjectExamLinks', {
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

// Organization registerOrganization(Organization organization) {
//
//
//   return null;
// }
// User registerUser(User user) {
//
// }
}
