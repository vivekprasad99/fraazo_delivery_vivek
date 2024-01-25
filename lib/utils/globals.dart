import 'package:flutter/scheduler.dart';
import 'package:fraazo_delivery/helpers/enums/app_update_type.dart';
import 'package:fraazo_delivery/helpers/error/error_reporter.dart';
import 'package:fraazo_delivery/helpers/route/route_helper.dart';
import 'package:fraazo_delivery/helpers/shared_pref/pref_helper.dart';
import 'package:fraazo_delivery/helpers/shared_pref/pref_keys.dart';
import 'package:fraazo_delivery/models/delivery/location.dart';
import 'package:fraazo_delivery/models/misc/AppMappingModel.dart';
import 'package:fraazo_delivery/models/user/profile/user_model.dart';
import 'package:fraazo_delivery/ui/screen_widgets/dialogs/mock_location_dialog.dart';
import 'package:fraazo_delivery/utils/constants.dart';

mixin Globals {
  static int appBuildNumber = 0;
  static String appVersion = "0";
  static String notificationType = '';

  static int riderVehicleId = 0;

  static String returnInventory = '';
  static String checkRiderLocation = '';
  static late User? user = null;
  static String linkUrl = '';
  static late List<Data> mappingData = [];
  static bool get isRiderAvailable =>
      user?.status == Constants.US_ONLINE ||
      user?.status == Constants.US_BUSY ||
      user?.status == Constants.US_APPROACHING;

  static late AppUpdateType appUpdateType = AppUpdateType.NONE;
  static late bool shouldShowBilling = true;
  static late bool isCurrentTaskCompletedDialogShown = false;
  static late bool isCancelledOrder = false;
  static late bool isSelfieEnabled = false;
  static late bool isSupportEnable = true;

  static Future<Location> getAssignedLocation(
      [double? latitude, double? longitude]) async {
    await PrefHelper.reload();
    if (Constants.isTestMode &&
        PrefHelper.getBool(PrefKeys.IS_TEMP_RIDER_LOCATION)) {
      return Location(
        latitude:
            PrefHelper.getDouble(PrefKeys.DUMMY_CURRENT_LATITUDE) ?? 19.113826,
        longitude:
            PrefHelper.getDouble(PrefKeys.DUMMY_CURRENT_LONGITUDE) ?? 72.891792,
      );
    } else {
      // As location service runs in background thread we need to reload to get latest instance
      return Location(
          latitude: PrefHelper.getDouble(PrefKeys.CURRENT_LATITUDE),
          longitude: PrefHelper.getDouble(PrefKeys.CURRENT_LONGITUDE));
    }
  }

  static bool checkAndShowMockLocationDialog() {
    try {
      if (PrefHelper.getBool(PrefKeys.IS_MOCK_LOCATION)) {
        SchedulerBinding.instance?.addPostFrameCallback((_) {
          RouteHelper.openDialog(
            MockLocationDialog(),
            barrierDismissible: false,
          );
        });
        if (Constants.isTestMode) {
          return false;
        }
        return true;
      }
    } catch (e, st) {
      ErrorReporter.error(e, st, "Globals: checkAndShowMockLocationDialog()");
    }
    return false;
  }
}
