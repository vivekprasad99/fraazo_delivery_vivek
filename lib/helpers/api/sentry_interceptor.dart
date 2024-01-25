import 'package:dio/dio.dart';
import 'package:fraazo_delivery/services/sdk/sentry/sentry_service.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

class SentryInterceptor extends InterceptorsWrapper {
  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    SentryService().addBreadcrumb(
      Breadcrumb(
        type: 'http',
        category: 'http',
        data: {
          'url': response.requestOptions.uri.toString(),
          'method': response.requestOptions.method,
          'status_code': response.statusCode,
          'reason': response.statusMessage,
        },
        message: 'API SUCCESS',
      ),
    );
    super.onResponse(response, handler);
  }

  @override
  void onError(DioError err, ErrorInterceptorHandler handler) {
    SentryService().addBreadcrumb(
      Breadcrumb(
        type: 'http',
        category: 'http',
        data: {
          'url': err.requestOptions.uri.toString(),
          'method': err.requestOptions.method,
          'status_code': err.response?.statusCode ?? "NA",
          'reason': err.response?.statusMessage,
        },
        message: 'API FAILURE',
      ),
    );
    super.onError(err, handler);
  }
}
