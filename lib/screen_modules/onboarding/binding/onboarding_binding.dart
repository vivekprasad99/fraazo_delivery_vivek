import 'package:get/get.dart';

import '../controller/onboarding_controller.dart';

class OnBoarding extends Bindings {
  @override
  void dependencies() {
    // TODO: implement dependencies
    Get.create(() => OnBoardingController());
  }
}
