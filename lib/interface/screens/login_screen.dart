import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../services/shared_preferences.dart';
import '../main_app.dart';
import '../../services/firestore_services.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final formKey = GlobalKey<FormState>();
  final TextEditingController controller = TextEditingController();
  bool validate() {
    bool status = false;
    final form = formKey.currentState;

    if (form!.validate()) {
      form.save();
      status = true;
    } else {
      status = false;
    }
    return status;
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          height: size.height,
          width: size.width,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(
                height: 30,
              ),
              Text(
                'Silakan input NIK Anda',
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              SvgPicture.asset(
                'assets/images/card.svg',
                fit: BoxFit.cover,
                height: size.height * 0.225,
                width: size.width * 0.4,
              ),
              Form(
                key: formKey,
                child: SizedBox(
                  width: size.width * 0.75,
                  child: TextFormField(
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    validator: (nik) {
                      RegExp regExp = RegExp(r'^[1-9]+[0-9]*$');
                      if (nik == '' || nik!.isEmpty) {
                        return 'NIK tidak boleh kosong';
                      } else if (!regExp.hasMatch(nik)) {
                        return 'NIK hanya berupa angka';
                      } else if (!(nik.length == 16)) {
                        return 'NIK harus berjumlah 16';
                      } else {
                        return null;
                      }
                    },
                    controller: controller,
                    cursorColor: Theme.of(context).primaryColor,
                    decoration: InputDecoration(
                      prefixIcon: Icon(
                        Icons.person,
                        color: Theme.of(context).primaryColor,
                        size: 32,
                      ),
                      labelText: 'NIK',
                      labelStyle: TextStyle(
                        color: Theme.of(context).primaryColor.withOpacity(0.4),
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                      hintText: '33030xxxxxxxxxxx',
                      hintStyle: TextStyle(
                        color: Colors.grey[400]!.withOpacity(0.8),
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                      enabledBorder: UnderlineInputBorder(
                        borderSide:
                            BorderSide(color: Theme.of(context).primaryColor),
                      ),
                    ),
                  ),
                ),
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
                onPressed: () async {
                  if (validate()) {
                    if (await FirestoreServices.validateUser(controller.text)) {
                      DataSharedPreferences.setNIK(controller.text);
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const MainApp(),
                        ),
                      );
                      debugPrint('submit true executed');
                    } else {
                      showDialog(
                          context: context,
                          builder: (_) => AlertDialog(
                                content: const Text(
                                    'Maaf, anda bukan warga Desa Toyareka'),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: const Text(
                                      'Ok',
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  )
                                ],
                              ));
                    }
                  }
                },
                child: SizedBox(
                  width: size.width * 0.5,
                  child: const Text(
                    'Masuk',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ),
              ),
              const Text(
                'SIPPeDes - Sistem Informasi Pelayanan Persuratan Desa\nDesa Toyareka',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(
                height: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
