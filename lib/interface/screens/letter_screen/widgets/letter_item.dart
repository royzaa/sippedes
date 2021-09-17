import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../letter_form/letter_form.dart';

class Letteritem extends StatelessWidget {
  const Letteritem(
      {Key? key, required this.color, required this.image, required this.name})
      : super(key: key);
  final Color color;
  final String name;
  final String image;

  @override
  Widget build(BuildContext context) {
    // final Size size = MediaQuery.of(context).size;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: InkWell(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) =>
                          const LetterForm(letterName: 'Surat Pindah')));
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 10),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.25),
                    blurRadius: 20,
                    offset: const Offset(0, 5),
                    spreadRadius: 5,
                  )
                ],
              ),
              child: SvgPicture.asset(
                image,
              ),
            ),
          ),
        ),
        const SizedBox(
          height: 10,
        ),
        Text(
          name,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
