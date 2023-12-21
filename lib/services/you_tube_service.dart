import 'package:edu_chatbot/util/dio_util.dart';
import 'package:edu_chatbot/util/environment.dart';

import '../data/youtube_data.dart';
import '../util/functions.dart';
import 'local_data_service.dart';

class YouTubeService {

  static const mm = '🥦🥦🥦YouTubeService: 🍎';
  final DioUtil dioUtil;
  final LocalDataService localDataService;

  YouTubeService(this.dioUtil, this.localDataService);

  Future<List<YoutubeData>> searchByTag({required int subjectId,
    required int maxResults, required int tagType}) async {
    pp('$mm searchByTag: subjectId: $subjectId');
    String url = ChatbotEnvironment.getSkunkUrl();
    String mUrl = '${url}searchVideosByTag';
    List<YoutubeData> youTubeDataList = [];
    var res = await dioUtil.sendGetRequest(mUrl, {
      'subjectId': subjectId,
      'maxResults': maxResults,
      'tagType': tagType
    });
    // Assuming the response data is a list of youTubeDataList

    List<dynamic> responseData = res;
    for (var linkData in responseData) {
      YoutubeData ytd = YoutubeData.fromJson(linkData);
      youTubeDataList.add(ytd);
    }

    pp("$mm YouTubeData found: ${youTubeDataList.length}, "
        "subjectId: $subjectId maxResults: $maxResults tagType: $tagType");
    if (youTubeDataList.isNotEmpty) {
      localDataService.addYouTubeData(youTubeDataList);
    }
    return youTubeDataList;
  }

}
