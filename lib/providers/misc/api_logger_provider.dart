import 'dart:async';
import 'dart:convert';

import 'package:fraazo_delivery/helpers/shared_pref/pref_helper.dart';
import 'package:fraazo_delivery/helpers/shared_pref/pref_keys.dart';
import 'package:fraazo_delivery/models/misc/api_logger_model.dart';

class ApiLoggerProvider {
  factory ApiLoggerProvider() {
    return _instance;
  }
  ApiLoggerProvider._();
  static final ApiLoggerProvider _instance = ApiLoggerProvider._();

  final StreamController<List<ApiLoggerModel>> _controller =
      StreamController<List<ApiLoggerModel>>.broadcast();

  StreamSink<List<ApiLoggerModel>> get _sink => _controller.sink;

  Stream<List<ApiLoggerModel>> get stream => _controller.stream;

  Future getApiLoggerList() async {
    _sink.add(await getStoredList());
  }

  Future addApiLogger(ApiLoggerModel apiLogger) async {
    // Have to store in shared preferences bcz of
    // background location tracking is there, as it runs in background

    final List<ApiLoggerModel> apiLoggerList = await getStoredList()
      ..add(apiLogger);
    final String encodeList = json.encode(
        apiLoggerList.map<Map<String, dynamic>>((al) => al.toJson()).toList());
    PrefHelper.setValue(PrefKeys.API_LOG_LIST, encodeList);
    _sink.add(apiLoggerList);
  }

  Future<List<ApiLoggerModel>> getStoredList() async {
    await PrefHelper.reload();
    final String stringData =
        PrefHelper.getString(PrefKeys.API_LOG_LIST) ?? "[]";
    final List savedJsonList = json.decode(stringData);
    final List<ApiLoggerModel> apiLoggerList =
        savedJsonList.map((v) => ApiLoggerModel.fromJson(v)).toList();

    return apiLoggerList;
  }

  void clearLogs() {
    PrefHelper.removeValue(PrefKeys.API_LOG_LIST);
    _sink.add([]);
  }

  void dispose() {
    _controller.close();
  }
}
