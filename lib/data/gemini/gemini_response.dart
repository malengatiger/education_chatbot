
import 'package:json_annotation/json_annotation.dart';
import 'parts.dart';
import 'safety_ratings.dart';
import 'prompt_feedback.dart';
import 'content.dart';
import 'package:json_annotation/json_annotation.dart';
import 'candidates.dart';
part 'gemini_response.g.dart';

@JsonSerializable()
class MyGeminiResponse {
  List<MyCandidates>? candidates;
  MyPromptFeedback? promptFeedback;

  MyGeminiResponse({this.candidates, this.promptFeedback});

  factory MyGeminiResponse.fromJson(Map<String, dynamic> json) =>
      _$GeminiResponseFromJson(json);

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = _$GeminiResponseToJson(this);

    return data;
  }}











