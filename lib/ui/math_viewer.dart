import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:edu_chatbot/ui/rating_widget.dart';
import 'package:edu_chatbot/util/functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_tex/flutter_tex.dart';

// import 'package:image/image.dart' as ui;
import '../data/exam_page_image.dart';

class MathViewer extends StatefulWidget {
  const MathViewer(
      {super.key,
      required this.text,
      required this.onShare,
      required this.onRerun,
      required this.selectedImages,
      required this.onExit});

  final String text;
  static const mm = '💙💙💙💙 MathViewer 💙';
  final Function(List<ExamPageImage>) onShare;
  final Function(List<ExamPageImage>) onExit;
  final Function(List<ExamPageImage>) onRerun;
  final List<ExamPageImage> selectedImages;

  @override
  State<MathViewer> createState() => _MathViewerState();
}

class _MathViewerState extends State<MathViewer> {
  final GlobalKey _repaintBoundaryKey = GlobalKey();

  bool _showRatingBar = true;
  List<ExamPageImage> list = [];

  @override
  void initState() {
    super.initState();
    _clone();
  }

  _clone() {
    for (var value in widget.selectedImages) {
      var m = ExamPageImage(
          value.examLinkId, value.id, value.downloadUrl, value.bytes, value.pageIndex,
      value.mimeType);
      list.add(m);
      pp('${MathViewer.mm} ... _cloned images: ${list.length}');

    }
  }

  @override
  Widget build(BuildContext context) {
    var h = MediaQuery.of(context).size.height;
    return PopScope(
      onPopInvoked: (isPopping) async {
        pp('${MathViewer.mm} ... onPopInvoked,  isPopping: $isPopping');
        widget.onExit(list);
      },
      child: SafeArea(
        child: Scaffold(
          appBar: AppBar(title: const Text('Mathematics'), actions: [
            PopupMenuButton(
              onSelected: (value) async {
                switch (value) {
                  case '/share':
                    pp('${MathViewer.mm} ... share required ... images: ${list.length}');
                    widget.onShare(list);
                    break;
                  case '/rating':
                    pp('${MathViewer.mm} ... rating required, will set _showRatingBar true');
                    setState(() {
                      _showRatingBar = true;
                    });
                    break;
                  case '/rerun':
                    pp('${MathViewer.mm} ... rerun required, images: ${list.length}');
                    widget.onRerun(list);
                    Navigator.pop(context); // Close the widget
                    break;
                }
              },
              itemBuilder: (BuildContext bc) {
                return const [
                  PopupMenuItem(
                    value: '/rating',
                    child: Icon(Icons.star),
                  ),
                  PopupMenuItem(
                    value: '/share',
                    child: Icon(Icons.share),
                  ),
                  PopupMenuItem(
                    value: '/rerun',
                    child: Icon(Icons.search),
                  )
                ];
              },
            )
          ]),
          backgroundColor: Colors.brown[100],
          body: Stack(
            children: [
              Positioned.fill(
                child: RepaintBoundary(
                  key: _repaintBoundaryKey,
                  child: Container(
                    width: double.infinity,
                    // height: h,
                    padding: const EdgeInsets.all(4.0),
                    child: Holder(text: getFormattedText()),
                  ),
                ),
              ),
              Positioned(
                  bottom: 16,
                  right: 48,
                  child: GeminiRating(
                    onRating: (rating) {
                      pp('💙💙 Gemini rating: $rating, 💙💙 set _showRatingBar to false');
                      showToast(
                          message: 'Rating saved. Thank you!',
                          textStyle: myTextStyleMediumLargeWithColor(context,
                              Colors.greenAccent, 16, FontWeight.normal),
                          context: context);
                      Future.delayed(const Duration(seconds: 2), () {
                        setState(() {
                          _showRatingBar = false;
                        });
                        if (rating < 3.0) {
                          widget.onRerun(list);
                          Navigator.pop(context); // Close the widget
                        }
                      });
                    },
                    visible: _showRatingBar,
                  )),
            ],
          ),
        ),
      ),
    );
  }

  String getFormattedText() {
    return widget.text;
  }

  Future<File> convertLatexToImage(
      String latexString, BuildContext context) async {
    final texView = TeXView(
      renderingEngine: const TeXViewRenderingEngine.katex(),
      child: TeXViewDocument(latexString),
    );

    final boundary = GlobalKey();
    final widget = RepaintBoundary(
      key: boundary,
      child: texView,
    );

    final completer = Completer<File>();

    WidgetsBinding.instance!.addPostFrameCallback((_) async {
      final renderObject =
          boundary.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (renderObject != null) {
        final image = await renderObject.toImage(pixelRatio: 3.0);
        final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
        final pngBytes = byteData!.buffer.asUint8List();

        final file =
            await File('${Directory.systemTemp.path}/latex_image.png').create();
        await file.writeAsBytes(pngBytes);

        completer.complete(file);
      } else {
        completer.completeError(
            Exception('Failed to capture the rendered LaTeX as an image.'));
      }
    });

    return completer.future;
  }

  //
  Future<File> _convertWidgetToImage(BuildContext context) async {
    RenderRepaintBoundary boundary = _repaintBoundaryKey.currentContext!
        .findRenderObject() as RenderRepaintBoundary;
    ui.Image? image = await boundary.toImage(
        pixelRatio: MediaQuery.of(context).devicePixelRatio);
    ByteData? byteData =
        await image!.toByteData(format: ui.ImageByteFormat.png);
    Uint8List? pngBytes = byteData?.buffer.asUint8List();
    File file =
        await File('${Directory.systemTemp.path}/widget_image.png').create();
    await file.writeAsBytes(pngBytes!);
    pp('${MathViewer.mm} 🍎🍎🍎_convertWidgetToImage: 💛file length: ${await file.length()} 💛 path: ${file.path}');
    return file;
  }
}

class Holder extends StatelessWidget {
  const Holder({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 8,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SizedBox(
          height: 600,
          child: Column(
            children: [
              Text(
                "SgelaAI Response",
                style: myTextStyleMediumLargeWithColor(
                  context,
                  Colors.black,
                  24,
                  FontWeight.w900,
                ),
              ),
              gapW16,
              Expanded(
                child: SingleChildScrollView(
                  child: TeXView(
                    renderingEngine: const TeXViewRenderingEngine.katex(),
                    child: TeXViewColumn(
                      children: [
                        TeXViewDocument(text),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
