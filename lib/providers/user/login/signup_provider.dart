import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fraazo_delivery/helpers/error/error_reporter.dart';
import 'package:fraazo_delivery/helpers/route/route_helper.dart';
import 'package:fraazo_delivery/helpers/route/routes.dart';
import 'package:fraazo_delivery/models/user/profile/user_model.dart';
import 'package:fraazo_delivery/services/api/authentication/authentication_service.dart';
import 'package:sms_autofill/sms_autofill.dart';

class SignupProvider extends StateNotifier<AsyncValue?> {
  SignupProvider([AsyncValue? state]) : super(state);

  final _authenticationService = AuthenticationService();

  Future signUpUser(
      {User? user,
      bool isResend = false,
      String phoneNo = '',
      bool isRevamp = false}) async {
    state = const AsyncLoading();
    try {
      final response = await _authenticationService.postRiderSignup(
          user: user, isRevamp: isRevamp, phoneNo: phoneNo);
      if (isResend) {
        _navigateToOTPScreen(response!, isResend: isResend);
      }
      state = AsyncData(response);
    } catch (e, st) {
      state = AsyncError(e, st);
      ErrorReporter.error(e, st, "SignupProvider: signUpUser()");
      rethrow;
    }
  }

  void _navigateToOTPScreen(User user, {required bool isResend}) {
    user.isLogin = false;
    if (Platform.isAndroid) {
      SmsAutoFill().listenForCode;
    }
    if (isResend) {
      RouteHelper.push(Routes.OTP_VERIFICATION, args: user);
    }
  }
}
