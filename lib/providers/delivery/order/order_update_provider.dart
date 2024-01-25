import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fraazo_delivery/helpers/error/error_reporter.dart';
import 'package:fraazo_delivery/helpers/route/route_helper.dart';
import 'package:fraazo_delivery/models/delivery/delivery_items_model.dart';
import 'package:fraazo_delivery/models/delivery/task_model.dart';
import 'package:fraazo_delivery/models/misc/AppMappingModel.dart';
import 'package:fraazo_delivery/providers/delivery/latest_task_provider.dart';
import 'package:fraazo_delivery/services/api/delivery/delivery_service.dart';
import 'package:fraazo_delivery/services/location/gps_service.dart';
import 'package:fraazo_delivery/services/media/image/compressed_image_service.dart';
import 'package:fraazo_delivery/ui/screens/delivery/steps/local_widgets/dialogs/delivered_to_dialog.dart';
import 'package:fraazo_delivery/ui/screens/delivery/steps/local_widgets/dialogs/delivery_otp_dialog.dart';
import 'package:fraazo_delivery/ui/utils/toast.dart';
import 'package:fraazo_delivery/utils/constants.dart';

final orderUpdateProvider = StateNotifierProvider((_) => OrderUpdateProvider());

class OrderUpdateProvider extends StateNotifier<AsyncValue?> {
  OrderUpdateProvider([AsyncValue? state]) : super(state);

  final _deliveryService = DeliveryService();
  final _compressedImageService = CompressedImageService();

  late OrderSeq currentOrder;

  String? _currentOrderDeliveredTo;

  bool _isInTaskUpdateState = false;
  int clickCount = 3;

  Future updateOrderStatus(
    String orderStatus, {
    String? deliveredTo,
    String? deliveryOTP,
    OrderSeq? orderSeq,
  }) async {
    try {
      state = const AsyncLoading();

      await GPSService().checkGPSServiceAndSetCurrentLocation();

      final order = await _deliveryService.putOrderUpdate(
        orderStatus,
        orderSeq?.id,
        customerLat: orderSeq?.lat,
        customerLng: orderSeq?.lng,
        deliveredTo: deliveredTo,
        deliveryOTP: deliveryOTP,
      );
      currentOrder = order;
      state = AsyncData(order);
    } catch (e, st) {
      state = AsyncError(e, st);
      ErrorReporter.error(e, st, "OrderUpdateProvider: updateOrder()");
      rethrow;
    }
  }

  void updateOrderDetails(OrderSeq order) {
    state = AsyncData(order);
  }

  Future callToCustomer(String? orderNumber) {
    return _deliveryService.callToCustomer(orderNumber);
  }

  void clickCallButton() {
    if (clickCount >= 1) {
      Toast.normal('Please complete $clickCount attempts to call the customer');
      clickCount--;
    }
  }

  Future updateCollectedOrderAmount({
    required String collectedAmount,
    required String orderNumber,
    required OrderItems orderItemList,
    bool isOther = false,
    String comment = "",
  }) {
    return _deliveryService.postDeliveryAmount(
      collectedAmount: num.parse(collectedAmount),
      orderNumber: orderNumber,
      orderItemList: orderItemList,
      isOther: isOther,
      comment: comment,
    );
  }

  Future uploadQualityIssueImages(
      int? orderId, List<String> imagePathList) async {
    for (final imagePath in imagePathList) {
      final compressedImagePath =
          await _compressedImageService.compressAndGetFilePath(imagePath);
      await _deliveryService.postDeliveryImage(compressedImagePath, orderId);
    }
  }

  Future showDeliveredToDialog(int taskID) async {
    _currentOrderDeliveredTo ??=
        await RouteHelper.openDialog(DeliveredToDialog());
    if (_currentOrderDeliveredTo != null) {
      await Toast.popupLoadingFuture(future: () => endOrderDelivery(taskID));
    }
  }

  Future endOrderDelivery(int taskID,
      {OrderSeq? orderSeq, String? deliveredTo}) async {
    if (_isInTaskUpdateState) {
      return;
    }
    _isInTaskUpdateState = true;
    //bool isDeliveryMarked = false;
    final Completer<bool> _completer = Completer();
    await Toast.popupLoadingFuture(
      future: () => updateOrderStatus(
        Constants.OS_DELIVERED,
        deliveredTo: deliveredTo ?? _currentOrderDeliveredTo,
        orderSeq: orderSeq,
      ),
      onSuccess: (_) {
        _completer.complete(true);
        //isDeliveryMarked = true;
      },
      onFailure: () async {
        //isDeliveryMarked = await _showDeliveryOTPDialog(orderSeq!);
        _completer.complete(await _showDeliveryOTPDialog(orderSeq!));
      },
    );
    final isDeliveryMarked = await _completer.future;
    if (isDeliveryMarked) {
      _currentOrderDeliveredTo = null;
      RouteHelper.navigatorContext
          .read(latestTaskProvider.notifier)
          .taskOrderComplete(
            taskId: taskID,
            orderNumber: orderSeq?.orderNumber ?? '',
          );
    }

    /*if (isDeliveryMarked) {
      Toast.showSuccessAlerter("Delivered #${orderSeq?.orderNumber}");
      _currentOrderDeliveredTo = null;
      RouteHelper.navigatorContext
          .read(latestTaskProvider.notifier)
          .taskOrderComplete(
            taskId: taskID,
          );

      */ /*RouteHelper.navigatorContext
          .read(taskUpdateProvider.notifier)
          .onTaskComplete(taskID);*/ /*

    }*/
    _isInTaskUpdateState = false;
  }

  Future<bool> _showDeliveryOTPDialog(OrderSeq order) async {
    bool isVerifiedByOTP = false;
    final _isVerifiedSuccessFully = await RouteHelper.openDialog(
      DeliveryOtpDialog(
        order: order,
        onOTPSent: (String otp) async {
          await Toast.popupLoadingFuture(
            future: () => updateOrderStatus(
              Constants.OS_DELIVERED,
              deliveryOTP: otp,
              orderSeq: order,
            ),
            onSuccess: (_) {
              isVerifiedByOTP = true;
              RouteHelper.pop(args: true);
            },
          );
        },
      ),
    );
    return _isVerifiedSuccessFully ?? isVerifiedByOTP;
  }

  Future<AppMappingModel> getAppMappingData() {
    return _deliveryService.getAppMappingData();
  }
}
