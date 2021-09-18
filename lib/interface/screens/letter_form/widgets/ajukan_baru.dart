import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';

import '../../../../services/firebase_storage.dart';
import '../../../../services/shared_preferences.dart';
import '../../../../services/firestore_services.dart';
import '../../../../services/sheet_api.dart';

class AjukanBaru extends StatefulWidget {
  const AjukanBaru({Key? key, required this.color}) : super(key: key);
  final Color color;

  @override
  State<AjukanBaru> createState() => _AjukanBaruState();
}

class _AjukanBaruState extends State<AjukanBaru> {
  final TextEditingController _alamatBaru = TextEditingController();

  File? image;
  final _userNIK = DataSharedPreferences.getNIK();
  final _formKey = GlobalKey<FormState>();

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

  void pickImage() async {
    try {
      final image = await ImagePicker().pickImage(
        source: ImageSource.gallery,
      );
      if (image == null) return;

      final tempImage = File(image.path);
      setState(() {
        this.image = tempImage;
        _fileName = DataSharedPreferences.getNIK() +
            '_KTP_' +
            basename(this.image!.path);
      });
    } on PlatformException catch (e) {
      debugPrint('Error when pick image: $e');
    }
  }

  late String _fileName;
  void uploadImageToFirebase(BuildContext context) async {
    final fileName = _fileName;

    final destination = 'foto_KTP/$_userNIK/$fileName';
    await FirebaseStorageServices.uploadFile(destination, image!)!.whenComplete(
      () => ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pengajuan anda sudah terkirim'),
        ),
      ),
    );
  }

  @override
  void initState() {
    FirebaseMessaging.instance.getInitialMessage();

    debugPrint(
        'issupported: ' + FirebaseMessaging.instance.isSupported().toString());
    FirebaseMessaging.instance.requestPermission();
    FirebaseMessaging.onMessage.listen((message) {
      debugPrint('message from cloud:' + message.notification!.body.toString());
    });

    WidgetsBinding.instance!.addPostFrameCallback((timeStamp) async {
      debugPrint(
          'token: ' + (await FirebaseMessaging.instance.getToken()).toString());
    });
    super.initState();
  }

  @override
  void dispose() {
    _alamatBaru.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return Form(
      key: _formKey,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(
              height: 30,
            ),
            const Text(
              'Tulis alamat baru',
              style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 16),
            ),
            TextFormField(
              autovalidateMode: AutovalidateMode.onUserInteraction,
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Alamat tidak boleh kosong';
                }
                return null;
              },
              controller: _alamatBaru,
              decoration: const InputDecoration(
                label: Text('Alamat baru'),
              ),
            ),
            const SizedBox(
              height: 30,
            ),
            const Text(
              'Pilih foto KTP',
              style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 16),
            ),
            Container(
              width: size.width * 0.65,
              decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.black,
                    width: 1,
                  ),
                  shape: BoxShape.rectangle),
              padding: const EdgeInsets.all(9),
              margin: const EdgeInsets.symmetric(vertical: 15),
              child: Column(
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      primary: widget.color,
                      minimumSize: const Size(double.infinity, 30),
                    ),
                    onPressed: pickImage,
                    child: Text(
                      image == null ? 'Pilih foto KTP' : 'Ganti foto KTP',
                      style: const TextStyle(color: Colors.black),
                    ),
                  ),
                  image == null
                      ? const SizedBox()
                      : Text(
                          _fileName,
                        ),
                ],
              ),
            ),
            const SizedBox(
              height: 30,
            ),
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  elevation: 30,
                  shadowColor: widget.color.withOpacity(0.5),
                  primary: Colors.black,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 28, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                onPressed: () async {
                  if (validate()) {
                    if (image == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Foto KTP harus diisi'),
                          duration: Duration(seconds: 3),
                        ),
                      );
                    } else {
                      uploadImageToFirebase(context);
                      await FirestoreServices.changeProfileField(
                          _userNIK, 'Alamat', _alamatBaru.text);
                      await SheetApi.updateData(
                          rowKey: DataSharedPreferences.getUserName(),
                          columnKey: 'Alamat',
                          newValue: _alamatBaru.text);
                    }
                  }
                },
                child: Text(
                  'Simpan dan ajukan',
                  style: TextStyle(
                    color: widget.color,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}