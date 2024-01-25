import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fraazo_delivery/helpers/error/error_reporter.dart';
import 'package:fraazo_delivery/helpers/route/route_helper.dart';
import 'package:fraazo_delivery/helpers/route/routes.dart';
import 'package:fraazo_delivery/models/user/profile/user_model.dart';
import 'package:fraazo_delivery/services/api/authentication/authentication_service.dart';
import 'package:fraazo_delivery/services/location/gps_service.dart';
import 'package:fraazo_delivery/utils/globals.dart';
import 'package:sms_autofill/sms_autofill.dart';

class LoginProvider extends StateNotifier<AsyncValue?> {
  LoginProvider([AsyncValue? state]) : super(state);

  final _authenticationService = AuthenticationService();

  Future loginByMobileNo(String? mobileNo, String? deviceId, String? deviceName,
      Map<String, String> location,
      {bool isResend = false}) async {
    state = const AsyncLoading();
    try {
      await GPSService().checkGPSServiceAndSetCurrentLocation();
      if (!Globals.checkAndShowMockLocationDialog()) {
        final response = await _authenticationService.postSendOTP(
            mobileNo, deviceId, deviceName, location);
        navigateToOTPScreen(mobileNo, isResend: isResend);
        state = AsyncData(response);
      }
    } catch (e, st) {
      state = AsyncError(e, st);
      ErrorReporter.error(e, st, "LoginProvider: loginByMobileNo()");
    }
  }

  void navigateToOTPScreen(String? mobileNo, {required bool isResend}) {
    if (Platform.isAndroid) {
      SmsAutoFill().listenForCode;
    }
    if (!isResend) {
      RouteHelper.push(Routes.OTP_VERIFICATION,
          args: User(mobile: mobileNo, isLogin: true));
    }
  }

  Future deviceVerification(
    String? mobileNo, {
    required List<String> imeiS,
  }) async {
    state = const AsyncLoading();
    try {
      final response = await _authenticationService.postIMEIsWithId(
        mobileNo: mobileNo ?? '',
        imeiS: imeiS,
      );
      state = AsyncData(response);
    } catch (e, st) {
      state = AsyncError(e, st);
      ErrorReporter.error(e, st, "LoginProvider: loginByMobileNo()");
      rethrow;
    }
  }
}
