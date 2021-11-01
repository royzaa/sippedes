import 'package:flutter/material.dart';

import '../letter/surat_pindah.dart';
import '../letter/skck.dart';
import '../letter/sktm.dart';
import '../letter/keterangan_usaha.dart';
import '../letter/surat_kehilangan.dart';
import '../letter/surat_kematian.dart';
import '../letter/surat_kelahiran.dart';
import '../letter/surat_ktp.dart';

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
      case 'SKCK':
        letter = Skck(color: color, letterName: letterName);
        break;
      case 'SKTM':
        letter = Sktm(color: color, letterName: letterName);
        break;
      case 'Surat Kehilangan':
        letter = SuratKehilangan(color: color, letterName: letterName);
        break;
      case 'Keterangan Usaha':
        letter = KeteranganUsaha(color: color, letterName: letterName);
        break;
      case 'Surat Kematian':
        letter = SuratKematian(color: color, letterName: letterName);
        break;
      case 'Surat Kelahiran':
        letter = SuratKelahiran(color: color, letterName: letterName);
        break;
      case 'KTP':
        letter = SuratKtp(color: color, letterName: letterName);
        break;
      default:
    }

    return letter!;
  }
}
