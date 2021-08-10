import 'package:flutter/material.dart';

class MainProvider extends ChangeNotifier {
  bool _busy = false;

  bool get busy => _busy;

  setBusy(bool val) {
    _busy = val;
    notifyListeners();
  }
}
