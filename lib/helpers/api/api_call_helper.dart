import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio_firebase_performance/dio_firebase_performance.dart';
import 'package:fraazo_delivery/helpers/api/api_logging_interceptor.dart';
import 'package:fraazo_delivery/helpers/api/apis.dart';
import 'package:fraazo_delivery/helpers/api/sentry_interceptor.dart';
import 'package:fraazo_delivery/helpers/error/error_reporter.dart';
import 'package:fraazo_delivery/helpers/shared_pref/pref_helper.dart';
import 'package:fraazo_delivery/helpers/shared_pref/pref_keys.dart';
import 'package:fraazo_delivery/helpers/type_aliases/json.dart';
import 'package:fraazo_delivery/providers/splash/authentication_provider.dart';
import 'package:fraazo_delivery/ui/utils/toast.dart';
import 'package:fraazo_delivery/utils/constants.dart';

class ApiCallHelper {
  factory ApiCallHelper() {
    return _singleton;
  }

  ApiCallHelper._() {
    _addInterceptors(_dio);
  }

  static final ApiCallHelper _singleton = ApiCallHelper._();

  static final BaseOptions _options = BaseOptions(
    baseUrl: APIs.BASE_URL,
    connectTimeout: 30000,
  );

  static final Dio _dio = Dio(_options);

  Future<JsonMap?> get(String url,
          {JsonMap? queryParams,
          CancelToken? cancelToken,
          bool isAppUrl = true}) =>
      _apiRequestCall("GET", url,
          queryParams: queryParams,
          cancelToken: cancelToken,
          isAppUrl: isAppUrl);

  Future<JsonMap?> post(String url,
          {dynamic body,
          bool shouldSaveHeaders = false,
          CancelToken? cancelToken}) =>
      _apiRequestCall("POST", url,
          body: body,
          shouldSaveHeaders: shouldSaveHeaders,
          cancelToken: cancelToken);

  Future<JsonMap?> put(String url, {dynamic body}) =>
      _apiRequestCall("PUT", url, body: body);

  Future<JsonMap?> _apiRequestCall(String method, String url,
      {dynamic body,
      JsonMap? queryParams,
      bool shouldSaveHeaders = false,
      CancelToken? cancelToken,
      bool isAppUrl = true}) async {
    try {
      // if (isAppUrl == false) {
      //   _dio.options.baseUrl = APIs.RAZORPAY_BASE_URL;
      // } else {
      //   _dio.options.baseUrl = APIs.BASE_URL;
      // }
      final Response networkResponse = await _dio.request(
        url,
        data: body,
        queryParameters: queryParams,
        options: Options(method: method, headers: await _getHeaders()),
        cancelToken: cancelToken,
      );

      return _decodeSuccessResponse(networkResponse,
          shouldSaveHeaders: shouldSaveHeaders);
    } catch (e, st) {
      throw _decodeErrorResponse(e, st);
    }
  }

  Future<JsonMap?> apiRequestCall(
    String method,
    String url, {
    dynamic body,
    JsonMap? queryParams,
    JsonMap? headers,
  }) async {
    try {
      final dio = Dio();
      _addInterceptors(dio);
      final Response networkResponse = await dio.request(
        url,
        data: body,
        queryParameters: queryParams,
        options: Options(method: method, headers: headers),
      );

      return _decodeSuccessResponse(networkResponse);
    } catch (e, st) {
      throw _decodeErrorResponse(e, st);
    }
  }

  JsonMap? _decodeSuccessResponse(Response response,
      {bool shouldSaveHeaders = false}) {
    final responseData = response.data;
    if (responseData != null) {
      if (shouldSaveHeaders) {
        _saveHeaders(responseData!['token'] as String?);
      }
    }
    if (responseData == "") {
      _showErrorToast();
    }
    return responseData;
  }

  dynamic _decodeErrorResponse(dynamic dioError, StackTrace st) {
    if (dioError is DioError) {
      final int statusCode = dioError.response?.statusCode ?? 0;
      if (statusCode == 401 || statusCode == 403) {
        PrefHelper.setValue(PrefKeys.IS_SESSION_EXPIRED, true);

        AuthenticationProvider().logout(checkPermission: false);
      }
      if (dioError.error is SocketException) {
        _showErrorToast("No Internet Connection");
        return const SocketException("No Internet Connection");
      }

      String? errorMessage = "Oops, Try Again";
      if (statusCode >= 300) {
        final errorMessageFromServer = dioError.response?.data;
        try {
          errorMessage = (errorMessageFromServer['message'] ??
              errorMessageFromServer['status']) as String;
        } catch (e, st) {
          errorMessage = errorMessageFromServer.toString();
          ErrorReporter.error(
              e, st, "ApiCallHelper: _decodedErrorResponse() - $errorMessage");
        }
      }

      // ErrorReporter.error(dioError, st, "API Error");
      if (dioError.type != DioErrorType.cancel) {
        _showErrorToast(errorMessage);
        if (dioError.type == DioErrorType.response) {
          return dioError.response?.data;
        }
      }
    } else {
      _showErrorToast("Oops, Try Again");
      ErrorReporter.error(
          dioError, st, "Some Other Error = ${dioError.toString()}");
    }
    return dioError;
  }

  Future<JsonMap> _getHeaders() async {
    await PrefHelper.reload();

    return {
      if (PrefHelper.containsKey(PrefKeys.AUTHORIZATION))
        PrefKeys.AUTHORIZATION: PrefHelper.getString(PrefKeys.AUTHORIZATION),
      "content-type": "application/json",
      "app-build-number": PrefHelper.getInt(PrefKeys.APP_BUILD_NO) == 0
          ? '38'
          : PrefHelper.getInt(PrefKeys.APP_BUILD_NO), //Globals.appBuildNumber,
      "app-version": PrefHelper.getString(PrefKeys.APP_VERSION) ?? '1.0.38',
    };
  }
  // PrefHelper.setValue('version', snapshot.data?.version);
  // PrefHelper.setValue(
  // 'buildNumber', snapshot.data?.buildNumber);

  void _saveHeaders(String? token) {
    PrefHelper.setValue(PrefKeys.AUTHORIZATION, "Bearer $token");
  }

  void _showErrorToast([String errorMsg = "Oops,\nTry Again"]) {
    if (errorMsg.contains("html>")) {
      // ignore: parameter_assignments
      errorMsg = "Oops,\nTry Again";
    }
    Toast.error(errorMsg);
  }

  void _addInterceptors(Dio dio) {
    if (Constants.isTestMode) {
      dio.interceptors.add(APILoggingInterceptor());
    }
    dio.interceptors.add(DioFirebasePerformanceInterceptor());
    dio.interceptors.add(SentryInterceptor());
  }

  void clearHeaders() {
    _dio.options.headers.clear();
  }

  void clearRequestsQueue() {
    _dio.clear();
  }
}
