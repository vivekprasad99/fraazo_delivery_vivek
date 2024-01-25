import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fraazo_delivery/helpers/error/error_reporter.dart';
import 'package:fraazo_delivery/permission_handler/phone_permission_handler.dart';
import 'package:fraazo_delivery/providers/splash/authentication_provider.dart';
import 'package:fraazo_delivery/services/api/authentication/authentication_service.dart';

class OTPVerificationProvider extends StateNotifier<AsyncValue?> {
  OTPVerificationProvider([AsyncValue? state]) : super(state);

  final _authenticationService = AuthenticationService();
  final _phonePermissionHandler = PhonePermissionHandler();

  Future verifyOTP(String mobileNo, String otp, {bool isLogin = true}) async {
    state = const AsyncLoading();
    try {
      final List<String> _list = await _phonePermissionHandler.getIMEIs();
      final response = isLogin
          ? await _authenticationService.postVerifyOTP(
              int.parse(mobileNo),
              otp,
              _list.last,
            )
          : await _authenticationService.postVerifySignUpOTP(
              int.parse(mobileNo), otp);
      await AuthenticationProvider().onAuthentication();
      state = AsyncData(response);
    } catch (e, st) {
      state = AsyncError(e, st);
      ErrorReporter.error(e, st, "OTPVerificationProvider: verifyOTP()");
    }
  }

  Future verifyPassword(String mobileNo, String password, String deviceId,
      String deviceName, Map<String, String> location) async {
    state = const AsyncLoading();
    try {
      final response = await _authenticationService.postLogin(
          mobileNo, password, deviceId, deviceName, location);
      authentication();
      state = AsyncData(response);
    } catch (e, st) {
      state = AsyncError(e, st);
      ErrorReporter.error(e, st, "OTPVerificationProvider: verifyOTP()");
    }
  }

  Future<void> authentication() async {
    await AuthenticationProvider().onAuthentication();
  }
}
