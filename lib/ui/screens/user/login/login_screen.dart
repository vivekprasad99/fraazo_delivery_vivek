import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fraazo_delivery/helpers/extensions/text_editing_controller_extension.dart';
import 'package:fraazo_delivery/helpers/route/route_helper.dart';
import 'package:fraazo_delivery/helpers/route/routes.dart';
import 'package:fraazo_delivery/helpers/shared_pref/pref_helper.dart';
import 'package:fraazo_delivery/helpers/shared_pref/pref_keys.dart';
import 'package:fraazo_delivery/models/user/profile/user_model.dart';
import 'package:fraazo_delivery/permission_handler/device_tagging_handler.dart';
import 'package:fraazo_delivery/permission_handler/phone_permission_handler.dart';
import 'package:fraazo_delivery/providers/user/deviceTagging/device_tagging_provider.dart';
import 'package:fraazo_delivery/providers/user/login/login_provider.dart';
import 'package:fraazo_delivery/services/location/gps_service.dart';
import 'package:fraazo_delivery/ui/global_widgets/colored_sizedbox.dart';
import 'package:fraazo_delivery/ui/global_widgets/mobile_input_text.dart';
import 'package:fraazo_delivery/ui/global_widgets/new_app_bar.dart';
import 'package:fraazo_delivery/ui/global_widgets/new_outline_button.dart';
import 'package:fraazo_delivery/ui/global_widgets/new_primary_button.dart';
import 'package:fraazo_delivery/ui/utils/textview.dart';
import 'package:fraazo_delivery/ui/utils/widgets_and_attributes.dart';
import 'package:fraazo_delivery/utils/constants.dart';
import 'package:fraazo_delivery/utils/globals.dart';
import 'package:fraazo_delivery/utils/utils.dart';
import 'package:fraazo_delivery/values/custom_colors.dart';
import 'package:get/get.dart';
import 'package:sms_autofill/sms_autofill.dart';

final deviceTaggingProvider =
    StateNotifierProvider((_) => DeviceTaggingProvider());

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _loginProvider =
      StateNotifierProvider.autoDispose((_) => LoginProvider());

  final _isPhoneValidProvider = StateProvider.autoDispose((_) => false);

  final _phoneTEC = TextEditingController();
  final _phoneFN = FocusNode();

  bool _canShowPhoneHint = true;
  bool _isLoginByOTP = true;

  final _phonePermissionHandler = PhonePermissionHandler();
  final _deviceTaggingHandler = DeviceTaggingHandler();
  late final _gpsService = GPSService();
  Map<String, String> deviceModelNo = {};
  Map<String, String> address = {};

  @override
  void initState() {
    super.initState();
    getModel();
    _gpsService.checkGPSServiceAndSetCurrentLocation().whenComplete(() {
      _phonePermissionHandler.getRiderLocation().then((value) {
        setState(() {
          address = value;
        });
      });
    });
    _phoneTEC.addListener(() {
      context.read(_isPhoneValidProvider.notifier).state =
          _phoneTEC.isEqLength(10);
    });
    PrefHelper.setValue(PrefKeys.APP_VERSION, Globals.appVersion);
    PrefHelper.setValue(PrefKeys.APP_BUILD_NO, Globals.appBuildNumber);
  }

  Future getModel() async {
    deviceModelNo = await _phonePermissionHandler.getModel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryBlackColor,
      appBar: const NewAppBar(
        isShowBack: false,
      ),
      body: _buildBody(),
      //bottomNavigationBar: const DummyLocationSwitch(),
    );
  }

  Widget _buildBody() {
    return GestureDetector(
      onTap: () => _canShowPhoneHint = true,
      child: SingleChildScrollView(
        child: _buildLoginCard(),
      ),
    );
  }

  Widget _buildLoginCard() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      width: MediaQuery.of(context).size.width,
      padding: const EdgeInsets.only(
          left: px_24, right: px_24, top: px_24, bottom: px_24),
      decoration: const BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(px_16), topRight: Radius.circular(px_16)),
        //boxShadow: [BoxShadow(blurRadius: 4, color: AppColors.black02)],
      ),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
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
              sizedBoxH15,
              MobileInputText(
                  textEditingController: _phoneTEC, onChangeValue: () {}),
              //   _buildPhoneNumberField(),
              sizedBoxH18,
              _buildLoginButton(true),
              sizedBoxH18,
              _buildLoginButton(false),
            ],
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextView(
                  title: "Don't have an Account?",
                  alignment: Alignment.center,
                  textStyle: commonTextStyle(
                      fontWeight: FontWeight.w400,
                      fontSize: 14,
                      color: inActiveTextColor)),
              TextButton(
                onPressed: () => RouteHelper.push(Routes.SIGN_UP),
                child: Text(
                  "Register Now",
                  style: commonTextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      color: buttonColor),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPhoneNumberField() {
    return Container(
      height: 52,
      decoration: BoxDecoration(
          border: Border.all(
            color: const Color(0xFF454545),
          ),
          borderRadius: BorderRadius.circular(6)),
      child: Row(
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 15),
            child: Text(
              "+91",
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1,
                  color: textColor),
            ),
          ),
          const ColoredSizedBox(
            width: 1,
            height: 52,
            color: Color(0xFF454545),
          ),
          Expanded(
              child: TextField(
            controller: _phoneTEC,
            focusNode: _phoneFN,
            style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                letterSpacing: 1,
                color: textColor),
            inputFormatters: [
              LengthLimitingTextInputFormatter(10),
              FilteringTextInputFormatter.digitsOnly
            ],
            onTap: _onPhoneTextFieldTap,
            keyboardType: TextInputType.phone,
            scrollPadding: const EdgeInsets.only(bottom: 100),
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 11, vertical: 14),
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildLoginButton(bool isOTP) {
    return Consumer(
      builder: (_, watch, __) {
        final bool isValid = watch(_isPhoneValidProvider).state;
        final loginAsyncValue = watch(_loginProvider);
        return isOTP
            ? NewPrimaryButton(
                buttonTitle: 'Login with OTP',
                isActive: isValid,
                activeColor: buttonColor,
                inactiveColor: buttonInActiveColor,
                buttonRadius: px_8,
                isLoading:
                    loginAsyncValue is AsyncLoading && _isLoginByOTP == isOTP,
                onPressed: isValid ? () => _onNextButtonTap(isOTP) : null,
                // onPressed: isValid ? _onSubmitTap : null,
              )
            : NewOutlineButton(
                isActive: isValid,
                activeColor: buttonColor,
                inactiveColor: const Color(0xFF545454),
                buttonRadius: px_8,
                buttonHeight: 45,
                borderWidth: 1,
                buttonWidth: Get.width,
                buttonTitle: 'Login with Password',
                fontColor: const Color(0xFFA7A7A7),
                onPressed: isValid ? () => _onNextButtonTap(isOTP) : null,
              );
      },
    );
  }

  Future _onPhoneTextFieldTap() async {
    if (Platform.isAndroid && _phoneTEC.isEmpty && _canShowPhoneHint) {
      final String? phoneNumber = await SmsAutoFill().hint;
      if (phoneNumber != null) {
        _phoneTEC.text = phoneNumber.replaceFirst("+91", "");
      } else {
        FocusScope.of(context).unfocus(); // Required
        Future.delayed(const Duration(milliseconds: 200), () {
          FocusScope.of(context).requestFocus(_phoneFN);
        });
      }

      _canShowPhoneHint = false;
    }
  }

  Future<void> _onNextButtonTap(bool isOTP) async {
    List<String> _list = <String>[];
    final _isPermissionAccepted =
        await _phonePermissionHandler.isPermissionAccepted();
    if (_isPermissionAccepted) {
      _list = await _phonePermissionHandler.getIMEIs();
    }

    _isLoginByOTP = isOTP;
    if (isOTP) {
      await context.read(_loginProvider.notifier).loginByMobileNo(
          _phoneTEC.text,
          _list.last,
          deviceModelNo['deviceName'] ?? '',
          address);

      context.read(_loginProvider.notifier).addListener((state) async {
        if (state is AsyncError) {
          final Map<String, dynamic> errorResponse =
              jsonDecode(jsonEncode(state.error));

          if (errorResponse.containsKey('device_verify_status')) {
            final status = errorResponse['device_verify_status'];
            if (status == Constants.DV_DEVICE_DETAILS_MISSING) {
              _deviceTaggingHandler.errorResponse(
                "otp",
                _list,
                deviceModelNo['modelNo'] ?? '',
                mobileNo: _phoneTEC.text,
              );
            }
          }
        }
      });
    } else {
      RouteHelper.push(
        Routes.OTP_VERIFICATION,
        args: User(mobile: _phoneTEC.text, isPasswordVerification: true),
      );
    }
  }

  @override
  void dispose() {
    _phoneFN.dispose();
    _phoneTEC.dispose();
    super.dispose();
  }
}
