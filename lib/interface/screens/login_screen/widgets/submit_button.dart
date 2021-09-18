import 'package:flutter/material.dart';

import '../../../../services/shared_preferences.dart';
import '../../../main_app.dart';
import '../../../../services/firestore_services.dart';

class SubmitButton extends StatefulWidget {
  const SubmitButton(
      {Key? key, required this.controller, required this.validation})
      : super(key: key);
  final bool Function() validation;
  final TextEditingController controller;

  @override
  _SubmitButtonState createState() => _SubmitButtonState();
}

class _SubmitButtonState extends State<SubmitButton> {
  bool _isLoading = false;

  void submitNIK() async {
    if (widget.validation()) {
      setState(() {
        _isLoading = true;
      });
      try {
        bool userStatus = false;
        Future.delayed(const Duration(milliseconds: 500), () async {
          await FirestoreServices.validateUser(widget.controller.text)
              .then((status) {
            setState(() {
              userStatus = status;
              _isLoading = false;
            });
          });
          if (userStatus) {
            DataSharedPreferences.setNIK(widget.controller.text);
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => const MainApp(),
              ),
            );
            debugPrint('submit true executed');
          } else if (userStatus == false) {
            showDialog(
              context: context,
              builder: (_) => AlertDialog(
                content: const Text('Maaf, anda bukan warga Desa Toyareka'),
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
              ),
            );
          }
        });
      } catch (e) {
        debugPrint('error when login: $e');
      }
    }
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
            : const Text(
                'Masuk',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
      ),
    );
  }
}
