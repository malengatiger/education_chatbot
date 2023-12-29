import 'parts.dart';
import 'package:json_annotation/json_annotation.dart';

part 'content.g.dart';

@JsonSerializable()
class MyContent {
  List<MyParts>? parts;
  String? role;

  MyContent({this.parts, this.role});

  factory MyContent.fromJson(Map<String, dynamic> json) =>
      _$ContentFromJson(json);

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = _$ContentToJson(this);

    return data;
  }}

