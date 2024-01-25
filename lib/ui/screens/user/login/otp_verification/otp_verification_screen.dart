import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fraazo_delivery/helpers/extensions/text_editing_controller_extension.dart';
import 'package:fraazo_delivery/helpers/route/route_helper.dart';
import 'package:fraazo_delivery/helpers/route/routes.dart';
import 'package:fraazo_delivery/models/user/profile/user_model.dart';
import 'package:fraazo_delivery/permission_handler/device_tagging_handler.dart';
import 'package:fraazo_delivery/permission_handler/phone_permission_handler.dart';
import 'package:fraazo_delivery/providers/user/login/login_provider.dart';
import 'package:fraazo_delivery/providers/user/login/otp_verification_provider.dart';
import 'package:fraazo_delivery/providers/user/login/signup_provider.dart';
import 'package:fraazo_delivery/ui/global_widgets/new_app_bar.dart';
import 'package:fraazo_delivery/ui/global_widgets/new_fd_textfield.dart';
import 'package:fraazo_delivery/ui/global_widgets/new_primary_button.dart';
import 'package:fraazo_delivery/ui/screen_widgets/otp_timer_and_resend_widget.dart';
import 'package:fraazo_delivery/ui/utils/textview.dart';
import 'package:fraazo_delivery/ui/utils/toast.dart';
import 'package:fraazo_delivery/ui/utils/widgets_and_attributes.dart';
import 'package:fraazo_delivery/utils/constants.dart';
import 'package:fraazo_delivery/utils/utils.dart';
import 'package:fraazo_delivery/values/custom_colors.dart';
import 'package:get/get.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:sms_autofill/sms_autofill.dart';

final otpVerificationProvider =
    StateNotifierProvider.autoDispose((_) => OTPVerificationProvider());

class OtpVerificationScreen extends StatefulWidget {
  final User user;

  const OtpVerificationScreen(this.user);

  @override
  _OtpVerificationScreenState createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  late final _loginProvider = StateNotifierProvider((_) => LoginProvider());
  late final _signupProvider = StateNotifierProvider((_) => SignupProvider());
  final _isOTPValidProvider = StateProvider.autoDispose((_) => false);

  final _otpPasswordTEC = TextEditingController();
  bool _isLogin = true;
  late final bool _isPasswordVerification =
      widget.user.isPasswordVerification ?? false;
  late final bool _isForgotPassword = widget.user.isVerified;

  final _phonePermissionHandler = PhonePermissionHandler();
  final _deviceTaggingHandler = DeviceTaggingHandler();

  @override
  void initState() {
    super.initState();
    _isLogin = widget.user.isLogin!;
    _otpPasswordTEC.addListener(() {
      context.read(_isOTPValidProvider.notifier).state =
          _otpPasswordTEC.isEqLength(6);
    });
    _listenForOTPCodeOnAndroid();
    getModel();
  }

  Map<String, String> deviceModelNo = {};
  Map<String, String> address = {};

  Future getModel() async {
    deviceModelNo = await _phonePermissionHandler.getModel();
    address = await _phonePermissionHandler.getRiderLocation();
  }

  @override
  Widget build(BuildContext context) {
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
          child: _buildBody()),
    );
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextView(
              title: _isPasswordVerification
                  ? 'Enter your Password'
                  : 'Enter the OTP',
              textStyle: commonTextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.white)),
          const SizedBox(
            height: 5,
          ),
          TextView(
              title: _isPasswordVerification
                  ? 'Please Enter your 6 digit Password'
                  : 'Please enter the  6 digit OTP sent to your mobile number +91 ${widget.user.mobile}',
              textStyle: commonTextStyle(
                  fontSize: 14,
                  color: lightBlackTxtColor,
                  fontWeight: FontWeight.w400)),
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
        sizedBoxH15,
        if (_isPasswordVerification)
          _buildPasswordField()
        else
          _buildOTPField(),
        sizedBoxH20,
        Consumer(
          builder: (_, watch, __) {
            final isValid = watch(_isOTPValidProvider).state;
            final otpVerificationAsyncValue = watch(otpVerificationProvider);
            return NewPrimaryButton(
              buttonTitle: 'Continue',
              isActive: isValid,
              activeColor: buttonColor,
              inactiveColor: buttonInActiveColor,
              buttonRadius: px_8,
              onPressed: _onSubmitTap,
              // onPressed: isValid ? _onSubmitTap : null,
            );
          },
        ),
        sizedBoxH10,
        // if (_isPasswordVerification)
        //   TextButton(
        //       onPressed: _onForgotPasswordTap,
        //       child: TextView(
        //         title: "Forgot Password?",
        //         textStyle: commonTextStyle(
        //             fontSize: 13,
        //             fontWeight: FontWeight.w600,
        //             color: inActiveTextColor),
        //       ))
        // else
        Visibility(
          visible: !_isPasswordVerification,
          child: OtpTimerAndResendWidget(
            onResend: _onResendTap,
          ),
        ),
      ],
    );
  }

  Widget _buildOTPField() {
    return PinCodeTextField(
      appContext: context,
      controller: _otpPasswordTEC,
      length: 6,
      cursorWidth: 1,
      autoFocus: true,
      cursorColor: Colors.white,
      textStyle: commonTextStyle(
          color: Colors.white, fontSize: tx_16, fontWeight: FontWeight.w600),
      animationType: AnimationType.fade,
      autoDisposeControllers: false,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      keyboardType: TextInputType.phone,
      pinTheme: PinTheme(
        shape: PinCodeFieldShape.box,
        borderRadius: BorderRadius.circular(px_5),
        fieldHeight: 40,
        fieldWidth: 40,
        borderWidth: 1,
        activeColor: borderLineColor,
        inactiveColor: borderLineColor,
        selectedColor: borderLineColor,
        inactiveFillColor: Colors.transparent,
        activeFillColor: Colors.transparent,
        selectedFillColor: Colors.transparent,
      ),
      animationDuration: const Duration(milliseconds: 200),
      backgroundColor: Colors.transparent,
      enableActiveFill: true,
      onCompleted: (_) => _onSubmitTap(),
      onSubmitted: (_) => _onSubmitTap(),
      onChanged: (_) => {},
    );
  }

  Widget _buildPasswordField() {
    return Column(
      children: [
        NewFDTextField(
          controller: _otpPasswordTEC,
          labelText: "",
          maxLength: 6,
          shouldHideText: true,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
                onPressed: _onForgotPasswordTap,
                child: TextView(
                  title: "Forgot Password?",
                  textStyle: commonTextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: inActiveTextColor),
                )),
          ],
        )
      ],
    );
  }

  void _listenForOTPCodeOnAndroid() {
    if (Platform.isAndroid) {
      SmsAutoFill().code.listen((String code) {
        _otpPasswordTEC.text = code;
      });
    }
  }

  Future<void> _onSubmitTap() async {
    List<String> _list = <String>[];
    final _isPermissionAccepted =
        await _phonePermissionHandler.isPermissionAccepted();
    if (_isPermissionAccepted) {
      _list = await _phonePermissionHandler.getIMEIs();
    }

    if (!_otpPasswordTEC.isEqLength(6)) {
      return Toast.normal(
        "Please enter valid 6 digit ${_isPasswordVerification ? "password" : "OTP"}",
      );
    }

    if (_isPasswordVerification) {
      context.read(otpVerificationProvider.notifier).verifyPassword(
            widget.user.mobile ?? "",
            _otpPasswordTEC.text,
            _list.last,
            deviceModelNo['deviceName'] ?? '',
            address,
          );

      context.read(otpVerificationProvider.notifier).addListener((state) async {
        if (state is AsyncError) {
          final Map<String, dynamic> errorResponse =
              jsonDecode(jsonEncode(state.error));

          if (errorResponse.containsKey('device_verify_status')) {
            final status = errorResponse['device_verify_status'];
            if (status == Constants.DV_DEVICE_DETAILS_MISSING) {
              _deviceTaggingHandler.errorResponse(
                  "password", _list, deviceModelNo['modelNo'] ?? '',
                  mobileNo: widget.user.mobile ?? "",
                  otpPassword: _otpPasswordTEC.text,
                  deviceName: deviceModelNo['deviceName'] ?? '',
                  location: address);
            }
          }
        }
      });
    } else {
      context.read(otpVerificationProvider.notifier).verifyOTP(
            widget.user.mobile ?? "",
            _otpPasswordTEC.text,
            isLogin: _isLogin,
          );
    }
  }

  void _onResendTap() async {
    List<String> _list = <String>[];
    final _isPermissionAccepted =
        await _phonePermissionHandler.isPermissionAccepted();
    if (_isPermissionAccepted) {
      _list = await _phonePermissionHandler.getIMEIs();
    }
    if (_isLogin) {
      context.read(_loginProvider.notifier).loginByMobileNo(widget.user.mobile,
          _list.last, deviceModelNo['deviceName'] ?? '', address,
          isResend: true);
    } else {
      context.read(_signupProvider.notifier).signUpUser(
          isRevamp: true, isResend: false, phoneNo: widget.user.mobile!);
      // context
      //     .read(_signupProvider.notifier)
      //     .signUpUser(user: widget.user, isResend: true);
    }
    _otpPasswordTEC.clear();
  }

  void _onForgotPasswordTap() {
    //if (Globals.user?.isVerified ?? false) {
    RouteHelper.pushReplacement(Routes.PASSWORD_RESET,
        args: widget.user.mobile);
    //}
  }

  @override
  void dispose() {
    _otpPasswordTEC.dispose();
    SmsAutoFill().unregisterListener();
    super.dispose();
  }
}
