import 'package:flutter/foundation.dart';

class ChatbotEnvironment {
  //💙Skunk backend -
  static const _devSkunkUrl = 'http://192.168.86.242:8080/skunk-service/';
  static const _prodSkunkUrl = 'https://kasietransie-umrjnxdnuq-ew.a.run.app/';
  //TODO - refresh url links after Skunk deployment

  //💙Chatbot Backend
  static const _devGeminiUrl = 'http://192.168.86.242:3012/';
  static const _prodGeminiUrl = 'https://kasie-nest-3-umrjnxdnuq-ew.a.run.app/api/v1/';
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
}
