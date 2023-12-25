import 'dart:io';

import 'package:archive/archive.dart';
import 'package:dio/dio.dart';
import 'package:edu_chatbot/data/subject.dart';
import 'package:edu_chatbot/services/local_data_service.dart';
import 'package:edu_chatbot/util/dio_util.dart';
import 'package:edu_chatbot/util/environment.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

import '../data/exam_image.dart';
import '../data/exam_link.dart';
import '../util/functions.dart';

class Repository {
  final DioUtil dioUtil;

  final Dio dio;
  final LocalDataService localDataService;

  static const mm = '💦💦💦💦 Repository 💦';

  Repository(this.dioUtil, this.localDataService, this.dio);

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

  Future<List<ExamImage>> extractImages(ExamLink link, bool refresh) async {
    pp('$mm extractImages ....');
    var list = <ExamImage>[];
    try {
      if (refresh) {
        var files = await _downloadImages(link);
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

  Future<List<ExamImage>> getExamImages(ExamLink examLink) async {
    List<ExamImage> examImages = [];

    var localImages = await localDataService.getExamImages(examLink.id!);
    if (localImages.isNotEmpty) {
      return localImages;
    }
    pp('$mm getExamImages: starting image file download ...');
    examImages = await _downloadImages(examLink);

    pp('$mm getExamImages: image file downloaded: ${examImages.length} ...');
    return examImages;
  }

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

  Future<List<ExamImage>> _downloadImages(ExamLink examLink) async {
    pp('$mm _downloadImages: extract images ...');
    var url = ChatbotEnvironment.getSkunkUrl();
    var res = await dioUtil.sendGetRequest(
        '${url}pdf/createPdfPageImages', {'examLinkId': examLink.id!});

    var newExamLink = ExamLink.fromJson(res);
    var files = await _downloadAndUnpackZip(newExamLink);
    pp("$mm _downloadImages: Image files found: ${files.length} ");
    return files;
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

  Future<List<ExamImage>> _downloadAndUnpackZip(ExamLink examLink) async {
    pp('$mm Download the zipped exam images file ...');
    if (examLink.pageImageZipUrl == null) {
      throw Exception('pageImageZipUrl is null! not on examLink');
    }

    List<File> extractedFiles = [];
    await _handleUncompress(examLink, extractedFiles);
    List<ExamImage> list = await localDataService.getExamImages(examLink.id!);

    return list;
  }

  Future<File> _handleUncompress(
      ExamLink examLink, List<File> extractedFiles) async {
    Response<List<int>> response = await dio.get<List<int>>(
      examLink.pageImageZipUrl!,
      options: Options(responseType: ResponseType.bytes),
    );

    // Create a temporary directory to extract the zip file
    pp('$mm Create a permanent directory to extract the zip file ...');
    File zipFile;

    // Get the app's documents directory
    Directory documentsDirectory = await getApplicationDocumentsDirectory();

    // Create a subdirectory within the documents directory
    Directory subDirectory =
        Directory('${documentsDirectory.path}/examLink_${examLink.id}');
    if (!await subDirectory.exists()) {
      await subDirectory.create(recursive: true);
    }
    pp('$mm permanent directory created: ${subDirectory.path} ...');
    // Save the downloaded zip file to the temporary directory

    String zipFilePath =
        path.join(subDirectory.path, 'images_${examLink.id}.zip');
    zipFile = File(zipFilePath);
    if (response.data != null) {
      await zipFile.writeAsBytes(response.data!, flush: true);
    }

    // Extract the zip file
    pp("$mm  Extract the image files from zipped directory: "
        " 💙💙💙💙💙 $zipFilePath ${(await zipFile.length())} bytes");

    Archive archive = ZipDecoder().decodeBytes(zipFile.readAsBytesSync());

    int index = 0;
    for (ArchiveFile file in archive) {
      if (file.isFile) {
        String filePath = path.join(subDirectory.path, file.name);
        File extractedFile = File(filePath);
        extractedFile.createSync(recursive: true);
        extractedFile.writeAsBytesSync(file.content);
        pp("$mm  File unpacked from zipped directory: "
            "💙index: $index  💙length: ${await extractedFile.length()} bytes");
        //
        var examImage =
            ExamImage(examLink.id, extractedFile.path, file.content, index);
        await localDataService.addExamImage(examImage);
        extractedFiles.add(extractedFile);
        index++;
      }
    }
    pp("$mm  Image files from zipped directory: "
        " 💙💙💙💙💙  ${(extractedFiles.length)} files");
    return zipFile;
  }
}
