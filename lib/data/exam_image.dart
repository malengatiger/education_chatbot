
import 'package:json_annotation/json_annotation.dart';

part 'exam_image.g.dart';

@JsonSerializable()
class ExamImage {
  int? examLinkId;
  int? id;
  String? filePath;


  ExamImage(this.examLinkId, this.filePath);

  factory ExamImage.fromJson(Map<String, dynamic> json) =>
      _$ExamImageFromJson(json);

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = _$ExamImageToJson(this);

    return data;
  }}

