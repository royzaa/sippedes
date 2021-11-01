import 'package:flutter/material.dart';

import './letter_item.dart';
import '../../../../model/letter.dart';

class LetterGrid extends StatelessWidget {
  const LetterGrid({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // final Size size = MediaQuery.of(context).size;
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: serviceableLetter.length,
      itemBuilder: (_, index) => Letteritem(
          color: serviceableLetter[index].color,
          image: serviceableLetter[index].image,
          name: serviceableLetter[index].name),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        childAspectRatio: 8 / 9,
        crossAxisSpacing: 20,
        mainAxisSpacing: 30,
        crossAxisCount: 2,
      ),
    );
  }
}
