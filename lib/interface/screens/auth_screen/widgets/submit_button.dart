import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:open_mail_app/open_mail_app.dart';

import '../../../../services/shared_preferences.dart';
import '../../../main_app.dart';
import '../../../../services/firestore_services.dart';
import '../../../../services/auth_services.dart';

class SubmitButton extends StatefulWidget {
  const SubmitButton({
    Key? key,
    this.nikController,
    this.isForRegister = true,
    required this.validation,
    required this.emailController,
    required this.passwordController,
  }) : super(key: key);
  final bool Function() validation;
  final bool isForRegister;
  final TextEditingController? nikController;
  final TextEditingController emailController;
  final TextEditingController passwordController;

  @override
  _SubmitButtonState createState() => _SubmitButtonState();
}

class _SubmitButtonState extends State<SubmitButton> {
  final AuthService auth = AuthService();
  bool _isLoading = false;
  late Timer timer;
  String? nik;

  void register() async {
    try {
      await auth
          .createUserWithEmailAndPassword(
        widget.emailController.text,
        widget.passwordController.text,
      )
          .then((value) {
        if (value == null) {
          return;
        }
        final User? user = value.user;

        if (user != null) {
          auth.sendEmailVerification().then((value) {
            setState(() {
              _isLoading = false;
            });
            showDialog(
              context: context,
              builder: (_) => AlertDialog(
                title: const Text(
                  'Sukses',
                  style: TextStyle(color: Colors.black),
                ),
                content: const Text(
                  'Kami telah mengirimkan email verifikasi. Silakan buka email dan verifikasi email anda',
                  style: TextStyle(color: Colors.black),
                ),
                actions: [
                  TextButton(
                    onPressed: () async {
                      // Android: Will open mail app or show native picker.
                      // iOS: Will open mail app if single mail app found.
                      var result = await OpenMailApp.openMailApp(
                          nativePickerTitle: 'Pilih aplikasi email');

                      if (!result.didOpen && result.canOpen) {
                        setState(() {
                          _isLoading = false;
                        });
                        showDialog(
                          context: context,
                          builder: (_) {
                            return MailAppPickerDialog(
                              mailApps: result.options,
                            );
                          },
                        );
                      }
                    },
                    child: Text(
                      'Buka email',
                      style: TextStyle(color: Theme.of(context).primaryColor),
                    ),
                  )
                ],
              ),
            );
          });
        }
      });
    } on FirebaseAuthException catch (e) {
      setState(() {
        _isLoading = false;
      });
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text(
            'Gagal',
            style: TextStyle(color: Colors.black),
          ),
          content: Text(
            e.message ?? 'Oops terdapat gangguan saat registrasi',
            style: const TextStyle(color: Colors.black),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(
                'Coba lagi',
                style: TextStyle(color: Theme.of(context).primaryColor),
              ),
            )
          ],
        ),
      );
    }
  }

  Future verification(String nik) async {
    await auth.checkEmailVerification().then((value) {
      if (value == true) {
        FirestoreServices.storeUserUid(auth.getCurrentUser!.uid, nik);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const MainApp(),
          ),
        );
        timer.cancel();
      }
    });
  }

  /// validating NIK then sign in or register
  void submitNIK() async {
    if (widget.validation()) {
      setState(() {
        _isLoading = true;
      });
      try {
        if (widget.isForRegister) {
          bool isUserValidate = false;
          Future.delayed(const Duration(milliseconds: 0), () async {
            await FirestoreServices.validateUser(widget.nikController!.text)
                .then((status) {
              isUserValidate = status;
            });
            if (isUserValidate) {
              await DataSharedPreferences.setNIK(widget.nikController!.text)
                  .then(
                (value) => nik = DataSharedPreferences.getNIK(),
              );
              if (nik != null) {
                register();
              }
              debugPrint('submit true executed');
            } else if (isUserValidate == false) {
              setState(() {
                _isLoading = false;
              });
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  content: const Text(
                    'Maaf, anda bukan warga Desa Toyareka',
                    style: TextStyle(color: Colors.black),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text(
                        'Ok',
                        style: TextStyle(color: Theme.of(context).primaryColor),
                      ),
                    )
                  ],
                ),
              );
            }
          });
        } else {
          try {
            final uid = await auth.signInWithEmailAndPassword(
                widget.emailController.text, widget.passwordController.text);
            if (uid.isNotEmpty) {
              FirestoreServices.getUserProfile(uid).then((value) {
                Navigator.of(context)
                    .push(MaterialPageRoute(builder: (_) => const MainApp()));
              });
            }
          } on FirebaseAuthException catch (e) {
            setState(() {
              _isLoading = false;
            });
            showDialog(
              context: context,
              builder: (_) => AlertDialog(
                title: const Text(
                  'Gagal',
                  style: TextStyle(color: Colors.black),
                ),
                content: Text(
                  e.message ?? 'Oops terdapat masalah saat login',
                  style: const TextStyle(color: Colors.black),
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text(
                      'Coba lagi',
                      style: TextStyle(color: Theme.of(context).primaryColor),
                    ),
                  )
                ],
              ),
            );
          }
        }
      } catch (e) {
        debugPrint('error when submit register/login: $e');
      }
    }
  }

  @override
  void initState() {
    timer = Timer.periodic(const Duration(seconds: 1), (_) async {
      if (nik != null) {
        await verification(nik!);
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25),
        ),
        primary: Theme.of(context).primaryColor,
        padding: const EdgeInsets.symmetric(vertical: 15),
        shadowColor: Theme.of(context).primaryColor.withOpacity(0.25),
        elevation: 20,
      ),
      onPressed: _isLoading ? null : submitNIK,
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
            : Text(
                widget.isForRegister ? 'Registrasi' : 'Masuk',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
      ),
    );
  }
}
