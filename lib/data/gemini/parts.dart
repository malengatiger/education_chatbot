import 'package:json_annotation/json_annotation.dart';

part 'parts.g.dart';

@JsonSerializable()
class Parts {
  String? text;

  Parts({this.text});

  factory Parts.fromJson(Map<String, dynamic> json) =>
      _$PartsFromJson(json);

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = _$PartsToJson(this);

    return data;
  }}

