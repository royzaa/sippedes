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
import '../date_time_picker.dart';
import '../image_selector.dart';
import '../gender.dart';

class SuratKelahiran extends StatefulWidget {
  const SuratKelahiran(
      {Key? key, required this.color, required this.letterName})
      : super(key: key);
  final Color color;
  final String letterName;

  @override
  State<SuratKelahiran> createState() => _SuratKelahiranState();
}

class _SuratKelahiranState extends State<SuratKelahiran> {
  final TextEditingController _address = TextEditingController();
  final TextEditingController _nik =
      TextEditingController(text: DataSharedPreferences.getNIK());
  final TextEditingController _name = TextEditingController();
  final TextEditingController _place = TextEditingController();
  final TextEditingController _father = TextEditingController();
  final TextEditingController _mother = TextEditingController();

  String? _skFileName, _skUrl, _jk, _date, _time;
  File? _skImage;

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
      {required String expctedImageType, bool fromCamera = false}) async {
    try {
      final pickImage = await ImagePicker().pickImage(
        source: fromCamera ? ImageSource.camera : ImageSource.gallery,
      );
      if (pickImage == null) return;

      final tempImage = File(pickImage.path);
      setState(() {
        _skImage = tempImage;
        _skFileName = DataSharedPreferences.getNIK() +
            '_${expctedImageType}_' +
            basename(_skImage!.path);
      });
    } on PlatformException catch (e) {
      debugPrint('Error when pick image: $e');
    }
  }

  Future<void> uploadImageToFirebase(
      {required BuildContext context,
      required String expctedImageType,
      required File? image,
      required void Function(String?) fileUrl,
      required String? picFileName}) async {
    final fileName = picFileName;

    final destination = 'foto_$expctedImageType/${_nik.text}/$fileName';
    await FirebaseStorageServices.uploadFile(destination, image!)!
        .then((p0) async {
      setState(() {
        isLoading = false;
      });
      String url = await p0.ref.getDownloadURL();
      fileUrl(url);
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
        if (_skImage == null) {
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
                  image: _skImage,
                  context: context,
                  fileUrl: (url) {
                    _skUrl = url;
                  },
                  picFileName: _skFileName,
                  expctedImageType: 'SK Kelahiran')
              .then(
            (value) async => await FirestoreLetterServices.createSKLahir(
                address: _address.text, // done
                name: _name.text, // dene
                date: _date!, // done
                day: _date!.split(',')[0],
                hour: _time!, // done
                jk: _jk ?? '-', // done
                place: _place.text, // done
                father: _father.text, // done
                mother: _mother.text, // done
                skUrl: _skUrl ?? '', // done
                letterId: generatedId), // done
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
                  'Data Orang Tua',
                  style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 18),
                ),

                const SizedBox(
                  height: 30,
                ),

                // NAMA AYAH

                TextInputField(
                  color: widget.color,
                  controller: _father,
                  fieldName: 'Ayah',
                ),

                // NAMA AYAH

                TextInputField(
                  color: widget.color,
                  controller: _mother,
                  fieldName: 'Ibu',
                ),

                // NIK

                TextInputField(
                  color: widget.color,
                  controller: _nik,
                  fieldName: 'NIK pemohon',
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

                const Text(
                  'Data Anak',
                  style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 18),
                ),

                const SizedBox(
                  height: 30,
                ),

                // NAMA

                TextInputField(
                  color: widget.color,
                  controller: _name,
                  fieldName: 'Nama lengkap',
                ),

                // ALAMAT

                TextInputField(
                  color: widget.color,
                  controller: _address,
                  fieldName: 'Alamat lengkap',
                ),

                Gender(value: (value) {
                  _jk = value;
                }),

                const Text(
                  'Lahir pada',
                  style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 16),
                ),

                DateTimePicker(
                    color: widget.color,
                    onDateValue: (date) {
                      _date = date;
                    },
                    onTimeValue: (time) {
                      _time = time;
                    }),

                // DIMANA

                TextInputField(
                  color: widget.color,
                  controller: _place,
                  fieldName: 'Di (tempat)',
                ),

                const Text(
                  'Surat keterangan lahir',
                  style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 16),
                ),

                ImageSelector(
                  color: widget.color,
                  expectedImageType: 'SK Kelahiran',
                  fileName: _skFileName ?? '',
                  image: _skImage,
                  pickImage: () => pickImage(
                    expctedImageType: 'SK Kelahiran',
                  ),
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
