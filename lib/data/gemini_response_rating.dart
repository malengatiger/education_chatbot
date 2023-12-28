import 'package:json_annotation/json_annotation.dart';

import 'exam_page_image.dart';

part 'gemini_response_rating.g.dart';
/*
    Long id;

    @ManyToOne
    @JoinColumn(name = "exam_page_image_id")
    private ExamPageImage examPageImage;

    @Column(name = "rating")
    int rating;
    @Column(name = "date")
    String date;
    @Column(name = "response_text")
    private String responseText;
    @Column(name = "prompt")
    private String prompt;
 */
@JsonSerializable()
class GeminiResponseRating {
  int? rating;
  String? date;
  int? id;
  ExamPageImage? examPageImage;
  String? responseText;
  String? prompt;


  GeminiResponseRating(
      this.rating, this.date, this.responseText, this.prompt);

  factory GeminiResponseRating.fromJson(Map<String, dynamic> json) =>
      _$GeminiResponseRatingFromJson(json);

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = _$GeminiResponseRatingToJson(this);

    return data;
  }}
