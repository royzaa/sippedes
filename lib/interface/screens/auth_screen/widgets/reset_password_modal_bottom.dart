import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import './dialog_box.dart';
import '../../../../services/auth_services.dart';

class ResetPasswordModalBottom extends StatefulWidget {
  const ResetPasswordModalBottom({Key? key}) : super(key: key);

  @override
  State<ResetPasswordModalBottom> createState() =>
      _ResetPasswordModalBottomState();
}

class _ResetPasswordModalBottomState extends State<ResetPasswordModalBottom> {
  final TextEditingController _resetPasswordController =
      TextEditingController();

  String _warning = '';

  bool validate() {
    final form = formKey.currentState;
    form!.save();
    if (form.validate()) {
      form.save();
      return true;
    } else {
      return false;
    }
  }

  Widget showAlert() {
    if (_warning.isNotEmpty) {
      return Container(
        color: Colors.red.shade400,
        width: double.infinity,
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            const Padding(
              padding: EdgeInsets.only(left: 10.0),
              child: Icon(Icons.error_outline),
            ),
            const SizedBox(
              width: 16.0,
            ),
            Expanded(
              child: Text(
                _warning,
                maxLines: 3,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                setState(() {
                  _warning = '';
                });
              },
            )
          ],
        ),
      );
    }
    return const SizedBox();
  }

  bool isLoading = false;

  final formKey = GlobalKey<FormState>();

  Future<void> submitResetPassword() async {
    if (validate()) {
      try {
        setState(() {
          isLoading = true;
        });

        final auth = AuthService();

        await auth.sendResetPassword(_resetPasswordController.text);
        setState(() {
          isLoading = false;
        });

        debugPrint('Request reset password sent');

        showDialog(
          context: context,
          builder: (BuildContext context) => const DialogBox(),
        );
      } on FirebaseAuthException catch (e) {
        setState(() {
          isLoading = false;
          _warning = e.message ?? 'Ooops ada sesuatu yang salah';
          debugPrint("pesan kegagalan: $_warning");
        });
        if (_warning.isNotEmpty) {
          showDialog(
            context: context,
            builder: (context) => errorDialog(e: e),
          );
        }
      }
    }
  }

  Widget errorDialog({required var e}) {
    return Dialog(
      insetAnimationCurve: Curves.easeIn,
      insetAnimationDuration: const Duration(milliseconds: 250),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(40),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Failed',
              style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.w500,
                  fontSize: 18),
            ),
            const SizedBox(
              height: 30,
            ),
            SizedBox(
                width: 300,
                child: Text(
                  e.message,
                  maxLines: 3,
                  textAlign: TextAlign.center,
                )),
            const SizedBox(
              height: 15,
            ),
            ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: Theme.of(context).primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Ok',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500),
                ),
                onPressed: () => Navigator.of(context).pop())
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget makedDismissable({required Widget child}) => GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => Navigator.of(context).pop(),
          child: GestureDetector(
            onTap: () {},
            child: child,
          ),
        );

    final Size mediaQuery = MediaQuery.of(context).size;

    return makedDismissable(
      child: DraggableScrollableSheet(
        initialChildSize: 0.15,
        maxChildSize: 0.82,
        minChildSize: 0.08,
        builder: (context, controller) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(40),
              topRight: Radius.circular(40),
            ),
          ),
          padding: const EdgeInsets.only(top: 20),
          child: ListView(
            controller: controller,
            children: [
              Column(
                children: [
                  Container(
                    width: mediaQuery.width * 0.3,
                    height: 7,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        color: Colors.grey.shade300),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  SizedBox(
                    height: mediaQuery.height * 0.1,
                    width: mediaQuery.height * 0.1,
                    child: SvgPicture.asset(
                      'assets/images/card.svg',
                      fit: BoxFit.cover,
                    ),
                  ),
                  SizedBox(
                    height: mediaQuery.height * 0.03,
                  ),
                  const Text(
                    "Reset Password",
                    style: TextStyle(
                        color: Colors.black87,
                        fontSize: 16,
                        fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  const Text(
                    'Isi form alamat email di bawah ini untuk\nreset password',
                    style: TextStyle(fontSize: 15, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(
                    height: 25,
                  ),
                  SizedBox(
                    width: mediaQuery.width * 0.625,
                    height: 55,
                    child: Form(
                      key: formKey,
                      child: TextFormField(
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        controller: _resetPasswordController,
                        validator: (String? value) =>
                            EmailValidator.validate(value),
                        onSaved: (String? value) => value,
                        cursorColor: Colors.grey,
                        decoration: InputDecoration(
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                            labelText: "Email",
                            labelStyle: const TextStyle(color: Colors.grey),
                            prefixIcon: const Icon(
                              Icons.mail,
                              color: Colors.grey,
                            ),
                            floatingLabelBehavior: FloatingLabelBehavior.auto),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 25,
                  ),
                  ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: isLoading
                            ? null
                            : const EdgeInsets.symmetric(
                                vertical: 10, horizontal: 25),
                        elevation: 0,
                        primary: Theme.of(context).primaryColor,
                        shape: isLoading
                            ? const CircleBorder()
                            : RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                      ),
                      child: isLoading
                          ? Center(
                              child: CircularProgressIndicator(
                                color: Theme.of(context).primaryColor,
                              ),
                            )
                          : const Text(
                              'Kirim permintaan',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500),
                            ),
                      onPressed:
                          isLoading ? null : () => submitResetPassword()),
                  const SizedBox(
                    height: 20,
                  ),
                  Opacity(
                    opacity: 0.15,
                    child: SvgPicture.asset(
                      "assets/images/unlock.svg",
                      width: mediaQuery.width - 40,
                      fit: BoxFit.cover,
                    ),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
