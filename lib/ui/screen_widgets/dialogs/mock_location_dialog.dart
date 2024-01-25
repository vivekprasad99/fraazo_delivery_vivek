import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fraazo_delivery/helpers/route/route_helper.dart';
import 'package:fraazo_delivery/helpers/shared_pref/pref_helper.dart';
import 'package:fraazo_delivery/helpers/shared_pref/pref_keys.dart';
import 'package:fraazo_delivery/providers/location/location_provider.dart';
import 'package:fraazo_delivery/ui/global_widgets/flex_separated.dart';
import 'package:fraazo_delivery/ui/screen_widgets/dialog_button_bar.dart';
import 'package:fraazo_delivery/ui/utils/toast.dart';
import 'package:fraazo_delivery/utils/constants.dart';

class MockLocationDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _exitApp,
      child: Dialog(
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: FlexSeparated(
            mainAxisSize: MainAxisSize.min,
            direction: Axis.vertical,
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 15,
            children: [
              Text(
                "Fake location",
                style: Theme.of(context).textTheme.headline6,
              ),
              Text(
                "It seems that you are using fake(mock) location.\n"
                "Beware that fake location is not allowed at all. Please disable fake location and Retry again.",
                style: Theme.of(context).textTheme.subtitle1,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (Constants.isTestMode) ...[
                    TextButton(
                      onPressed: () => RouteHelper.pop(),
                      child: const Text("Skip"),
                    ),
                  ],
                  DialogButtonBar(
                    confirmText: "Retry",
                    onConfirmTap: () => _onRetryTap(context),
                    cancelText: "Exit App",
                    onCancelTap: _exitApp,
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Future _onRetryTap(BuildContext context) async {
    final cancelFunc = Toast.popupLoading();
    try {
      await context
          .read(locationProvider)
          .checkForGPSStatus(shouldCheckWithoutAvailability: true);
      if (!PrefHelper.getBool(PrefKeys.IS_MOCK_LOCATION)) {
        RouteHelper.pop();
      } else {
        Toast.normal("Fake GPS is not disabled yet.");
      }
    } finally {
      cancelFunc();
    }
  }

  Future<bool> _exitApp() async {
    RouteHelper.exitApp();
    return false;
  }
}
