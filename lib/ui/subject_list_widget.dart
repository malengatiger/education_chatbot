import 'package:flutter/material.dart';
import 'package:edu_chatbot/data/Subject.dart';
import 'package:edu_chatbot/repositories/repository.dart';

import '../util/functions.dart';
import 'exam_link_list_widget.dart';

class SubjectListWidget extends StatefulWidget {
  const SubjectListWidget({super.key, required this.repository});
  final Repository repository;
  @override
  SubjectListWidgetState createState() => SubjectListWidgetState();
}

class SubjectListWidgetState extends State<SubjectListWidget> {
  // Replace with your actual Repository instance
  List<Subject> subjects = [];

  @override
  void initState() {
    super.initState();
    _getSubjects();
  }

  Future<void> _getSubjects() async {
    try {
      List<Subject> fetchedSubjects = await widget.repository
          .getSubjects(false);
      setState(() {
        subjects = fetchedSubjects;
      });
    } catch (e) {
      // Handle error
      pp('Error fetching subjects: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Subject List'),
      ),
      body: Column(
        children: [
          // Header section
          Container(
            padding: const EdgeInsets.all(16),
            child: const Text(
              'Header Section',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          // Subject list
          Expanded(
            child: ListView.builder(
              itemCount: subjects.length,
              itemBuilder: (context, index) {
                Subject subject = subjects[index];
                return GestureDetector(
                    onTap: (){
                      navigateToExamLinkListWidget(context,subject);
                    },
                    child: SubjectWidget(subject: subject));
              },
            ),
          ),
        ],
      ),
    );
  }

  navigateToExamLinkListWidget(BuildContext context, Subject subject) {
    Navigator.push(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 500),
        pageBuilder: (context, animation,
            secondaryAnimation) => ExamLinkListWidget(
          subjectId: subject.id!, repository: widget.repository,),
        transitionsBuilder: (context,
            animation, secondaryAnimation, child) {
          var begin = const Offset(1.0, 0.0);
          var end = Offset.zero;
          var curve = Curves.ease;

          var tween = Tween(begin: begin, end: end).chain(
              CurveTween(curve: curve));

          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
      ),
    );
  }
}

class SubjectWidget extends StatelessWidget {
  final Subject subject;

  const SubjectWidget({super.key, required this.subject});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(subject.title ?? ''),
    );
  }
}