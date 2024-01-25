import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fraazo_delivery/helpers/api/apis.dart';
import 'package:fraazo_delivery/helpers/error/error_reporter.dart';
import 'package:fraazo_delivery/models/delivery/task_status_model.dart';
import 'package:fraazo_delivery/services/socket/new_task_socket.dart';
import 'package:fraazo_delivery/ui/utils/toast.dart';
import 'package:fraazo_delivery/utils/constants.dart';
import 'package:fraazo_delivery/utils/globals.dart';

final taskBySocketProvider =
    StateNotifierProvider((_) => TaskBySocketProvider());

class TaskBySocketProvider extends StateNotifier<TaskStatusModel?> {
  TaskBySocketProvider([TaskStatusModel? state]) : super(state);
  final _newTaskSocket = NewTaskSocket();

  bool _isConnected = false;
  bool _isClosedManually = false;

  void open() {
    if (_isConnected) return;
    _isClosedManually = false;
    _newTaskSocket.connectSocketChannel(socketURL);
    _listenToStream();
    _isConnected = true;
  }

  void _listenToStream() {
    _newTaskSocket.subscribeToSocketStream?.listen((data) {
      log("SOCKET Data", error: data);
      _onSocketData(data);
    }, onDone: () {
      log("SOCKET onDone");
      _isConnected = false;
      if (!_isClosedManually) {
        open();
      }
    }, onError: (e, st) {
      _isConnected = false;
      log("SOCKET onError : ", error: e, stackTrace: st);
      ErrorReporter.error(
          e, st, "TaskBySocketProvider: _listenToStream() - Socket onError");
    });
  }

  void _onSocketData(dynamic data) {
    final Map<String, dynamic> decodedJson = json.decode(data);

    final Map<String, dynamic> decodedDataJson =
        json.decode(decodedJson['data']);

    final taskStatus = TaskStatusModel.fromJson(decodedDataJson);
    if (taskStatus.type == "TASK") {
      state?.task?.expiresIn = decodedDataJson["expires_in"] ?? 60;
      // state = taskStatus;
    } else if (taskStatus.type == Constants.TS_DELETE) {
      if (taskStatus.task != null) {
        Toast.normal("This task #${taskStatus.task?.taskId} is removed.");
      }
    }
    state = taskStatus;
  }

  String get socketURL => "${APIs.WS__GET_TASK}${"/${Globals.user?.id}"}";

  Future close() async {
    _isClosedManually = true;
    await _newTaskSocket.closeSocketChannel();
    _isConnected = false;
  }
}
