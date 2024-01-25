import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fraazo_delivery/helpers/enums/delivery_type.dart';
import 'package:fraazo_delivery/helpers/enums/partial_amount_type.dart';
import 'package:fraazo_delivery/helpers/route/route_helper.dart';
import 'package:fraazo_delivery/helpers/route/routes.dart';
import 'package:fraazo_delivery/helpers/shared_pref/pref_helper.dart';
import 'package:fraazo_delivery/helpers/shared_pref/pref_keys.dart';
import 'package:fraazo_delivery/models/delivery/task_model.dart';
import 'package:fraazo_delivery/providers/delivery/latest_task_provider.dart';
import 'package:fraazo_delivery/providers/delivery/order/order_update_provider.dart';
import 'package:fraazo_delivery/ui/global_widgets/fd_app_bar.dart';
import 'package:fraazo_delivery/ui/global_widgets/flex_separated.dart';
import 'package:fraazo_delivery/ui/global_widgets/primary_button.dart';
import 'package:fraazo_delivery/ui/utils/app_colors.dart';
import 'package:fraazo_delivery/ui/utils/toast.dart';
import 'package:fraazo_delivery/ui/utils/widgets_and_attributes.dart';
import 'package:fraazo_delivery/utils/constants.dart';

class DeliveryTypeSelectorScreen extends StatefulWidget {
  const DeliveryTypeSelectorScreen({Key? key}) : super(key: key);

  @override
  _DeliveryTypeSelectorScreenState createState() =>
      _DeliveryTypeSelectorScreenState();
}

class _DeliveryTypeSelectorScreenState
    extends State<DeliveryTypeSelectorScreen> {
  final List<String> _codOptionsList = const [
    "Full Amount Collected",
    "Customer Not Available",
    "Partial Amount Collected"
  ];

  final List<String> _onlineOptionsList = const [
    "Delivered",
    "Customer Not Available",
  ];

  late final List<String> _partialPaymentTypesList = const [
    "Missing Items",
    "Quality Issue",
    "Both",
    "Other"
  ];

  late PartialAmountType? _selectedPartialAmountType = null;
  late final OrderSeq _currentOrder =
      context.read(orderUpdateProvider.notifier).currentOrder;

  late final bool _isOnlinePayment = !_currentOrder.isCod;

  DeliveryType? _selectedDeliveryType;
  bool? _isPartialAmountCollected;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const FDAppBar(
        titleText: "Select Delivery Type",
      ),
      body: _buildBody(),
      bottomNavigationBar: Padding(
        padding: padding15,
        child: PrimaryButton(
          text: _selectedDeliveryType == DeliveryType.FULL ? "SUBMIT" : "NEXT",
          color: AppColors.secondary,
          onPressed: _onSubmitOrNextButtonTap,
        ),
      ),
    );
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      padding: padding15,
      child: FlexSeparated(
        direction: Axis.vertical,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!_isOnlinePayment) ...[
            Text(
              "COD Order Amount: ₹${_currentOrder.amountTruncated}",
              style: const TextStyle(
                color: Colors.red,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            sizedBoxH5,
            Text(
              "Please select cod payment status:",
              style:
                  Theme.of(context).textTheme.overline?.copyWith(fontSize: 15),
            ),
          ],
          ...List.generate(
            _isOnlinePayment
                ? _onlineOptionsList.length
                : _codOptionsList.length,
            (index) => _buildOptionTile(index),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionTile(int index) {
    final String label =
        _isOnlinePayment ? _onlineOptionsList[index] : _codOptionsList[index];
    return Material(
      elevation: 2,
      child: Column(
        children: [
          RadioListTile<DeliveryType?>(
            value: DeliveryType.values[index],
            groupValue: _selectedDeliveryType,
            tileColor: Colors.white,
            onChanged: _onOptionTileTap,
            activeColor: AppColors.primary,
            contentPadding: const EdgeInsets.all(8),
            subtitle:
                (index == 2 && _selectedDeliveryType == DeliveryType.PARTIAL)
                    ? _buildPartialPaymentOptionsDropdown()
                    : null,
            title: Text(
              label,
              style:
                  Theme.of(context).textTheme.headline6?.copyWith(fontSize: 18),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPartialPaymentOptionsDropdown() {
    return Container(
      margin: const EdgeInsets.only(top: 12, right: 10),
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      height: 40.0,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.0),
        color: AppColors.primary.withOpacity(0.5),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<PartialAmountType>(
          value: _selectedPartialAmountType,
          hint: const Text(
            "Select reason for partial payment",
            style: TextStyle(
              color: Colors.black54,
              fontWeight: FontWeight.w600,
            ),
          ),
          elevation: 16,
          style: const TextStyle(color: Colors.deepPurple),
          onChanged: (PartialAmountType? newValue) {
            setState(() {
              _selectedPartialAmountType = newValue;
            });
          },
          items: List.generate(
            _partialPaymentTypesList.length,
            (int index) => DropdownMenuItem<PartialAmountType>(
              value: PartialAmountType.values[index],
              child: Text(
                _partialPaymentTypesList[index],
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _onOptionTileTap(DeliveryType? value) {
    setState(() {
      _selectedDeliveryType = value;
    });
  }

  Future _onSubmitOrNextButtonTap() async {
    final int? taskID =
        context.read(latestTaskProvider.notifier).currentTask?.id ??
            PrefHelper.getInt(PrefKeys.CURRENT_TASK_ID);

    if (_selectedDeliveryType == null) {
      return Toast.info("Please select delivery status.");
    } else if (_selectedDeliveryType == DeliveryType.PARTIAL &&
        _selectedPartialAmountType == null) {
      return Toast.info("Please select reason for partial payment.");
    }
    if (_selectedDeliveryType == DeliveryType.CUSTOMER_UNAVAILABLE) {
      Toast.popupLoadingFuture(
        future: () => context
            .read(orderUpdateProvider.notifier)
            .updateOrderStatus(Constants.OS_CUSTOMER_NOT_AVAILABLE),
        onSuccess: (_) {
          PrefHelper.setValue(PrefKeys.IS_NEW_ORDER, false);
          RouteHelper.pushReplacement(Routes.SUPPORT_CALL_SCREEN);
        },
      );
      return;
    } else if (_selectedDeliveryType == DeliveryType.PARTIAL) {
      _isPartialAmountCollected ??= await RouteHelper.push(
          Routes.PARTIAL_AMOUNT_REASON,
          args: _selectedPartialAmountType);

      if (_isPartialAmountCollected == null) {
        return;
      }
      context.read(orderUpdateProvider.notifier).endOrderDelivery(taskID!);
      return;
    }
    context.read(orderUpdateProvider.notifier).showDeliveredToDialog(taskID!);
  }

/*
  Future _setDeliveredToAndMarkDelivery() async {
    final String? currentOrderDeliveredTo =
        await showDialog(context: context, builder: (_) => DeliveredToDialog());
    if (currentOrderDeliveredTo == null) {
      return;
    }
    await _endOrderDelivery(actualOrderIndex, newIndex);
  }

  Future _endOrderDelivery(int actualOrderIndex, int newIndex) async {
    bool isDeliveryMarked = false;
    try {
      await _updateOrderStatusToDelivered(order);
      isDeliveryMarked = true;
    } catch (e) {
      isDeliveryMarked = await _showDeliveryOTPDialog(order);
    }
    if (isDeliveryMarked) {
      Toast.showSuccessAlerter("Delivered #${order.orderNumber}");
      await _onTaskCompleted();
    }
  }

  Future _onTaskCompleted() async {
    */ /*  await context
        .read(taskUpdateProvider.notifier)
        .updateTask(widget.task?.id, Constants.TS_COMPLETED);*/ /*
    FeedbackService().vibrate();
    _showDeliveryCompleteDialog();
    context
        .read(userProfileProvider.notifier)
        .changeUserStatus(Constants.US_ONLINE);
    context.read(latestTaskProvider.notifier).getLatestTask();
    context.read(todaysStatsProvider.notifier).getStats();
  }

  void _showDeliveryCompleteDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => DeliveryCompleteDialog(),
    );
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
  }*/
}
