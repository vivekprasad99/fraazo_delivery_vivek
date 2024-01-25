import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fraazo_delivery/helpers/extensions/text_editing_controller_extension.dart';
import 'package:fraazo_delivery/providers/user/profile/password_provider.dart';
import 'package:fraazo_delivery/providers/user/profile/user_profile_provider.dart';
import 'package:fraazo_delivery/ui/global_widgets/new_app_bar.dart';
import 'package:fraazo_delivery/ui/global_widgets/new_fd_textfield.dart';
import 'package:fraazo_delivery/ui/global_widgets/new_primary_button.dart';
import 'package:fraazo_delivery/ui/utils/textview.dart';
import 'package:fraazo_delivery/ui/utils/toast.dart';
import 'package:fraazo_delivery/ui/utils/widgets_and_attributes.dart';
import 'package:fraazo_delivery/utils/utils.dart';
import 'package:fraazo_delivery/values/custom_colors.dart';
import 'package:get/get.dart';

class SetPasswordScreen extends StatefulWidget {
  const SetPasswordScreen({Key? key}) : super(key: key);

  @override
  State<SetPasswordScreen> createState() => _SetPasswordScreenState();
}

class _SetPasswordScreenState extends State<SetPasswordScreen> {
  final _passwordProvider = ChangeNotifierProvider((ref) => PasswordProvider());

  final _passwordTEC = TextEditingController();
  final _confirmPasswordTEC = TextEditingController();

  @override
  void initState() {
    super.initState();
    _passwordTEC.addListener(_onTextChangeListener);
    _confirmPasswordTEC.addListener(_onTextChangeListener);
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarBrightness: Brightness.dark,
    ));
    return Scaffold(
      backgroundColor: primaryBlackColor,
      appBar: const NewAppBar(
        isShowLogout: true,
      ),
      body: Container(
          padding: const EdgeInsets.only(left: px_24, right: px_24, top: px_24),
          height: Get.height,
          width: Get.width,
          decoration: const BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(px_16),
                  topRight: Radius.circular(px_16))),
          child: _buildBody()),
    );
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      child: Column(
        children: [
          TextView(
              title: "Set Password",
              textStyle: commonTextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.white)),
          sizedBoxH6,
          TextView(
              title: "Secure your account with a 6 digit Password",
              textStyle: commonTextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                  color: lightBlackTxtColor)),
          sizedBoxH30,
          NewFDTextField(
            controller: _passwordTEC,
            labelText: "Password*",
            maxLength: 6,
            shouldHideText: true,
            spacing: 2,
          ),
          sizedBoxH30,
          NewFDTextField(
            controller: _confirmPasswordTEC,
            labelText: "Confirm Password*",
            maxLength: 6,
            shouldHideText: true,
            spacing: 2,
          ),
          sizedBoxH30,
          Consumer(
            builder: (_, watch, __) {
              final password = watch(_passwordProvider);
              //final isValid = watch(_isOTPValidProvider).state;
              //final otpVerificationAsyncValue = watch(_otpVerificationProvider);
              return NewPrimaryButton(
                buttonTitle: 'Continue',
                isActive: password.isEnabled,
                activeColor: buttonColor,
                inactiveColor: buttonInActiveColor,
                buttonRadius: px_8,
                onPressed: _onContinueTap,
                //onPressed: isValid ? _onSubmitTap : null,
              );
            },
          ),
        ],
      ),
    );
  }

  Future _onContinueTap() async {
    if (_areFieldsValid()) {
      await context
          .read(userProfileProvider.notifier)
          .setPassword(_passwordTEC.text);
      Toast.info("Password added Successfully");
    }
  }

  bool _areFieldsValid() {
    if (!_passwordTEC.isEqLength(6) || !_confirmPasswordTEC.isEqLength(6)) {
      Toast.normal("Password and Confirm password must be 6-digit long.");
      return false;
    }
    if (_passwordTEC.trim != _confirmPasswordTEC.trim) {
      Toast.normal("Password and Confirm password must be same.");
      return false;
    }
    return true;
  }

  Future _onTextChangeListener() async {
    if (_passwordTEC.text.isNotEmpty && _confirmPasswordTEC.text.isNotEmpty) {
      context.read(_passwordProvider).isButtonEnable(true);
    } else {
      context.read(_passwordProvider).isButtonEnable(false);
    }
  }

  @override
  void dispose() {
    _passwordTEC.dispose();
    _confirmPasswordTEC.dispose();
    super.dispose();
  }
}
