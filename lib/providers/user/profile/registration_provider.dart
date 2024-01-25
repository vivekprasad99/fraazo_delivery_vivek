import 'package:flutter/material.dart';

class RegistrationProvider extends ChangeNotifier {
  bool isChecked = false;
  int _index = 0;
  int get getIndexValue => _index;

  void isCheckedBox(bool value, int index) {
    _index = index;
    isChecked = value;
    notifyListeners();
  }
}
