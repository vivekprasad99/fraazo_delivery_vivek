import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fraazo_delivery/helpers/error/error_reporter.dart';
import 'package:fraazo_delivery/helpers/route/route_helper.dart';
import 'package:fraazo_delivery/models/delivery/generate_qr_model.dart';
import 'package:fraazo_delivery/models/delivery/task_model.dart';
import 'package:fraazo_delivery/providers/user/profile/user_profile_provider.dart';
import 'package:fraazo_delivery/providers/user/todays_stats_provider.dart';
import 'package:fraazo_delivery/services/api/delivery/delivery_service.dart';
import 'package:fraazo_delivery/services/location/gps_service.dart';
import 'package:fraazo_delivery/services/media/sound/feedback_service.dart';
import 'package:fraazo_delivery/ui/screens/delivery/steps/local_widgets/dialogs/task_complete_dialog.dart';
import 'package:fraazo_delivery/ui/utils/toast.dart';
import 'package:fraazo_delivery/utils/constants.dart';

import '../../helpers/shared_pref/pref_helper.dart';
import '../../helpers/shared_pref/pref_keys.dart';
import 'latest_task_provider.dart';

final taskUpdateProvider = StateNotifierProvider((_) => TaskUpdateProvider());

class TaskUpdateProvider extends StateNotifier<AsyncValue?> {
  TaskUpdateProvider([AsyncValue? state]) : super(state);

  final _deliveryService = DeliveryService();

  Future updateTask(int? taskId, String taskStatus) async {
    state = const AsyncLoading();
    try {
      await GPSService().checkGPSServiceAndSetCurrentLocation();

      final Task? task =
          await _deliveryService.putTaskUpdate(taskId, taskStatus);
      state = AsyncData(task);
    } catch (e, st) {
      state = AsyncError(e, st);
      ErrorReporter.error(e, st, "TaskUpdateProvider: updateTask()");
      rethrow;
    }
  }

  Future sendDeliveryVerificationOTP(String? customerMobileNo, int? orderId) {
    return _deliveryService.postDeliverySMS(customerMobileNo, orderId);
  }

  Future onTaskComplete(int? taskID,
      {required String orderNumber,
      String orderStatus = '',
      bool isSingleOrder = false}) async {
    if (taskID != null) {
      return Toast.popupLoadingFuture(
        future: () => RouteHelper.navigatorContext
            .read(taskUpdateProvider.notifier)
            .updateTask(taskID, Constants.TS_COMPLETED),
        onSuccess: (_) => onCompleteOperations(
            orderNumber: orderNumber,
            orderStatus: orderStatus,
            isSingleOrder: isSingleOrder),
      );
    } else {
      return onCompleteOperations(
          orderNumber: orderNumber,
          orderStatus: orderStatus,
          isSingleOrder: isSingleOrder);
    }
  }

  Future onCompleteOperations(
      {required String orderNumber,
      String orderStatus = '',
      bool isSingleOrder = false}) async {
    final context = RouteHelper.navigatorContext;

    FeedbackService().vibrate();
    RouteHelper.openBottomSheet(
      TaskCompleteDialog(
        orderNumber: orderNumber,
        orderStatus: orderStatus,
        isSingleOrder: isSingleOrder,
      ),
    );
    // RouteHelper.openDialog(TaskCompleteDialog(), barrierDismissible: false);
    PrefHelper.setValue(PrefKeys.IS_NEW_ORDER, false);
    PrefHelper.setValue(PrefKeys.IS_CALL_ENABLE, false);
    context
        .read(userProfileProvider.notifier)
        .changeUserStatus(Constants.US_ONLINE);
    context.read(latestTaskProvider.notifier).getLatestTask();
    context.read(todaysStatsProvider.notifier).getStats();
    context.read(userProfileProvider.notifier).getUserDetails();
  }

  Future updateReachedDarkStore() {
    return _deliveryService.getStatusChangeApproaching();
  }

  Future<GenerateQRModel> generateQRCodeForCOD(
      {String? orderNumber, int? taskID, num? amount}) {
    return _deliveryService.postPaymentQRGenerate(
        orderNumber: orderNumber, taskID: taskID, amount: amount);
  }

  Future<bool> verifyPaymentQR(int currentTaskID) {
    return _deliveryService.postQRPaymentVerify(currentTaskID);
  }

  Future<Map<String, dynamic>> createZendeskTicket(
      int currentTaskID, String orderNo, num? amount) {
    return _deliveryService.createZendeskTicket(currentTaskID, orderNo, amount);
  }
}
