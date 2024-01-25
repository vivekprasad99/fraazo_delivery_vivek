import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fraazo_delivery/helpers/route/route_helper.dart';
import 'package:fraazo_delivery/helpers/route/routes.dart';
import 'package:fraazo_delivery/models/user/device_verification_model.dart';
import 'package:fraazo_delivery/models/user/profile/user_model.dart';
import 'package:fraazo_delivery/ui/screens/user/local_widgets/device_verification_alert.dart';
import 'package:fraazo_delivery/ui/screens/user/login/login_screen.dart';
import 'package:fraazo_delivery/ui/screens/user/login/otp_verification/otp_verification_screen.dart';
import 'package:fraazo_delivery/ui/utils/toast.dart';

class DeviceTaggingHandler {
  Future<void> errorResponse(
      String checkDevicePlace, List<String> _list, String deviceModelNo,
      {String? mobileNo,
      String? otpPassword,
      String? deviceName,
      Map<String, String>? location}) async {
    final isConfirm = await RouteHelper.openDialog(
        DeviceVerificationConfirmAlert(isHome: checkDevicePlace == 'home'),
        barrierDismissible: false);
    if (isConfirm != null && isConfirm) {
      deviceTagging(
        _list,
        deviceModelNo,
        checkDevicePlace,
        mobileNo: mobileNo,
        otpPassword: otpPassword,
      );
    }
  }

  Future deviceTagging(
      List<String> _list, String deviceModelNo, String checkDevicePlace,
      {String? mobileNo,
      String? otpPassword,
      String? deviceName,
      Map<String, String>? location}) async {
    final Completer _completer = Completer();
    await Toast.popupLoadingFuture(
      future: () => RouteHelper.navigatorContext
          .read(deviceTaggingProvider.notifier)
          .addDevice(mobileNo, deviceModelNo, imeiS: _list)
          .whenComplete(() => _completer.complete(true)),
      onSuccess: (_) async {},
    );
    final isResult = await _completer.future;

    if (isResult && checkDevicePlace != 'home') {
      final _deviceVerificationResult = RouteHelper.navigatorContext
          .read(deviceTaggingProvider.notifier)
          .state
          ?.data
          ?.value;
      if (_deviceVerificationResult is DeviceVerificationModel?) {
        if (_deviceVerificationResult?.success != null &&
            _deviceVerificationResult!.success!) {
          if (checkDevicePlace == 'otp') {
            RouteHelper.push(Routes.OTP_VERIFICATION,
                args: User(mobile: mobileNo, isLogin: true));
          } else if (checkDevicePlace == 'password') {
            RouteHelper.navigatorContext
                .read(otpVerificationProvider.notifier)
                .verifyPassword(mobileNo!, otpPassword!, _list.last,
                    deviceName ?? '', location!);
          }
        }
      }
    }
  }
}
