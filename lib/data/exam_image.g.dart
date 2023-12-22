// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exam_image.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ExamImage _$ExamImageFromJson(Map<String, dynamic> json) => ExamImage(
      json['examLinkId'] as int?,
      json['filePath'] as String?,
    )..id = json['id'] as int?;

Map<String, dynamic> _$ExamImageToJson(ExamImage instance) => <String, dynamic>{
      'examLinkId': instance.examLinkId,
      'id': instance.id,
      'filePath': instance.filePath,
    };
