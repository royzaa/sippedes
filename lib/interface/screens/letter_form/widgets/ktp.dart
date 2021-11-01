import 'dart:io';

import 'package:flutter/material.dart';

import './image_selector.dart';

class Ktp extends StatelessWidget {
  const Ktp(
      {Key? key,
      required this.ktpFileName,
      required this.color,
      required,
      required this.image,
      required this.pickImage})
      : super(key: key);
  final Color color;
  final File? image;
  final String ktpFileName;
  final VoidCallback pickImage;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: Column(
        children: [
          // KTP
          const Text(
            'Ambil foto KTP',
            style: TextStyle(
                color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16),
          ),
          ImageSelector(
            color: color,
            expectedImageType: 'KTP',
            fileName: ktpFileName,
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
