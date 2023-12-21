import 'package:edu_chatbot/data/Subject.dart';
import 'package:edu_chatbot/util/dio_util.dart';
import 'package:edu_chatbot/util/environment.dart';

import '../data/exam_link.dart';
import '../util/functions.dart';

class Repository {
  final DioUtil dioUtil;
  static const mm = '💦💦💦💦 Repository 💦';

  Repository(this.dioUtil);

  Future<List<Subject>> getSubjects() async {
    try {
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

      return subjects;
    } catch (e) {
      pp(e);
      rethrow;
    }
  }

  Future<List<ExamLink>> getExamLinks(int subjectId) async {
    try {
      var url = ChatbotEnvironment.getSkunkUrl();
      var res = await dioUtil.sendGetRequest('${url}links/getSubjectExamLinks', {
        'subjectId': subjectId
      });
      // Assuming the response data is a list of examLinks
      pp(res);
      List<dynamic> responseData = res;
      List<ExamLink> examLinks = [];

      for (var linkData in responseData) {
        ExamLink examLink = ExamLink.fromJson(linkData);
        examLinks.add(examLink);
      }

      pp("$mm  Exam links found: ${examLinks.length}, subjectId: $subjectId ");

          return examLinks;
    } catch (e) {
      pp(e);
      rethrow;
    }
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
