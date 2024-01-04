import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart' as dot;

import 'functions.dart';

class ChatbotEnvironment {
  //💙Skunk backend -
  static const _devSkunkUrl = 'http://192.168.86.242:8080/skunk-service/';
  static const _prodSkunkUrl = 'https://skunkworks-backend-service-knzs6eczwq-nw.a.run.app/';

  //TODO - refresh url links after Skunk deployment

  //💙Chatbot Backend
  static const _devGeminiUrl = 'http://192.168.86.242:3010/';
  static const _prodGeminiUrl = 'https://sgela-ai-knzs6eczwq-nw.a.run.app/';

  //TODO - refresh url links after Gemini deployment

  static String getSkunkUrl() {
    if (kDebugMode) {
      return _devSkunkUrl;
    } else {
      return _prodSkunkUrl;
    }
  }

  static String getGeminiUrl() {
    if (kDebugMode) {
      return _devGeminiUrl;
    } else {
      return _prodGeminiUrl;
    }
  }

  static int maxResults = 32;

  static bool isDotLoaded = false;
  static String part1 = 'SyAuArZYG0wNXtNdz8aa1YX';
  static String part2 = 'CjYxlVcnDF8M';
  static String part0 = 'AIza';
  static String getGeminiAPIKey()  {
    return '$part0$part1$part2';

  }
}
