import 'dart:async';

import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:fraazo_delivery/helpers/error/error_reporter.dart';
import 'package:fraazo_delivery/ui/utils/toast.dart';
import 'package:url_launcher/url_launcher.dart';

class DeviceAppLauncher {
  Future callPhoneNumber(String phoneNumber) async {
    final bool? isCalled =
        await FlutterPhoneDirectCaller.callNumber(phoneNumber);
    if (!isCalled!) {
      launchByUrl("tel:$phoneNumber");
    }
  }

  Future launchByUrl(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      Toast.normal("Sorry! Failed to open.");
      ErrorReporter.error("Failed to open url $url");
    }
  }
}
