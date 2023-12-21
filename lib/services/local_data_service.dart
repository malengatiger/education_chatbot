import 'package:edu_chatbot/data/Subject.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../util/functions.dart';

class LocalDataService {
  static const mm = '💙💙💙💙 LocalDataService 💙';

  late Database db;

  void init() async {
    pp('$mm initialize sqlite ...');

    db = await openDatabase(
      join(await getDatabasesPath(), 'skunk0.db'),
      version: 1,
    );
    pp('$mm SQLite Database is open: ${db.isOpen} 🔵🔵 ${db.path}');
    await _createTables();
  }

  Future<void> _createTables() async {
    // Check if the "subjects" table exists
    bool subjectsTableExists = await _tableExists('subjects');
    if (!subjectsTableExists) {
      await db.execute('''
        CREATE TABLE subjects (
          id INTEGER PRIMARY KEY,
          title TEXT
        )
      ''');
      pp('$mm Created the subjects table 🔵🔵');
    }

    // Check if the "exam_links" table exists
    bool examLinksTableExists = await _tableExists('exam_links');
    if (!examLinksTableExists) {
      await db.execute('''
        CREATE TABLE exam_links (
          id INTEGER PRIMARY KEY,
          title TEXT,
          link TEXT,
          subject_id INTEGER,
          page_image_zip_url TEXT,
          document_title TEXT,
          FOREIGN KEY (subject_id) REFERENCES subjects (id)
        )
      ''');
      pp('$mm Created the exam_links table 🔵🔵');
    }

    // Check if the "subscriptions" table exists
    bool subscriptionsTableExists = await _tableExists('subscriptions');
    if (!subscriptionsTableExists) {
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
        pp("$mm ERROR: 🖐🏽${e.toString()} 🖐🏽");
      }
    }
  }

  LocalDataService() {
    init();
  }
}
