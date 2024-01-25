import 'package:flutter/material.dart';

extension TextEditingControllerX on TextEditingController {
  String get trim => text.trim();
  bool isEqLength(int length) => trim.length == length;
  bool hasGtLength(int length) => trim.length > length;
  bool hasLtLength(int length) => trim.length < length;

  bool get isBlank => trim.isEmpty;
  bool get isNotBlank => trim.isNotEmpty;
  bool get isEmpty => text.isEmpty;
  bool get isNotEmpty => text.isNotEmpty;
  set anyText(Object? newValue) => text = newValue?.toString() ?? "";
}
