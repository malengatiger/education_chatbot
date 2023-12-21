import 'package:flutter/material.dart';
import 'package:edu_chatbot/data/exam_link.dart';
import 'package:edu_chatbot/repositories/repository.dart';

import '../util/functions.dart';

class ExamLinkListWidget extends StatefulWidget {
  final int subjectId;
  final Repository repository;
  const ExamLinkListWidget({super.key, required this.subjectId, required this.repository});

  @override
  ExamLinkListWidgetState createState() => ExamLinkListWidgetState();
}

class ExamLinkListWidgetState extends State<ExamLinkListWidget> {
  List<ExamLink> examLinks = [];

  @override
  void initState() {
    super.initState();
    _getExamLinks();
  }

  Future<void> _getExamLinks() async {
    try {
      List<ExamLink> fetchedExamLinks = await widget.repository
          .getExamLinks(widget.subjectId, false);
      setState(() {
        examLinks = fetchedExamLinks;
      });
    } catch (e) {
      // Handle error
      pp('Error fetching exam links: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Exam Links'),
      ),
      body: ListView.builder(
        itemCount: examLinks.length,
        itemBuilder: (context, index) {
          ExamLink examLink = examLinks[index];
          return ExamLinkWidget(examLink: examLink);
        },
      ),
    );
  }
}

class ExamLinkWidget extends StatelessWidget {
  final ExamLink examLink;

  const ExamLinkWidget({super.key, required this.examLink});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(examLink.title ?? ''),
      onTap: () {
        // Handle onTap event
      },
    );
  }
}