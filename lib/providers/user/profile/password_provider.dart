import 'package:flutter/material.dart';

class PasswordProvider extends ChangeNotifier {
  bool isEnabled = false;
  void isButtonEnable(bool isFilled) {
    isEnabled = isFilled;
    notifyListeners();
  }
}
