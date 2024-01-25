import 'dart:async';

import 'package:fraazo_delivery/helpers/error/error_reporter.dart';
import 'package:fraazo_delivery/helpers/shared_pref/pref_helper.dart';
import 'package:fraazo_delivery/helpers/shared_pref/pref_keys.dart';
import 'package:fraazo_delivery/ui/utils/toast.dart';
import 'package:fraazo_delivery/utils/globals.dart';
import 'package:geolocator/geolocator.dart';

class GPSService {
  factory GPSService() {
    return _instance;
  }

  GPSService._();

  static final GPSService _instance = GPSService._();

  bool _isGPSStreamSubscribed = false;
  bool _isGPSDialogVisible = false;
  late final StreamSubscription<ServiceStatus> _locationStreamSubscription;

  Future checkGPSServiceAndSetCurrentLocation(
      {LocationAccuracy desiredAccuracy =
          LocationAccuracy.bestForNavigation}) async {
    if (_isGPSDialogVisible) {
      return;
    }
    _isGPSDialogVisible = true;
    try {
      final Position currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: desiredAccuracy,
        timeLimit: const Duration(seconds: 20),
      );

      await Future.value([
        PrefHelper.setValue(
            PrefKeys.CURRENT_LATITUDE, currentPosition.latitude),
        PrefHelper.setValue(
            PrefKeys.CURRENT_LONGITUDE, currentPosition.longitude),
        PrefHelper.setValue(
            PrefKeys.IS_MOCK_LOCATION, currentPosition.isMocked),
      ]);
    } on LocationServiceDisabledException catch (e, st) {
      Toast.normal("Location services are disabled. Please allow to proceed.");
      ErrorReporter.error(e, st,
          "LocationProvider: checkGPSServiceAndSetCurrentLocation() - (LocationServiceDisabledException) Location services are disabled. Please allow to proceed.");
      rethrow;
    } on PermissionDeniedException catch (e, st) {
      Toast.normal("Location permission denied. Please allow to proceed.");
      ErrorReporter.error(e, st,
          "LocationProvider: checkGPSServiceAndSetCurrentLocation() - (PermissionDeniedException) Location permission denied. Please allow to proceed.");
      rethrow;
    } finally {
      _isGPSDialogVisible = false;
    }
  }

  void listenToGPSStatusStream() {
    if (_isGPSStreamSubscribed) {
      return;
    }
    _locationStreamSubscription = Geolocator.getServiceStatusStream().listen(
      (serviceStatus) {
        if (serviceStatus == ServiceStatus.disabled &&
            Globals.isRiderAvailable) {
          checkGPSServiceAndSetCurrentLocation();
        }
      },
    );
    _isGPSStreamSubscribed = true;
  }

  void dispose() {
    if (_isGPSStreamSubscribed) {
      _locationStreamSubscription.cancel();
    }
  }
}
