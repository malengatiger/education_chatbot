import 'package:dio/dio.dart';
import 'package:edu_chatbot/repositories/repository.dart';
import 'package:edu_chatbot/services/accounting_service.dart';
import 'package:edu_chatbot/services/auth_service.dart';
import 'package:edu_chatbot/services/agriculture_service.dart';
import 'package:edu_chatbot/services/chat_service.dart';
import 'package:edu_chatbot/services/local_data_service.dart';
import 'package:edu_chatbot/services/math_service.dart';
import 'package:edu_chatbot/services/physics_service.dart';
import 'package:edu_chatbot/services/you_tube_service.dart';
import 'package:edu_chatbot/ui/subject_search.dart';
import 'package:edu_chatbot/util/dio_util.dart';
import 'package:edu_chatbot/util/functions.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import 'firebase_options.dart';

Future<void> main() async {
  pp('🍎 🍎 🍎 AI ChatBuddy starting .... 🍎 🍎 🍎');
  WidgetsFlutterBinding.ensureInitialized();
  var app = await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  pp('🍎 🍎 🍎 Firebase has been initialized!! 🍎 🍎 🍎 name: ${app.name}');

  // Register services
  await registerServices();

  runApp(const MyApp());
}

Future<void> registerServices() async {
  var lds = LocalDataService();
  await lds.init();
  var dioUtil = DioUtil(Dio(), lds);
  GetIt.instance.registerLazySingleton<MathService>(() => MathService());
  GetIt.instance.registerLazySingleton<ChatService>(() => ChatService());
  GetIt.instance.registerLazySingleton<AgricultureService>(() => AgricultureService());
  GetIt.instance.registerLazySingleton<PhysicsService>(() => PhysicsService());
  GetIt.instance.registerLazySingleton<Repository>(() => Repository(dioUtil, lds));
  GetIt.instance.registerLazySingleton<AuthService>(() => AuthService());
  GetIt.instance.registerLazySingleton<AccountingService>(() => AccountingService());
  GetIt.instance.registerLazySingleton<LocalDataService>(() => lds);
  GetIt.instance.registerLazySingleton<YouTubeService>(() => YouTubeService(dioUtil, lds));


  pp('🍎 🍎 🍎 main: GetIt has registered all the services. 🍎Cool!');
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    var repository = GetIt.instance<Repository>();
    return MaterialApp(
      title: 'AI Chat Buddy',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.pink.shade800),
        useMaterial3: true,
      ),
      home:  SubjectSearch(repository: repository,),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  static const mm = '💙💙💙💙 MyHomePage 💙';

  final Repository repository = GetIt.instance<Repository>();
  final LocalDataService localDataService = GetIt.instance<LocalDataService>();
  final YouTubeService youTubeService = GetIt.instance<YouTubeService>();

  Future<void> _getTestData() async {
    var list = await repository.getSubjects(false);
    pp("$mm  Subjects found: ${list.length} ");

    var list2 = await repository.getExamLinks(
        8, false);
    pp("$mm  Exam Links found: ${list2.length} ");

    var videos = await youTubeService.searchByTag(
        subjectId: 7, maxResults: 24, tagType: 1);

    pp("$mm  YouTube Videos found: ${videos.length} ");

    setState(() {
      _counter = videos.length;
    });
  }

  void getSubjects() {

  }
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(

        backgroundColor: Theme.of(context).colorScheme.inversePrimary,

        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: const TextStyle(fontSize: 64, fontWeight: FontWeight.w900),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _getTestData,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
