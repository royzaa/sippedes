import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';

import '../../../../services/firebase_storage.dart';
import '../../../../services/shared_preferences.dart';
import '../../../../services/firestore_services.dart';
import '../../../../services/sheet_api.dart';

class AjukanBaru extends StatefulWidget {
  const AjukanBaru({Key? key}) : super(key: key);

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
      final image = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (image == null) return;

      final tempImage = File(image.path);
      setState(() {
        this.image = tempImage;
      });
    } on PlatformException catch (e) {
      debugPrint('Error when pick image: $e');
    }
  }

  void uploadImageToFirebase(BuildContext context) async {
    final fileName = basename(image!.path);

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
              height: 30,
              decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.black,
                    width: 1,
                  ),
                  shape: BoxShape.rectangle),
              padding: const EdgeInsets.all(8),
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: image == null
                  ? ElevatedButton(
                      onPressed: pickImage,
                      child: const Text('Pilih gambar'),
                    )
                  : Text(
                      basename(image!.path),
                    ),
            ),
            Center(
              child: ElevatedButton(
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
                child: const Text('Simpan dan ajukan'),
              ),
            )
          ],
        ),
      ),
    );
  }
}
