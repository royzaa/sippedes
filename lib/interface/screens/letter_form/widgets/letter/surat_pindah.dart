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
import '../image_selector.dart';
import '../gender.dart';
import '../education_degree.dart';
import '../relationship_status.dart';
import '../birth.dart';
import '../ktp.dart';
import '../kk.dart';

class SuratPindah extends StatefulWidget {
  const SuratPindah({Key? key, required this.color, required this.letterName})
      : super(key: key);
  final Color color;
  final String letterName;

  @override
  State<SuratPindah> createState() => _SuratPindahState();
}

class _SuratPindahState extends State<SuratPindah> {
  final TextEditingController _address = TextEditingController();
  final TextEditingController _previousAddress = TextEditingController();
  final TextEditingController _name = TextEditingController();
  final TextEditingController _job = TextEditingController();
  final TextEditingController _education = TextEditingController();
  final TextEditingController _father = TextEditingController();
  final TextEditingController _mother = TextEditingController();
  final TextEditingController _excuse = TextEditingController();
  final TextEditingController _nik = TextEditingController();
  final TextEditingController _nationality = TextEditingController();
  final Map<String, String> _followers = {};
  String? _ktpFileName,
      _kkFileName,
      _photoFileName,
      _ktpUrl,
      _photoUrl,
      _kkUrl,
      _ttgl,
      _jk,
      _relationshipStatus;
  File? _ktpImage, _kkImage, _photoImage;

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

  void pickKTPImage(
      {required String expctedImageType,
      bool fromCamera = false}) async {
    try {
      final pickImage = await ImagePicker().pickImage(
        source: fromCamera ? ImageSource.camera : ImageSource.gallery,
      );
      if (pickImage == null) return;

      final tempImage = File(pickImage.path);
      setState(() {
        _ktpImage = tempImage;
        _ktpFileName = DataSharedPreferences.getNIK() +
            '_${expctedImageType}_' +
            basename(_ktpImage!.path);
      });
    } on PlatformException catch (e) {
      debugPrint('Error when pick image: $e');
    }
  }

  void pickKKImage(
      {required String expctedImageType,
      bool fromCamera = false}) async {
    try {
      final pickImage = await ImagePicker().pickImage(
        source: fromCamera ? ImageSource.camera : ImageSource.gallery,
      );
      if (pickImage == null) return;

      final tempImage = File(pickImage.path);
      setState(() {
        _kkImage = tempImage;
        _kkFileName = DataSharedPreferences.getNIK() +
            '_${expctedImageType}_' +
            basename(_kkImage!.path);
      });
    } on PlatformException catch (e) {
      debugPrint('Error when pick image: $e');
    }
  }

  void pickPhotoImage(
      {required String expctedImageType,
      bool fromCamera = false}) async {
    try {
      final pickImage = await ImagePicker().pickImage(
        source: fromCamera ? ImageSource.camera : ImageSource.gallery,
      );
      if (pickImage == null) return;

      final tempImage = File(pickImage.path);
      setState(() {
        _photoImage = tempImage;
        _photoFileName = DataSharedPreferences.getNIK() +
            '_${expctedImageType}_' +
            basename(_photoImage!.path);
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
        if (_kkImage == null && _ktpImage == null && _photoImage == null) {
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
                  image: _ktpImage,
                  picFileName: _ktpFileName ?? _nik.text,
                  expctedImageType: 'KTP')
              .then(
            (value) async => await FirestoreLetterServices.createSuratPindah(
              education: _education.text,
              excuse: _excuse.text, // done
              father: _father.text, // done
              jk: _jk ?? 'Belum diisi',
              job: _job.text,
              kkUrl: _kkUrl ?? 'Belum diisi', // done
              mother: _mother.text, // done
              name: _name.text, // done
              nationality: _nationality.text, // done
              photoUrl: _photoUrl ?? '', // done
              previousAddress: _previousAddress.text, // done
              relationshipStatus: _relationshipStatus ?? 'Belum diisi',
              ttgl: _ttgl ?? 'Belum diisi', // done
              address: _address.text, // done
              ktpUrl: _ktpUrl ?? 'Belum diisi', // done
              migratedNIK: _nik.text, // done
              followers: _followers,
              letterId: generatedId, // done
            ),
          );
          uploadImageToFirebase(
              context: context,
              expctedImageType: 'KK',
              image: _kkImage,
              fileUrl: _kkUrl,
              picFileName: _kkFileName);
          uploadImageToFirebase(
              context: context,
              expctedImageType: 'Photo',
              image: _photoImage,
              fileUrl: _photoUrl,
              picFileName: _photoFileName);
          await FirestoreLetterServices.writeLetterStatus(
              letterId: generatedId,
              letterType: LetterType.suratPindah,
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

                // ALAMAT BARU

                TextInputField(
                  color: widget.color,
                  controller: _address,
                  fieldName: 'Alamat baru',
                ),

                // ALAMAT LAMA

                TextInputField(
                  color: widget.color,
                  controller: _previousAddress,
                  fieldName: 'Alamat lama',
                ),

                // ALASAN PINDAH

                TextInputField(
                  color: widget.color,
                  controller: _excuse,
                  fieldName: 'Alasan pindah',
                ),

                // KTP
                Ktp(
                  ktpFileName: _ktpFileName ?? '',
                  color: widget.color,
                  image: _ktpImage,
                  pickImage: () => pickKTPImage(expctedImageType: 'KTP'),
                ),

                // KK
                Kk(
                  kkFileName: _kkFileName ?? '',
                  color: widget.color,
                  image: _kkImage,
                  pickImage: () => pickKKImage(expctedImageType: 'KK')
                ),

                // PHOTO
                const Text(
                  'Pilih foto formal',
                  style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 16),
                ),
                ImageSelector(
                  color: widget.color,
                  expectedImageType: 'Photo',
                  fileName: _photoFileName ?? '',
                  image: _photoImage,
                  pickImage: () => pickPhotoImage(expctedImageType: 'Photo')
                ),
                const SizedBox(
                  height: 30,
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
