import 'dart:io';

import 'package:edu_chatbot/ui/chat_widget.dart';
import 'package:edu_chatbot/util/functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tex/flutter_tex.dart';

class GenericImageResponseViewer extends StatelessWidget {
  const GenericImageResponseViewer(
      {super.key,
      required this.text,
      required this.isLaTex,
      required this.file});

  final String text;
  final bool isLaTex;
  final File file;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
            appBar: AppBar(
              title: const Text('Result from Image'),
            ),
            backgroundColor: Colors.brown[100],
            body: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Card(
                      child: Column(
                    children: [
                      gapH16,
                      Text(
                        'SgelaAI Response',
                        style: myTextStyle(
                            context,
                            Theme.of(context).primaryColor,
                            24,
                            FontWeight.w900),
                      ),
                      isLaTex
                          ? Expanded(
                              child: SingleChildScrollView(
                                child: TeXView(
                                  renderingEngine:
                                      const TeXViewRenderingEngine.katex(),
                                  child: TeXViewColumn(
                                    children: [
                                      TeXViewDocument(text),
                                    ],
                                  ),
                                ),
                              ),
                            )
                          : Expanded(
                              child: MarkdownWidget(text: text),
                            ),
                    ],
                  )),
                ),
                Positioned(
                    bottom: 24, left: 28,
                    child: Card(
                        elevation: 16,
                        child: Image.file(file, height: 160, width: 160, fit: BoxFit.cover))),
              ],
            )));
  }
}
