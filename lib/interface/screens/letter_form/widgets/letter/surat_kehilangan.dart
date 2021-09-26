import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';

import '../../../../../services/firebase_storage.dart';
import '../../../../../services/shared_preferences.dart';
import '../../../../../services/firestore_services.dart' hide FirestoreServices;
import '../../../../../services/sheet_api.dart';
import '../text_input_field.dart';
import '../submit_form_button.dart';
import '../gender.dart';
import '../education_degree.dart';
import '../relationship_status.dart';
import '../birth.dart';
import '../ktp.dart';

class SuratKehilangan extends StatefulWidget {
  const SuratKehilangan(
      {Key? key, required this.color, required this.letterName})
      : super(key: key);
  final Color color;
  final String letterName;

  @override
  State<SuratKehilangan> createState() => _SuratKehilanganState();
}

class _SuratKehilanganState extends State<SuratKehilangan> {
  final TextEditingController _address = TextEditingController();
  final TextEditingController _name = TextEditingController();
  final TextEditingController _job = TextEditingController();
  final TextEditingController _education = TextEditingController();
  final TextEditingController _what = TextEditingController();
  final TextEditingController _where = TextEditingController();
  final TextEditingController _when = TextEditingController();
  final TextEditingController _necessity = TextEditingController();
  final TextEditingController _nik = TextEditingController();
  final TextEditingController _nationality = TextEditingController();
  String? _ktpFileName, _ktpUrl, _ttgl, _jk, _relationshipStatus;
  File? ktpImage;

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

  void pickImage(
      {required String expctedImageType,
      required String fileName,
      required File? image,
      bool fromCamera = false}) async {
    try {
      final pickImage = await ImagePicker().pickImage(
        source: fromCamera ? ImageSource.camera : ImageSource.gallery,
      );
      if (pickImage == null) return;

      final tempImage = File(pickImage.path);
      setState(() {
        image = tempImage;
        fileName = DataSharedPreferences.getNIK() +
            '_${expctedImageType}_' +
            basename(image!.path);
      });
    } on PlatformException catch (e) {
      debugPrint('Error when pick image: $e');
    }
  }

  Future<void> uploadImageToFirebase(
      {required BuildContext context,
      required String expctedImageType,
      required File? image,
      required String? fileUrl,
      required String? picFileName}) async {
    final fileName = picFileName;

    final destination = 'foto_$expctedImageType/${_nik.text}/$fileName';
    await FirebaseStorageServices.uploadFile(destination, image!)!
        .then((p0) async {
      setState(() {
        isLoading = false;
      });
      fileUrl = await p0.ref.getDownloadURL();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pengajuan anda sudah terkirim'),
        ),
      );
    });
  }

  void submitForm(BuildContext context) async {
    if (validate()) {
      try {
        if (ktpImage == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Dokumen berupa foto belum lengkap'),
              duration: Duration(seconds: 3),
            ),
          );
        } else {
          setState(() {
            isLoading = true;
          });
          final String generatedId =
              (DateTime.now().millisecondsSinceEpoch ~/ 10).toString();

          uploadImageToFirebase(
                  fileUrl: _ktpUrl,
                  context: context,
                  image: ktpImage,
                  picFileName: _ktpFileName ?? _nik.text,
                  expctedImageType: 'KTP')
              .then(
            (value) async =>
                await FirestoreLetterServices.createSuratKehilangan(
              lostDescription: {
                'what': _what.text,
                'when': _when.text,
                'where': _where.text,
              },
              jk: _jk ?? 'Belum diisi',
              job: _job.text,
              necessity: _necessity.text,
              name: _name.text, // done
              nationality: _nationality.text, // done
              relationshipStatus: _relationshipStatus ?? 'Belum diisi',
              ttgl: _ttgl ?? 'Belum diisi', // done
              address: _address.text, // done
              ktpUrl: _ktpUrl ?? 'Belum diisi', // done
              nik: _nik.text, // done
              letterId: generatedId, // done
            ),
          );
          await FirestoreLetterServices.writeLetterStatus(
              letterId: generatedId,
              letterType: LetterType.suratKehilangan,
              registredNIK: DataSharedPreferences.getNIK());

          /// Digunakan oleh admin:

          // await FirestoreLetterServices.changeProfileField(
          //     _userNIK, 'Alamat', _address.text);
          // await SheetApi.updateData(
          //     rowKey: DataSharedPreferences.getUserName(),
          //     columnKey: 'Alamat',
          //     newValue: _address.text);
        }
      } catch (e) {
        debugPrint('error when submit new letter: ' + e.toString());
      }
    }
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

                // NAMA LENGKAP

                TextInputField(
                  color: widget.color,
                  controller: _name,
                  fieldName: 'Nama lengkap',
                ),

                // NIK

                TextInputField(
                  color: widget.color,
                  controller: _nik,
                  fieldName: 'NIK',
                ),

                // KEWARGANEGARAAN
                TextInputField(
                    color: widget.color,
                    controller: _nationality,
                    customValidator: (value) {
                      RegExp regExp = RegExp(r'^[a-zA-Z ]*$');
                      if (value!.isEmpty) {
                        return "Kewarganegaraan harus diisi";
                      } else if (!(regExp.hasMatch(value))) {
                        return "Negara hanya berupa huruf alfabet";
                      } else {
                        return null;
                      }
                    },
                    fieldName: 'Kewarganegaraan(Nama negara)'),

                // // TTGL

                Birth(
                  color: widget.color,
                  onValue: (ttgl) {
                    _ttgl = ttgl;
                  },
                ),

                // JENIS KELAMIN

                Gender(
                  value: (jk) {
                    _jk = jk;
                  },
                ),

                // PENDIDIKAN

                EducationDegree(education: _education),

                // PEKERJAAN

                TextInputField(
                  color: widget.color,
                  controller: _job,
                  fieldName: 'Pekerjaan',
                ),

                // STATUS PERKAWINAN
                RelationshipStatus(
                  relationshipStatus: (status) {
                    if (status != null) {
                      _relationshipStatus = status;
                    }
                  },
                ),

                // ALAMAT BARU

                TextInputField(
                  color: widget.color,
                  controller: _address,
                  fieldName: 'Alamat',
                ),

                // KEPERLUAN

                TextInputField(
                  color: widget.color,
                  controller: _necessity,
                  fieldName: 'Keperluan',
                ),

                // ORANG TUA

                const Text(
                  'Deskripsi kehilangan',
                  style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 16),
                ),
                TextInputField(
                  isCustom: true,
                  color: widget.color,
                  controller: _what,
                  fieldName: 'Apa barang yang hilang',
                ),
                TextInputField(
                  isCustom: true,
                  color: widget.color,
                  controller: _when,
                  fieldName: 'Kapan perkiraan hilang',
                ),
                TextInputField(
                  isCustom: true,
                  color: widget.color,
                  controller: _where,
                  fieldName: 'Dimana perkiraan hilang',
                ),
                const SizedBox(
                  height: 30,
                ),

                // KTP
                Ktp(
                  ktpFileName: _ktpFileName ?? '',
                  color: widget.color,
                  image: ktpImage,
                  pickImage: () => pickImage(
                    image: ktpImage,
                    expctedImageType: 'KTP',
                    fileName: _ktpFileName ?? '',
                  ),
                ),

                Center(
                  child: SubmitFormButton(
                    color: widget.color,
                    isLoading: isLoading,
                    submitForm: submitForm,
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
