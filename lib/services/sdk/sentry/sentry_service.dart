import 'package:dio/dio.dart';
import 'package:fraazo_delivery/helpers/error/error_reporter.dart';
import 'package:fraazo_delivery/models/user/profile/user_model.dart';
import 'package:fraazo_delivery/services/sdk/base_analytics.dart';
import 'package:fraazo_delivery/utils/constants.dart';
import 'package:fraazo_delivery/utils/sdk_keys.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

class SentryService extends BaseAnalytics {
  factory SentryService() {
    return _instance;
  }
  static final _instance = SentryService._();
  SentryService._();

  @override
  Future initialise([AppRunner? appRunner]) {
    return SentryFlutter.init(
      (options) {
        options
          ..dsn = SDKKeys.SENTRY_DSN
          ..beforeSend = _beforeSend
          ..environment =
              Constants.isProductionRelease ? "production" : "staging";
      },
      appRunner: appRunner,
    );
  }

  SentryEvent _beforeSend(SentryEvent event, {dynamic hint}) {
    if (event.throwable is DioError) {
      try {
        final dioError = event.throwable as DioError;
        final request = dioError.requestOptions;
        String errorMessage = "";
        if (dioError.response?.data is Map) {
          errorMessage = dioError.response?.data['message'];
        }
        //ignore: parameter_assignments
        event = event.copyWith(
          tags: {
            "error_type": "API",
            "status_code": dioError.response?.statusCode?.toString() ?? "",
          },
          extra: {
            "method": request.method,
            "path": request.path,
            "request": request.data ?? request.queryParameters,
            "status_code": dioError.response?.statusCode,
            "response": dioError.response?.data,
          },
          message: event.message != null
              ? event.message?.copyWith(formatted: hint)
              : SentryMessage(hint),
          exceptions: [
            if (event.exceptions != null && event.exceptions!.isNotEmpty)
              event.exceptions!.first.copyWith(
                  type: "API Error",
                  value:
                      "Status Code: ${dioError.response?.statusCode} | Path: ${request.path} | Error: $errorMessage")
          ],
        );
      } catch (e, st) {
        ErrorReporter.error(e, st, "SentryService: _beforeSend()");
      }
    }
    return event;
  }

  @override
  void log(String name) {}

  @override
  void setUserProperties(User user) {
    Sentry.configureScope((scope) {
      scope.user =
          SentryUser(id: user.id.toString(), username: user.mobile, extras: {
        'Full Name': user.fullName,
        'Mobile No': user.mobile,
        'Vendor Id': user.vendorId,
        'Rider status': user.status,
      });
    });
  }

  @override
  void logoutReset() {}

  Future<SentryId> recordError(dynamic error, StackTrace? stackTrace,
      {String? errorMsg}) {
    return Sentry.captureException(error,
        stackTrace: stackTrace, hint: errorMsg);
  }

  void addBreadcrumb(Breadcrumb breadcrumb) {
    Sentry.addBreadcrumb(breadcrumb);
  }
}
