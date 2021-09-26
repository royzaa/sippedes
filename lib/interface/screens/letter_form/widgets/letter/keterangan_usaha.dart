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
  final TextEditingController _nik = TextEditingController();
  final TextEditingController _jenisUsaha = TextEditingController();
  final TextEditingController _phone = TextEditingController();
  final TextEditingController _tempatUsaha = TextEditingController();

  String? _ktpFileName, _ktpUrl, _ttgl;
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
        SnackBar(
          content: Text('Dokumen $fileName sudah terkirim'),
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
                  image: ktpImage,
                  context: context,
                  fileUrl: _ktpUrl,
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
                  fieldName: 'Alamat',
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
