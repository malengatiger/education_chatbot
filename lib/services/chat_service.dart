import 'dart:io';
import 'dart:convert';
import 'package:edu_chatbot/util/environment.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';

import '../data/gemini/gemini_response.dart';
import '../util/dio_util.dart';
import '../util/functions.dart' as fun;

class ChatService {
  static const mm = '💜💜💜💜 ChatService';

  final DioUtil dioUtil;

  ChatService(this.dioUtil);
  Future<GeminiResponse> sendImageTextPrompt(List<File> imageFiles, String prompt) async {

    fun.pp('$mm .... sendImageTextPrompt starting ... '
        'imageFiles: ${imageFiles.length}');
    if (imageFiles.isEmpty) {
      throw Exception('No image files provided');
    }
    String urlPrefix = ChatbotEnvironment.getGeminiUrl();
    String url = '${urlPrefix}textImage/sendTextImagePrompt';
    String param = 'file';
    if (imageFiles.length > 1) {
      url = '${urlPrefix}textImage/sendTextImagesPrompt';
    }
    fun.pp('$mm sendImageTextPrompt: will send ,,,,, $url ...');

    try {
      http.MultipartRequest request = http.MultipartRequest(
          'POST', Uri.parse(url));
      request.fields['prompt'] = prompt;

      // Add the image files to the request
      for (var i = 0; i < imageFiles.length; i++) {
        var file = imageFiles[i];
        var stream = http.ByteStream(file.openRead());
        var length = await file.length();
        http.MultipartFile multipartFile = http.MultipartFile(param, stream, length,
            filename: file.path.split('/').last);
        request.files.add(multipartFile);
      }
      // Send the request and get the response
      StreamedResponse response = await request.send();
      fun.pp('$mm 🥬🥬🥬🥬 Gemini AI returned response ...'
          'statusCode: ${response.statusCode}  🥬🥬🥬🥬reasonPhrase: ${response.reasonPhrase}');
      if (response.statusCode != 200 && response.statusCode != 201) {
        fun.pp('$mm 👿👿👿👿 sendImageTextPrompt: ERROR, '
            'status: ${response.statusCode} ${response.reasonPhrase} 👿👿👿👿');
        throw Exception('Failed to send AI request: ${response.reasonPhrase}');
      }
      // Read the response as a string
      var responseString = await response.stream.bytesToString();
      fun.pp('$mm 🥬🥬🥬🥬 Gemini AI returned responseString: $responseString ... 🥬🥬🥬🥬');

      // Parse the response string as JSON
      var jsonResponse = jsonDecode(responseString);
      fun.pp('$mm 🥬🥬🥬🥬 Gemini AI returned jsonResponse: $jsonResponse ... 🥬🥬🥬🥬');
      if (jsonResponse is ! Map<String, dynamic>) {
        fun.pp('$mm 👿👿👿👿 Gemini AI returned jsonResponse is not a Map 👿👿👿👿');
        throw Exception('Failed to send AI request: jsonResponse is not a Map');
      }
      GeminiResponse geminiResponse = GeminiResponse.fromJson(jsonResponse['response']);

      fun.pp('$mm 🥬🥬🥬🥬 Gemini AI returned response, see below ... 🥬🥬🥬🥬');
      fun.pp(geminiResponse.toJson());

      // Return the parsed JSON response
      return geminiResponse;
    } catch (e) {
      fun.pp('$mm 👿👿👿👿 Gemini AI returned error ... 👿👿👿👿');
      fun.pp(e);
      rethrow;
    }
  }

  Future<GeminiResponse> sendTextPrompt(String prompt) async {

    fun.pp('$mm sendTextPrompt starting ...');
    String urlPrefix = ChatbotEnvironment.getGeminiUrl();
    String url = '${urlPrefix}chats/sendChatPrompt';

    fun.pp('$mm sendTextPrompt: will send $url ...');

    try {
      var resp = await dioUtil.sendGetRequest(url, {'prompt':  prompt});

      GeminiResponse geminiResponse = GeminiResponse.fromJson(resp);

      fun.pp('$mm 🥬🥬🥬🥬 Gemini AI returned response ... 🥬🥬🥬🥬');
      fun.pp(resp);
      return geminiResponse;
    } catch (e) {
      fun.pp('$mm 👿👿👿👿 Gemini AI returned error ... 👿👿👿👿');
      fun.pp(e);
      rethrow;
    }
  }

}
