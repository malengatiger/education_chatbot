// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exam_text.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ExamText _$ExamTextFromJson(Map<String, dynamic> json) => ExamText(
      json['examLinkId'] as int?,
      json['text'] as String?,
    )..id = json['id'] as int?;

Map<String, dynamic> _$ExamTextToJson(ExamText instance) => <String, dynamic>{
      'examLinkId': instance.examLinkId,
      'id': instance.id,
      'text': instance.text,
    };
