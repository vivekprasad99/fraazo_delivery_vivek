import 'package:get/get.dart';

import '../controller/signup_controller.dart';

class SignupBinding extends Bindings {
  @override
  void dependencies() {
    // TODO: implement dependencies
    Get.put(SignupController());
  }
}
