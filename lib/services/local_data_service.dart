import 'package:edu_chatbot/data/Subject.dart';
import 'package:edu_chatbot/data/exam_link.dart';
import 'package:edu_chatbot/data/youtube_data.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../util/functions.dart';

class LocalDataService {
  static const mm = '💙💙💙💙 LocalDataService 💙';

  late Database db;

  Future init() async {
    pp('$mm initialize sqlite ...');

    db = await openDatabase(
      join(await getDatabasesPath(), 'skunk007.db'),
      version: 1,
    );
    pp('$mm SQLite Database is open: ${db.isOpen} 🔵🔵 ${db.path}');
    await _createTables();
  }

  Future<void> _createTables() async {
    // Check if the "subjects" table exists
    bool subjectsTableExists = await _tableExists(
        'subjects');
    if (!subjectsTableExists) {
      try {
        await db.execute('''
                CREATE TABLE subjects (
                  id INTEGER PRIMARY KEY,
                  title TEXT
                )
              ''');
        pp('$mm Created the subjects table 🔵🔵');
      } catch (e) {
        pp('$mm subjectsTable: error: 👿👿👿$e');
      }
    }

    // Check if the "exam_links" table exists
    bool examLinksTableExists = await _tableExists(
        'exam_links');
    if (!examLinksTableExists) {
      try {
        await db.execute('''
                CREATE TABLE exam_links (
                  id INTEGER PRIMARY KEY,
                  title TEXT,
                  link TEXT,
                  subjectId INTEGER,
                  subjectTitle TEXT,
                  pageImageZipUrl TEXT,
                  documentTitle TEXT,
                  FOREIGN KEY (subjectId) REFERENCES subjects (id)
                )
              ''');
        pp('$mm Created the exam_links table 🔵🔵');
      } catch (e) {
        pp('$mm examLinksTable: ERROR: 👿👿👿$e');
      }
    }

    // Check if the "subscriptions" table exists
    bool subscriptionsTableExists = await _tableExists(
        'subscriptions');
    if (!subscriptionsTableExists) {
      try {
        await db.execute('''
                CREATE TABLE subscriptions (
                  id INTEGER PRIMARY KEY,
                  country_id INTEGER,
                  organization_id INTEGER,
                  user_id INTEGER,
                  date TEXT,
                  pricing_id INTEGER,
                  subscription_type INTEGER,
                  active_flag INTEGER,
                  FOREIGN KEY (country_id) REFERENCES countries (id),
                  FOREIGN KEY (organization_id) REFERENCES organizations (id),
                  FOREIGN KEY (user_id) REFERENCES users (id),
                  FOREIGN KEY (pricing_id) REFERENCES pricings (id)
                )
              ''');
        pp('$mm Created the subscriptions table 🔵🔵');
      } catch (e) {
        pp('$mm subscriptionsTableExists: 👿👿👿$e');

      }
    }
    // Check if the "youtube" table exists
    bool youtubeTableExists = await _tableExists(
        'youtube');
    if (!youtubeTableExists) {
      try {
        await db.execute('''
                CREATE TABLE youtube (
                  id INTEGER PRIMARY KEY,
                  title TEXT,
                  description TEXT,
                  channelId TEXt,
                  videoId TEXT,
                  playlistId TEXT,
                  videoUrl TEXT,
                  channelUrl TEXT,
                  playlistUrl TEXT,
                  thumbnailHigh TEXT,
                  thumbnailMedium TEXT,
                  thumbnailDefault TEXT,
                  subjectId TEXT
                  
                )
              ''');
        pp('$mm Created the youtube table 🔵🔵');
      } catch (e) {
        pp('$mm youtubeTableExists: 👿👿👿$e');

      }
    }
  }

  Future<bool> _tableExists(String tableName) async {
    List<Map<String, dynamic>> tables = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type='table' AND name='$tableName'",
    );
    return tables.isNotEmpty;
  }

  Future<List<Subject>> getSubjects() async {
    List<Subject> list = [];
    List<Map<dynamic, dynamic>> maps =
        await db.query('subjects', columns: ["id", "title"]);
    if (maps.isNotEmpty) {
      for (var element in maps) {
        var mapWithStrings = element.cast<String, dynamic>();
        list.add(Subject.fromJson(mapWithStrings));
      }
    }
    pp('$mm getSubjects found on local db: ${list.length}');
    return list;
  }

  Future addSubjects(List<Subject> subjects) async {
    pp('$mm addSubjects to sqlite ...  😎 ${subjects.length}  😎');
    int cnt = 0;
    for (var subject in subjects) {
      try {
        await db.insert('subjects', subject.toJson());
        cnt++;
        pp('$mm subject #$cnt added to local db, '
                  'id: 🍎${subject.id} 🔵🔵 title: ${subject.title}');
      } catch (e) {
        pp("$mm addSubjects: ERROR: 👿${e.toString()} 👿🏽");
      }
    }
  }
  Future addYouTubeData(List<YoutubeData> youTubeData) async {
    pp('$mm addYouTubeData to sqlite ...  😎 ${youTubeData.length}  😎');
    int cnt = 0;
    for (var ytd in youTubeData) {
      try {
        await db.insert('youtube', ytd.toJson());
        cnt++;
        pp('$mm YoutubeData #$cnt added to local db, '
            'id: 🍎${ytd.id} 🔵🔵 title: ${ytd.title}');
      } catch (e) {
        pp("$mm addYouTubeData: ERROR: 👿${e.toString()} 👿🏽");
      }
    }
  }
  Future addExamLinks(List<ExamLink> examLinks) async {
    pp('$mm addSubjects to sqlite ...  😎 ${examLinks.length}  😎');
    int cnt = 0;
    for (var examLink in examLinks) {
      try {
        var obj = examLink.toJson();
        pp('$mm examLink: $obj');
        await db.insert('exam_links', obj);
        cnt++;
        pp('$mm examLink #$cnt added to local db, '
            'id: 🍎${examLink.id} 🔵🔵 title: ${examLink.title}');
      } catch (e) {
        pp("$mm addExamLinks: ERROR: 🖐🏽${e.toString()} 🖐🏽");
      }
    }
  }
  Future<List<ExamLink>> getExamLinksBySubject(int subjectId) async {
    List<ExamLink> list = [];
    List<Map<String, dynamic>> maps = await db.query(
      'exam_links',
      columns: ["id", "title", "link", "pageImageZipUrl", "documentTitle"],
      where: "subjectId = ?",
      whereArgs: [subjectId],
    );
    if (maps.isNotEmpty) {
      for (var element in maps) {
        var mapWithStrings = element.cast<String, dynamic>();
        list.add(ExamLink.fromJson(mapWithStrings));
      }
    }
    pp('$mm getExamLinksBySubject found on local db: ${list.length}');
    return list;
  }

}
