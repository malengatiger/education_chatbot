import 'package:badges/badges.dart' as bd;
import 'package:edu_chatbot/ui/chat_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tex/flutter_tex.dart';

import '../data/exam_link.dart';
import '../data/subject.dart';
import '../repositories/repository.dart';
import '../services/chat_service.dart';
import '../util/functions.dart';

class TextChat extends StatefulWidget {
  const TextChat(
      {super.key,
      required this.examLink,
      required this.repository,
      required this.chatService,
      required this.subject});

  final ExamLink examLink;
  final Repository repository;
  final ChatService chatService;
  final Subject subject;

  @override
  TextChatState createState() => TextChatState();
}

class TextChatState extends State<TextChat>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  TextEditingController textEditingController = TextEditingController();

  bool isMarkDown = false;
  String copiedText = '';
  String responseText = 'The response text will show up right here. ';
  static const mm = '🍎🍎🍎TextChat 🍎';
  bool busy = false;
  int chatCount = 0;
  List<String> promptHistory = [];

  @override
  void initState() {
    _controller = AnimationController(vsync: this);
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _sendChatPrompt() async {
    String prompt = textEditingController.value.text;
    var promptContext = getPromptContext();
    if (chatCount == 0) {
      prompt = '$promptContext \nSubject: ${widget.subject.title}. $prompt';
    } else {
      prompt = '$promptContext $prompt';
    }
    pp('$mm .............. sending chat prompt: \n🍎🍎$prompt 🍎🍎\n');

    setState(() {
      busy = true;
    });
    try {
      var resp = await widget.chatService.sendChatPrompt(prompt);
      pp('$mm ....... chat response: \n$resp\n');
      responseText = resp;
      bool yes = isMarkdownFormat(responseText);
      if (yes) {
        isMarkDown = true;
        pp('$mm ....... isMarkdownFormat: 🍎$yes 🍎');
      } else {
        isMarkDown = false;
      }
      chatCount++;
      promptHistory.add(resp);
    } catch (e) {
      pp(e);
      if (mounted) {
        showErrorDialog(context, 'Error: $e');
      }
    }
    setState(() {
      busy = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
            appBar: AppBar(
              title: const Text('SgelaAI Chatbot'),
            ),
            backgroundColor: Colors.brown[100],
            body: Padding(
              padding: const EdgeInsets.all(8.0),
              child: bd.Badge(
                position: bd.BadgePosition.topEnd(end:8, top:-8),
                badgeStyle: const bd.BadgeStyle(
                  elevation: 16,
                  padding: EdgeInsets.all(12.0),
                ),
                badgeContent: Text(
                  '${(responseText.length/1024).toStringAsFixed(0)}K',
                  style:
                      myTextStyle(context, Colors.white, 16, FontWeight.normal),
                ),
                child: Column(
                  children: [
                    Expanded(
                      child: isMarkDown
                          ? MarkdownWidget(text: responseText)
                          : TeXView(
                              renderingEngine:
                                  const TeXViewRenderingEngine.katex(),
                              child: TeXViewColumn(
                                children: [
                                  TeXViewDocument(responseText),
                                ],
                              ),
                            ),
                    ),
                    Card(
                        elevation: 8,
                        child: Form(
                            child: Column(
                          children: [
                            gapH16,
                            TextFormField(
                              controller: textEditingController,
                              minLines: 2,
                              maxLines: 4,
                              decoration: const InputDecoration(
                                  border: OutlineInputBorder(),
                                  label: Text(
                                      'SgelaAI question can be entered here')),
                            ),
                            gapH16,
                            busy
                                ? const SizedBox(
                                    height: 18,
                                    width: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 6,
                                      backgroundColor: Colors.pink,
                                    ),
                                  )
                                : ElevatedButton.icon(
                                    style: const ButtonStyle(
                                      elevation: MaterialStatePropertyAll(16),
                                    ),
                                    onPressed: () {
                                      FocusScope.of(context).unfocus();
                                      _sendChatPrompt();
                                    },
                                    icon: const Icon(Icons.send),
                                    label: const Text('Send to SgelaAI')),
                            gapH16,
                          ],
                        ))),
                  ],
                ),
              ),
            )));
  }
}
