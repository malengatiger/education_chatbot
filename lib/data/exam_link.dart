import 'package:edu_chatbot/data/Subject.dart';
import 'package:json_annotation/json_annotation.dart';

part 'exam_link.g.dart';

@JsonSerializable()
class ExamLink {
  String? title;
  String? link;
  int? id;
  Subject? subject;
  String? pageImageZipUrl;
  String? documentTitle;

  ExamLink(this.title, this.link, this.id, this.subject, this.pageImageZipUrl,
      this.documentTitle);

  factory ExamLink.fromJson(Map<String, dynamic> json) =>
      _$ExamLinkFromJson(json);

  Map<String, dynamic> toJson() => _$ExamLinkToJson(this);
}
