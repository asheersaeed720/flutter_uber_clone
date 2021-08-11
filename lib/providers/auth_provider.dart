import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_uber_clone/main.dart';
import 'package:flutter_uber_clone/models/user.dart';
import 'package:flutter_uber_clone/providers/main_provider.dart';
import 'package:flutter_uber_clone/screens/main_screen.dart';
import 'package:flutter_uber_clone/utils/display_toast_message.dart';

class AuthProvider extends MainProvider {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  bool _obscureText = true;
  bool get obscureText => _obscureText;
  set obscureText(bool newVal) {
    _obscureText = newVal;
    notifyListeners();
  }

  UserFormData _userFormData = UserFormData();
  UserFormData get userFormData => _userFormData;
  set userFormData(UserFormData newUserFormData) {
    _userFormData = newUserFormData;
    notifyListeners();
  }

  void loginUser(context) async {
    setBusy(true);
    final User? firebaseUser = (await _firebaseAuth
            .signInWithEmailAndPassword(
                email: userFormData.email ?? '', password: userFormData.password ?? '')
            .catchError(
      (errMsg) {
        log('$errMsg');
        setBusy(false);
        displayToastMessage('Error $errMsg');
      },
    ))
        .user;

    if (firebaseUser != null) {
      userRef.child(firebaseUser.uid).once().then((DataSnapshot snap) {
        if (snap.value != null) {
          Navigator.of(context).pushNamedAndRemoveUntil(MainScreen.routeName, (route) => false);

          Future.delayed(const Duration(seconds: 1), () {
            displayToastMessage('Success');
          });
        } else {
          _firebaseAuth.signOut();
          displayToastMessage('No Record Exist');
        }
      });
    } else {
      displayToastMessage('Error Occured');
    }
    setBusy(false);
  }

  void registerNewUser(context) async {
    setBusy(true);
    final User? firebaseUser = (await _firebaseAuth
            .createUserWithEmailAndPassword(
                email: userFormData.email ?? '', password: userFormData.password ?? '')
            .catchError(
      (errMsg) {
        log('$errMsg');
        setBusy(false);
        displayToastMessage('Error $errMsg');
      },
    ))
        .user;

    if (firebaseUser != null) {
      Map userData = {
        "name": userFormData.name,
        "email": userFormData.email,
        "phone": userFormData.mobileNo,
      };
      userRef.child(firebaseUser.uid).set(userData);
      Navigator.of(context).pushNamedAndRemoveUntil(MainScreen.routeName, (route) => false);
      Future.delayed(const Duration(seconds: 1), () {
        displayToastMessage('Welcome, ${userFormData.name}');
      });
    } else {
      displayToastMessage('New User has not been created');
    }
    setBusy(false);
  }
}

final authProvider = ChangeNotifierProvider((ref) => AuthProvider());
