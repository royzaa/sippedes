import 'package:flutter/material.dart';

import '../letter/surat_pindah.dart';

class AjukanBaru extends StatelessWidget {
  const AjukanBaru({Key? key, required this.color, required this.letterName})
      : super(key: key);
  final Color color;
  final String letterName;

  @override
  Widget build(BuildContext context) {
    Widget? letter;

    switch (letterName) {
      case 'Surat Pindah':
        letter = SuratPindah(color: color, letterName: letterName);
        break;
      default:
    }

    return letter!;
  }
}
