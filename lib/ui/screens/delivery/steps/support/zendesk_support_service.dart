import 'package:flutter/services.dart';

class ZendeskSupportService {
  static const _platformChannel = MethodChannel("com.rbdevs/zendesk_messaging");

  Future<bool> initialise(String channelKey) async {
    return await _platformChannel.invokeMethod("initialise", channelKey);
  }

  Future<bool> openZendeskMessaging() async {
    return await _platformChannel.invokeMethod("open_messaging");
  }
}
