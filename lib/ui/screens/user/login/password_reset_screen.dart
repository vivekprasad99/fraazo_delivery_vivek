import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fraazo_delivery/helpers/extensions/text_editing_controller_extension.dart';
import 'package:fraazo_delivery/helpers/route/route_helper.dart';
import 'package:fraazo_delivery/helpers/route/routes.dart';
import 'package:fraazo_delivery/providers/user/login/password_reset_provider.dart';
import 'package:fraazo_delivery/ui/global_widgets/new_app_bar.dart';
import 'package:fraazo_delivery/ui/global_widgets/new_fd_textfield.dart';
import 'package:fraazo_delivery/ui/global_widgets/new_primary_button.dart';
import 'package:fraazo_delivery/ui/utils/textview.dart';
import 'package:fraazo_delivery/ui/utils/toast.dart';
import 'package:fraazo_delivery/ui/utils/widgets_and_attributes.dart';
import 'package:fraazo_delivery/utils/utils.dart';
import 'package:fraazo_delivery/values/custom_colors.dart';
import 'package:get/get.dart';
import 'package:sms_autofill/sms_autofill.dart';

class PasswordResetScreen extends StatefulWidget {
  final String phoneNumber;
  const PasswordResetScreen(this.phoneNumber);
  @override
  _PasswordResetScreenState createState() => _PasswordResetScreenState();
}

class _PasswordResetScreenState extends State<PasswordResetScreen> {
  final _passwordResetProvider =
      StateNotifierProvider.autoDispose((_) => PasswordResetProvider());

  final _otpTEC = TextEditingController();
  final _passwordTEC = TextEditingController();
  final _confirmPasswordTEC = TextEditingController();

  @override
  void initState() {
    super.initState();
    _callForgotPasswordApi();
    _listenForOTPCodeOnAndroid();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // body: SafeArea(
      //   child: _buildBody(),
      // ),
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
            topRight: Radius.circular(px_16),
          ),
        ),
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // const IconButton(
          //   icon: Icon(
          //     Icons.arrow_back,
          //   ),
          //   onPressed: RouteHelper.pop,
          // ),
          _buildOTPAreaWidget(),
        ],
      ),
    );
  }

  Widget _buildOTPAreaWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextView(
            title: 'Update your password',
            textStyle: commonTextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.white)),
        sizedBoxH10,
        Text(
          "Enter OTP code sent to +91 ${widget.phoneNumber} and your new password",
          style: commonTextStyle(
            color: lightBlackTxtColor,
          ),
        ),
        sizedBoxH20,
        NewFDTextField(
          controller: _otpTEC,
          labelText: "Enter 6-digit OTP",
          maxLength: 6,
          isNumber: true,
          spacing: 2,
        ),
        sizedBoxH20,
        Text(
          "Please enter your new 6-digit password below.",
          style: commonTextStyle(color: lightBlackTxtColor),
        ),
        sizedBoxH10,
        NewFDTextField(
          controller: _passwordTEC,
          labelText: "Enter New 6-digit Password",
          maxLength: 6,
          shouldHideText: true,
          spacing: 2,
        ),
        sizedBoxH20,
        NewFDTextField(
          controller: _confirmPasswordTEC,
          labelText: "Confirm 6-digit Password",
          maxLength: 6,
          shouldHideText: true,
          spacing: 2,
        ),
        sizedBoxH30,
        Consumer(
          builder: (_, watch, __) {
            //final isValid = watch(_isOTPValidProvider).state;
            //final otpVerificationAsyncValue = watch(_otpVerificationProvider);
            return NewPrimaryButton(
              buttonTitle: 'Submit',
              isActive: true,
              activeColor: buttonColor,
              inactiveColor: buttonInActiveColor,
              buttonRadius: px_8,
              onPressed: _onSubmitTap,
              // onPressed: isValid ? _onSubmitTap : null,
            );
          },
        ),
        // Consumer(
        //   builder: (_, watch, __) {
        //     final otpVerificationAsyncValue = watch(_passwordResetProvider);
        //     return PrimaryButton(
        //       text: "Submit",
        //       isLoading: otpVerificationAsyncValue is AsyncLoading,
        //       onPressed: _onSubmitTap,
        //     );
        //   },
        // ),
      ],
    );
  }

  void _listenForOTPCodeOnAndroid() {
    if (Platform.isAndroid) {
      SmsAutoFill().code.listen((String code) {
        _otpTEC.text = code;
      });
    }
  }

  Future _onSubmitTap() async {
    if (_areFieldsValid()) {
      await context.read(_passwordResetProvider.notifier).updatePassword(
            mobileNo: widget.phoneNumber,
            otp: _otpTEC.trim,
            password: _confirmPasswordTEC.trim,
          );
      Toast.normal("Password is updated successfully. Please login now.");
      RouteHelper.popUntil(Routes.LOGIN);
    }
  }

  bool _areFieldsValid() {
    if (!_otpTEC.isEqLength(6)) {
      Toast.normal("Please enter valid 6 digit OTP");
      return false;
    }
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

  Future _callForgotPasswordApi() async {
    await context
        .read(_passwordResetProvider.notifier)
        .forgotPassword(widget.phoneNumber);
    Toast.normal("OTP sent successfully");
  }

  @override
  void dispose() {
    _otpTEC.dispose();
    _passwordTEC.dispose();
    _confirmPasswordTEC.dispose();
    SmsAutoFill().unregisterListener();
    super.dispose();
  }
}
