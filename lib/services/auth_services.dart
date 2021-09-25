import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  Stream<String> get authStateChanged =>
      _firebaseAuth.authStateChanges().map((User? user) {
        if (user != null) {
          return user.uid;
        } else {
          return '';
        }
      });

  /// get the current user
  User? get getCurrentUser => _firebaseAuth.currentUser;

  Future<UserCredential?> createUserWithEmailAndPassword(
    String email,
    String password,
  ) async {
    debugPrint('createUserWithEmailAndPassword...');
    UserCredential? userCredential;
    await _firebaseAuth
        .createUserWithEmailAndPassword(email: email, password: password)
        .then((value) => userCredential = value);
    debugPrint(
        'createUserWithEmailAndPassword... with user credential: $userCredential');
    return userCredential;
  }

  Future<void> sendEmailVerification() async {
    User? user = _firebaseAuth.currentUser;
    if (user != null) {
      await _firebaseAuth.currentUser!.sendEmailVerification();
    }
  }

  Future<bool> checkEmailVerification() async {
    bool status = false;
    User? user = _firebaseAuth.currentUser;
    await user!.reload();
    status = user.emailVerified;
    return status;
  }

  Future<String> signInWithEmailAndPassword(
          String email, String password) async =>
      (await _firebaseAuth.signInWithEmailAndPassword(
              email: email, password: password))
          .user!
          .uid;

  void sendResetPassword(String email) async =>
      _firebaseAuth.sendPasswordResetEmail(email: email);

  void signOut() => _firebaseAuth.signOut();
}

class EmailValidator {
  static String? validate(String? email) {
    if (email == '' || email!.isEmpty) {
      return 'Email tidak boleh kosong';
    } else {
      return null;
    }
  }
}

class NikValidator {
  static String? validate(String? nik) {
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
  }
}

class PasswordValidator {
  static String? validate(String? password) {
    RegExp regExp = RegExp(r'^(?=.*[A-Z])(?=.*[a-z])(?=.*?[0-9])');
    if (password == '' || password!.isEmpty) {
      return 'Password tidak boleh kosong';
    } else if (!regExp.hasMatch(password)) {
      return 'Password harus memiliki huruf besar, kecil, dan angka';
    } else if (password.length < 8) {
      return 'Password minimal berjumlah 8 digit';
    } else {
      return null;
    }
  }
}
