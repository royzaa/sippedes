import 'dart:io';

import 'package:flutter/material.dart';

class ImageSelector extends StatelessWidget {
  const ImageSelector(
      {Key? key,
      required this.color,
      required this.expectedImageType,
      required this.fileName,
      required this.image,
      required this.pickImage})
      : super(key: key);
  final Color color;
  final VoidCallback pickImage;
  final File? image;
  final String expectedImageType, fileName;

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return Container(
      width: size.width * 0.65,
      decoration: BoxDecoration(
          border: Border.all(
            color: Colors.black,
            width: 1,
          ),
          shape: BoxShape.rectangle),
      padding: const EdgeInsets.all(9),
      margin: const EdgeInsets.symmetric(vertical: 15),
      child: Column(
        children: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              primary: color,
              minimumSize: const Size(double.infinity, 30),
            ),
            onPressed: pickImage,
            child: Text(
              image == null
                  ? 'Pilih foto $expectedImageType'
                  : 'Ganti foto $expectedImageType',
              style: const TextStyle(color: Colors.black),
            ),
          ),
          image == null
              ? const SizedBox()
              : Text(
                  fileName,
                ),
        ],
      ),
    );
  }
}
