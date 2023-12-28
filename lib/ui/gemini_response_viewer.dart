import 'package:edu_chatbot/util/functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

import '../data/exam_link.dart';
import '../data/gemini/gemini_response.dart';

class GeminiResponseViewer extends StatefulWidget {
  const GeminiResponseViewer(
      {super.key, required this.examLink, required this.geminiResponse});

  final ExamLink examLink;
  final GeminiResponse geminiResponse;

  @override
  State<GeminiResponseViewer> createState() => _GeminiResponseViewerState();
}

class _GeminiResponseViewerState extends State<GeminiResponseViewer> {
  String getResponseString() {
    var sb = StringBuffer();
    widget.geminiResponse.candidates?.forEach((candidate) {
      for (var parts in candidate.content!.parts!) {
        sb.write(parts.text);
        sb.write("\n");
      }
    });
    return sb.toString();
  }

  bool _showRatingBar = true;

  Widget getRatingWidget() {
    return RatingBar.builder(
      initialRating: 0,
      minRating: 1,
      direction: Axis.horizontal,
      allowHalfRating: false,
      itemCount: 5,
      itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
      itemBuilder: (context, _) => const Icon(
        Icons.star,
        color: Colors.amber,
      ),
      onRatingUpdate: (rating) {
        pp('🍎🍎🍎 onRatingUpdate: rating: 🍎$rating 🍎');
        Future.delayed(const Duration(seconds: 2), () {
          setState(() {
            _showRatingBar = false;
          });
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
            appBar: AppBar(
              title: const Text("SgelaAI Response"),
            ),
            backgroundColor: Colors.brown.shade100,
            body: Stack(
              children: [
                ListView(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Card(
                          elevation: 8,
                          shape: getDefaultRoundedBorder(),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(getResponseString(),
                                style: myTextStyle(
                                    context,
                                    Theme.of(context).primaryColor,
                                    16,
                                    FontWeight.normal)),
                          )),
                    ),
                  ],
                ),
                _showRatingBar
                    ? Positioned(
                        bottom: 12,
                        right: 48,
                        child: Card(
                          elevation: 16,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: getRatingWidget(),
                          ),
                        ),
                      )
                    : gapW8,
              ],
            )));
  }
}
