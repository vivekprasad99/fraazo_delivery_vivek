import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fraazo_delivery/models/delivery/task_model.dart';
import 'package:fraazo_delivery/providers/delivery/order/order_update_provider.dart';
import 'package:fraazo_delivery/ui/global_widgets/fd_app_bar.dart';
import 'package:fraazo_delivery/ui/global_widgets/primary_button.dart';
import 'package:fraazo_delivery/ui/screen_widgets/shadow_card.dart';
import 'package:fraazo_delivery/ui/utils/app_colors.dart';
import 'package:fraazo_delivery/ui/utils/widgets_and_attributes.dart';
import 'package:fraazo_delivery/utils/constants.dart';
import 'package:fraazo_delivery/utils/device_app_launcher.dart';

class SupportCallScreen extends StatefulWidget {
  const SupportCallScreen({Key? key}) : super(key: key);

  @override
  State<SupportCallScreen> createState() => _SupportCallScreenState();
}

class _SupportCallScreenState extends State<SupportCallScreen> {
  late final OrderSeq _currentOrder =
      context.read(orderUpdateProvider.notifier).currentOrder;
  late final Timer _dialingInTimer;
  int _timerSeconds = 5;

  @override
  void initState() {
    super.initState();
    _dialingInTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _timerSeconds--;
      });
      if (_timerSeconds == 0) {
        _dialingInTimer.cancel();
        _callSupport();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const FDAppBar(
        titleText: "Call Support",
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          _buildOrderInfoCard(),
          const Spacer(),
          Container(
            padding: padding10,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: AppColors.primary,
                width: 2,
              ),
            ),
            child: Text(
              "#${_currentOrder.zendeskTicketId} has been created to assist you with delivery, wait while your call is being connected to Fraazo Support",
              style: const TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.w500,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          sizedBoxH40,
          if (_dialingInTimer.isActive)
            Text(
              "Calling in next $_timerSeconds sec...",
              style: Theme.of(context)
                  .textTheme
                  .overline
                  ?.copyWith(color: Colors.orange, fontSize: 18),
            ),
          sizedBoxH10,
          PrimaryButton(
            onPressed: _callSupport,
            text: "CALL SUPPORT",
          ),
          const Spacer(),
        ],
      ),
    );
  }

  Widget _buildOrderInfoCard() {
    return ShadowCard(
      child: Padding(
        padding: paddingH10V6,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  "Order No: ",
                  style: TextStyle(
                    color: Colors.black45,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  "${_currentOrder.orderNumber}",
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            sizedBoxH5,
            Row(
              children: [
                const Text(
                  "Customer Name: ",
                  style: TextStyle(
                    color: Colors.black54,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  "${_currentOrder.custName}",
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w600,
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _callSupport() {
    _dialingInTimer.cancel();
    DeviceAppLauncher().callPhoneNumber(Constants.SUPPORT_PHONE_NUMBER);
    setState(() {});
  }

  @override
  void dispose() {
    _dialingInTimer.cancel();
    super.dispose();
  }
}
