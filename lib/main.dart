import 'package:dio/dio.dart';
import 'package:edu_chatbot/repositories/repository.dart';
import 'package:edu_chatbot/services/accounting_service.dart';
import 'package:edu_chatbot/services/auth_service.dart';
import 'package:edu_chatbot/services/agriculture_service.dart';
import 'package:edu_chatbot/services/chat_service.dart';
import 'package:edu_chatbot/services/local_data_service.dart';
import 'package:edu_chatbot/services/math_service.dart';
import 'package:edu_chatbot/services/physics_service.dart';
import 'package:edu_chatbot/util/dio_util.dart';
import 'package:edu_chatbot/util/functions.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

void main() {
  pp('🍎 🍎 🍎 AI ChatBuddy starting .... 🍎 🍎 🍎');
  // Register services
  registerServices();

  runApp(const MyApp());
}

void registerServices() {
  GetIt.instance.registerLazySingleton<MathService>(() => MathService());
  GetIt.instance.registerLazySingleton<ChatService>(() => ChatService());
  GetIt.instance.registerLazySingleton<AgricultureService>(() => AgricultureService());
  GetIt.instance.registerLazySingleton<PhysicsService>(() => PhysicsService());
  GetIt.instance.registerLazySingleton<Repository>(() => Repository(DioUtil(Dio())));
  GetIt.instance.registerLazySingleton<AuthService>(() => AuthService());
  GetIt.instance.registerLazySingleton<AccountingService>(() => AccountingService());
  GetIt.instance.registerLazySingleton<LocalDataService>(() => LocalDataService());

  pp('🍎 🍎 🍎 main: GetIt has registered all the services. 🍎Cool!');
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a blue toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
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

  Future<void> _getTestData() async {
    var list = await repository.getSubjects();
    pp("$mm  Subjects found: ${list.length} ");
    await localDataService.addSubjects(list);
    pp("$mm  Subjects written to local database ");

    var list2 = await repository.getExamLinks(7);
    pp("$mm  Exam Links found: ${list2.length} ");

    var localSubs = await repository.getSubjects();
    pp("$mm Subjects found on local db: 🍔${localSubs.length} 🍔");

    setState(() {
      _counter = list2.length;
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
