import 'package:flutter/material.dart';
import 'package:fraazo_delivery/helpers/route/route_helper.dart';
import 'package:fraazo_delivery/models/user/device_verification_model.dart';
import 'package:fraazo_delivery/utils/utils.dart';

class RemoveDeviceAlert extends StatelessWidget {
  final DeviceVerificationData? deviceVerificationData;
  const RemoveDeviceAlert({required this.deviceVerificationData});
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        "Account Activities",
        style: commonTextStyle(
          fontSize: 18,
          color: Colors.blue,
        ),
      ),
      content: Text.rich(
        TextSpan(
          //text: 'Please select ',
          children: [
            TextSpan(
              text:
                  "You are currently logged in ${(deviceVerificationData?.imeiNumbers ?? []).length} devices. Please remove the device which does not belong to you.",
              style:
                  const TextStyle(fontWeight: FontWeight.normal, height: 1.2),
            ),
            const TextSpan(text: " & then "),
            const WidgetSpan(
              child: SizedBox(
                height: 15,
              ),
            ),
            WidgetSpan(
              child: Row(
                children: [
                  Expanded(
                    flex: 8,
                    child: Text(
                        'Device Id:${(deviceVerificationData?.imeiNumbers ?? []).single}'),
                  ),
                  Expanded(
                    flex: 2,
                    child: InkWell(
                      onTap: () => RouteHelper.pop(args: true),
                      child: Text(
                        'Remove',
                        style: commonTextStyle(
                          fontSize: 16,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                  )
                ],
              ),
            )
            //TextSpan(text: "If not, Please log in with your permanent device"),
          ],
        ),
      ),
      /*actions: [
        TextButton(
          onPressed: () => RouteHelper.pop(args: true),
          child: Text(
            "Confirm",
            style: commonTextStyle(
              fontSize: 18,
              color: Colors.blue,
            ),
          ),
        )
      ],*/
    );
  }
}
