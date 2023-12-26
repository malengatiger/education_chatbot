import 'dart:collection';
import 'dart:io';
import 'dart:typed_data';

import 'package:edu_chatbot/data/exam_link.dart';
import 'package:edu_chatbot/repositories/repository.dart';
import 'package:edu_chatbot/ui/exam_paper_header.dart';
import 'package:edu_chatbot/ui/gemini_response_viewer.dart';
import 'package:edu_chatbot/ui/math_viewer.dart';
import 'package:edu_chatbot/ui/pdf_viewer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tex/flutter_tex.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../data/exam_image.dart';
import '../data/gemini/gemini_response.dart';
import '../services/chat_service.dart';
import '../util/functions.dart';

class ExamPaperPages extends StatefulWidget {
  final ExamLink examLink;
  final Repository repository;
  final ChatService chatService;

  const ExamPaperPages(
      {super.key,
      required this.examLink,
      required this.repository,
      required this.chatService});

  @override
  ExamPaperPagesState createState() => ExamPaperPagesState();
}

class ExamPaperPagesState extends State<ExamPaperPages> {
  List<ExamImage> images = [];
  List<ExamImage> selectedImages = [];
  List<File> examImageFiles = [];
  late PageController _pageController;
  bool isHeaderVisible = true; // Track the visibility of the ExamPaperHeader
  static const mm = '🍐🍐🍐🍐 ExamPaperPages 🍐';
  final FocusNode _focusNode = FocusNode();
  bool busy = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _fetchExamImages();
  }

  String prompt = '';

  /*
  file size: 🍎764916 bytes -  🍐 🍐 🍐 /var/mobile/Containers/Data/Application/236581DF-3EB0-4BB5-8B95-46BCA0795238/Documents/examLink_90/image0.png
  file size: 🍎253990 bytes -  🍐 🍐 🍐 /var/mobile/Containers/Data/Application/236581DF-3EB0-4BB5-8B95-46BCA0795238/Documents/examLink_90/image1.png
  file size: 🍎287811 bytes -  🍐 🍐 🍐 /var/mobile/Containers/Data/Application/236581DF-3EB0-4BB5-8B95-46BCA0795238/Documents/examLink_90/image2.png
  file size: 🍎301182 bytes -  🍐 🍐 🍐 /var/mobile/Containers/Data/Application/236581DF-3EB0-4BB5-8B95-46BCA0795238/Documents/examLink_90/image3.png
  file size: 🍎254834 bytes -  🍐 🍐 🍐 /var/mobile/Containers/Data/Application/236581DF-3EB0-4BB5-8B95-46BCA0795238/Documents/examLink_90/image4.png
  file size: 🍎428849 bytes -  🍐 🍐 🍐 /var/mobile/Containers/Data/Application/236581DF-3EB0-4BB5-8B95-46BCA0795238/Documents/examLink_90/image5.png
  file size: 🍎288582 bytes -  🍐 🍐 🍐 /var/mobile/Containers/Data/Application/236581DF-3EB0-4BB5-8B95-46BCA0795238/Documents/examLink_90/image6.png
  file size: 🍎368541 bytes -  🍐 🍐 🍐 /var/mobile/Containers/Data/Application/236581DF-3EB0-4BB5-8B95-46BCA0795238/Documents/examLink_90/image7.png
  file size: 🍎264324 bytes -  🍐 🍐 🍐 /var/mobile/Containers/Data/Application/236581DF-3EB0-4BB5-8B95-46BCA0795238/Documents/examLink_90/image8.png
   */
  Future<void> _fetchExamImages() async {
    pp('$mm get exam images for display ...');

    try {
      if (widget.examLink.pageImageZipUrl == null) {
        images = await widget.repository.extractImages(widget.examLink, true);
      } else {
        images = await widget.repository.getExamImages(widget.examLink);
      }
      pp('$mm exam images found for display: ${images.length}');

      setState(() {});
    } catch (e) {
      pp(e);
      if (mounted) {
        showErrorDialog(context, 'Failed to load examination images');
      }
    }
  }

  bool _checkIfThisImageIsAlreadySelected(ExamImage image) {
    bool found = false;
    for (var element in selectedImages) {
      if (element.imageIndex == image.imageIndex) {
        found = true;
      }
    }

    return found;
  }

  int currentPageIndex = 0;

  void _handlePageChanged(int index) {
    // pp('$mm _handlePageChanged, index: $index ...');
    setState(() {
      currentPageIndex = index;
    });
    var image = images[index];
    // pp('$mm _handlePageChanged, imageIndex: ${image.imageIndex}');
    showToast(
        message: 'Page ${image.imageIndex! + 1}',
        context: context,
        duration: const Duration(milliseconds: 500),
        toastGravity: ToastGravity.TOP_RIGHT,
        backgroundColor: Colors.black,
        textStyle: const TextStyle(fontSize: 18, color: Colors.white));
  }

  void _handlePageTapped(ExamImage examImage) {
    pp('$mm _handlePageTapped, index: ${examImage.imageIndex} ...');

    String sb = _parseSelected();

    // pp('$mm _handlePageChanged, imageIndex: ${image.imageIndex}');
    _displayToast(sb);
  }

  String _parseSelected() {
    var sb = StringBuffer();
    sb.write('Pages selected: ');

    for (var image in selectedImages) {
      sb.write('${image.imageIndex! + 1}, ');
    }
    pp('$mm _handlePageTapped, selectedImages: ${sb.toString()}');
    return sb.toString();
  }

  void _displayToast(String message) {
    showToast(
        message: message,
        context: context,
        duration: const Duration(milliseconds: 2000),
        toastGravity: ToastGravity.BOTTOM_RIGHT,
        backgroundColor: Colors.black,
        textStyle: const TextStyle(fontSize: 18, color: Colors.yellow));
  }

  void _onShowPagesToast() {
    pp('$mm _handleRequestFromSubmitWidget ...');
    _displayToast(_parseSelected());
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _fillSelected(ExamImage examImage) {
    bool found = false;
    for (var element in selectedImages) {
      if (element.imageIndex == examImage.imageIndex!) {
        found = true;
      }
    }
    if (found) {
      selectedImages.remove(examImage);
      pp('$mm _fillSelected, image removed from selected pages: ${selectedImages.length}');
    } else {
      selectedImages.add(examImage);
      pp('$mm _fillSelected, image added to selected pages: ${selectedImages.length}');
    }

    HashMap<int, ExamImage> map = HashMap();
    for (var element in selectedImages) {
      map[element.imageIndex!] = element;
    }
    selectedImages.clear();
    selectedImages.addAll(map.values);
    selectedImages.sort((a, b) => a.imageIndex!.compareTo(b.imageIndex!));
    pp('$mm _fillSelected, selectedImages: ${selectedImages.length}');

    setState(() {});
  }

  void _navigateToPdfViewer() {
    pp('$mm _navigateToPdfViewer ...');
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PDFViewer(
          pdfUrl: widget.examLink.link!,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Exam Paper'),
          actions: [
            IconButton(
              icon: Icon(
                  isHeaderVisible ? Icons.visibility_off : Icons.visibility),
              onPressed: () {
                setState(() {
                  isHeaderVisible = !isHeaderVisible;
                });
              },
            ),
            IconButton(
              icon: const Icon(Icons.file_download),
              onPressed: () {
                _navigateToPdfViewer();
              },
            ),
          ],
        ),
        body: Stack(
          children: [
            Positioned.fill(
              child: PageView.builder(
                controller: _pageController,
                itemCount: images.length,
                reverse: false,
                onPageChanged: (index) {
                  _handlePageChanged(index);
                },
                itemBuilder: (context, index) {
                  final image = images[index];
                  Uint8List bytes = Uint8List.fromList(image.bytes!);
                  return Stack(
                    children: [
                      GestureDetector(
                        onTap: () {
                          pp('$mm onTap, selected images: ${selectedImages.length} '
                              '🍎${image.bytes!.length}');
                          _fillSelected(image);
                          _handlePageTapped(image);
                          setState(() {});
                        },
                        child: Image.memory(
                          bytes,
                          fit: BoxFit.cover,
                          height: double.infinity,
                          width: double.infinity,
                        ),
                      ),
                      if (_checkIfThisImageIsAlreadySelected(image))
                        const Positioned(
                          top: 8,
                          right: 8,
                          child: Icon(
                            Icons.check_circle,
                            color: Colors.green,
                          ),
                        ),
                      if (!_checkIfThisImageIsAlreadySelected(image))
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Icon(
                            Icons.add_box_sharp,
                            color: Colors.grey.shade400,
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),
            if (isHeaderVisible) // Conditionally show the ExamPaperHeader
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: ExamPaperHeader(
                  examLink: widget.examLink,
                  onClose: () {
                    setState(() {
                      isHeaderVisible = false;
                    });
                  },
                ),
              ),
          ],
        ),
        floatingActionButton: selectedImages.isEmpty
            ? gapW8
            : FloatingActionButton(
                onPressed: () {
                  _onSubmit();
                },
                elevation: 16,
                child: const Icon(Icons.send),
              ),
      ),
    );
  }

  TextEditingController textFieldController = TextEditingController();

  _navigateToGeminiResponse(GeminiResponse geminiResponse) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GeminiResponseViewer(
          examLink: widget.examLink,
          geminiResponse: geminiResponse,
        ),
      ),
    );
  }

  _navigateToMathViewer(String text) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => MathViewer(text: text)),
    );
  }

  _onSubmit() async {
    pp('$mm submitting the whole thing to Gemini AI : image files: ${selectedImages.length}');

    setState(() {
      busy = true;
    });

    String mPrompt = getPrompt(widget.examLink.subjectTitle!);
    GeminiResponse? response;
    try {
      response =
          await widget.chatService.sendImageTextPrompt(selectedImages, mPrompt);
      pp('$mm 😎 😎 😎 Gemini AI has responded! see below .... 😎 😎 😎');
      myPrettyJsonPrint(response.toJson());
      String text = getResponseString(response);
      if (isValidLaTeXString(text)) {
        _navigateToMathViewer(text);
      } else {
        _navigateToGeminiResponse(response);
      }
    } catch (e) {
      pp('$mm ERROR $e');
      if (mounted) {
        showErrorDialog(context, 'Error from Gemini AI: $e');
      }
      setState(() {
        busy = false;
      });
    }

    //_onShowPagesToast();
  }

  String getResponseString(GeminiResponse geminiResponse) {
    var sb = StringBuffer();
    geminiResponse.candidates?.forEach((candidate) {
      for (var parts in candidate.content!.parts!) {
        sb.write(parts.text);
        sb.write("\n");
      }
    });
    return sb.toString();
  }

  bool isValidLaTeXString(String text) {
    try {
      // Create a TeXView widget with the given text
      TeXView(
        renderingEngine: const TeXViewRenderingEngine.katex(),
        child: TeXViewDocument(text),
      );
      // If no exception is thrown, the rendering is successful
      return true;
    } catch (e) {
      // An exception occurred, indicating an invalid LaTeX string
      return false;
    }
  }

  String getPrompt(String subject) {
    switch (subject) {
      case 'MATHEMATICS':
        return "Solve the problem in the image. Explain each step in detail. Use well structured Latex(Math) format in your response";
      default:
        return "Help me with this. Explain each step";
    }
  }
}
