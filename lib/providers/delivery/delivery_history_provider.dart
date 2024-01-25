import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fraazo_delivery/helpers/error/error_reporter.dart';
import 'package:fraazo_delivery/models/delivery/delivery_history_model.dart';
import 'package:fraazo_delivery/models/delivery/task_model.dart';
import 'package:fraazo_delivery/services/api/delivery/delivery_service.dart';

class DeliveryHistoryProvider
    extends StateNotifier<AsyncValue<DeliveryHistory>?> {
  DeliveryHistoryProvider([AsyncValue<DeliveryHistory>? state]) : super(state);
  final _deliveryService = DeliveryService();
  DeliveryHistory? _deliveryHistory;
  List<Task>? _taskList = [];

  Future getTaskHistory(
      {String from = "",
      String to = "",
      String taskid = "",
      String orderId = ""}) async {
    state = const AsyncLoading();
    try {
      // As date shown as dd-mm-yyyy then just reverse to send it
      _deliveryHistory = await _deliveryService.postGetTaskHistory(from, to,
          orderNumber: orderId, taskId: taskid);
      _taskList = _deliveryHistory?.tasks?.map((element) => element).toList();

      state = AsyncData(_deliveryHistory!);
    } catch (e, st) {
      state = AsyncError(e, st);
      ErrorReporter.error(e, st, "DeliveryHistoryProvider: getTaskHistory()");
    }
  }

  void getSearchItem(String queryTxt) {
    if (queryTxt.isNotEmpty) {
      final _searchList = getFilterTaskHistory(queryTxt);
      if (_searchList.isNotEmpty) {
        _getUpdatedList(_searchList);
      } else {
        _deliveryHistory?.tasks?.clear();
        state = AsyncData(_deliveryHistory!);
      }
    } else {
      _getUpdatedList(_taskList!);
    }
  }

  List<Task> getFilterTaskHistory(String queryTxt) {
    final _taskList = this._taskList ?? [];

    final _searchedTaskList = _taskList
        .where((task) => task.id.toString().contains(queryTxt))
        .toList();

    if (_searchedTaskList.isNotEmpty) {
      return _searchedTaskList;
    } else {
      return _taskList
          .where(
            (task) => (task.orderSeq ?? [])
                .where(
                  (order) => (order.orderNumber ?? '').contains(queryTxt),
                )
                .isNotEmpty,
          )
          .toList();
    }
  }

  void _getUpdatedList(List<Task> updatedList) {
    _deliveryHistory?.tasks?.clear();
    _deliveryHistory?.tasks?.addAll(updatedList);
    state = AsyncData(_deliveryHistory!);
  }

  // Future<List<Task>?> getFilterTaskHistory(String queryTxt) async {
  //   try {
  //     _deliveryHistory?.tasks?.where((m) => m.orderSeq!
  //         .where((s) =>
  //         s.id.toString().contains(queryTxt)) // or Testing 123
  //         .isNotEmpty)
  //         .toList();
  //     return _deliveryHistory?.tasks
  //         ?.where((element) =>
  //             element.taskId.toString().contains(queryTxt) ||
  //             (element.orderSeq.where(
  //                 (orderSeq) => orderSeq.id.toString().contains(queryTxt))))
  //         .toList()
  //         .toList();
  //   } catch (e, st) {
  //     state = AsyncError(e, st);
  //     ErrorReporter.error(e, st, "DeliveryHistoryProvider: getTaskHistory()");
  //   }
  // }

  @override
  void dispose() {
    _deliveryService.cancelToken("DeliveryHistoryProvider");
    super.dispose();
  }
}
