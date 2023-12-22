import 'dart:io';

import 'package:edu_chatbot/repositories/repository.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

import '../data/exam_link.dart';

class ExamImageList extends StatefulWidget {
  final Repository repository;
  final ExamLink examLink;

  const ExamImageList({
    super.key,
    required this.examLink, required this.repository,
  });

  @override
  ExamImageListState createState() => ExamImageListState();
}

class ExamImageListState extends State<ExamImageList> {
  List<File> selectedImages = [];
  List<File> examImages = [];

  @override
  void initState() {
    super.initState();
    _getImages();

  }
  Future _getImages() async {
    examImages = await widget.repository.extractImages(
        widget.examLink, false);
   setState(() {

   });
  }
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CarouselSlider(
          options: CarouselOptions(
            enableInfiniteScroll: false,
            onPageChanged: (index, reason) {
              setState(() {
                selectedImages.clear();
              });
            },
          ),
          items: examImages.map((image) {
            return Builder(
              builder: (BuildContext context) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      if (selectedImages.contains(image)) {
                        selectedImages.remove(image);
                      } else {
                        selectedImages.add(image);
                      }
                    });
                  },
                  child: Stack(
                    children: [
                      Image.file(image),
                      if (selectedImages.contains(image))
                        const Positioned(
                          top: 8,
                          right: 8,
                          child: Icon(
                            Icons.check_circle,
                            color: Colors.green,
                          ),
                        ),
                    ],
                  ),
                );
              },
            );
          }).toList(),
        ),
        ElevatedButton(
          onPressed: () {
            // Handle button press
            // You can access the selected images using the 'selectedImages' list
          },
          child: Text('Submit'),
        ),
      ],
    );
  }
}