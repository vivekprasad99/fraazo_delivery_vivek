import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fraazo_delivery/helpers/error/error_reporter.dart';
import 'package:fraazo_delivery/services/api/authentication/authentication_service.dart';

class DeviceTaggingProvider extends StateNotifier<AsyncValue?> {
  DeviceTaggingProvider([AsyncValue? state]) : super(state);

  final _authenticationService = AuthenticationService();

  Future addDevice(
    String? mobileNo,
    String deviceModelNo, {
    required List<String> imeiS,
  }) async {
    state = const AsyncLoading();
    try {
      final response = await _authenticationService.addDevice(
        mobileNo: mobileNo ?? '',
        deviceModelNo: deviceModelNo,
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
