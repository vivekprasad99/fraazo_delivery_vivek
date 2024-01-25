import 'package:flutter/material.dart';
import 'package:fraazo_delivery/utils/globals.dart';
import 'package:fraazo_delivery/utils/utils.dart';
import 'package:fraazo_delivery/values/custom_colors.dart';
import 'package:geolocator/geolocator.dart';
import 'package:package_info/package_info.dart';

class AppVersionWidget extends StatelessWidget {
  const AppVersionWidget();

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Geolocator.openAppSettings(),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Align(
          heightFactor: 1,
          widthFactor: 1,
          child: FutureBuilder<PackageInfo>(
            future: PackageInfo.fromPlatform(),
            builder: (_, snapshot) {
              if (snapshot.hasData) {
                Globals.appBuildNumber = int.parse(snapshot.data!.buildNumber);
                Globals.appVersion = snapshot.data!.version;
              }
              return Text(
                "App version ${snapshot.data?.version} (${snapshot.data?.buildNumber})",
                style: commonTextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: textColor),
              );
            },
          ),
        ),
      ),
    );
  }
}
