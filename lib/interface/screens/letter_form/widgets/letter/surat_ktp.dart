import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

import '../text_input_field.dart';
import '../submit_form_button.dart';
import '../gender.dart';
import '../religion.dart';
import '../birth.dart';
import '../blood_type.dart';
import '../nationality.dart';
import '../relationship_status.dart';
import '../family_status.dart';
import '../../../../../api/pdf_ktp_api.dart';
import '../../../../../api/pdf_api.dart';
import '../../../../../model/ktp_model.dart';

class SuratKtp extends StatefulWidget {
  const SuratKtp({Key? key, required this.color, required this.letterName})
      : super(key: key);
  final Color color;
  final String letterName;

  @override
  State<SuratKtp> createState() => _SuratKtp();
}

class _SuratKtp extends State<SuratKtp> {
  final TextEditingController _address = TextEditingController();
  final TextEditingController _name = TextEditingController();
  final TextEditingController _job = TextEditingController();
  final TextEditingController _religion = TextEditingController();
  final TextEditingController _nik = TextEditingController();
  final TextEditingController _father = TextEditingController();
  final TextEditingController _mother = TextEditingController();
  final TextEditingController _noKk = TextEditingController();
  final TextEditingController _namaKepalaKeluarga = TextEditingController();
  final TextEditingController _bloodType = TextEditingController();

  String? _relationshipStatus, _familyStatus, _nationality, _ttgl, _jk;

  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;

  bool validate() {
    bool status = false;
    final form = _formKey.currentState;

    if (form!.validate()) {
      form.save();
      status = true;
    } else {
      status = false;
    }
    return status;
  }

  Future<void> submitButton(BuildContext context) async {
    if (validate()) {
      final ktpData = KtpModel(
        dataKk: DataKepalaKeluarga(
            alamat: _address.text,
            namaKepalaKeluarga: _namaKepalaKeluarga.text,
            nomorKK: _noKk.text),
        dataPenduduk: DataPenduduk(
          agama: _religion.text,
          ayah: _father.text,
          goldar: _bloodType.text,
          ibu: _mother.text,
          jenisKelamin: _jk!,
          kewarganegaraan: _nationality!,
          namaLengkap: _name.text,
          nik: _nik.text,
          pekerjaan: _job.text,
          statusHubunganDalamRT: _familyStatus!,
          statusKawin: _relationshipStatus!,
          tanggalLahir: _ttgl!.split(',')[1].trim(),
          tempatLahir: _ttgl!.split(',')[0],
        ),
        tanggalDibuat: DateFormat('d MMMM y').format(DateTime.now()),
      );
      setState(() {
        isLoading = true;
      });
      await PdfKTPApi.generate(ktpData).then((pdf) async {
        await Future.delayed(const Duration(milliseconds: 250), () async {
          await PdfApi.openFile(pdf);
          setState(() {
            isLoading = false;
          });
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // final Size size = MediaQuery.of(context).size;

    return Form(
      key: _formKey,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: SizedBox(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(
                  height: 30,
                ),

                const Text(
                  'Data Kepala Keluarga KK',
                  style: TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                      fontSize: 18),
                ),

                const SizedBox(
                  height: 30,
                ),

                // NOMOR KK

                TextInputField(
                  color: widget.color,
                  controller: _noKk,
                  fieldName: 'Nomor KK',
                  customValidator: (value) {
                    RegExp regExp = RegExp(r'^[1-9]+[0-9]*$');
                    if (value == '' || value!.isEmpty) {
                      return 'Nomor KK tidak boleh kosong';
                    } else if (!regExp.hasMatch(value)) {
                      return 'Nomor KK hanya berupa angka';
                    } else if (!(value.length == 16)) {
                      return 'Nomor KK berjumlah 16 digit';
                    } else {
                      return null;
                    }
                  },
                ),

                // NAMA KEPALA KELUARGA

                TextInputField(
                  color: widget.color,
                  controller: _namaKepalaKeluarga,
                  fieldName: 'Nama kepala keluarga',
                ),

                // ADDRESS

                TextInputField(
                  color: widget.color,
                  controller: _address,
                  fieldName: 'Alamat lengkap (beserta RT/RW)',
                ),

                const Text(
                  'Data Penduduk (KTP)',
                  style: TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                      fontSize: 18),
                ),

                const SizedBox(
                  height: 30,
                ),

                // NIK

                TextInputField(
                  color: widget.color,
                  controller: _nik,
                  fieldName: 'NIK',
                  customValidator: (value) {
                    RegExp regExp = RegExp(r'^[1-9]+[0-9]*$');
                    if (value == '' || value!.isEmpty) {
                      return 'NIK tidak boleh kosong';
                    } else if (!regExp.hasMatch(value)) {
                      return 'NIK hanya berupa angka';
                    } else if (!(value.length == 16)) {
                      return 'NIK berjumlah 16';
                    } else {
                      return null;
                    }
                  },
                ),

                // Nama lengkap

                TextInputField(
                  color: widget.color,
                  controller: _name,
                  fieldName: 'Nama lengkap',
                ),

                // JK

                Gender(value: (value) {
                  _jk = value;
                }),

                // FAMILY STATUS

                FamilyStatus(familyStatus: (value) {
                  _familyStatus = value;
                }),

                // TTGL

                Birth(
                  color: widget.color,
                  onValue: (ttgl) {
                    _ttgl = ttgl;
                  },
                ),

                // STATUS PERKAWINAN

                RelationshipStatus(relationshipStatus: (value) {
                  _relationshipStatus = value;
                }),

                // AGAMA

                Religion(religion: _religion),

                // GOLDAR

                BloodType(bloodType: _bloodType),

                // KEWARGANEGARAAN

                Nationality(value: (value) {
                  _nationality = value;
                }),

                // PEKERJAAN

                TextInputField(
                  color: widget.color,
                  controller: _job,
                  fieldName: 'Pekerjaan',
                ),

                // ORANG TUA

                const Text(
                  'Nama orang tua',
                  style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 16),
                ),
                TextInputField(
                  isCustom: true,
                  color: widget.color,
                  controller: _father,
                  fieldName: 'Ayah',
                ),
                TextInputField(
                  isCustom: true,
                  color: widget.color,
                  controller: _mother,
                  fieldName: 'Ibu',
                ),
                const SizedBox(
                  height: 30,
                ),

                Center(
                  child: SubmitFormButton(
                    customButtonName: 'Cetak Formulir',
                    color: widget.color,
                    isLoading: isLoading,
                    submitForm: submitButton,
                  ),
                ),
                const SizedBox(
                  height: 30,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
