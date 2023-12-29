import 'package:dio/dio.dart';
import 'package:edu_chatbot/repositories/repository.dart';
import 'package:edu_chatbot/services/accounting_service.dart';
import 'package:edu_chatbot/services/agriculture_service.dart';
import 'package:edu_chatbot/services/auth_service.dart';
import 'package:edu_chatbot/services/chat_service.dart';
import 'package:edu_chatbot/services/local_data_service.dart';
import 'package:edu_chatbot/services/math_service.dart';
import 'package:edu_chatbot/services/physics_service.dart';
import 'package:edu_chatbot/services/you_tube_service.dart';
import 'package:edu_chatbot/ui/subject_search.dart';
import 'package:edu_chatbot/util/dio_util.dart';
import 'package:edu_chatbot/util/environment.dart';
import 'package:edu_chatbot/util/functions.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
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
  Gemini.init(apiKey: ChatbotEnvironment.getGeminiAPIKey());
  pp('🍎 🍎 🍎 Gemini AI API has been initialized!! 🍎 🍎 🍎 Gemini apiKey: ${ChatbotEnvironment.getGeminiAPIKey()}');

  runApp(const MyApp());
}

Future<void> registerServices() async {
  pp('🍎 🍎 🍎 main: initialize service singletons with GetIt .... 🍎');

  var lds = LocalDataService();
  await lds.init();
  Dio dio = Dio();
  var dioUtil = DioUtil(dio, lds);
  GetIt.instance.registerLazySingleton<MathService>(() => MathService());
  GetIt.instance.registerLazySingleton<ChatService>(() => ChatService(dioUtil));
  GetIt.instance
      .registerLazySingleton<AgricultureService>(() => AgricultureService());
  GetIt.instance.registerLazySingleton<PhysicsService>(() => PhysicsService());
  GetIt.instance
      .registerLazySingleton<Repository>(() => Repository(dioUtil, lds, dio));
  GetIt.instance.registerLazySingleton<AuthService>(() => AuthService());
  GetIt.instance
      .registerLazySingleton<AccountingService>(() => AccountingService());
  GetIt.instance.registerLazySingleton<LocalDataService>(() => lds);
  GetIt.instance.registerLazySingleton<YouTubeService>(
      () => YouTubeService(dioUtil, lds));

  pp('🍎 🍎 🍎 main: GetIt has registered all the services. 🍎Cool!');
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  void _dismissKeyboard(BuildContext context) {
    final currentFocus = FocusScope.of(context);
    if (!currentFocus.hasPrimaryFocus && currentFocus.hasFocus) {
      FocusManager.instance.primaryFocus?.unfocus();
    }
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    var repository = GetIt.instance<Repository>();
    var youTubeService = GetIt.instance<YouTubeService>();
    return GestureDetector(
      onTap: () {
        pp('main: ... dismiss keyboard? Tapped somewhere ...');
        _dismissKeyboard(context);
      },
      child: MaterialApp(
        title: 'SgelaAI',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme:
              ColorScheme.fromSeed(seedColor: Colors.deepPurple.shade800),
          useMaterial3: true,
        ),
        home: SubjectSearch(
          repository: repository,
          localDataService: GetIt.instance<LocalDataService>(),
          chatService: GetIt.instance<ChatService>(),
          youTubeService: youTubeService,
        ),
      ),
    );
  }
}
