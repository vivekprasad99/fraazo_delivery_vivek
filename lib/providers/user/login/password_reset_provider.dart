import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fraazo_delivery/helpers/error/error_reporter.dart';
import 'package:fraazo_delivery/services/api/authentication/authentication_service.dart';

class PasswordResetProvider extends StateNotifier<AsyncValue?> {
  PasswordResetProvider([AsyncValue? state]) : super(state);

  final _authenticationService = AuthenticationService();

  Future updatePassword(
      {required String mobileNo,
      required String otp,
      required String password}) async {
    state = const AsyncLoading();
    try {
      final response = await _authenticationService.postUpdatePassword(
          mobileNo: mobileNo, otp: otp, password: password);
      state = AsyncData(response);
    } catch (e, st) {
      state = AsyncError(e, st);
      ErrorReporter.error(e, st, "PasswordResetProvider: updatePassword()");
      rethrow;
    }
  }

  Future forgotPassword(String mobileNo) {
    return _authenticationService.postResetPassword(mobileNo);
  }
}
