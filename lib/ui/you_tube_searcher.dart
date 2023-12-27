import 'package:edu_chatbot/ui/you_tube_viewer.dart';
import 'package:edu_chatbot/util/environment.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../data/youtube_data.dart';
import '../services/you_tube_service.dart';
import '../util/functions.dart';
import '../util/navigation_util.dart';

class YouTubeSearcher extends StatefulWidget {
  const YouTubeSearcher(
      {super.key, required this.youTubeService, required this.subjectId});

  final YouTubeService youTubeService;
  final int subjectId;

  @override
  YouTubeSearcherState createState() => YouTubeSearcherState();
}

class YouTubeSearcherState extends State<YouTubeSearcher> {
  List<YouTubeData> videos = [];
  TextEditingController textEditingController = TextEditingController();
  static const mm = '🍎🍎🍎🍎 YouTubeSearcher 🍐';

  Future<void> _search() async {
    pp('$mm ... search YouTube ...');
    videos = await widget.youTubeService.searchByTag(
        subjectId: widget.subjectId,
        maxResults: ChatbotEnvironment.maxResults,
        tagType: 1);
    pp('$mm ... search YouTube found: ${videos.length} ...');
  }

  void _launchVideo(String videoUrl) async {
    if (await canLaunchUrl(Uri.parse(videoUrl))) {
      await launchUrl(Uri.parse(videoUrl));
    } else {
      // If the YouTube app is not installed, open the video in a WebView
      if (mounted) {
        NavigationUtils.navigateToPage(
            context: context,
            widget: YouTubeViewer(
              youTubeVideoUrl: videoUrl,
            ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          appBar: AppBar(),
          body: Stack(
            children: [
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      controller: textEditingController,
                      onChanged: (value) {
                        pp('... search text: $value');
                      },
                      decoration: InputDecoration(
                        labelText: 'Search',
                        border: const OutlineInputBorder(),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.search),
                          onPressed: () {
                            _search();
                          },
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 8.0,
                        mainAxisSpacing: 8.0,
                      ),
                      itemCount: videos.length,
                      itemBuilder: (context, index) {
                        YouTubeData video = videos[index];
                        return GestureDetector(
                          onTap: () {
                            _launchVideo(video.videoUrl!);
                          },
                          child: Image.network(video.thumbnailDefault ?? ''),
                        );
                      },
                    ),
                  ),
                ],
              )
            ],
          )),
    );
  }
}
