import 'package:flutter/material.dart';

import './text_input_field.dart';

class Followers extends StatefulWidget {
  const Followers({Key? key}) : super(key: key);

  @override
  _FollowersState createState() => _FollowersState();
}

class _FollowersState extends State<Followers> {
  final _noKK = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey();

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

  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          color: Colors.white,
        ),
        child: Column(
          children: [
            const Text(
              "Cari keluargamu",
              style: TextStyle(
                  color: Colors.black87,
                  fontSize: 16,
                  fontWeight: FontWeight.w600),
            ),
            const SizedBox(
              height: 15,
            ),
            const Text(
              'Isi no KK, kami carikan kerabatmu \nyang akan ikut berpindah',
              style: TextStyle(fontSize: 15, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(
              height: 25,
            ),
            Form(
              key: _formKey,
              child: TextInputField(
                color: Theme.of(context).primaryColor,
                controller: _noKK,
                suffixIcon: Icon(
                  Icons.search,
                  color: Theme.of(context).primaryColor,
                ),
                inputType: TextInputType.phone,
                fieldName: 'Input nomer KK',
                customValidator: (value) {
                  RegExp regExp = RegExp(r'^[1-9]+[0-9]*$');
                  if (value == '' || value!.isEmpty) {
                    return 'Nomor KK tidak boleh kosong';
                  } else if (!regExp.hasMatch(value)) {
                    return 'Nomor KK hanya berupa angka';
                  } else if (!(value.length == 16)) {
                    return 'Nomor KK berjumlah 16 digit';
                  } else {
                    return null;
                  }
                },
              ),
            ),
            const SizedBox(
              height: 30,
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                primary: Theme.of(context).primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shadowColor: Theme.of(context).primaryColor.withOpacity(0.25),
                elevation: 20,
              ),
              onPressed: () {},
              //  _isLoading ? null : submitNIK,
              child: SizedBox(
                width: size.width * 0.5,
                height: 28,
                child: _isLoading
                    ? const Center(
                        child: SizedBox(
                          width: 28,
                          child: CircularProgressIndicator(
                            color: Colors.grey,
                          ),
                        ),
                      )
                    : const Text(
                        'Cari',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
