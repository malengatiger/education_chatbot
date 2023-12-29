import 'content.dart';
import 'safety_ratings.dart';
import 'package:json_annotation/json_annotation.dart';

part 'candidates.g.dart';

@JsonSerializable()
class MyCandidates {
  MyContent? content;
  String? finishReason;
  int? index;
  List<SafetyRatings>? safetyRatings;

  MyCandidates({this.content, this.finishReason, this.index, this.safetyRatings});

  factory MyCandidates.fromJson(Map<String, dynamic> json) =>
      _$CandidatesFromJson(json);

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = _$CandidatesToJson(this);

    return data;
  }}
