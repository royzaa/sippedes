import 'package:flutter/material.dart';

class Letter {
  final String name;
  final Color color;
  final String image;

  const Letter(
      {required this.name,
      required this.color,
      this.image = 'assets/images/document.svg'});
}

const serviceableLetter = <Letter>[
  Letter(
    name: 'SKCK',
    color: Color.fromRGBO(255, 166, 166, 1),
  ),
  Letter(
    name: 'KTP',
    color: Color.fromRGBO(166, 218, 255, 1),
  ),
  Letter(
    name: 'SKTM',
    color: Color.fromRGBO(255, 166, 235, 1),
  ),
  Letter(
    name: 'Surat Kelahiran',
    color: Color.fromRGBO(255, 214, 166, 1),
  ),
  Letter(
    name: 'Surat Pindah',
    color: Color.fromRGBO(166, 255, 169, 1),
  ),
  Letter(
    name: 'Surat Kehilangan',
    color: Color.fromRGBO(166, 255, 212, 1),
  ),
  Letter(
    name: 'Surat Jalan',
    color: Color.fromRGBO(194, 166, 255, 1),
  ),
  Letter(
    name: 'Surat Kematian',
    color: Color.fromRGBO(255, 246, 166, 1),
  ),
  Letter(
    name: 'Keterangan Usaha',
    color: Color.fromRGBO(234, 211, 190, 1),
  ),
  Letter(
    name: 'Surat Domisili',
    color: Color.fromRGBO(225, 255, 175, 1),
  ),
];
