import 'package:edu_chatbot/data/Subject.dart';
import 'package:json_annotation/json_annotation.dart';
part 'youtube_data.g.dart';
@JsonSerializable()

class YoutubeData {
  int? id;
  String? title, description, channelId, videoId, playlistId;
  String? videoUrl, channelUrl, playlistUrl;
  String? thumbnailHigh, thumbnailMedium, thumbnailDefault;
  int? subjectId;



  YoutubeData(
      this.id,
      this.title,
      this.description,
      this.channelId,
      this.videoId,
      this.playlistId,
      this.videoUrl,
      this.channelUrl,
      this.playlistUrl,
      this.thumbnailHigh,
      this.thumbnailMedium,
      this.thumbnailDefault,
      this.subjectId);

  factory YoutubeData.fromJson(Map<String, dynamic> json) =>
      _$YoutubeDataFromJson(json);

  Map<String, dynamic> toJson() => _$YoutubeDataToJson(this);

  static const String VIDEO = "https://www.youtube.com/watch?v=";
  static const String CHANNEL = "https://www.youtube.com/channel/";
  static const String PLAYLIST = "https://www.youtube.com/playlist?list=";
}

