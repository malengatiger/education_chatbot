import 'parts.dart';
import 'package:json_annotation/json_annotation.dart';

part 'content.g.dart';

@JsonSerializable()
class Content {
  List<Parts>? parts;
  String? role;

  Content({this.parts, this.role});

  factory Content.fromJson(Map<String, dynamic> json) =>
      _$ContentFromJson(json);

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = _$ContentToJson(this);

    return data;
  }}

