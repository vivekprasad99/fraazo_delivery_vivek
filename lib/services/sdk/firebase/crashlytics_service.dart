import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:fraazo_delivery/helpers/error/error_reporter.dart';
import 'package:fraazo_delivery/models/user/profile/user_model.dart';
import 'package:fraazo_delivery/utils/constants.dart';

import '../base_analytics.dart';

class CrashlyticsService extends BaseAnalytics {
  CrashlyticsService._();
  static final CrashlyticsService instance = CrashlyticsService._();

  @override
  void initialise() {
    FirebaseCrashlytics.instance
        .setCrashlyticsCollectionEnabled(Constants.isProductionRelease);
  }

  @override
  void setUserProperties(User user) {
    try {
      FirebaseCrashlytics.instance.setUserIdentifier(user.id.toString());
      FirebaseCrashlytics.instance.setCustomKey("Mobile No", user.mobile!);
      FirebaseCrashlytics.instance.setCustomKey("Name", user.fullName!);
    } catch (e, st) {
      ErrorReporter.error(e, st, "CrashlyticsService: setUserProperties()");
    }
  }

  @override
  void log(String message) {
    FirebaseCrashlytics.instance.log(message);
  }

  Future<void> recordError(dynamic error, StackTrace? stackTrace,
      {String? errorMsg}) {
    return FirebaseCrashlytics.instance
        .recordError(error, stackTrace, reason: errorMsg);
  }

  @override
  void logoutReset() {}
}
