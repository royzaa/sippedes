import 'dart:io';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';

import './pdf_api.dart';
import '../model/ktp_model.dart';

class PdfKTPApi {
  static const verticalSpacing = 4 * PdfPageFormat.mm;
  static const horizontalSpacing = 1.5 * PdfPageFormat.mm;
  static const diffCharacterSpacing = 7.5 * PdfPageFormat.mm;

  static Future<File> generate(KtpModel ktp) async {
    final pdf = Document();

    pdf.addPage(MultiPage(
      pageFormat: PdfPageFormat.a5,
      margin: const EdgeInsets.all(diffCharacterSpacing),
      build: (conbuildText) => [
        buildHeader(ktp),
        Divider(),
        buildTitle(),
        buildDataKepalaKeluarga(ktp),
        SizedBox(height: verticalSpacing),
        buildDataPenduduk(ktp),
        SizedBox(height: verticalSpacing),
        Divider(),
        SizedBox(height: verticalSpacing),
        buildRatification(ktp),
      ],
    ));

    return PdfApi.saveDocument(name: 'Formulir KTP.pdf', pdf: pdf);
  }

  static Widget buildHeader(KtpModel ktp) {
    final tipeFormulir = <String>['BARU', 'PERPANJANGAN', 'PENGGANTIAN'];
    final lokasiDesa = <Map<String, String>>[
      {'KECAMATAN': 'KEMANGKON'},
      {'DESA': 'TOYAREKA'},
      {'KODE DESA': '3303012017'},
    ];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        SizedBox(
          width: PdfPageFormat.a5.width * 0.3,
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            ...tipeFormulir.asMap().entries.map((entry) {
              final item = entry.value;
              final index = entry.key;
              return Row(
                children: [
                  Container(
                    margin: const EdgeInsets.only(bottom: 1),
                    decoration: BoxDecoration(
                      border: Border.all(color: PdfColors.black, width: 0.5),
                    ),
                    padding: const EdgeInsets.all(1.5),
                    child: buildText((index + 1).toString()),
                  ),
                  SizedBox(width: horizontalSpacing),
                  buildText(item),
                ],
              );
            }),
          ]),
        ),
        SizedBox(
          width: PdfPageFormat.a5.width * 0.5,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildText('PEMERINTAH KABUPATEN PURBALINGGA'),
              Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ...lokasiDesa.map(
                        (item) => Padding(
                          padding: const EdgeInsets.only(
                            right: 2 * PdfPageFormat.cm,
                          ),
                          child: buildText(
                            item.keys.toList()[0],
                          ),
                        ),
                      )
                    ],
                  ),
                  Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ...List.generate(
                          lokasiDesa.length,
                          (index) => Padding(
                            padding:
                                const EdgeInsets.only(right: horizontalSpacing),
                            child: buildText(':'),
                          ),
                        ),
                      ]),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ...lokasiDesa.map(
                        (item) => Padding(
                          padding: const EdgeInsets.only(
                            right: 0,
                          ),
                          child: buildText(item.values.toList()[0]),
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ],
          ),
        )
      ],
    );
  }

  static Widget buildTitle() {
    return Center(
        child: Column(
      children: [
        buildText('FORMULIR ISIAN DATA PENDUDUK', isBold: true),
        buildText('( Diisi dengan huruf cetak )'),
      ],
    ));
  }

  static Widget buildDataKepalaKeluarga(KtpModel ktp) {
    final dataKey = <String>['Nomor KK', 'Nama Kepala Keluarga', 'Alamat'];
    final datavalue = <String>[
      ktp.dataKk.nomorKK,
      ktp.dataKk.namaKepalaKeluarga,
      ktp.dataKk.alamat
    ];
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      buildText('I. DATA KEPALA KELUARGA KK'),
      SizedBox(height: horizontalSpacing),
      Padding(
          padding: const EdgeInsets.only(left: verticalSpacing),
          child: Row(children: [
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              ...dataKey.asMap().entries.map((entry) {
                final int index = entry.key;

                return Padding(
                    padding: const EdgeInsets.only(right: horizontalSpacing),
                    child: buildText((index + 1).toString() + '.'));
              })
            ]),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              ...dataKey.asMap().entries.map((entry) {
                final String item = entry.value;

                return Padding(
                    padding: const EdgeInsets.only(right: diffCharacterSpacing),
                    child: buildText(item));
              })
            ]),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              ...List.generate(
                dataKey.length,
                (index) => Padding(
                  padding: const EdgeInsets.only(right: horizontalSpacing),
                  child: buildText(':'),
                ),
              ),
            ]),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              ...datavalue.map((item) {
                return buildText(item.toUpperCase());
              })
            ]),
          ]))
    ]);
  }

  static buildDataPenduduk(KtpModel ktp) {
    final Map<String, dynamic> data = {
      'NIK': ktp.dataPenduduk.nik,
      'Nama Lengkap': ktp.dataPenduduk.namaLengkap,
      'Jenis Kelamin': ktp.dataPenduduk.jenisKelamin,
      'Status Hubungan dalam Rumah Tangga':
          ktp.dataPenduduk.statusHubunganDalamRT,
      'Tanggal Lahir': ktp.dataPenduduk.tanggalLahir,
      'Tempat Lahir': ktp.dataPenduduk.tempatLahir,
      'Agama': ktp.dataPenduduk.agama,
      'Golongan darah': ktp.dataPenduduk.goldar,
      'Warga negara': ktp.dataPenduduk.kewarganegaraan,
      'Pekerjaan': ktp.dataPenduduk.pekerjaan,
      'Nama orang tua': {
        'ayah': ktp.dataPenduduk.ayah,
        'ibu': ktp.dataPenduduk.ibu,
      }
    };
    final datavalue = data.values.toList();
    final dataKey = data.keys.toList();
    return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildText('II. DATA PENDUDUK KTP'),
          SizedBox(height: horizontalSpacing),
          Padding(
              padding: const EdgeInsets.only(left: verticalSpacing),
              child:
                  Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  ...dataKey.asMap().entries.map((entry) {
                    final int index = entry.key;

                    return Padding(
                        padding:
                            const EdgeInsets.only(right: horizontalSpacing),
                        child: buildText((index + 1).toString() + '.'));
                  })
                ]),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  ...dataKey.asMap().entries.map((entry) {
                    final String item = entry.value;

                    return Padding(
                        padding:
                            const EdgeInsets.only(right: diffCharacterSpacing),
                        child: buildText(item));
                  })
                ]),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  ...List.generate(
                    dataKey.length,
                    (index) => Padding(
                      padding: const EdgeInsets.only(right: horizontalSpacing),
                      child: buildText(':'),
                    ),
                  ),
                ]),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  ...datavalue.whereType<String>().map((item) {
                    //  final List<String> char = item.split('');
                    return buildText(item.toUpperCase());
                    // ListView.builder(
                    //     direction: Axis.horizontal,
                    //     itemBuilder: (_, index) {
                    //       return Container(
                    //           height: null,
                    //           width: null,
                    //           alignment: Alignment.center,
                    //           decoration: BoxDecoration(
                    //               //border: Border.all(width: 0.5),
                    //               ),
                    //           child: buildText(char[index].toUpperCase()));
                    //     },
                    //     itemCount: item.length);
                  }),
                  ...datavalue.whereType<Map<String, String>>().map((item) {
                    final dataKey = item.keys.toList();
                    final dataValues = item.values.toList();
                    return Row(children: [
                      Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ...dataKey.asMap().entries.map((entry) {
                              final String item = entry.value;

                              return Padding(
                                  padding: const EdgeInsets.only(
                                      right: verticalSpacing),
                                  child: buildText(item));
                            })
                          ]),
                      Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ...List.generate(
                              dataKey.length,
                              (index) => Padding(
                                padding: const EdgeInsets.only(
                                    right: horizontalSpacing),
                                child: buildText(':'),
                              ),
                            ),
                          ]),
                      Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ...dataValues.map((item) {
                              return buildText(item.toUpperCase());
                            })
                          ]),
                    ]);
                  })
                ]),
              ]))
        ]);
  }

  static Widget buildRatification(KtpModel ktp) {
    return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(children: [
            buildTTD('RT'),
            SizedBox(height: verticalSpacing),
            buildTTD('Kepala Desa/Kelurahan'),
          ]),
          Column(children: [
            buildTTD('RW'),
            SizedBox(height: verticalSpacing),
            buildTTD('Camat'),
          ]),
          Column(children: [
            buildText('Purbalingga ${ktp.tanggalDibuat}'),
            SizedBox(height: horizontalSpacing),
            buildTTD('Pemohon'),
          ]),
        ]);
  }

  static Widget buildTTD(

      /// RT/RW/Kades/Camat
      String pejabat) {
    return Column(children: [
      buildText('Mengetahui $pejabat'),
      SizedBox(height: diffCharacterSpacing * 1.5),
      buildText('(' + '.' * 25 + ')')
    ]);
  }

  static buildText(String text, {bool isBold = false}) {
    return Text(
      text,
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 8,
        fontWeight: isBold ? FontWeight.bold : null,
      ),
    );
  }
}
