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
import '../text_input_field.dart';
import '../submit_form_button.dart';
import '../gender.dart';
import '../religion.dart';
import '../birth.dart';
import '../kk.dart';
import '../ktp.dart';

class Sktm extends StatefulWidget {
  const Sktm({Key? key, required this.color, required this.letterName})
      : super(key: key);
  final Color color;
  final String letterName;

  @override
  State<Sktm> createState() => _SktmState();
}

class _SktmState extends State<Sktm> {
  final TextEditingController _address = TextEditingController();
  final TextEditingController _name = TextEditingController();
  final TextEditingController _job = TextEditingController();
  final TextEditingController _religion = TextEditingController();
  final TextEditingController _necessity = TextEditingController();
  final TextEditingController _nik = TextEditingController();
  final TextEditingController _nationality = TextEditingController();
  final TextEditingController _childName = TextEditingController();
  final TextEditingController _schoolOrUniversity = TextEditingController();
  final TextEditingController _gradeOrSemester = TextEditingController();

  String? _ktpFileName, _kkFileName, _ktpUrl, _kkUrl, _ttgl, _jk;
  File? kkImage, ktpImage;

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
        SnackBar(
          content: Text('Dokumen $fileName sudah terkirim'),
        ),
      );
    });
  }

  void submitForm(BuildContext context) async {
    if (validate()) {
      try {
        if (kkImage == null && ktpImage == null) {
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
                  image: ktpImage,
                  context: context,
                  fileUrl: _ktpUrl,
                  picFileName: _ktpFileName,
                  expctedImageType: 'KTP')
              .then(
            (value) async => await FirestoreLetterServices.createSKTM(
                address: _address.text, // done
                ktpUrl: _ktpUrl ?? 'Belum diisi', // done
                name: _name.text, // dene
                ttgl: _ttgl ?? 'Belum diisi', // done
                nationality: _nationality.text, // done
                schoolOrUniversity: _schoolOrUniversity.text, // done
                childName: _childName.text, // done,
                gradeOrSemester: _gradeOrSemester.text, // dene,
                jk: _jk ?? 'Perempuan',
                kkUrl: _kkUrl ?? 'Belum diisi', // done
                job: _job.text, // done
                necessity: _necessity.text, // done
                nik: _nik.text, // dine
                letterId: generatedId), // done
          );
          uploadImageToFirebase(
              context: context,
              expctedImageType: 'KK',
              image: kkImage,
              fileUrl: _kkUrl,
              picFileName: _kkFileName);
          await FirestoreLetterServices.writeLetterStatus(
              letterId: generatedId,
              letterType: LetterType.sktm,
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
                    fieldName: 'Kewarganegaraan'),

                // // TTGL

                Birth(
                  color: widget.color,
                  onValue: (ttgl) {
                    _ttgl = ttgl;
                  },
                ),

                // JK

                Gender(value: (value) {
                  _jk = value;
                }),

                // PENDIDIKAN

                Religion(religion: _religion),

                // PEKERJAAN

                TextInputField(
                  color: widget.color,
                  controller: _job,
                  fieldName: 'Pekerjaan',
                ),

                // ALAMAT

                TextInputField(
                  color: widget.color,
                  controller: _address,
                  fieldName: 'Alamat sesuai KTP',
                ),

                // NAMA ANAK

                TextInputField(
                  color: widget.color,
                  controller: _childName,
                  fieldName: 'Nama anak',
                ),

                // Sekolah

                TextInputField(
                  color: widget.color,
                  controller: _schoolOrUniversity,
                  fieldName: 'Nama sekolah/universitas',
                ),

                // Kelas atau semester

                TextInputField(
                  color: widget.color,
                  controller: _gradeOrSemester,
                  fieldName: 'Kelas/semester',
                ),

                // KEPERLUAN

                TextInputField(
                  color: widget.color,
                  controller: _necessity,
                  fieldName: 'Keperluan',
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

                // KK
                Kk(
                  kkFileName: _kkFileName ?? '',
                  color: widget.color,
                  image: kkImage,
                  pickImage: () => pickImage(
                      image: kkImage,
                      expctedImageType: 'KK',
                      fileName: _kkFileName ?? ''),
                ),

                Center(
                  child: SubmitFormButton(
                    color: widget.color,
                    isLoading: isLoading,
                    submitForm: submitForm,
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
