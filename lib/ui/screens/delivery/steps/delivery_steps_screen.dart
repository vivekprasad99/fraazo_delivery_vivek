import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fraazo_delivery/helpers/enums/delivery_type.dart';
import 'package:fraazo_delivery/helpers/route/route_helper.dart';
import 'package:fraazo_delivery/helpers/route/routes.dart';
import 'package:fraazo_delivery/helpers/shared_pref/pref_helper.dart';
import 'package:fraazo_delivery/helpers/shared_pref/pref_keys.dart';
import 'package:fraazo_delivery/models/delivery/delivery_step.dart';
import 'package:fraazo_delivery/models/delivery/location.dart';
import 'package:fraazo_delivery/models/delivery/task_model.dart';
import 'package:fraazo_delivery/providers/delivery/latest_task_provider.dart';
import 'package:fraazo_delivery/providers/delivery/order/order_update_provider.dart';
import 'package:fraazo_delivery/providers/delivery/task_update_provider.dart';
import 'package:fraazo_delivery/providers/location/location_provider.dart';
import 'package:fraazo_delivery/services/sdk/firebase/firebase_notification_service.dart';
import 'package:fraazo_delivery/ui/global_widgets/fd_app_bar.dart';
import 'package:fraazo_delivery/ui/screens/delivery/steps/local_widgets/dialogs/delivery_otp_dialog.dart';
import 'package:fraazo_delivery/ui/screens/delivery/steps/local_widgets/timeline_widget.dart';
import 'package:fraazo_delivery/ui/utils/toast.dart';
import 'package:fraazo_delivery/utils/constants.dart';
import 'package:fraazo_delivery/utils/globals.dart';
import 'package:geolocator/geolocator.dart';

import '../../../../models/misc/AppMappingModel.dart';
import '../../../../services/api/delivery/delivery_service.dart';
import '../../../../services/sdk/firebase/crashlytics_service.dart';
import '../../../screen_widgets/dummy_location_switch.dart';
import 'local_widgets/current_delivery_details_widget.dart';
import 'local_widgets/dialogs/delivered_to_dialog.dart';
import 'local_widgets/order_skus_selection_sheet.dart';

class DeliveryStepsScreen extends StatefulWidget {
  final Task? task;

  const DeliveryStepsScreen(this.task, {Key? key}) : super(key: key);

  @override
  _DeliveryStepsScreenState createState() => _DeliveryStepsScreenState();
}

class _DeliveryStepsScreenState extends State<DeliveryStepsScreen> {
  final List<DeliveryStep> _deliveryStepsList = [];

  int _currentStatusIndex = 0;
  bool _isFirstOpen = false;
  final _deliveryService = DeliveryService();
  // To keep values in-case of api fails
  late bool _isOrderSkusSelected = false;
  late DeliveryType? _deliveryType = null;
  String? _currentOrderDeliveredTo;
  final _isCallProvider = StateProvider.autoDispose((_) => false);

  Timer? timer;
  StreamSubscription<Position>? positionStream;

  Future<void> _listenLocation() async {
    positionStream = Geolocator.getPositionStream(
      desiredAccuracy: LocationAccuracy.bestForNavigation,
      distanceFilter: 10,
      intervalDuration: const Duration(seconds: 10),
    ).listen(
      (Position? position) {
        // debugPrint("Print after 10 seconds");
        // print(
        //     "Rider current location ${position?.latitude}  ${position?.longitude} \n order location ${widget.task!.orderSeq![0].lat} ${widget.task!.orderSeq![0].lng}");

        try {
          // Toast.normal('Rider current location');
          if (position != null) {
            double distanceInMeters = Geolocator.distanceBetween(
                position.latitude,
                position.longitude,
                widget.task!.orderSeq![0].lat!,
                widget.task!.orderSeq![0].lng!);
            CrashlyticsService.instance.log(
                "Rider current location ${position.latitude}  ${position.longitude} \n order location ${widget.task!.orderSeq![0].lat} ${widget.task!.orderSeq![0].lng} distance $distanceInMeters");

            if (distanceInMeters <= 200) {
              PrefHelper.setValue(PrefKeys.IS_NEW_ORDER, false);
              PrefHelper.setValue(PrefKeys.IS_CALL_ENABLE, true);
              context.read(_isCallProvider.notifier).state = true;
            } else {
              context.read(_isCallProvider.notifier).state = false;
            }
          } else {
            debugPrint("Print after else 10 seconds");
          }
        } catch (e) {
          print(e);
        }
      },
      onError: (err) {
        print('Error! $err');
      },
      cancelOnError: false,
      onDone: () {
        print('Done!');
      },
    );

    // timer = Timer.periodic(const Duration(seconds: 10), (Timer t) {
    //   debugPrint("Print after 5 seconds");
    //
    //   // double distanceInMeters = Geolocator.distanceBetween(
    //   //     PrefHelper.getDouble(PrefKeys.CURRENT_LATITUDE)!,
    //   //     PrefHelper.getDouble(PrefKeys.CURRENT_LONGITUDE)!,
    //   //     widget.task!.orderSeq![0].lat!,
    //   //     widget.task!.orderSeq![0].lng!);
    //   //
    //   // if (distanceInMeters <= 200) {
    //   //   PrefHelper.setValue(PrefKeys.IS_NEW_ORDER, false);
    //   //   PrefHelper.setValue(PrefKeys.IS_CALL_ENABLE, true);
    //   //   context.read(_isCallProvider.notifier).state = true;
    //   // } else {
    //   //   context.read(_isCallProvider.notifier).state = false;
    //   // }
    // });
  }

  Future<void> _stopListen() async {
    positionStream?.cancel();
    setState(() {
      positionStream = null;
    });
  }

  @override
  void initState() {
    super.initState();
    Globals.checkAndShowMockLocationDialog();
    _createDeliveryStepsList();
    _isFirstOpen = _currentStatusIndex == 0;
    context.read(locationProvider.notifier).checkForGPSStatus();
    callMapping();
  }

  FirebaseNotificationService firebaseService = FirebaseNotificationService();

  @override
  Widget build(BuildContext context) {
    _setStatusOfTaskAndOrder();
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: FDAppBar(
          titleText: "Task #${widget.task?.id}",
        ),
        body: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        TimelineWidget(_deliveryStepsList, _currentStatusIndex),
        const DummyLocationSwitch(),
        CurrentDeliveryDetailsWidget(
          _deliveryStepsList[_currentStatusIndex],
          currentStepIndex: _currentStatusIndex,
          onActionButtonSwiped: _onActionButtonSwiped,
          isCallProvider: _isCallProvider,
        ),
      ],
    );
  }

  void _createDeliveryStepsList() {
    // FirebaseMessaging.onMessage.listen((event) {
    //   setState(() {
    //     _deliveryStepsList[_deliveryStepsList.length - 1].order!.orderStatus =
    //         Constants.OS_DELIVERY_STARTED;
    //     _deliveryStepsList[_deliveryStepsList.length - 1].buttonText =
    //         "Reached Customer Location";
    //   });
    // });

    final storeInfo = widget.task!.storeInfo!;
    _deliveryStepsList.add(DeliveryStep(
      label: "PICK UP",
      description: storeInfo.storeName,
      isStarted: widget.task?.status == Constants.TS_PICKUP_STARTED,
      buttonText: widget.task?.status == Constants.TS_PICKUP_STARTED
          ? "Start Order 1 Delivery"
          : "Start Pickup",
      location:
          Location(latitude: storeInfo.storeLat, longitude: storeInfo.storeLng),
    ));

    // if pickup is started already
    if (widget.task?.status == Constants.TS_PICKUP_STARTED) {
      _currentStatusIndex = 1;
    }

    int currentDeliveredIndex = 0;
    for (int i = 0; i < widget.task!.orderSeq!.length; i++) {
      final order = widget.task!.orderSeq![i];
      final bool isDeliveryStarted = [
        Constants.OS_DELIVERY_STARTED,
        Constants.OS_CUSTOMER_NOT_AVAILABLE,
        Constants.OS_REATTEMPT_DELIVERY
      ].contains(order.orderStatus);

      _deliveryStepsList.add(DeliveryStep(
        label: "Drop Off ${i + 1} - Order #${order.orderNumber}",
        description: order.address,
        order: order,
        location: Location(latitude: order.lat, longitude: order.lng),
        isStarted: isDeliveryStarted,
        buttonText: order.orderStatus == Constants.OS_CREATED
            ? "Start Order ${i + 1} Delivery"
            : "Order ${i + 1} Delivered",
      ));
      if (isDeliveryStarted) {
        _currentStatusIndex = i + 1;
      } else if (order.orderStatus == Constants.OS_DELIVERED) {
        currentDeliveredIndex = i + 1;
      } else if (order.orderStatus == Constants.OS_CREATED &&
          currentDeliveredIndex > 0) {
        currentDeliveredIndex = i + 1;
      } else if (order.orderStatus == Constants.OS_REACHED_CUSTOMER) {
        currentDeliveredIndex = i + 1;
      }
    }
    _currentStatusIndex = max(_currentStatusIndex, currentDeliveredIndex);
  }

  void _setStatusOfTaskAndOrder() {
    for (int i = 0; i < _deliveryStepsList.length; i++) {
      if (i == 0) {
        _deliveryStepsList[i]
          ..isStarted = widget.task?.status == Constants.TS_PICKUP_STARTED
          ..buttonText = widget.task?.status == Constants.TS_PICKUP_STARTED
              ? "Start Delivery #${widget.task?.orderSeq?[0].orderNumber}"
              : "Start Pickup";
      } else {
        final order = _deliveryStepsList[i].order!;
        _deliveryStepsList[i]
          ..isStarted = order.orderStatus == Constants.OS_DELIVERY_STARTED
          ..buttonText = Globals.user!.reachedCx! == true
              ? order.orderStatus == Constants.OS_DELIVERY_STARTED
                  ? "Reached Customer Location"
                  : "Delivered #${order.orderNumber}"
              : order.orderStatus == Constants.OS_CREATED
                  ? "Start Delivery #${order.orderNumber}"
                  : "Delivered #${order.orderNumber}";
        // order.orderStatus == Constants.OS_CREATED
        //     ? "Start Delivery #${order.orderNumber}"
        //     :

        if (order.orderStatus == Constants.OS_DELIVERY_STARTED ||
            order.orderStatus == Constants.OS_REACHED_CUSTOMER) {
          _listenLocation();
        }
      }
    }
  }

  Future _onActionButtonSwiped(int newIndex) async {
    if (newIndex == 0) {
      await _showWithPopupLoading(_startPickup(newIndex));
    } else if (newIndex >= 1) {
      final actualOrderIndex = newIndex - 1;
      if (widget.task?.orderSeq?[actualOrderIndex].orderStatus ==
          Constants.OS_CREATED) {
        await _beforeStartTaskDelivery(actualOrderIndex, newIndex);
      } else if (widget.task?.orderSeq?[actualOrderIndex].orderStatus ==
              Constants.OS_DELIVERY_STARTED &&
          Globals.user!.reachedCx!) {
        await _reachedCustomerLocation(actualOrderIndex, newIndex);
      } else {
        await _beforeEndOrderDelivery(actualOrderIndex, newIndex);
      }
    }
    setState(() {});
  }

  Future _startPickup(int newIndex) async {
    await context
        .read(taskUpdateProvider.notifier)
        .updateTask(widget.task?.id, Constants.TS_PICKUP_STARTED);
    widget.task?.status = Constants.TS_PICKUP_STARTED;
    _currentStatusIndex = newIndex;
    _deliveryStepsList[0].isStarted = true;
    Toast.showInfoAlerter("Pickup started");
  }

/*
  Future _beforeStartTaskDelivery(int actualOrderIndex, int newIndex) async {
    if (actualOrderIndex == 0) {
      if (!_isOrderImagesUploaded) {
        final bool? isUploaded = await _showTaskImagesUploadDialog();
        if (isUploaded == null || !isUploaded) {
          return Toast.normal("Please upload images to start delivery.");
        }
        _isOrderImagesUploaded = true;
      }
    }
    await _showWithPopupLoading(
        _startOrderDelivery(actualOrderIndex, newIndex));
  }*/

  Future _beforeStartTaskDelivery(int actualOrderIndex, int newIndex) async {
    if (actualOrderIndex == 0) {
      if (!_isOrderSkusSelected) {
        final order = widget.task!.orderSeq![actualOrderIndex];
        final bool? areSkusSelected = await _showOrderSkuSelectionSheet(order);
        if (areSkusSelected == null || !areSkusSelected) {
          return Toast.normal("Please select items to start delivery.");
        }
        _isOrderSkusSelected = true;
      }
    }
    await _showWithPopupLoading(
        _startOrderDelivery(actualOrderIndex, newIndex));
  }

  Future _startOrderDelivery(int actualOrderIndex, int newIndex) async {
    if (actualOrderIndex == 0) {
      // Update the task for first time
      await context
          .read(taskUpdateProvider.notifier)
          .updateTask(widget.task?.id, Constants.TS_DELIVERY_STARTED);
    }

    // Update the order status
    final order = widget.task!.orderSeq![actualOrderIndex];
    context.read(orderUpdateProvider.notifier).updateOrderDetails(order);
    await context.read(orderUpdateProvider.notifier).updateOrderStatus(
          Constants.OS_DELIVERY_STARTED,
        );
    widget.task?.orderSeq?[actualOrderIndex].orderStatus =
        Constants.OS_DELIVERY_STARTED;
    _currentStatusIndex = newIndex;
    Toast.showInfoAlerter("Started delivery for #${order.orderNumber}");
    _listenLocation();
    // await context.read(latestTaskProvider.notifier).listenLocation();
  }

  Future _reachedCustomerLocation(int actualOrderIndex, int newIndex) async {
    // Update the order status
    final order = widget.task!.orderSeq![actualOrderIndex];
    context.read(orderUpdateProvider.notifier).updateOrderDetails(order);
    await context.read(orderUpdateProvider.notifier).updateOrderStatus(
          Constants.OS_REACHED_CUSTOMER,
        );
    widget.task?.orderSeq?[actualOrderIndex].orderStatus =
        Constants.OS_REACHED_CUSTOMER;
    // _currentStatusIndex = newIndex;
    // Toast.showInfoAlerter("Started delivery for #${order.orderNumber}");
    // _listenLocation();
    // await context.read(latestTaskProvider.notifier).listenLocation();
  }

  Future _beforeEndOrderDelivery(int actualOrderIndex, int newIndex) async {
    if (await _isDeliveredStatusSelected(actualOrderIndex)) {
      if (_deliveryType != DeliveryType.CUSTOMER_UNAVAILABLE) {
        _currentOrderDeliveredTo ??= await showDialog(
            context: context, builder: (_) => DeliveredToDialog());
        if (_currentOrderDeliveredTo == null) {
          return;
        }
        await _showWithPopupLoading(
            _endOrderDelivery(actualOrderIndex, newIndex));
      }
    }
  }

  Future _endOrderDelivery(int actualOrderIndex, int newIndex) async {
    bool isDeliveryMarked = false;
    final order = widget.task!.orderSeq![actualOrderIndex];
    try {
      await _updateOrderStatusToDelivered(order,
          deliveredTo: _currentOrderDeliveredTo);
      isDeliveryMarked = true;
    } catch (e) {
      isDeliveryMarked = await _showDeliveryOTPDialog(order);
    }
    if (isDeliveryMarked) {
      widget.task?.orderSeq?[actualOrderIndex].orderStatus =
          Constants.OS_DELIVERED;

      Toast.showSuccessAlerter("Delivered #${order.orderNumber}");
      _currentOrderDeliveredTo = null;

      if (_currentStatusIndex < widget.task!.orderSeq!.length) {
        _currentStatusIndex = newIndex + 1;
      } else {
        await context
            .read(taskUpdateProvider.notifier)
            .onTaskComplete(widget.task?.id, orderNumber: '');
      }
    }
  }

  Future _updateOrderStatusToDelivered(OrderSeq order,
      {String? deliveryOTP, String? deliveredTo}) async {
    context.read(orderUpdateProvider.notifier).updateOrderDetails(order);
    _stopListen();

    return context
        .read(orderUpdateProvider.notifier)
        .updateOrderStatus(Constants.OS_DELIVERED);
  }

  void callMapping() async {
    try {
      AppMappingModel appMapping = await _deliveryService.getAppMappingData();
      Globals.mappingData = appMapping.data!;
    } on Exception catch (e) {
      // TODO
    }
  }

  Future<bool> _showDeliveryOTPDialog(OrderSeq order) async {
    bool isVerifiedByOTP = false;
    await showDialog(
      context: context,
      builder: (_) => DeliveryOtpDialog(
        order: order,
        onOTPSent: (String otp) async {
          await _showWithPopupLoading(
              _updateOrderStatusToDelivered(order, deliveryOTP: otp));
          isVerifiedByOTP = true;
          RouteHelper.pop();
        },
      ),
    );
    return isVerifiedByOTP;
  }

  Future<bool> _isDeliveredStatusSelected(int actualOrderIndex) async {
    final order = context.read(orderUpdateProvider.notifier).currentOrder;
    if (order.orderStatus == Constants.OS_CUSTOMER_NOT_AVAILABLE) {
      await RouteHelper.push(Routes.SUPPORT_CALL_SCREEN);
    } else {
      _deliveryType ??= await RouteHelper.push(Routes.DELIVERY_TYPE_SELECTOR);
    }
    context.read(latestTaskProvider.notifier).getLatestTask();
    if (_deliveryType == null) {
      return false;
    }
    return true;
  }

  Future<bool?> _showOrderSkuSelectionSheet(OrderSeq order) async {
    final bool? result = await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => OrderSkusSelectionSheet(order),
    );
    return result;
  }

  Future _showWithPopupLoading(Future callback) async {
    final cancelFunc = Toast.popupLoading();
    try {
      await callback;
    } catch (e) {
      rethrow;
    } finally {
      cancelFunc();
    }
  }

  Future<bool> _onWillPop() {
    if (_isFirstOpen) {
      // I really don't know solution for this so using this as fix
      // problem is that, going back doesn't preserve task status so changing it only for first time
      RouteHelper.navigatorContext
          .read(latestTaskProvider.notifier)
          .getLatestTask();
    }
    return Future.value(true);
  }
}
