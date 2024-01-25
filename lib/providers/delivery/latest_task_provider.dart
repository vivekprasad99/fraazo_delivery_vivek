import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fraazo_delivery/helpers/error/error_reporter.dart';
import 'package:fraazo_delivery/helpers/route/route_helper.dart';
import 'package:fraazo_delivery/helpers/shared_pref/pref_helper.dart';
import 'package:fraazo_delivery/helpers/shared_pref/pref_keys.dart';
import 'package:fraazo_delivery/models/delivery/task_model.dart';
import 'package:fraazo_delivery/providers/delivery/order/order_update_provider.dart';
import 'package:fraazo_delivery/providers/delivery/task_update_provider.dart';
import 'package:fraazo_delivery/services/api/delivery/delivery_service.dart';
import 'package:fraazo_delivery/utils/constants.dart';
import 'package:fraazo_delivery/utils/globals.dart';

final latestTaskProvider =
    StateNotifierProvider<LatestTaskProvider, AsyncValue<Task?>>(
  (_) => LatestTaskProvider(),
);

class LatestTaskProvider extends StateNotifier<AsyncValue<Task?>> {
  LatestTaskProvider([AsyncValue<Task?> state = const AsyncLoading()])
      : super(state);

  final _deliveryService = DeliveryService();

  Task? currentTask;

  Future<Task?> getLatestTask() async {
    state = const AsyncLoading();
    try {
      final Task? task = await _deliveryService.getGetLatestTask();
      await setNewTask(task);
      return task;
    } catch (e, st) {
      state = AsyncError(e, st);
      ErrorReporter.error(e, st, "LatestTaskProvider: getLatestTask()");
    }
  }

  Future setNewTask(Task? task) async {
    if (task != null) {
      PrefHelper.setValue(PrefKeys.CURRENT_TASK_ID, task.id);
      PrefHelper.setValue(PrefKeys.IS_NEW_ORDER, true);
      PrefHelper.setValue(PrefKeys.IS_CALL_ENABLE, false);
      Globals.user?.status = Constants.US_BUSY;
      if (task.orderSeq?.isNotEmpty ?? false) {
        RouteHelper.navigatorContext
            .read(orderUpdateProvider.notifier)
            .currentOrder = task.orderSeq!.first;
      }
    } else {
      await PrefHelper.removeValue(PrefKeys.CURRENT_TASK_ID);
      PrefHelper.setValue(PrefKeys.IS_NEW_ORDER, false);
      Globals.user?.status = Constants.US_ONLINE;
      PrefHelper.setValue(PrefKeys.IS_NEW_ORDER, false);
    }
    currentTask = task;
    state = AsyncData(task);
  }

  Future assignTaskByQR(int orderID) {
    return _deliveryService.postAssignTaskQR(orderID);
  }

  Future<void> taskOrderComplete(
      {required int taskId, required String orderNumber}) async {
    await getLatestTask();
    final orderSeqList = state.data?.value?.orderSeq;

    if (orderSeqList?.last.orderStatus == Constants.OS_DELIVERED ||
        orderSeqList?.last.orderStatus == Constants.OS_CANCELLED_BY_FRZ ||
        orderSeqList?.last.orderStatus == Constants.OS_RESCHEDULED) {
      await RouteHelper.navigatorContext
          .read(taskUpdateProvider.notifier)
          .onTaskComplete(taskId,
              orderNumber: '', isSingleOrder: orderSeqList!.length == 1);
    } else {
      await RouteHelper.navigatorContext
          .read(taskUpdateProvider.notifier)
          .onCompleteOperations(
              orderNumber: orderNumber,
              isSingleOrder: orderSeqList!.length == 1);
    }
  }

  List<OrderSeq>? getOrderSeq() => state.data?.value?.orderSeq?.toList();
}
