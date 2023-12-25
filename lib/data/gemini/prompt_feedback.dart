import 'safety_ratings.dart';
import 'package:json_annotation/json_annotation.dart';

part 'prompt_feedback.g.dart';

@JsonSerializable()
class PromptFeedback {
  List<SafetyRatings>? safetyRatings;

  PromptFeedback({this.safetyRatings});

  factory PromptFeedback.fromJson(Map<String, dynamic> json) =>
      _$PromptFeedbackFromJson(json);

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = _$PromptFeedbackToJson(this);

    return data;
  }}

