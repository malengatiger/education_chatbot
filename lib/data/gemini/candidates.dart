import 'content.dart';
import 'safety_ratings.dart';
import 'package:json_annotation/json_annotation.dart';

part 'candidates.g.dart';

@JsonSerializable()
class Candidates {
  Content? content;
  String? finishReason;
  int? index;
  List<SafetyRatings>? safetyRatings;

  Candidates({this.content, this.finishReason, this.index, this.safetyRatings});

  factory Candidates.fromJson(Map<String, dynamic> json) =>
      _$CandidatesFromJson(json);

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = _$CandidatesToJson(this);

    return data;
  }}
