import 'package:background_locator/location_dto.dart';
import 'package:battery_plus/battery_plus.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fraazo_delivery/helpers/error/error_reporter.dart';
import 'package:fraazo_delivery/helpers/route/route_helper.dart';
import 'package:fraazo_delivery/helpers/shared_pref/pref_helper.dart';
import 'package:fraazo_delivery/helpers/shared_pref/pref_keys.dart';
import 'package:fraazo_delivery/providers/delivery/task_by_socket_provider.dart';
import 'package:fraazo_delivery/providers/home_screen/earning_daily_order_provider.dart';
import 'package:fraazo_delivery/providers/user/profile/user_profile_provider.dart';
import 'package:fraazo_delivery/screen_modules/signup/ui/local_widgets/rider_go_online_widget.dart';
import 'package:fraazo_delivery/services/api/user/user_service.dart';
import 'package:fraazo_delivery/services/location/background_location_service.dart';
import 'package:fraazo_delivery/services/location/gps_service.dart';
import 'package:fraazo_delivery/services/media/image/compressed_image_service.dart';
import 'package:fraazo_delivery/ui/screens/home/local_widgets/location_permission_info_dialog.dart';
import 'package:fraazo_delivery/ui/utils/toast.dart';
import 'package:fraazo_delivery/utils/constants.dart';
import 'package:fraazo_delivery/utils/globals.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../helpers/type_aliases/json.dart';

final locationProvider = ChangeNotifierProvider((_) => LocationProvider());

class LocationProvider extends ChangeNotifier {
  final _backgroundLocationService = BackgroundLocationService();
  late final _gpsService = GPSService();
  late final _userService = UserService();

  bool isServiceRunning = false;
  bool isLoading = false;

  String _getNumOfLoginHours = '';
  String get getNumOfLoginHours => _getNumOfLoginHours;

  LocationProvider() {
    _backgroundLocationService.isServiceRunning().then(onStart);
  }

  Future init() async {
    try {
      if (!isServiceRunning) {
        await _backgroundLocationService.init();
      }
    } catch (e, st) {
      ErrorReporter.error(e, st, "LocationProvider : init()");
    }
  }

  // ignore: avoid_positional_boolean_parameters
  Future onStart(bool isRunning) async {
    // isServiceRunning = isRunning;
    if (!isRunning && Globals.isRiderAvailable) {
      await startService(shouldCallApi: false);
      // while (!isSuccess) {
      //   Toast.normal("Please grant permission to continue being online");
      // issSuccess = await startService(shouldCallApi: false);
      // }
    } else if (isRunning && Globals.user?.status == Constants.US_OFFLINE) {
      bool isSuccess =
          await stopService(shouldCheckPermission: false, shouldCallApi: false);
      while (!isSuccess) {
        isSuccess = await stopService(
          shouldCheckPermission: false,
          shouldCallApi: false,
        );
      }
    } else {
      isServiceRunning = isRunning;
      notifyListeners();
    }
    if (isRunning && Globals.isRiderAvailable) {
      RouteHelper.navigatorContext.read(taskBySocketProvider.notifier).open();
      _gpsService.checkGPSServiceAndSetCurrentLocation();
      _gpsService.listenToGPSStatusStream();
    }
  }

  Future<bool> startService({bool shouldCallApi = true}) async {
    _setIsLoading(true);
    try {
      if (await _checkLocationPermissions()) {
        if (shouldCallApi) {
          return await updateRiderStatus(
              shouldCallApi: shouldCallApi, riderStatus: Constants.US_ONLINE);
        }
        await _backgroundLocationService.startLocationService(
            onLocationUpdate: onLocationUpdate);
        if (Globals.user?.status == Constants.US_ONLINE) {
          RouteHelper.navigatorContext
              .read(taskBySocketProvider.notifier)
              .open();
          _gpsService.listenToGPSStatusStream();
        }
        isServiceRunning = true;
        return true;
      } else {
        return false;
      }
      // return shouldCallApi
      //     ?
      //     : false;
    } catch (e, st) {
      ErrorReporter.error(e, st, "LocationProvider: startService()");
      return false;
    } finally {
      _setIsLoading(false);
    }
  }

  static Future onLocationUpdate(LocationDto locationDto) async {
    await PrefHelper.getInstance();
    await PrefHelper.reload();
    try {
      Firebase.initializeApp();
    } finally {
      //in any case it crashes. We have to go ahead.
    }
    await Future.value([
      PrefHelper.setValue(PrefKeys.CURRENT_LATITUDE, locationDto.latitude),
      PrefHelper.setValue(PrefKeys.CURRENT_LONGITUDE, locationDto.longitude),
      PrefHelper.setValue(PrefKeys.IS_MOCK_LOCATION, locationDto.isMocked),
      PrefHelper.setValue(PrefKeys.CURRENT_LOCATION_SENT_TIME, 30)
    ]);

    await UserService().postRiderLocation();
  }

  Future<bool> stopService({
    bool shouldCheckPermission = true,
    bool shouldCallApi = true,
  }) async {
    _setIsLoading(true);
    try {
      // JsonMap? response;
      // if (shouldCheckPermission) {
      //   if (await _checkLocationPermissions(isStartService: false)) {
      //     if (Globals.isSelfieEnabled) {
      //       response = await _sefieClick(
      //         shouldCallApi: shouldCallApi,
      //         status: Constants.US_OFFLINE,
      //       );
      //     } else {
      //       if (shouldCallApi) {
      //         response = await _setOnlineStatus(Constants.US_OFFLINE, '');
      //       }
      //     }
      //     /*await _sefieClick(
      //         shouldCallApi: shouldCallApi, status: Constants.US_OFFLINE);*/
      //   }

      // }
      if (shouldCallApi) {
        await updateRiderStatus(
            shouldCallApi: shouldCallApi,
            isStartService: false,
            riderStatus: Constants.US_OFFLINE);
      }
      return true;
    } catch (e, st) {
      ErrorReporter.error(e, st, "LocationProvider: endService()");
      return false;
    } finally {
      _setIsLoading(false);
    }
  }

  Future<bool> _checkLocationPermissions({bool isStartService = true}) async {
    try {
      final currentStatus = await Permission.locationAlways.status;
      if (!currentStatus.isGranted && isStartService) {
        // I don't want to call ui things here but not other better way I found;
        await RouteHelper.openDialog(const LocationPermissionInfoDialog());
      }
      final normalLocationPermission = await Permission.location.request();
      if (normalLocationPermission.isGranted) {
        final requestStatus = await Permission.locationAlways.request();
        if (requestStatus.isGranted) {
          await _gpsService.checkGPSServiceAndSetCurrentLocation();

          if (isStartService) {
            await Permission.ignoreBatteryOptimizations.request();
          }
          return true;
        } else {
          Toast.normal(
            "Please grant Allow all the time location permission to proceed.",
          );
          return false;
        }
      } else {
        Toast.normal("Please grant location permission to proceed.");
        return false;
      }
    } on LocationServiceDisabledException {
      return false;
    } catch (e, st) {
      Toast.normal(
        "Please grant Allow all the time location permission to proceed.",
      );
      ErrorReporter.error(
        e,
        st,
        "LocationProvider: _checkLocationPermission() - Please grant Allow all the time location permission to proceed",
      );
      return false;
    }
  }

  Future checkForGPSStatus(
      {bool shouldCheckWithoutAvailability = false}) async {
    try {
      if (shouldCheckWithoutAvailability || Globals.isRiderAvailable) {
        await _gpsService.checkGPSServiceAndSetCurrentLocation();
      }
    } finally {}
  }

  Future<JsonMap> setOnlineStatus(String status, String imagePath) async {
    final JsonMap? responsData =
        await _userService.putRiderGoOnline(status, imagePath);
    Globals.user?.status = responsData!['status'];
    if (responsData!.containsKey('num_online_hours')) {
      _getNumOfLoginHours = responsData['num_online_hours'];
      PrefHelper.setValue(
          PrefKeys.LOGIN_HOURS, responsData['num_online_hours']);
      notifyListeners();
    }
    RouteHelper.navigatorContext
        .read(userProfileProvider.notifier)
        .changeUserStatus(status);

    final Battery _battery = Battery();
    final int batteryLevel = await _battery.batteryLevel;
    RouteHelper.navigatorContext
        .read(dailyEarningProvider.notifier)
        .getEarningAndOrdersDaily(
            riderId: Globals.user?.id ?? 0, batteryLevel: batteryLevel);

    bool isPopup = responsData['pop_up'] ?? false;
    if (isPopup) {
      showDialog(
        context: RouteHelper.navigatorContext,
        barrierDismissible: false,
        builder: (_) => RiderGoOnlineWidget(
          showButton: true,
          msg1: '',
          msg2: responsData['message'],
          imgName: 'rider_on_time',
        ),
      );
    }
    return responsData;
  }

  void showAlertDialog(BuildContext context, String msg) {
    // set up the button
    Widget okButton = TextButton(
      child: Text("OK"),
      onPressed: () {
        RouteHelper.pop();
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Info"),
      content: Text(msg),
      actions: [
        okButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  Future _sefieClick(
      {bool shouldCallApi = true, String status = Constants.US_ONLINE}) async {
    if (shouldCallApi) {
      final picker = ImagePicker();
      try {
        final pickedFile = await picker.pickImage(
          source: ImageSource.camera,
          preferredCameraDevice: CameraDevice.front,
        );
        if (pickedFile != null) {
          //RouteHelper.pop();
          String selfiePaht = await _uploadRiderSelfie(pickedFile.path);
          if (shouldCallApi) {
            JsonMap? responsData = await setOnlineStatus(status, selfiePaht);
            return responsData;
          }
          // return _uploadRiderSelfie(pickedFile.path);
        }
      } on PlatformException catch (e, st) {
        Toast.normal(e.message!);
        ErrorReporter.error(
          e,
          st,
          "Selfie Click - PlatformException ${e.message}",
        );
      }
    } else {
      return true;
    }
  }

  Future _uploadRiderSelfie(String filePath) async {
    late final _compressedImageService = CompressedImageService();
    try {
      final newFilePath =
          await _compressedImageService.compressAndGetFilePath(filePath);
      String urlPath = await _userService.postRiderSelfie(newFilePath);
      return urlPath;
    } catch (e, st) {
      ErrorReporter.error(e, st, "LocationProvider: _uploadRiderSelfie()");
      rethrow;
    }
  }

  void _setIsLoading(bool isLoadingValue) {
    isLoading = isLoadingValue;
    notifyListeners();
  }

  Future<bool> updateRiderStatus(
      {String riderStatus = Constants.US_ONLINE,
      bool shouldCallApi = true,
      bool isStartService = true}) async {
    JsonMap? response;
    if (await _checkLocationPermissions(isStartService: isStartService)) {
      final JsonMap? responsData =
          await _userService.putGeoFencingValidation(riderStatus);
      if (responsData?['success'] == true) {
        if (Globals.isSelfieEnabled) {
          response = await _sefieClick(
              shouldCallApi: shouldCallApi, status: riderStatus);
        } else {
          if (shouldCallApi) {
            response = await setOnlineStatus(riderStatus, '');
          }
        }

        if (response != null) {
          if (riderStatus == Constants.US_ONLINE) {
            await _backgroundLocationService.startLocationService(
              onLocationUpdate: onLocationUpdate,
            );
            if (Globals.user?.status == Constants.US_ONLINE) {
              RouteHelper.navigatorContext
                  .read(taskBySocketProvider.notifier)
                  .open();
              _gpsService.listenToGPSStatusStream();
            }
            isServiceRunning = true;
          } else {
            await _backgroundLocationService.stopLocationService();
            RouteHelper.navigatorContext
                .read(taskBySocketProvider.notifier)
                .close();
            isServiceRunning = false;
          }
        }
      } else {
        Toast.error(responsData?['message']);
      }
      return true;
    } else {
      return false;
    }
  }

  Future<bool> markOfflineWithNotification(
      {String riderStatus = Constants.US_OFFLINE}) async {
    await _backgroundLocationService.stopLocationService();

    isServiceRunning = false;
    RouteHelper.navigatorContext.read(taskBySocketProvider.notifier).close();
    return true;
  }

  void notify() => notifyListeners();
}
