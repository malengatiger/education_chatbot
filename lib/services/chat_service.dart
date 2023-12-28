import 'dart:convert';
import 'dart:io';

import 'package:edu_chatbot/util/environment.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';

import '../data/exam_page_image.dart';
import '../data/gemini/gemini_response.dart';
import '../util/dio_util.dart';
import '../util/functions.dart' as fun;

class ChatService {
  static const mm = '💜💜💜💜 ChatService';

  final DioUtil dioUtil;

  ChatService(this.dioUtil);

  Future<GeminiResponse> sendImageTextPrompt(
      List<ExamPageImage> imageFiles, String prompt) async {
    fun.pp('$mm .... sendImageTextPrompt starting ... '
        'imageFiles: ${imageFiles.length}');
    if (imageFiles.isEmpty) {
      throw Exception('No image files provided');
    }
    String urlPrefix = ChatbotEnvironment.getGeminiUrl();
    String url = '${urlPrefix}textImage/sendTextImagePrompt';
    String param = 'examPageImage';
    if (imageFiles.length > 1) {
      url = '${urlPrefix}textImage/sendTextImagesPrompt';
    }
    fun.pp('$mm sendImageTextPrompt: will send ,,,,, $url ...');

    try {
      http.MultipartRequest request =
          http.MultipartRequest('POST', Uri.parse(url));
      request.fields['prompt'] = prompt;

      // Add the image files to the request
      for (var i = 0; i < imageFiles.length; i++) {
        var examPageImage = imageFiles[i];
        var mimeType = "png";
        examPageImage.mimeType ??= mimeType;
        var multipartFile = createMultipartFile(examPageImage.bytes!, "file",
            "image_${examPageImage.examLinkId}_i$i.${examPageImage.mimeType}");
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
      // Parse the response string as JSON
      var jsonResponse = jsonDecode(responseString);
      if (jsonResponse is! Map<String, dynamic>) {
        fun.pp(
            '$mm 👿👿👿👿 Gemini AI returned jsonResponse is not a Map 👿👿👿👿');
        throw Exception('Failed to send AI request: jsonResponse is not a Map');
      }

      GeminiResponse geminiResponse =
          GeminiResponse.fromJson(jsonResponse['response']);
      // Return the parsed JSON response
      return geminiResponse;
    } catch (e) {
      fun.pp('$mm 👿👿👿👿 Gemini AI returned error ... 👿👿👿👿');
      fun.pp(e);
      rethrow;
    }
  }

  http.MultipartFile createMultipartFile(
      List<int> bytes, String fieldName, String filename) {
    // Create a byte stream from the bytes list
    var stream = http.ByteStream.fromBytes(bytes);
    // Get the length of the byte stream
    var length = bytes.length;

    // Create the multipart file object
    var multipartFile =
        http.MultipartFile(fieldName, stream, length, filename: filename);

    return multipartFile;
  }

  Future<GeminiResponse> sendTextPrompt(String prompt) async {
    fun.pp('$mm sendTextPrompt starting ...');
    String urlPrefix = ChatbotEnvironment.getGeminiUrl();
    String url = '${urlPrefix}chats/sendChatPrompt';

    fun.pp('$mm sendTextPrompt: will send $url ...');

    try {
      var resp = await dioUtil.sendGetRequest(url, {'prompt': prompt});

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

  Future<GeminiResponse> sendGenericImageTextPrompt(
      File imageFile, String prompt) async {
    var length = await imageFile.length();
    fun.pp('$mm .... sendGenericImageTextPrompt starting ... '
        'imageFile: $length');
    if (length > (1024 * 1024 * 4)) {
      throw Exception('Image file too big');
    }
    String urlPrefix = ChatbotEnvironment.getGeminiUrl();
    String url = '${urlPrefix}textImage/sendTextImagePrompt';
    String param = 'file';
    fun.pp('$mm sendImageTextPrompt: will send ,,,,, $url ...');

    try {
      http.MultipartRequest request =
          http.MultipartRequest('POST', Uri.parse(url));
      request.fields['prompt'] = prompt;

      // Add the image files to the request
      var stream = http.ByteStream(imageFile.openRead());
      var multipartFile = http.MultipartFile("file", stream, length);
      request.files.add(multipartFile);
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
      // Parse the response string as JSON
      var jsonResponse = jsonDecode(responseString);
      if (jsonResponse is! Map<String, dynamic>) {
        fun.pp(
            '$mm 👿👿👿👿 Gemini AI returned jsonResponse is not a Map 👿👿👿👿');
        throw Exception('Failed to send AI request: jsonResponse is not a Map');
      }
      GeminiResponse geminiResponse =
          GeminiResponse.fromJson(jsonResponse['response']);

      // Return the parsed JSON response
      return geminiResponse;
    } catch (e) {
      fun.pp('$mm 👿👿👿👿 Gemini AI returned error ... 👿👿👿👿');
      fun.pp(e);
      rethrow;
    }
  }
}
