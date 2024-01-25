import 'dart:convert';
import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:fraazo_delivery/models/misc/api_logger_model.dart';
import 'package:fraazo_delivery/providers/misc/api_logger_provider.dart';
import 'package:intl/intl.dart';

class APILoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    dynamic requestBody = options.data ?? options.queryParameters;
    if (requestBody is FormData) {
      requestBody = "${requestBody.fields}\n${requestBody.files}";
    } else {
      requestBody = json.encode(requestBody);
    }
    log(
      "${options.baseUrl} => ${options.method} => ${options.path}",
      error: requestBody,
      name: "⏳ Request",
    );
    log(
      "",
      error: options.headers.toString(),
      name: "💀 Headers-Request",
    );

    return super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    final apiLoggerModel =
        _getApiLoggerModel(response.requestOptions, response);
    log(
      "${apiLoggerModel.requestMethod} =>  ${apiLoggerModel.statusCode} : ${apiLoggerModel.pathURL}${response.requestOptions.queryParameters}",
      error: json.encode(response.data),
      name: "✅ Response",
    );
    ApiLoggerProvider().addApiLogger(apiLoggerModel);
    return super.onResponse(response, handler);
  }

  @override
  void onError(DioError err, ErrorInterceptorHandler handler) {
    final apiLoggerModel = _getApiLoggerModel(err.requestOptions, err.response);
    log(
      "${err.requestOptions.method} =>  ${err.response?.statusCode} : ${err.requestOptions.path}${err.requestOptions.queryParameters}",
      error: json.encode(err.response?.data),
      name: "❌ Error-Response",
    );
    ApiLoggerProvider().addApiLogger(apiLoggerModel);
    return super.onError(err, handler);
  }

  ApiLoggerModel _getApiLoggerModel(
      RequestOptions requestOptions, Response? response) {
    dynamic requestJson = requestOptions.data ?? requestOptions.queryParameters;
    if (requestJson is FormData) {
      requestJson = requestJson.fields.toList().toString();
    }
    return ApiLoggerModel(
      requestMethod: requestOptions.method,
      statusCode: response?.statusCode ?? 0,
      pathURL: requestOptions.path,
      requestData: _prettyJson(requestJson),
      responseData: _prettyJson(response?.data),
      logTime: DateFormat.jms().format(DateTime.now()),
    );
  }

  String _prettyJson(dynamic json, {int indent = 2}) {
    final spaces = ' ' * indent;
    final encoder = JsonEncoder.withIndent(spaces);
    return encoder.convert(json);
  }
}
