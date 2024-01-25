import 'package:flutter/material.dart';
import 'package:fraazo_delivery/helpers/route/route_helper.dart';

class LocationPermissionInfoDialog extends StatelessWidget {
  const LocationPermissionInfoDialog();
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Allow all the time"),
      content: const Text.rich(
        TextSpan(
          text: 'Please select ',
          children: [
            TextSpan(
                text: "Allow only while using the app",
                style: TextStyle(fontWeight: FontWeight.bold)),
            TextSpan(text: " & then "),
            TextSpan(
                text: "Allow all the time",
                style: TextStyle(fontWeight: FontWeight.bold)),
            TextSpan(
                text: " from the options to proceed."
                    "\n\nThis app collects location data in order to keep user current location up-to date with Fraazo's system "
                    "in order to check whether user is near to address to start or deliver order even when the app is closed or not in use only when user is in Online mode."),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => RouteHelper.pop(),
          child: const Text("Sure"),
        )
      ],
    );
  }
}
