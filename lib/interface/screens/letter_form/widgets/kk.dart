import 'dart:io';

import 'package:flutter/material.dart';

import './image_selector.dart';

class Kk extends StatelessWidget {
  const Kk(
      {Key? key,
      required this.kkFileName,
      required this.color,
      required,
      required this.image,
      required this.pickImage})
      : super(key: key);
  final Color color;
  final File? image;
  final String kkFileName;
  final VoidCallback pickImage;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: Column(
        children: [
          // KK
          const Text(
            'Ambil foto KK',
            style: TextStyle(
                color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16),
          ),
          ImageSelector(
            color: color,
            expectedImageType: 'KK',
            fileName: kkFileName,
            image: image,
            pickImage: () => pickImage(),
          ),
          const SizedBox(
            height: 30,
          ),
        ],
      ),
    );
  }
}
