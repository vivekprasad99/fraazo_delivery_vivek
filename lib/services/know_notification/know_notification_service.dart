import 'package:flutter/services.dart';

class KnowNotificationService {
  static const _platformChannel = MethodChannel("knowNotificationService");

  Future<bool> initialise(Map<String, String?> userInfo) async {
    return await _platformChannel.invokeMethod("initialiseKnow", userInfo);
  }

  Future<bool> openNotificationList() async {
    return await _platformChannel.invokeMethod("openKnowNotification");
  }

  Future<bool> knowSignOut() async {
    return await _platformChannel.invokeMethod("knowSignOut");
  }

  Future<bool> initialiseFirebase() async {
    return await _platformChannel.invokeMethod("initialiseFirebase");
  }

  Future<bool> knowReadEvent(Map<String, String?> info) async {
    return await _platformChannel.invokeMethod("knowReadEvent", info);
  }
}
