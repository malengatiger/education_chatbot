// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'prompt_feedback.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MyPromptFeedback _$PromptFeedbackFromJson(Map<String, dynamic> json) =>
    MyPromptFeedback(
      safetyRatings: (json['safetyRatings'] as List<dynamic>?)
          ?.map((e) => SafetyRatings.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$PromptFeedbackToJson(MyPromptFeedback instance) =>
    <String, dynamic>{
      'safetyRatings': instance.safetyRatings,
    };
