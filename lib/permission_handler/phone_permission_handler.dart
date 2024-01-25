import 'dart:async';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:fraazo_delivery/helpers/shared_pref/pref_helper.dart';
import 'package:fraazo_delivery/helpers/shared_pref/pref_keys.dart';
import 'package:geocoding/geocoding.dart';
import 'package:imei_plugin/imei_plugin.dart';
import 'package:permission_handler/permission_handler.dart';

class PhonePermissionHandler {
  static final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();

  void permissionServiceCall() {
    permissionServices().then(
      (value) {
        if (value.isNotEmpty) {
          if (value[Permission.phone]?.isGranted ?? false) {
            getIMEIs();
          } else {
            permissionServiceCall();
          }
        }
      },
    );
  }

  Future<bool> isPermissionAccepted() async {
    final _permissionStatusMap = await permissionServices();
    if (_permissionStatusMap.isNotEmpty) {
      return _permissionStatusMap[Permission.phone]?.isGranted ?? false;
    } else {
      await isPermissionAccepted();
    }
    return false;
  }

  Future<List<String>> getIMEIs() async {
    final _list = <String>[];
    String? platformImei;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      platformImei = await ImeiPlugin.getImei();
      final List<String>? multiImei = await ImeiPlugin.getImeiMulti();
      _list.addAll(multiImei ?? []);
      final String? idUnique = await ImeiPlugin.getId();
      _list.add(idUnique ?? '');
      debugPrint('IMEIsState Ex:UniqueId:$idUnique>>IMEIs:>> $_list');
    } on PlatformException {
      platformImei = 'Failed to get platform version.';
      debugPrint('IMEIsState Ex: $platformImei');
    }
    return _list;
  }

  /*Permission services*/
  Future<Map<Permission, PermissionStatus>> permissionServices() async {
    // You can request multiple permissions at once.
    final Map<Permission, PermissionStatus> statuses = await [
      Permission.phone,
    ].request();

    if (statuses[Permission.phone]?.isPermanentlyDenied ?? false) {
      await openAppSettings().then(
        (value) async {
          if (value) {
            if (await Permission.storage.status.isPermanentlyDenied == true &&
                await Permission.storage.status.isGranted == false) {
              openAppSettings();
              /* opens app settings until permission is granted */
            }
          }
        },
      );
    } else {
      if (statuses[Permission.phone]?.isPermanentlyDenied ?? false) {
        permissionServiceCall();
      }
    }
    /*{Permission.phone}*/
    return statuses;
  }

  Future<Map<String, String>> getModel() async {
    if (Platform.isAndroid) {
      final AndroidDeviceInfo androidInfo = await deviceInfoPlugin.androidInfo;
      return {
        "modelNo": androidInfo.model!,
        "deviceName": androidInfo.manufacturer ?? '',
      };
    } else if (Platform.isIOS) {
      final IosDeviceInfo iosInfo = await deviceInfoPlugin.iosInfo;
      return {
        "modelNo": iosInfo.model!,
        "deviceName": iosInfo.name ?? '',
      };
    } else {
      throw UnimplementedError();
    }
  }

  Future<Map<String, String>> getRiderLocation() async {
    final List<Placemark> placemarks = await placemarkFromCoordinates(
        PrefHelper.getDouble(PrefKeys.CURRENT_LATITUDE)!,
        PrefHelper.getDouble(PrefKeys.CURRENT_LONGITUDE)!);
    final Placemark place = placemarks[0];
    return {
      "current_area": place.subLocality ?? '',
      "current_city": place.locality ?? '',
    };
  }
}
