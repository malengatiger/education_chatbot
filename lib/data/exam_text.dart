import 'package:json_annotation/json_annotation.dart';

part 'exam_text.g.dart';

@JsonSerializable()
class ExamText {
  int? examLinkId;
  int? id;
  String? text;


  ExamText(this.examLinkId, this.text);

  factory ExamText.fromJson(Map<String, dynamic> json) =>
      _$ExamTextFromJson(json);

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = _$ExamTextToJson(this);

    return data;
  }}
