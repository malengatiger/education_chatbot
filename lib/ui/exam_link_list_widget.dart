import 'package:badges/badges.dart' as bd;
import 'package:edu_chatbot/data/exam_link.dart';
import 'package:edu_chatbot/data/subject.dart';
import 'package:edu_chatbot/repositories/repository.dart';
import 'package:flutter/material.dart';
import 'package:focused_menu/focused_menu.dart';
import 'package:focused_menu/modals.dart';

import '../util/functions.dart';
import 'exam_paper_text_widget.dart';

class ExamLinkListWidget extends StatefulWidget {
  final Subject subject;
  final Repository repository;

  const ExamLinkListWidget({
    super.key,
    required this.subject,
    required this.repository,
  });

  @override
  ExamLinkListWidgetState createState() => ExamLinkListWidgetState();
}

class ExamLinkListWidgetState extends State<ExamLinkListWidget> {
  List<ExamLink> examLinks = [];
  List<ExamLink> filteredExamLinks = [];
  static const mm = '🍎🍎🍎ExamLinkListWidget 🍎';

  @override
  void initState() {
    super.initState();
    _getExamLinks();
  }

  Future<void> _getExamLinks() async {
    pp('$mm  _getExamLinks ...');
    List<ExamLink> filtered = [];
    try {
      List<ExamLink> fetchedExamLinks =
          await widget.repository.getExamLinks(widget.subject.id!, false);
      pp('$mm fetchedExamLinks: ${fetchedExamLinks.length}');

      for (var link in fetchedExamLinks) {
        if (!link.title!.contains('Afrikaans')) {
          filtered.add(link);
        }
      }
      setState(() {
        examLinks = filtered;
        filteredExamLinks = filtered;
      });
    } catch (e) {
      // Handle error
      pp('Error fetching exam links: $e');
    }
  }

  void _filterExamLinks(String query) {
    setState(() {
      filteredExamLinks = examLinks
          .where((examLink) =>
              examLink.title!.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  List<FocusedMenuItem> _getMenuItems(ExamLink examLink, BuildContext context) {
    List<FocusedMenuItem> list = [];
    list.add(FocusedMenuItem(
        title: Text('Use Text Search', style: myTextStyleSmallBlack(context)),
        // backgroundColor: Theme.of(context).primaryColor,
        trailingIcon: Icon(
          Icons.search,
          color: Theme.of(context).primaryColor,
        ),
        onPressed: () {
          _navigateToExamPaperTextOnly(examLink);
        }));
    list.add(FocusedMenuItem(
        title:
            Text('Use Image and Text', style: myTextStyleSmallBlack(context)),
        // backgroundColor: Theme.of(context).primaryColor,
        trailingIcon: Icon(
          Icons.camera_alt,
          color: Theme.of(context).primaryColor,
        ),
        onPressed: () {
          _navigateToExamPaperTextAndImages(examLink);
        }));
    list.add(FocusedMenuItem(
        title:
        Text('Search YouTube', style: myTextStyleSmallBlack(context)),
        // backgroundColor: Theme.of(context).primaryColor,
        trailingIcon: Icon(
          Icons.video_call,
          color: Theme.of(context).primaryColor,
        ),
        onPressed: () {
          _navigateToYouTube(examLink);
        }));
    list.add(FocusedMenuItem(
        title: Text('Cancel', style: myTextStyleSmallBlack(context)),
        // backgroundColor: Theme.of(context).primaryColor,
        trailingIcon: Icon(
          Icons.close,
          color: Theme.of(context).primaryColor,
        ),
        onPressed: () {}));

    return list;
  }

  @override
  Widget build(BuildContext context) {
    pp('$mm .... build ...');
    final TextStyle titleStyle =
        Theme.of(context).textTheme.bodySmall!.copyWith(
              fontWeight: FontWeight.bold,
            );
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${widget.subject.title}',
          style: titleStyle,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.only(
                  left: 8.0,
                  right: 8,
                  top: 4,
                  bottom: 8,
                ),
                child: TextField(
                  onChanged: _filterExamLinks,
                  decoration: const InputDecoration(
                    labelText: 'Search Exams',
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: bd.Badge(
                  position: bd.BadgePosition.topEnd(top: -8, end: -2),
                  badgeContent: Text(
                    '${filteredExamLinks.length}',
                    style: const TextStyle(color: Colors.white),
                  ),
                  badgeStyle: bd.BadgeStyle(
                      padding: const EdgeInsets.all(8.0),
                      badgeColor: Colors.indigo.shade800,
                      elevation: 12),
                  child: ListView.builder(
                    itemCount: filteredExamLinks.length,
                    itemBuilder: (context, index) {
                      ExamLink examLink = filteredExamLinks[index];
                      pp('$mm examLink selected, id: ${examLink.id} '
                          'title: ${examLink.title}');
                      return FocusedMenuHolder(
                        menuItems: _getMenuItems(examLink, context),
                        menuOffset: 20,
                        duration: const Duration(milliseconds: 300),
                        animateMenuItems: true,
                        openWithTap: true,
                        onPressed: () {
                          pp('💛️💛️💛💛️💛️💛💛️💛️💛️ tapped FocusedMenuHolder ...');
                        },
                        child: ExamLinkWidget(
                          examLink: examLink,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToExamPaperTextOnly(ExamLink examLink) {
    pp('$mm _navigateToExamPaperTextOnly ...');
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ExamPaperTextWidget(
          examLink: examLink,
          repository: widget.repository,
        ),
      ),
    );
  }

  void _navigateToExamPaperTextAndImages(ExamLink examLink) {
    pp('$mm _navigateToExamPaperTextAndImages ...');

    // Handle 'Use Text and Images' option
  }
  void _navigateToYouTube(ExamLink examLink) {
    pp('$mm _navigateToYouTube ...');
  }
}

class ExamLinkWidget extends StatelessWidget {
  final ExamLink examLink;
  static const mm = '🍎🍎🍎ExamLinkWidget 🍎';

  const ExamLinkWidget({
    super.key,
    required this.examLink,
  });

  @override
  Widget build(BuildContext context) {
    final TextStyle titleStyle =
        Theme.of(context).textTheme.bodyMedium!.copyWith(
              fontWeight: FontWeight.bold,
            );
    final TextStyle idStyle = Theme.of(context).textTheme.bodyLarge!.copyWith(
          fontWeight: FontWeight.w900,
        );
    return Card(
      elevation: 2,
      child: ListTile(
        title: Row(
          children: [
            SizedBox(
              width: 60,
              child: Text(
                '${examLink.id}',
                style: idStyle,
              ),
            ),
            Expanded(
              child: Text(
                examLink.title ?? '',
                style: titleStyle,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
