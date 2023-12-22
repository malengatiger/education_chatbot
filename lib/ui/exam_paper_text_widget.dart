import 'dart:io';

import 'package:edu_chatbot/data/exam_link.dart';
import 'package:edu_chatbot/repositories/repository.dart';
import 'package:flutter/material.dart';

import '../util/functions.dart';

class ExamPaperTextWidget extends StatefulWidget {
  final Repository repository;
  final ExamLink examLink;

  const ExamPaperTextWidget({
    super.key,
    required this.repository,
    required this.examLink,
  });

  @override
  ExamPaperTextWidgetState createState() => ExamPaperTextWidgetState();
}

class ExamPaperTextWidgetState extends State<ExamPaperTextWidget> {
  String? _examPaperText = '';
  String _textSelected = '';
  static const mm = '🍔🍔🍔🍔ExamPaperTextWidget 🍎';

  void _fetchExamPaperText() async {
    pp('$mm ... _fetchExamPaperText ...');
    try {
      String? text = await widget.repository.extractExamPaperText(
        widget.examLink.id!,
        false,
      );
      if (text != null) {
        pp('$mm text extracted, length: ${text.length}');
      }
      setState(() {
        _examPaperText = text;
      });
    } catch (e) {
      // Handle error
      pp('Error fetching exam paper text: $e');
    }
  }

  List<File> examImages = [];
  _fetchExamImages() async {
      examImages = await widget.repository.extractImages(
          widget.examLink, false);
      setState(() {

      });
  }

  void _searchText() {
    pp('$mm _searchText ... do something with _examPaperText:'
        '\n $_examPaperText');

    // Execute search logic here
    // This method will be called when the Submit Search button is pressed
  }

  @override
  void initState() {
    super.initState();
    _fetchExamPaperText();
    _fetchExamImages();
  }

  @override
  Widget build(BuildContext context) {
    final TextStyle titleStyle =
    Theme.of(context).textTheme.bodyLarge!.copyWith(
      fontWeight: FontWeight.w900,
    );
    return Scaffold(
      appBar: AppBar(
        title: const Text('Exam Paper Text'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Card(
                    elevation: 8,
                    child: SizedBox(height: 100,
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Row(
                              children: [
                                const Text('Number of Characters'),
                                const SizedBox(
                                  width: 8,
                                ),
                                Text('${_textSelected.length}', style: titleStyle,)
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 4,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SelectableText(
                    _examPaperText ?? '',
                    onSelectionChanged: (selection, _) {
                      if (selection.baseOffset != -1 &&
                          selection.extentOffset != -1) {
                        String selectedText = _examPaperText!.substring(
                          selection.baseOffset,
                          selection.extentOffset,
                        );
                        pp('$mm selectedText: $selectedText');

                        setState(() {
                          _textSelected = selectedText;
                        });
                      }
                    },
                    style: const TextStyle(fontSize: 16.0),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: const Text('Search Text'),
                content: Text('Selected Text: $_textSelected'),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () {
                      _searchText();
                      Navigator.of(context).pop();
                    },
                    child: const Text('Submit Search'),
                  ),
                ],
              );
            },
          );
        },
        child: const Icon(Icons.search),
      ),
    );
  }
}
