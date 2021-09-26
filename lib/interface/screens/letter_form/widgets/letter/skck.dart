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
import '../image_selector.dart';
import '../relationship_status.dart';
import '../religion.dart';
import '../birth.dart';

class Skck extends StatefulWidget {
  const Skck({Key? key, required this.color, required this.letterName})
      : super(key: key);
  final Color color;
  final String letterName;

  @override
  State<Skck> createState() => _SkckState();
}

class _SkckState extends State<Skck> {
  final TextEditingController _address = TextEditingController();
  final TextEditingController _name = TextEditingController();
  final TextEditingController _job = TextEditingController();
  final TextEditingController _religion = TextEditingController();
  final TextEditingController _necessity = TextEditingController();
  final TextEditingController _nik = TextEditingController();
  final TextEditingController _nationality = TextEditingController();
  String? _ktpFileName, _ktpUrl, _ttgl, _relationshipStatus;
  File? image;

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
        if (image == null) {
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
                  image: image,
                  context: context,
                  fileUrl: _ktpUrl,
                  picFileName: _ktpFileName,
                  expctedImageType: 'KTP')
              .then(
            (value) async => await FirestoreLetterServices.createSKCK(
                address: _address.text, // done
                ktpUrl: _ktpUrl ?? 'Belum diisi', // done
                name: _name.text, // dene
                ttgl: _ttgl ?? 'Belum diisi', // done
                nationality: _nationality.text, // done
                relationshipStatus:
                    _relationshipStatus ?? 'Belum diisi', // done
                religion: _religion.text, // done
                job: _job.text, // done
                necessity: _necessity.text, // done
                nik: _nik.text, // dine
                letterId: generatedId), // done
          );
          await FirestoreLetterServices.writeLetterStatus(
              letterId: generatedId,
              letterType: LetterType.skck,
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

                // PENDIDIKAN

                Religion(religion: _religion),

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

                // ALASAN PINDAH

                TextInputField(
                  color: widget.color,
                  controller: _necessity,
                  fieldName: 'Keperluan',
                ),

                // KTP

                const Text(
                  'Ambil foto KTP',
                  style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 16),
                ),
                ImageSelector(
                  color: widget.color,
                  expectedImageType: 'KTP',
                  fileName: _ktpFileName ?? '',
                  image: image,
                  pickImage: () => pickImage(
                    image: image,
                    expctedImageType: 'KTP',
                    fileName: _ktpFileName ?? '',
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
