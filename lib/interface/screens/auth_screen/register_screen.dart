import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import './widgets/submit_button.dart';
import '../../../services/auth_services.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final formKey = GlobalKey<FormState>();
  final TextEditingController _nikController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final ValueNotifier<bool> _isPasswordNotVisible = ValueNotifier(true);

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
    _nikController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
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
          width: size.width,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                height: MediaQuery.of(context).padding.top + 30,
              ),
              Text(
                'Silakan lengkapi formulir',
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(
                height: 20,
              ),
              SvgPicture.asset(
                'assets/images/card.svg',
                fit: BoxFit.cover,
                height: size.height * 0.225,
                width: size.width * 0.4,
              ),
              const SizedBox(
                height: 20,
              ),
              Form(
                key: formKey,
                child: SizedBox(
                  width: size.width * 1,
                  child: Column(
                    children: [
                      TextFormField(
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        validator: (value) {
                          return NikValidator.validate(value);
                        },
                        controller: _nikController,
                        cursorColor: Theme.of(context).primaryColor,
                        decoration: InputDecoration(
                          helperText: '',
                          prefixIcon: Icon(
                            Icons.person,
                            color: Theme.of(context).primaryColor,
                            size: 32,
                          ),
                          labelText: 'NIK',
                          labelStyle: TextStyle(
                            color:
                                Theme.of(context).primaryColor.withOpacity(0.4),
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
                            borderSide: BorderSide(
                                color: Theme.of(context).primaryColor),
                          ),
                        ),
                      ),
                      TextFormField(
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        validator: (value) {
                          return EmailValidator.validate(value);
                        },
                        controller: _emailController,
                        cursorColor: Theme.of(context).primaryColor,
                        decoration: InputDecoration(
                          helperText: '',
                          prefixIcon: Icon(
                            Icons.email,
                            color: Theme.of(context).primaryColor,
                            size: 32,
                          ),
                          labelText: 'Email',
                          labelStyle: TextStyle(
                            color:
                                Theme.of(context).primaryColor.withOpacity(0.4),
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                          hintText: 'youremail@mail.com',
                          hintStyle: TextStyle(
                            color: Colors.grey[400]!.withOpacity(0.8),
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                          ),
                          floatingLabelBehavior: FloatingLabelBehavior.always,
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                                color: Theme.of(context).primaryColor),
                          ),
                        ),
                      ),
                      ValueListenableBuilder(
                        valueListenable: _isPasswordNotVisible,
                        builder: (context, bool isPasswordVisible, _) {
                          return TextFormField(
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            validator: (value) {
                              return PasswordValidator.validate(value);
                            },
                            obscureText: _isPasswordNotVisible.value,
                            controller: _passwordController,
                            cursorColor: Theme.of(context).primaryColor,
                            decoration: InputDecoration(
                              helperText: '',
                              suffixIcon: IconButton(
                                onPressed: () {
                                  _isPasswordNotVisible.value =
                                      !_isPasswordNotVisible.value;
                                },
                                icon: _isPasswordNotVisible.value
                                    ? const Icon(
                                        Icons.visibility,
                                        color: Colors.grey,
                                      )
                                    : Icon(
                                        Icons.visibility_off,
                                        color: Theme.of(context).primaryColor,
                                      ),
                              ),
                              prefixIcon: Icon(
                                Icons.lock,
                                color: Theme.of(context).primaryColor,
                                size: 32,
                              ),
                              labelText: 'Password',
                              labelStyle: TextStyle(
                                color: Theme.of(context)
                                    .primaryColor
                                    .withOpacity(0.4),
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                              hintText: 'xxxxxxxx',
                              hintStyle: TextStyle(
                                color: Colors.grey[400]!.withOpacity(0.8),
                                fontWeight: FontWeight.w500,
                                fontSize: 14,
                              ),
                              floatingLabelBehavior:
                                  FloatingLabelBehavior.always,
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                    color: Theme.of(context).primaryColor),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 35),
              SubmitButton(
                nikController: _nikController,
                emailController: _emailController,
                passwordController: _passwordController,
                validation: validate,
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: size.width * 0.85,
                child: const FittedBox(
                  child: Text(
                    'SIPPeDes - Sistem Informasi Pelayanan Persuratan Desa\nDesa Toyareka',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
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
