import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

void displayToastMessage(String msg) {
  Fluttertoast.showToast(
    msg: "$msg",
    gravity: ToastGravity.BOTTOM,
    timeInSecForIosWeb: 1,
    backgroundColor: Colors.black87,
    textColor: Colors.white,
    fontSize: 16.0,
  );
}
