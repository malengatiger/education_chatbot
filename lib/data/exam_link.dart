import 'package:json_annotation/json_annotation.dart';

part 'exam_link.g.dart';

@JsonSerializable()
class ExamLink {
  String? title;
  String? link;
  int? id;
  String? subjectTitle;
  int? subjectId;
  String? pageImageZipUrl;
  String? documentTitle;


  ExamLink(this.title, this.link, this.id, this.subjectTitle, this.subjectId,
      this.pageImageZipUrl, this.documentTitle);

  factory ExamLink.fromJson(Map<String, dynamic> json) =>
      _$ExamLinkFromJson(json);

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = _$ExamLinkToJson(this);

    return data;
  }}
