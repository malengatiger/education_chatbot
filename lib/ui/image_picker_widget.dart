import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

import '../services/chat_service.dart';
import '../util/functions.dart';

class ImagePickerWidget extends StatefulWidget {
  const ImagePickerWidget({super.key, required this.chatService});

  final ChatService chatService;

  @override
  ImagePickerWidgetState createState() => ImagePickerWidgetState();
}

class ImagePickerWidgetState extends State<ImagePickerWidget> {
  final List<File> _images = [];
  static const mm = '🥦🥦🥦🥦 ImagePickerWidget 🍐';

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await ImagePicker().pickImage(source: source);
    if (pickedFile != null) {
      final image = File(pickedFile.path);
      final appDir = await getApplicationDocumentsDirectory();
      final savedImage =
          await image.copy('${appDir.path}/${image.path.split('/').last}');
      setState(() {
        _images.add(savedImage);
      });
      pp('$mm ... image picked, savedImage: ${savedImage.path}');
    }
  }

  Future _sendImageToAI() async {
    pp('$mm _sendImageToAI: ...........................'
        ' images: ${_images.length}');

    try {
      var rr = await widget.chatService
          .sendGenericImageTextPrompt(_images.first, 'Tell me what you see');
      pp('$mm _sendImageToAI: ...... Gemini AI has responded! ');

      pp('$mm ... ${rr.toJson()}');
    } catch (e) {
      pp('$mm ERROR $e');
      if (mounted) {
        showErrorDialog(context, 'Fell down, Boss! 🍎 $e');
      }
    }
  }

  bool _useCamera = true;
  final List<String> _captions = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Image AI Buddy'),
        bottom: PreferredSize(
            preferredSize: const Size.fromHeight(36),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(_useCamera
                        ? 'Use the CAMERA'
                        : 'Get Picture from GALLERY'),
                    gapW16,
                    Switch(
                      value: _useCamera,
                      onChanged: (value) {
                        setState(() {
                          _useCamera = value;
                        });
                      },
                    ),
                  ],
                ),
              ],
            )),
      ),
      body: Stack(
        children: [
          PageView.builder(
            itemCount: _images.length,
            itemBuilder: (context, index) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      decoration: const InputDecoration(
                        labelText: 'Say something!',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _captions[index] = value;
                        });
                      },
                    ),
                  ),
                  Expanded(
                    child: Image.file(
                      _images[index],
                      fit: BoxFit.cover,
                    ),
                  ),
                ],
              );
            },
          ),
          Positioned(
              bottom: 8,
              child: Center(
                child: ToolBar(
                  onCamera: () {
                    _pickImage(
                        _useCamera ? ImageSource.camera : ImageSource.gallery);
                  },
                  onSubmit: () {
                    if (_images.isNotEmpty) {
                      _sendImageToAI();
                    }
                  },
                  showSubmit: _images.isNotEmpty,
                ),
              )),
        ],
      ),
    );
  }
}

class ToolBar extends StatelessWidget {
  const ToolBar(
      {super.key,
      required this.onCamera,
      required this.onSubmit,
      required this.showSubmit});

  final Function() onCamera;
  final Function() onSubmit;
  final bool showSubmit;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          gapW16,
          SizedBox(width: 160,
            child: ElevatedButton.icon(
              style: const ButtonStyle(
                elevation: MaterialStatePropertyAll(8),
              ),
              onPressed: () {
                onCamera();
              },
              icon: const Icon(Icons.camera_alt),
              label: const Text('Get Image'),
            ),
          ),
          gapW16,
          showSubmit
              ? SizedBox(width: 160,
                child: ElevatedButton.icon(
                    style: const ButtonStyle(
                      elevation: MaterialStatePropertyAll(8),
                    ),
                    onPressed: () {
                      onSubmit();
                    },
                    icon: const Icon(Icons.send),
                    label: const Text('Send'),
                  ),
              )
              : gapW8,
          gapW16,
        ],
      ),
    );
  }
}
