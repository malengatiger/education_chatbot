import 'dart:async';
import 'dart:collection';
import 'dart:io';
import 'dart:typed_data';

import 'package:badges/badges.dart' as bd;
import 'package:edu_chatbot/data/exam_link.dart';
import 'package:edu_chatbot/repositories/repository.dart';
import 'package:edu_chatbot/ui/exam_paper_header.dart';
import 'package:edu_chatbot/ui/gemini_response_viewer.dart';
import 'package:edu_chatbot/ui/math_viewer.dart';
import 'package:edu_chatbot/ui/pdf_viewer.dart';
import 'package:edu_chatbot/util/busy_indicator.dart';
import 'package:edu_chatbot/util/navigation_util.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../data/exam_page_image.dart';
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
  List<ExamPageImage> images = [];
  List<ExamPageImage> selectedImages = [];
  List<File> examImageFiles = [];
  late PageController _pageController;
  bool isHeaderVisible = true; // Track the visibility of the ExamPaperHeader
  static const mm = '🍐🍐🍐🍐 ExamPaperPages 🍐';
  bool busyLoading = false;
  bool busySending = false;

  late StreamSubscription pageSub;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _listen();
    _fetchExamImages();
  }

  int pageNumber = 0;

  _listen() {
    pageSub = widget.repository.pageStream.listen((page) {
      pp('$mm pageStream : ............. downloaded page $page');
      if (mounted) {
        _showPageToast(page);
      }
    });
  }

  late Timer timer;

  void _executeAfterDelay() {
    timer = Timer(const Duration(seconds: 10), () {
      // Code to be executed after the delay of 10 seconds
      pp('$mm Hiding the header after 10 seconds');
      if (mounted) {
        setState(() {
          isHeaderVisible = false;
        });
      }
    });
  }

  _showPageToast(int pageNumber) {
    showToast(
        message: 'Page $pageNumber downloaded and converted to image',
        context: context,
        duration: const Duration(seconds: 2),
        toastGravity: ToastGravity.CENTER,
        backgroundColor: Colors.black,
        textStyle: const TextStyle(fontSize: 14, color: Colors.white));
  }

  @override
  void dispose() {
    pageSub.cancel();
    _pageController.dispose();
    timer.cancel();
    super.dispose();
  }

  String prompt = '';

  Future<void> _fetchExamImages() async {
    pp('$mm .........................'
        'get exam images for display ...');
    setState(() {
      busyLoading = true;
    });

    try {
      images = await widget.repository.getExamImages(widget.examLink.id!);
      pp('$mm exam images found for display: ${images.length}');
      _executeAfterDelay();
    } catch (e) {
      pp(e);
      if (mounted) {
        showErrorDialog(context, 'Failed to load examination images');
      }
    }
    setState(() {
      busyLoading = false;
    });
  }

  bool _checkIfThisImageIsAlreadySelected(ExamPageImage image) {
    bool found = false;
    for (var element in selectedImages) {
      if (element.pageIndex == image.pageIndex) {
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
        message: 'Page ${image.pageIndex! + 1}',
        context: context,
        duration: const Duration(milliseconds: 500),
        toastGravity: ToastGravity.TOP_RIGHT,
        backgroundColor: Colors.black,
        textStyle: const TextStyle(fontSize: 18, color: Colors.white));
  }

  void _handlePageTapped(ExamPageImage examImage) {
    pp('$mm _handlePageTapped, index: ${examImage.pageIndex} ...');

    // pp('$mm _handlePageChanged, imageIndex: ${image.imageIndex}');
    if (selectedImages.isNotEmpty) {
      String sb = _parseSelected();
      _displayToast(sb);
    }
  }

  String _parseSelected() {
    var sb = StringBuffer();
    sb.write('Page selected: ');

    for (var image in selectedImages) {
      sb.write('${image.pageIndex! + 1} ');
    }
    pp('$mm _handlePageTapped, selectedImages: ${sb.toString()}');
    return sb.toString();
  }

  void _displayToast(String message) {
    showToast(
        message: message,
        context: context,
        duration: const Duration(milliseconds: 1000),
        toastGravity: ToastGravity.CENTER,
        backgroundColor: Colors.black,
        textStyle: const TextStyle(fontSize: 18, color: Colors.yellow));
  }

  void _fillSelected(ExamPageImage examImage) {
    bool found = false;
    for (var element in selectedImages) {
      if (element.pageIndex == examImage.pageIndex!) {
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

    HashMap<int, ExamPageImage> map = HashMap();
    for (var element in selectedImages) {
      map[element.pageIndex!] = element;
    }
    selectedImages.clear();
    selectedImages.addAll(map.values);
    selectedImages.sort((a, b) => a.pageIndex!.compareTo(b.pageIndex!));
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

  _share() {}

  _navigateToMathViewer(String text) async {
    pp('$mm _navigateToMathViewer: selectedImages: ${selectedImages.length}');

    await NavigationUtils.navigateToPage(
        context: context,
        widget: MathViewer(
          text: text,
          onShare: (images) {
            pp('$mm ... will share ... images: ${images.length}');
            selectedImages = images;
          },
          onRerun: (images) {
            pp('$mm ... will rerun ... images: ${images.length}');
            busySending = false;
            _onRerun(images);
          },
          selectedImages: selectedImages,
          onExit: (images) {
            pp('$mm viewer exited and returned here ...images: ${images.length}');
          },
          repository: widget.repository,
          prompt: prompt,
        ));
    pp('$mm ... back from Math Viewer');
  }

  _onSubmit() async {
    pp('$mm submitting the whole thing to Gemini AI : image files: ${selectedImages.length}');

    if (busySending) {
      return;
    }
    setState(() {
      busySending = true;
    });

    prompt = getPrompt(widget.examLink.subjectTitle!);
    GeminiResponse? response;
    try {
      response =
          await widget.chatService.sendImageTextPrompt(selectedImages, prompt);
      pp('$mm 😎 😎 😎 Gemini AI has responded! see below .... 😎 😎 😎');
      // myPrettyJsonPrint(response.toJson());
      String text = _getResponseString(response);
      if (isValidLaTeXString(text)) {
        await _navigateToMathViewer(text);
      } else {
       await _navigateToGeminiResponse(response);
      }
      Future.delayed(const Duration(milliseconds: 1000), () {
        setState(() {
          selectedImages.clear();
        });
      });
    } catch (e) {
      pp('$mm ERROR $e');
      if (mounted) {
        showErrorDialog(context, 'Error from Gemini AI: $e');
      }
    }
    setState(() {
      busySending = false;
    });
    //_onShowPagesToast();
  }

  _onRerun(List<ExamPageImage> images) async {
    pp('$mm _onRerun .... : image files: ${images.length}');

    if (busySending) {
      return;
    }
    setState(() {
      busySending = true;
    });

    // selectedImages = images;
    String mPrompt = getPrompt(widget.examLink.subjectTitle!);
    GeminiResponse? response;
    try {
      response = await widget.chatService.sendImageTextPrompt(images, mPrompt);
      pp('$mm 😎 😎 😎 Gemini AI has responded!  .... 😎 😎 😎');
      // myPrettyJsonPrint(response.toJson());
      String text = _getResponseString(response);
      if (isValidLaTeXString(text)) {
        _navigateToMathViewer(text);
      } else {
        _navigateToGeminiResponse(response);
      }
      Future.delayed(const Duration(milliseconds: 1000), () {
        selectedImages.clear();
      });
    } catch (e) {
      pp('$mm ERROR $e');
      if (mounted) {
        showErrorDialog(context, 'Error from Gemini AI: $e');
      }
    }
    setState(() {
      busySending = false;
    });
    //_onShowPagesToast();
  }

  String _getResponseString(GeminiResponse geminiResponse) {
    var sb = StringBuffer();
    geminiResponse.candidates?.forEach((candidate) {
      candidate.content?.parts?.forEach((parts) {
        sb.write(parts.text ?? '');
        sb.write('\n');
      });
    });
    return sb.toString();
  }

  bool isValidLaTeXString(String text) {
    // Define a list of special characters or phrases to check for
    List<String> specialCharacters = [
      '\\(',
      '\\)',
      '\\[',
      '\\]',
      '\\frac',
      '\\cdot'
    ];

    // Check if the text contains any of the special characters or phrases
    for (String character in specialCharacters) {
      if (text.contains(character)) {
        return true;
      }
    }

    return false;
  }

  String getPrompt(String subject) {
    switch (subject) {
      case 'MATHEMATICS':
        return "Solve the problem in the image. Explain each step in detail. "
            "Use well structured Latex(Math) format in your response. "
            "Use paragraphs and/or sections to optimize readability";
      default:
        return "Help me with this. Explain each step";
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Exam Paper'),
          actions: [
            bd.Badge(
              badgeContent: Text(
                '${images.length}',
                style:
                    myTextStyle(context, Colors.white, 14, FontWeight.normal),
              ),
              badgeStyle: const bd.BadgeStyle(
                elevation: 12,
                padding: EdgeInsets.all(12),
              ),
            ),
            gapW16,
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
        backgroundColor: Colors.brown[100],
        body: Stack(
          children: [
            busyLoading
                ? const Positioned(
                    bottom: 64,
                    left: 20,
                    right: 20,
                    child: BusyIndicator(
                        caption:
                            "Loading exam paper and converting to images. This may take a few minutes. Please wait for completion."))
                : Positioned.fill(
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
                              child: Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: InteractiveViewer(
                                  child: Image.memory(
                                    bytes,
                                    fit: BoxFit.cover,
                                    height: double.infinity,
                                    width: double.infinity,
                                  ),
                                ),
                              ),
                            ),
                            busySending
                                ? const Positioned(
                                    top: 240,
                                    right: 60,
                                    left: 60,
                                    child: BusyIndicator(
                                      caption:
                                          'Waiting for SgelaAI ... This may take a minute or two. Please wait. ',
                                    ),
                                  )
                                : gapW8,
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
        floatingActionButton: Visibility(
          visible: _shouldSendButtonBeVisible(),
          child: FloatingActionButton.extended(
            onPressed: () {
              _onSubmit();
            },
            elevation: 16,
            shape: const RoundedRectangleBorder(),
            label: const SizedBox(
                height: 160,
                width: 200,
                child: Row(
                  children: [
                    Icon(Icons.send, size: 36, color: Colors.blue),
                    gapW16,
                    Text('Send to SgelaAI 🍎')
                  ],
                )),
          ),
        ),
      ),
    );
  }

  bool _shouldSendButtonBeVisible() {
    if (busyLoading) {
      return false;
    }
    if (busySending) {
      return false;
    }
    if (selectedImages.isEmpty) {
      return false;
    }
    return true;
  }

  Widget _getButton() {
    if (busyLoading) {
      return gapW8;
    }
    if (busySending) {
      return gapW8;
    }
    if (selectedImages.isEmpty) {
      return gapW8;
    }
    return FloatingActionButton.extended(
      onPressed: () {
        _onSubmit();
      },
      elevation: 16,
      shape: const RoundedRectangleBorder(),
      label: const SizedBox(
          height: 160,
          width: 200,
          child: Row(
            children: [
              Icon(Icons.send, size: 36, color: Colors.blue),
              gapW16,
              Text('Send to SgelaAI')
            ],
          )),
    );
  }
}
