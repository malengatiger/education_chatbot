import 'package:edu_chatbot/ui/busy_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

import '../data/exam_link.dart';
import '../data/subject.dart';
import '../repositories/repository.dart';
import '../services/chat_service.dart';
import '../util/functions.dart';

class ChatWidget extends StatefulWidget {
  const ChatWidget(
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
  State<ChatWidget> createState() => ChatWidgetState();
}

class ChatWidgetState extends State<ChatWidget> {
  String responseText = 'The response text will show up right here. ';
  static const mm = '🍎🍎🍎ChatWidget 🍎';
  bool busy = false;
  int chatCount = 0;
  TextEditingController textEditingController = TextEditingController();
  List<String> promptHistory = [];
  String copiedText = '';

  void _handleTextFieldTap() {
    if (textEditingController.selection.isValid) {
      final selectedText = textEditingController.selection
          .textInside(textEditingController.text);
      if (selectedText.isNotEmpty) {
        setState(() {
          copiedText = selectedText;
        });
      }
    }
  }

  bool isMarkDown = false;

  Future<String> _sendChatPrompt() async {
    // if (textEditingController.value.text.isEmpty) {
    //   showToast(
    //       message: 'Please enter search text',
    //       textStyle: myTextStyle(context, Colors.white, 16, FontWeight.normal),
    //       context: context);
    //   return '';
    // }
    String prompt = textEditingController.value.text;
    var promptContext = _getPromptContext();
    if (chatCount == 0) {
      prompt = '$promptContext \nSubject: ${widget.subject.title}. $prompt';
    } else {
      prompt = '$promptContext $prompt';
    }
    pp('$mm .............. sending chat prompt: \n$prompt\n');
    StringBuffer sb = StringBuffer();

    setState(() {
      busy = true;
    });
    try {
      var resp = await widget.chatService.sendChatPrompt(prompt);
      pp('$mm ....... chat response: \n$resp\n');
      responseText = resp;
      if (isMarkdownFormat(responseText)) {
        isMarkDown = true;
        pp('$mm ....... isMarkdownFormat: 🍎$isMarkdownFormat 🍎');
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

    return sb.toString();
  }

  String _getPromptContext() {
    StringBuffer sb = StringBuffer();
    sb.write(
        'My name is SgelaAI and I am a super tutor who knows everything. I am here to help you study for all your high school courses and subjects\n');
    sb.write('I answer questions that relates to the subject provided. \n');
    sb.write('I keep my answers to the high school or college freshman level');
    sb.write(
        'I return all my responses in markdown format. I use headings and paragraphs to enhance readability');
    return sb.toString();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('SgelaAI Chat'),
        ),
        backgroundColor: Colors.brown[100],
        body: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  isMarkDown
                      ? MarkdownWidget(text: responseText)
                      :Text(
                    '${widget.subject.title}',
                    style:
                        myTextStyle(context, Colors.black, 18, FontWeight.w900),
                  ),
                  Expanded(
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: Card(
                          elevation: 8.0,
                          child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: SingleChildScrollView(
                                child: Text(
                                  responseText,
                                  maxLines: null,
                                  textAlign: TextAlign.center,
                                ),
                              ))),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                         TextField(
                                decoration: const InputDecoration(
                                  border: OutlineInputBorder(),
                                  labelText: 'Search Text Here',
                                ),
                                controller: textEditingController,
                                onTap: _handleTextFieldTap,
                              ),
                        gapH16,
                        ElevatedButton.icon(
                          style: const ButtonStyle(
                            elevation: MaterialStatePropertyAll(8.0),
                          ),
                          onPressed: () {
                            _sendChatPrompt();
                          },
                          icon: const Icon(
                            Icons.send,
                          ),
                          label: const Text('Send to SgelaAI'),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
            busy
                ? const Positioned(
                    top: 240,
                    left: 48,
                    right: 48,
                    child: BusyIndicator(
                      caption:
                          'Talking to SgelaAI ... may take a minute or two. Please wait.',
                    ))
                : gapW8,
            Positioned(
                bottom: 16,
                left: 48,
                child: Text('${promptHistory.length}',
                    style:
                        myTextStyle(context, Colors.grey, 28, FontWeight.w900)))
          ],
        ),
      ),
    );
  }
}

class MarkdownWidget extends StatelessWidget {
  const MarkdownWidget({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 8,
      child: SizedBox(
        height: 500,
        child: Markdown(
          data: text,
          selectable: true,
          controller: ScrollController(),
        ),
      ),
    );
  }
}
