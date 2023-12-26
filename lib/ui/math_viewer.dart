import 'package:edu_chatbot/util/functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tex/flutter_tex.dart';
class MathViewer extends StatelessWidget {
  const MathViewer({super.key, required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return SafeArea(child: Scaffold(
      appBar: AppBar(
        title: const Text('Mathematics Viewer')
      ),
      backgroundColor: Colors.brown[100],
      body:  Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SingleChildScrollView(
              child: Card(
                elevation: 8,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Text("SgelaAI Response", style: myTextStyleMediumLargeWithColor(context,
                          Colors.black, 24, FontWeight.w900),),
                      gapW16,
                      TeXView(
                        renderingEngine: const TeXViewRenderingEngine.katex(),
                        child: TeXViewColumn(children: [
                        TeXViewDocument(getFormattedText()),
                      ], ),
                      ),
                    ],
                  ),
                )
              ),
            ),
          )
        ],
      )
    ));
  }

String getFormattedText() {
  return text;
}

}
