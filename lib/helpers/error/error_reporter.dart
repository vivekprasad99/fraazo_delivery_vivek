import 'package:fraazo_delivery/services/sdk/sentry/sentry_service.dart';

class ErrorReporter {
  static Future error(dynamic error,
      [StackTrace? stackTrace, String? errorMsg]) async {
    /*log(errorMsg,
        error: error, stackTrace: stackTrace, name: "⛔️Error Reporter");*/
    await SentryService().recordError(error, stackTrace, errorMsg: errorMsg);
    // await CrashlyticsService.instance
    //     .recordError(error, stackTrace, errorMsg: errorMsg);
  }
}
