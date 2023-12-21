import 'package:edu_chatbot/data/country.dart';
import 'package:json_annotation/json_annotation.dart';

part 'organization.g.dart';
@JsonSerializable()
class Organization {
  String? name, email, cellphone;
  int? id;
  Country? country;


  Organization(this.name, this.email, this.cellphone, this.id, this.country);

  factory Organization.fromJson(Map<String, dynamic> json) =>
      _$OrganizationFromJson(json);

  Map<String, dynamic> toJson() => _$OrganizationToJson(this);
}
