import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fraazo_delivery/models/delivery/delivery_step.dart';
import 'package:fraazo_delivery/models/delivery/location.dart';
import 'package:fraazo_delivery/models/delivery/task_model.dart';
import 'package:fraazo_delivery/providers/delivery/latest_task_provider.dart';
import 'package:fraazo_delivery/providers/delivery/order/order_update_provider.dart';
import 'package:fraazo_delivery/ui/global_widgets/container_divider.dart';
import 'package:fraazo_delivery/ui/global_widgets/primary_button.dart';
import 'package:fraazo_delivery/ui/screens/delivery/steps/local_widgets/slide_button.dart';
import 'package:fraazo_delivery/ui/utils/app_colors.dart';
import 'package:fraazo_delivery/ui/utils/toast.dart';
import 'package:fraazo_delivery/ui/utils/widgets_and_attributes.dart';
import 'package:fraazo_delivery/utils/constants.dart';
import 'package:fraazo_delivery/utils/device_app_launcher.dart';
import 'package:fraazo_delivery/utils/globals.dart';

import '../../../../../helpers/error/error_reporter.dart';
import '../../../../../helpers/type_aliases/json.dart';
import '../../../../../services/sdk/firebase/firebase_firestore_service.dart';
import 'cash_or_qr_code_widget.dart';

enum DeliveryStatus { NONE, PICKUP, START_ORDER, ORDER_DELIVERY, COMPLETE }

class CurrentDeliveryDetailsWidget extends StatefulWidget {
  final DeliveryStep deliveryStep;
  final ValueChanged<int> onActionButtonSwiped;
  final int currentStepIndex;
  final AutoDisposeStateProvider? isCallProvider;

  const CurrentDeliveryDetailsWidget(this.deliveryStep,
      {Key? key,
      required this.onActionButtonSwiped,
      this.currentStepIndex = 0,
      this.isCallProvider})
      : super(key: key);

  @override
  _CurrentDeliveryDetailsWidgetState createState() =>
      _CurrentDeliveryDetailsWidgetState();
}

class _CurrentDeliveryDetailsWidgetState
    extends State<CurrentDeliveryDetailsWidget>
    with SingleTickerProviderStateMixin {
  OrderSeq? _order;

  late final int _taskID;
  final _firebaseFirestoreService = FirebaseFirestoreService();
  bool isCallFeatureEnable = false;

  @override
  void initState() {
    checkForCallFeature();
    super.initState();
    _taskID = context.read(latestTaskProvider.notifier).currentTask!.id!;
  }

  Future<bool> checkForCallFeature() async {
    // bool isCallFeatureEnable = false;
    try {
      final DocumentReference<Map<String, dynamic>> documentReference =
          FirebaseFirestore.instance
              .collection("call_feature")
              .doc(const String.fromEnvironment("env", defaultValue: "prod"));

      documentReference.snapshots().listen((event) {
        // print('event ${event.data()}');
        final JsonMap? callFeature = event.data();
        isCallFeatureEnable = callFeature?["is_enable"];
      });

      final JsonMap? callFeature =
          await _firebaseFirestoreService.getCallFeatureConfig();

      isCallFeatureEnable = callFeature?["is_enable"];
      print('checkForCallFeature $isCallFeatureEnable');
      setState(() {});
    } catch (e, st) {
      ErrorReporter.error(e, st, "Call Feature Enable: checkForCallFeature()");
    }

    return isCallFeatureEnable;
  }

  @override
  Widget build(BuildContext context) {
    _order = widget.deliveryStep.order;
    // if (_order != null) {
    //   if (_order?.callEnabled == true) {
    //     PrefHelper.setValue(PrefKeys.IS_NEW_ORDER, false);
    //   } else {
    //     PrefHelper.setValue(PrefKeys.IS_NEW_ORDER, true);
    //   }
    // }
    return AnimatedSize(
      duration: const Duration(milliseconds: 300),
      curve: Curves.fastOutSlowIn,
      child: DecoratedBox(
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              offset: Offset(0, 1),
              blurRadius: 2,
              spreadRadius: 4,
              color: Colors.black26,
            )
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Current Status Details",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              sizedBoxH5,
              const ContainerDivider(endIndent: 100),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.deliveryStep.label ?? "Location",
                    style: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  PrimaryButton(
                    text: "Directions",
                    width: 98,
                    height: 36,
                    color: AppColors.secondary,
                    fontSize: 15,
                    onPressed: () {
                      final Location? location = widget.deliveryStep.location;
                      DeviceAppLauncher().launchByUrl(
                        "http://maps.google.com/maps?daddr=${location?.latitude},${location?.longitude}",
                      );
                    },
                  )
                ],
              ),
              Text(
                widget.deliveryStep.description!,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Divider(height: 10),
              if (_order != null &&
                  _order!.orderStatus != Constants.OS_CREATED) ...[
                _buildCustomerDetails(),
                sizedBoxH5,
              ],
              _buildActionButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCustomerDetails() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Order Details",
                style: TextStyle(
                  color: Colors.grey.shade500,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              sizedBoxH5,
              _buildNameValueRow("Name:", _order?.custName),
              sizedBoxH2,
              Row(
                children: [
                  Consumer(
                    builder: (_, watch, __) {
                      watch(orderUpdateProvider.notifier);
                      return _buildNameValueRow(
                          "Amount:", "₹${_order?.amountTruncated}");
                    },
                  ),
                  sizedBoxW5,
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _order!.isCod ? Colors.red : Colors.green,
                      borderRadius: const BorderRadius.all(Radius.circular(2)),
                    ),
                    child: Text(
                      _order!.isCod ? "UNPAID" : "PAID",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  )
                ],
              ),
              if (_order!.details!.isNotEmpty) ...[
                sizedBoxH2,
                _buildNameValueRow("Order Instructions:", _order?.details),
              ]
            ],
          ),
        ),
        if (Globals.user!.qrEnable && _order!.isCod)
          CashOrQrCodeWidget(
            _order,
            onGenerateTap: () => context
                .read(orderUpdateProvider.notifier)
                .endOrderDelivery(_taskID),
            shouldShowQRIcon: true,
          ),
        Consumer(
          builder: (_, watch, __) {
            final bool isValid = watch(widget.isCallProvider!).state;
            return Visibility(
              child: IconButton(
                  icon: const Icon(
                    Icons.phone,
                  ),
                  onPressed:
                      // _order!.orderStatus == Constants.OS_DELIVERY_STARTED
                      //     ? null
                      //     :
                      () {
                    if (isValid || isCallFeatureEnable) {
                      _onCallButtonTap();
                    } else {
                      Toast.normal(
                          'A call request will be available once you reach the customer location.');
                    }
                  }
                  // ? _onCallButtonTap : Toast.normal(msg);,
                  ),
            );
          },
        )

        // Visibility(
        //   child: IconButton(
        //       icon: const Icon(
        //         Icons.phone,
        //       ),
        //       onPressed:
        //       // _order!.orderStatus == Constants.OS_DELIVERY_STARTED
        //       //     ? null
        //       //     :
        //           () {
        //         if (_order!.callEnabled!) {
        //           _onCallButtonTap();
        //         } else {
        //           Toast.normal(
        //               'A call request will be available once you reach the customer location.');
        //         }
        //       }
        //     // ? _onCallButtonTap : Toast.normal(msg);,
        //   ),
        // )
        //   },
        // )
      ],
    );
  }

  Widget _buildNameValueRow(String label, String? value) {
    return RichText(
      text: TextSpan(
        text: label,
        style: const TextStyle(
          color: Colors.black,
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
        children: [
          const WidgetSpan(child: sizedBoxW5),
          TextSpan(text: value, style: TextStyle(color: Colors.grey.shade600))
        ],
      ),
    );
  }

  Widget _buildActionButton() {
    return SlideButton(
      backgroundColor: AppColors.secondary,
      slidingBarColor: AppColors.primary,
      height: 50,
      initialSliderPercentage: 0.22,
      resetAfterSlide: true,
      onButtonOpened: _onActionButtonTap,
      backgroundChild: Align(
        child: Text(
          widget.deliveryStep.buttonText,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      slidingChild: const Align(
        child: Icon(
          Icons.arrow_forward_ios,
          color: Colors.white,
        ),
      ),
    );
  }

  Future _onCallButtonTap() async {
    // if (context.read(orderUpdateProvider.notifier).clickCount == 0) {
    final cancelFunc = Toast.popupLoading();
    try {
      await context
          .read(orderUpdateProvider.notifier)
          .callToCustomer(_order?.orderNumber);
      context.read(orderUpdateProvider.notifier).clickCount = 3;
      Toast.normal(
          "Call request is sent. Please wait and accept incoming call.");
    } catch (e, st) {
      ErrorReporter.error(
          e, st, "CurrentDeliveryDetailsWidget: _onCallButtonTap()");
    }
    cancelFunc();
    // } else {
    //   context.read(orderUpdateProvider.notifier).clickCallButton();
    // }
  }

  void _onActionButtonTap() {
    if (widget.currentStepIndex == 0 && widget.deliveryStep.isStarted) {
      widget.onActionButtonSwiped(widget.currentStepIndex + 1);
    } else {
      widget.onActionButtonSwiped(widget.currentStepIndex);
    }
  }
}
