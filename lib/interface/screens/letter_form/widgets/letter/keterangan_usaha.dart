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
import '../birth.dart';
import '../ktp.dart';

class KeteranganUsaha extends StatefulWidget {
  const KeteranganUsaha(
      {Key? key, required this.color, required this.letterName})
      : super(key: key);
  final Color color;
  final String letterName;

  @override
  State<KeteranganUsaha> createState() => KeteranganUsahaState();
}

class KeteranganUsahaState extends State<KeteranganUsaha> {
  final TextEditingController _address = TextEditingController();
  final TextEditingController _name = TextEditingController();
  final TextEditingController _lamaUsaha = TextEditingController();
  final TextEditingController _nik =
      TextEditingController(text: DataSharedPreferences.getNIK());
  final TextEditingController _jenisUsaha = TextEditingController();
  final TextEditingController _phone = TextEditingController();
  final TextEditingController _tempatUsaha = TextEditingController();

  String? _ktpFileName, _ktpUrl, _ttgl;
  File? _ktpImage;

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
        _ktpImage = tempImage;
        _ktpFileName = DataSharedPreferences.getNIK() +
            '_${expctedImageType}_' +
            basename(_ktpImage!.path);
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
        if (_ktpImage == null) {
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
                  image: _ktpImage,
                  context: context,
                  fileUrl: (url) {
                    _ktpUrl = url;
                  },
                  picFileName: _ktpFileName,
                  expctedImageType: 'KTP')
              .then(
            (value) async => await FirestoreLetterServices.createSKUsaha(
                address: _address.text, // done
                ktpUrl: _ktpUrl ?? 'Belum diisi', // done
                name: _name.text, // dene
                ttgl: _ttgl ?? 'Belum diisi', // done
                jenisUsaha: _jenisUsaha.text,
                lamaUsaha: _lamaUsaha.text,
                phone: _phone.text,
                tempatUsaha: _tempatUsaha.text,
                nik: _nik.text, // dine
                letterId: generatedId), // done
          );
          await FirestoreLetterServices.writeLetterStatus(
              letterId: generatedId,
              letterType: LetterType.keteranganUsaha,
              registredNIK: DataSharedPreferences.getNIK());
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

                // TTGL

                Birth(
                  color: widget.color,
                  onValue: (ttgl) {
                    _ttgl = ttgl;
                  },
                ),

                // ALAMAT

                TextInputField(
                  color: widget.color,
                  controller: _address,
                  fieldName: 'Alamat sesuai KTP',
                ),

                // JENIS USAHA

                TextInputField(
                  color: widget.color,
                  controller: _jenisUsaha,
                  fieldName: 'Jenius usaha',
                ),

                // LAMA USAHA

                TextInputField(
                  color: widget.color,
                  controller: _lamaUsaha,
                  fieldName: 'Lama usaha',
                ),

                // TEMPAT USAHA

                TextInputField(
                  color: widget.color,
                  controller: _tempatUsaha,
                  fieldName: 'Tempat usaha',
                ),

                // PHONEE

                TextInputField(
                  color: widget.color,
                  controller: _phone,
                  fieldName: 'Nomor hp',
                  customValidator: (value) {
                    RegExp regExp = RegExp(r'^[1-9]+[0-9]*$');
                    if (value == '' || value!.isEmpty) {
                      return 'No hp tidak boleh kosong';
                    } else if (!regExp.hasMatch(value)) {
                      return 'No hp hanya berupa angka';
                    } else {
                      return null;
                    }
                  },
                ),

                // KTP
                Ktp(
                  ktpFileName: _ktpFileName ?? '',
                  color: widget.color,
                  image: _ktpImage,
                  pickImage: () => pickImage(
                    expctedImageType: 'KTP',
                  ),
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
