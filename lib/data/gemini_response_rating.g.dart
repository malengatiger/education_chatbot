// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gemini_response_rating.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GeminiResponseRating _$GeminiResponseRatingFromJson(
        Map<String, dynamic> json) =>
    GeminiResponseRating(
      json['rating'] as int?,
      json['date'] as String?,
      json['responseText'] as String?,
      json['prompt'] as String?,
    )
      ..id = json['id'] as int?
      ..examPageImage = json['examPageImage'] == null
          ? null
          : ExamPageImage.fromJson(
              json['examPageImage'] as Map<String, dynamic>);

Map<String, dynamic> _$GeminiResponseRatingToJson(
        GeminiResponseRating instance) =>
    <String, dynamic>{
      'rating': instance.rating,
      'date': instance.date,
      'id': instance.id,
      'examPageImage': instance.examPageImage,
      'responseText': instance.responseText,
      'prompt': instance.prompt,
    };
