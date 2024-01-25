import 'package:flutter/material.dart';

class HomeButtonTabProvider extends ChangeNotifier {
  List<bool> isSelectedButton = [true, false];
  void selectButton(int index) {
    if (index == 0) {
      isSelectedButton = [true, false];
    } else {
      isSelectedButton = [false, true];
    }
    notifyListeners();
  }
}
