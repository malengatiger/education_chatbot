import 'package:badges/badges.dart' as bd;
import 'package:edu_chatbot/data/subject.dart';
import 'package:edu_chatbot/repositories/repository.dart';
import 'package:edu_chatbot/util/functions.dart';
import 'package:flutter/material.dart';

import 'exam_link_list_widget.dart';

class SubjectSearch extends StatefulWidget {
  final Repository repository;

  const SubjectSearch({super.key, required this.repository});

  @override
  SubjectSearchState createState() => SubjectSearchState();
}

class SubjectSearchState extends State<SubjectSearch> {
  final TextEditingController _searchController = TextEditingController();
  List<Subject> _subjects = [];
  List<Subject> _filteredSubjects = [];

  @override
  void initState() {
    super.initState();
    _getSubjects();
  }

  void _getSubjects() async {
    try {
      List<Subject> subjects = await widget.repository.getSubjects(false);
      setState(() {
        _subjects = subjects;
        _filteredSubjects = subjects;
      });
    } catch (e) {
      // Handle error
      pp('Error fetching subjects: $e');
    }
  }

  void _filterSubjects(String query) {
    setState(() {
      _filteredSubjects = _subjects
          .where((subject) =>
              subject.title!.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final TextStyle titleStyle =
        Theme.of(context).textTheme.bodySmall!.copyWith(
              fontWeight: FontWeight.w900,
            );
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: SafeArea(
        child: Scaffold(
          appBar: AppBar(
            title: const Text('AI Buddy'),
            actions: [
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.refresh),
              )
            ],
          ),
          backgroundColor: Colors.brown.shade100,
          body: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Card(
                  elevation: 4,
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) {
                      pp('🍎 🍎 ........ value: $value');
                      _filterSubjects(value);
                    },
                    // autofocus: false,
                    decoration: const InputDecoration(
                        hintText: 'Search Subjects', icon: Icon(Icons.search)),
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: bd.Badge(
                    position: bd.BadgePosition.topEnd(top: -8, end: -2),
                    badgeContent: Text(
                      '${_filteredSubjects.length}',
                      style: const TextStyle(color: Colors.white),
                    ),
                    badgeStyle: bd.BadgeStyle(
                    padding: const EdgeInsets.all(8.0),
                        badgeColor: Colors.pink.shade800, elevation: 12),
                    child: ListView.builder(
                      itemCount: _filteredSubjects.length,
                      itemBuilder: (context, index) {
                        Subject subject = _filteredSubjects[index];
                        return GestureDetector(
                          onTap: () {
                            navigateToExamLinkListWidget(context, subject);
                          },
                          child: Card(
                            elevation: 8,
                            shape: getDefaultRoundedBorder(),
                            child: ListTile(
                              leading: const Icon(Icons.ac_unit),
                              title: Text(
                                subject.title ?? '',
                                style: titleStyle,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  navigateToExamLinkListWidget(BuildContext context, Subject subject) {
    Navigator.push(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 500),
        pageBuilder: (context, animation, secondaryAnimation) =>
            ExamLinkListWidget(
          subject: subject,
          repository: widget.repository,
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          var begin = const Offset(1.0, 0.0);
          var end = Offset.zero;
          var curve = Curves.ease;

          var tween =
              Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
      ),
    );
  }
}
