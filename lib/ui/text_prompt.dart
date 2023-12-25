import 'dart:io';

import 'package:edu_chatbot/data/exam_link.dart';
import 'package:edu_chatbot/repositories/repository.dart';
import 'package:edu_chatbot/services/local_data_service.dart';
import 'package:flutter/material.dart';

import '../data/gemini/gemini_response.dart';
import '../services/chat_service.dart';
import '../util/functions.dart' as fun;
import 'exam_paper_header.dart';

class TextPrompt extends StatefulWidget {
  final Repository repository;
  final ExamLink examLink;
  final LocalDataService localDataService;
  final ChatService chatService;

  const TextPrompt({
    super.key,
    required this.repository,
    required this.examLink, required this.localDataService, required this.chatService,
  });

  @override
  TextPromptState createState() => TextPromptState();
}

class TextPromptState extends State<TextPrompt> {
  String? _examPaperText = '';
  String _textSelected = '';
  static const mm = '🍔🍔🍔🍔 TextPrompt 🍎';
  Future<void> _searchText() async {
    fun.pp('$mm _searchText ... do something with _textSelected:'
        '\n $_textSelected');

    GeminiResponse gResponse = await widget.chatService.sendTextPrompt('Help!');
    fun.pp('$mm Gemini AI says: ${gResponse.candidates?[0].toJson()}');

  }

  @override
  void initState() {
    super.initState();
    _examPaperText = widget.examLink.examText;
  }

  @override
  Widget build(BuildContext context) {
    final TextStyle titleStyle =
        Theme.of(context).textTheme.bodyLarge!.copyWith(
              fontWeight: FontWeight.w900,
            );
    return Scaffold(
      appBar: AppBar(
        title: Text('Exam Paper Text', style: titleStyle,),
        bottom: PreferredSize(
            preferredSize: const Size.fromHeight(140),
            child: Column(
              children: [
                ExamPaperHeader(examLink: widget.examLink, onClose: () {  },),
              ],
            )),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
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
                        fun.pp('$mm selectedText: $selectedText');

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


