import 'dart:io';

import 'package:edu_chatbot/data/exam_page_image.dart';
import 'package:edu_chatbot/repositories/repository.dart';
import 'package:edu_chatbot/util/functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

import '../data/exam_link.dart';
import '../data/gemini/gemini_response.dart';
import '../data/gemini_response_rating.dart';

class GeminiResponseViewer extends StatefulWidget {
  const GeminiResponseViewer(
      {super.key,
      required this.examLink,
      required this.geminiResponse,
      required this.repository,
      required this.prompt,
      required this.examPageImage});

  final ExamLink examLink;
  final MyGeminiResponse geminiResponse;
  final Repository repository;
  final String prompt;
  final ExamPageImage examPageImage;

  @override
  State<GeminiResponseViewer> createState() => _GeminiResponseViewerState();
}

class _GeminiResponseViewerState extends State<GeminiResponseViewer> {
  static const mm = '🍐🍐🍐🍐 GeminiResponseViewer 🍐';

  String getResponseString() {
    var sb = StringBuffer();
    widget.geminiResponse.candidates?.forEach((candidate) {
      candidate.content?.parts?.forEach((parts) {
        sb.write(parts.text ?? '');
        sb.write('\n');
      });
    });
    return sb.toString();
  }

  final bool _showRatingBar = true;

  _sendRating(int mRating) async {
    try {
      var gr = GeminiResponseRating(
          rating: mRating,
          date: DateTime.now().toIso8601String(),
          examPageImageId: widget.examPageImage.id,
          responseText: getResponseString(),
          prompt: widget.prompt);

      var res = await widget.repository.addRating(gr);
      pp('$mm 💙💙💙💙 GeminiResponseRating sent to backend!');
      myPrettyJsonPrint(res.toJson());
    } catch (e) {
      pp('$mm ERROR - $e');
    }
  }

  bool isRated = false;
  int ratingUpdated = 0;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            "${widget.examLink.title}",
            style: myTextStyle(context, Colors.black, 14, FontWeight.bold),
          ),
          leading: IconButton(
              icon: Icon(
                Platform.isAndroid ? Icons.arrow_back : Icons.arrow_back_ios,
              ),
              onPressed: () {
                // Handle the back button press
                if (isRated) {
                  Navigator.of(context).pop(ratingUpdated);
                } else {
                  showToast(
                      message: 'Please Rate the SgelaAI response',
                      textStyle: myTextStyle(
                          context, Colors.amber, 16, FontWeight.normal),
                      context: context);
                }
              }),
          actions: [
            IconButton(
                onPressed: () {
                  pp('$mm ... share pressed');
                },
                icon: const Icon(Icons.share))
          ],
        ),
        backgroundColor: Colors.brown.shade100,
        body: Stack(
          children: [
            Column(
              children: [
                gapH8,
                Card(
                  elevation: 8,
                  child: Padding(
                    padding: const EdgeInsets.only(
                        left: 48.0, right: 48.0, top: 8.0, bottom: 8.0),
                    child: Text('SgelaAI Response',
                        style: myTextStyle(
                            context,
                            Theme.of(context).primaryColor,
                            20,
                            FontWeight.w900)),
                  ),
                ),
                Expanded(
                  child: ListView(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Card(
                            elevation: 8,
                            shape: getDefaultRoundedBorder(),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: SingleChildScrollView(
                                child: Text(getResponseString(),
                                    style: myTextStyle(context, Colors.black,
                                        16, FontWeight.normal)),
                              ),
                            )),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            _showRatingBar
                ? Positioned(
                    bottom: 12,
                    right: 48,
                    child: Card(
                      elevation: 16,
                      color: Colors.amber[200],
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: RatingBar.builder(
                          initialRating: 0,
                          minRating: 1,
                          direction: Axis.horizontal,
                          allowHalfRating: false,
                          itemCount: 5,
                          itemPadding:
                              const EdgeInsets.symmetric(horizontal: 4.0),
                          itemBuilder: (context, _) =>  Icon(
                            Icons.star,
                            color: Colors.pink[700],
                          ),
                          onRatingUpdate: (rating) async {
                            pp('$mm 🍎🍎🍎 onRatingUpdate: rating: 🍎$rating 🍎 send to backend ...');
                            isRated = true;
                            ratingUpdated = rating.round();
                            _sendRating(rating
                                .round()); // Convert the floating-point number to an integer
                            pp('$mm 🍎🍎🍎 onRatingUpdate: rating:  wait 2 seconds ...');
                            await Future.delayed(
                                const Duration(milliseconds: 2000), () {
                              pp('$mm 🍎🍎🍎 onRatingUpdate: Future.delayed fired');
                              try {
                                if (mounted) {
                                  Navigator.of(context).pop();
                                }
                              } catch (e) {
                                pp('$mm 👿👿👿 Error with Navigator popping: 👿$e 👿');
                              }
                            });
                          },
                        ),
                      ),
                    ),
                  )
                : gapW8,
          ],
        ),
      ),
    );
  }
}
