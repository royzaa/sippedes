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
import '../date_time_picker.dart';
import '../image_selector.dart';
import '../gender.dart';

class SuratKematian extends StatefulWidget {
  const SuratKematian({Key? key, required this.color, required this.letterName})
      : super(key: key);
  final Color color;
  final String letterName;

  @override
  State<SuratKematian> createState() => _SuratKematianState();
}

class _SuratKematianState extends State<SuratKematian> {
  final TextEditingController _address = TextEditingController();
  final TextEditingController _nik = TextEditingController();
  final TextEditingController _name = TextEditingController();
  final TextEditingController _cause = TextEditingController();
  final TextEditingController _ages = TextEditingController();
  final TextEditingController _place = TextEditingController();
  final TextEditingController _relationship = TextEditingController();
  final TextEditingController _reporterName = TextEditingController();

  String? _skFileName, _skUrl, _jk, _date, _time;
  File? skImage;

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
        if (skImage == null) {
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
                  image: skImage,
                  context: context,
                  fileUrl: _skUrl,
                  picFileName: _skFileName,
                  expctedImageType: 'SK Kematian')
              .then(
            (value) async => await FirestoreLetterServices.createSKKematian(
                address: _address.text, // done
                name: _name.text, // dene
                ages: _ages.text, // done
                cause: _cause.text, // done
                date: _date!, // done
                day: _date!.split(',')[0],
                hour: _time!, // done
                jk: _jk ?? '-', // done
                place: _place.text, // done
                relationship: _relationship.text, // done
                reporterName: _reporterName.text, // done
                skUrl: _skUrl ?? '', // done
                letterId: generatedId), // done
          );

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

                const Text(
                  'Data Pelapor',
                  style: TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                      fontSize: 18),
                ),

                const SizedBox(
                  height: 30,
                ),

                // NAMA PELAPOR

                TextInputField(
                  color: widget.color,
                  controller: _reporterName,
                  fieldName: 'Nama lengkap pelapor',
                ),

                // NIK

                TextInputField(
                  color: widget.color,
                  controller: _nik,
                  fieldName: 'NIK',
                ),

                // HUUNGAN DENGAN PELAPOR

                TextInputField(
                  color: widget.color,
                  controller: _relationship,
                  fieldName: 'Hubungan dengan mendiang',
                ),

                const Text(
                  'Data Mendiang',
                  style: TextStyle(
                      color: Colors.grey,
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
                  fieldName: 'Alamat',
                ),

                // AGES

                TextInputField(
                  color: widget.color,
                  controller: _ages,
                  fieldName: 'Usia',
                  customValidator: (value) {
                    RegExp regExp = RegExp(r'^[1-9]+[0-9]*$');
                    if (value == '' || value!.isEmpty) {
                      return 'Usia tidak boleh kosong';
                    } else if (!regExp.hasMatch(value)) {
                      return 'Usia hanya berupa angka';
                    } else {
                      return null;
                    }
                  },
                ),

                Gender(value: (value) {
                  _jk = value;
                }),

                const Text(
                  'Meninggal pada',
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
                  fieldName: 'Meninggal di',
                ),

                // CAUSE

                TextInputField(
                  color: widget.color,
                  controller: _cause,
                  fieldName: 'Penyebab',
                ),

                const Text(
                  'Surat keterangan meninggal',
                  style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 16),
                ),

                ImageSelector(
                  color: widget.color,
                  expectedImageType: 'SK Kematian',
                  fileName: _skFileName ?? '',
                  image: skImage,
                  pickImage: () => pickImage(
                      expctedImageType: 'SK Kematian',
                      fileName: _skFileName ?? '',
                      image: skImage),
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
