import 'package:flutter/material.dart';
import 'package:fraazo_delivery/helpers/enums/app_update_type.dart';
import 'package:fraazo_delivery/helpers/route/route_helper.dart';
import 'package:fraazo_delivery/utils/device_app_launcher.dart';

class AppUpdateDialog extends StatelessWidget {
  final AppUpdateType appUpdateType;

  const AppUpdateDialog(this.appUpdateType);

  @override
  Widget build(BuildContext context) {
    final bool isForced = appUpdateType == AppUpdateType.FORCED_APP_VERSION;
    return WillPopScope(
      onWillPop: () => _onExitOrLater(isForced),
      child: AlertDialog(
        title: const Text("Update Available"),
        content: Text(isForced
            ? "Please update app to new version to continue using."
            : "Please update app to new version for latest features and changes.\nCan be skipped for later."),
        actions: [
          TextButton(
              onPressed: () => _onExitOrLater(isForced),
              child: Text(isForced ? "Exit" : "Later")),
          TextButton(
              onPressed: () => DeviceAppLauncher().launchByUrl(
                  "https://play.google.com/store/apps/details?id=com.fraazo.delivery"),
              child: const Text("Update")),
        ],
      ),
    );
  }

  Future<bool> _onExitOrLater(bool isForced) async {
    if (isForced) {
      RouteHelper.exitApp();
    } else {
      RouteHelper.pop();
    }
    return false;
  }
}
