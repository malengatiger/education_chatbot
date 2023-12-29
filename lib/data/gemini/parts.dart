import 'package:json_annotation/json_annotation.dart';

part 'parts.g.dart';

@JsonSerializable()
class MyParts {
  String? text;

  MyParts({this.text});

  factory MyParts.fromJson(Map<String, dynamic> json) =>
      _$PartsFromJson(json);

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = _$PartsToJson(this);

    return data;
  }}

