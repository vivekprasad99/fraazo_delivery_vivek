import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fraazo_delivery/helpers/extensions/text_editing_controller_extension.dart';
import 'package:fraazo_delivery/ui/global_widgets/container_box.dart';
import 'package:fraazo_delivery/ui/global_widgets/mobile_input_text.dart';
import 'package:fraazo_delivery/ui/global_widgets/new_app_bar.dart';
import 'package:fraazo_delivery/ui/global_widgets/new_primary_button.dart';
import 'package:fraazo_delivery/ui/utils/textview.dart';
import 'package:fraazo_delivery/utils/utils.dart';
import 'package:get/get.dart';

import '../../../providers/user/login/login_provider.dart';
import '../../../providers/user/login/signup_provider.dart';
import '../../../ui/utils/widgets_and_attributes.dart';
import '../../../values/custom_colors.dart';

class NewSignUpPage extends StatefulWidget {
  const NewSignUpPage({Key? key}) : super(key: key);

  @override
  State<NewSignUpPage> createState() => _NewSignUpPageState();
}

class _NewSignUpPageState extends State<NewSignUpPage> {
  final _isPhoneValidProvider = StateProvider.autoDispose((_) => false);
  final _signupProvider =
      StateNotifierProvider.autoDispose((_) => SignupProvider());
  final _phoneTEC = TextEditingController();
  final _phoneFN = FocusNode();
  final _loginProvider =
      StateNotifierProvider.autoDispose((_) => LoginProvider());

  List<Map<String, String>> gridData = [];

  @override
  void initState() {
    super.initState();
    gridData.add({"text": "Free Registration", "icon": "bike"});
    gridData.add({"text": "Earn up to 30,000", "icon": "wallet"});
    gridData.add({"text": "On Time Payouts", "icon": "money"});
    gridData.add({"text": "Performance Rewards", "icon": "award"});
    _phoneTEC.addListener(() {
      context.read(_isPhoneValidProvider.notifier).state =
          _phoneTEC.isEqLength(10);
    });
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarBrightness: Brightness.dark,
    ));
    return Scaffold(
      backgroundColor: primaryBlackColor,
      appBar: const NewAppBar(),
      body: Container(
        padding: const EdgeInsets.only(left: px_24, right: px_24, top: px_24),
        height: Get.height,
        width: Get.width,
        decoration: const BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(px_16),
                topRight: Radius.circular(px_16))),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextView(
                  title: 'Hello Partner',
                  textStyle: commonTextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.white)),
              const SizedBox(
                height: 5,
              ),
              TextView(
                  title: 'Please Enter your mobile number',
                  textStyle: commonTextStyle(
                      fontSize: 14,
                      color: lightBlackTxtColor,
                      fontWeight: FontWeight.w400)),
              MobileInputText(
                onChangeValue: (value) {
                  print('onChangeValue $value');
                },
                textEditingController: _phoneTEC,
              ),
              Container(
                  margin: const EdgeInsets.only(top: px_22),
                  child: Consumer(builder: (_, watch, __) {
                    final bool isValid = watch(_isPhoneValidProvider).state;
                    final loginAsyncValue = watch(_signupProvider);
                    return NewPrimaryButton(
                      activeColor: buttonColor,
                      inactiveColor: buttonInActiveColor,
                      buttonRadius: px_8,
                      isActive: isValid,
                      isLoading: loginAsyncValue is AsyncLoading,
                      buttonTitle: 'Request OTP',
                      onPressed: () {
                        // context
                        //     .read(_loginProvider.notifier)
                        //     .loginByMobileNo(_phoneTEC.text);
                        context.read(_signupProvider.notifier).signUpUser(
                            isRevamp: true,
                            isResend: true,
                            phoneNo: _phoneTEC.text);
                      },
                    );
                  })),
              TextView(
                  title: 'Why you should join Fraazo?',
                  margin: const EdgeInsets.only(top: px_60),
                  textStyle: commonTextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Colors.white)),
              const SizedBox(
                height: px_18,
              ),
              GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisSpacing: px_12,
                      mainAxisSpacing: px_20,
                      crossAxisCount: 2),
                  itemCount: gridData.length,
                  shrinkWrap: true,
                  itemBuilder: (builder, index) {
                    Map<String, String> data = gridData[index];
                    return ContainerBox(
                      label: data['text'],
                      imagePath: data['icon'],
                    );
                  })
            ],
          ),
        ),
      ),
    );
  }
}
