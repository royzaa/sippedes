import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../../../../../services/sheet_api.dart';
import '../text_input_field.dart';
import '../submit_form_button.dart';
import '../gender.dart';
import '../religion.dart';
import '../birth.dart';
import '../blood_type.dart';
import '../nationality.dart';
import '../relationship_status.dart';

import '../family_status.dart';

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

  @override
  void initState() {
    WidgetsBinding.instance!.addPostFrameCallback((_) async {
      await SheetApi.init();
    });
    super.initState();
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
                  fieldName: 'Alamat',
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
                    color: widget.color,
                    isLoading: isLoading,
                    submitForm: (context) {},
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
