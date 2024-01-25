import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

class SignupController extends GetxController {
  TextEditingController mobileEditingController = TextEditingController();
  RxBool isValidNo = false.obs;

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    mobileEditingController.addListener(() {});
  }
}
