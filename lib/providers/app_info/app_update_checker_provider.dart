import 'package:fraazo_delivery/helpers/enums/app_update_type.dart';
import 'package:fraazo_delivery/helpers/error/error_reporter.dart';
import 'package:fraazo_delivery/helpers/shared_pref/pref_helper.dart';
import 'package:fraazo_delivery/helpers/shared_pref/pref_keys.dart';
import 'package:fraazo_delivery/helpers/type_aliases/json.dart';
import 'package:fraazo_delivery/services/sdk/firebase/firebase_firestore_service.dart';
import 'package:fraazo_delivery/utils/globals.dart';
import 'package:package_info/package_info.dart';

class AppUpdateCheckerProvider {
  final _firebaseFirestoreService = FirebaseFirestoreService();

  Future<AppUpdateType> checkForAppUpdate() async {
    try {
      final JsonMap? appVersions =
          await _firebaseFirestoreService.getAppVersions();

      final int forcedAndroidVersion = appVersions?["forced-android-version"];
      final int recommendedAndroidVersion =
          appVersions?["recommended-android-version"];

      final PackageInfo packageInfo = await PackageInfo.fromPlatform();
      final int buildNumber = int.parse(packageInfo.buildNumber);
      Globals.appBuildNumber = buildNumber;
      Globals.appVersion = packageInfo.version;

      if (forcedAndroidVersion > buildNumber) {
        Globals.appUpdateType = AppUpdateType.FORCED_APP_VERSION;
      } else if (recommendedAndroidVersion > buildNumber) {
        Globals.appUpdateType = AppUpdateType.RECOMMENDED_APP_VERSION;
      }
    } catch (e, st) {
      ErrorReporter.error(
          e, st, "LatestAppVersionProvider: checkIfUpdateAvailable()");
    }
    return Globals.appUpdateType;
  }

  Future<bool> checkForAssetManagement() async {
    bool isAssetMngmtEnable = false;
    try {
      final JsonMap? assetManagement =
          await _firebaseFirestoreService.getAssetManagementConfig();

      isAssetMngmtEnable = assetManagement?["is_enable"];
      print('checkForAssetManagement $isAssetMngmtEnable');
    } catch (e, st) {
      ErrorReporter.error(
          e, st, "Asset Management Enable: checkForAssetManagement()");
    }
    PrefHelper.setValue(PrefKeys.IS_ASSET_ENABLE, isAssetMngmtEnable);
    return isAssetMngmtEnable;
  }
}
