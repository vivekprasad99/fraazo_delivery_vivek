import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fraazo_delivery/helpers/route/route_helper.dart';
import 'package:fraazo_delivery/models/delivery/task_status_model.dart';
import 'package:fraazo_delivery/providers/delivery/latest_task_provider.dart';
import 'package:fraazo_delivery/providers/delivery/task_by_socket_provider.dart';
import 'package:fraazo_delivery/providers/delivery/task_update_provider.dart';
import 'package:fraazo_delivery/ui/global_widgets/fd_circular_loader.dart';
import 'package:fraazo_delivery/ui/global_widgets/new_primary_button.dart';
import 'package:fraazo_delivery/ui/global_widgets/primary_button.dart';
import 'package:fraazo_delivery/ui/utils/app_colors.dart';
import 'package:fraazo_delivery/ui/utils/toast.dart';
import 'package:fraazo_delivery/ui/utils/widgets_and_attributes.dart';
import 'package:fraazo_delivery/utils/constants.dart';
import 'package:fraazo_delivery/utils/utils.dart';
import 'package:fraazo_delivery/values/custom_colors.dart';

import '../../../../../global_widgets/counter_widget.dart';

class PodQrCodeDialog extends StatefulWidget {
  final String imageURL;
  final num? upiAmount;
  int qrExpiryTime;
  String? orderNo;

  final VoidCallback? onPaymentSuccess;

  PodQrCodeDialog(this.imageURL,
      {Key? key,
      this.upiAmount,
      this.onPaymentSuccess,
      this.qrExpiryTime = 0,
      this.orderNo})
      : super(key: key);

  @override
  State<PodQrCodeDialog> createState() => _PodQrCodeDialogState();
}

class _PodQrCodeDialogState extends State<PodQrCodeDialog>
    with SingleTickerProviderStateMixin {
  late final RemoveListener _socketListener;
  // late Timer _countDownTimer;
  bool _isPaymentSuccess = false;
  bool _isTimerComplete = true;

  late final int _currentTaskID;

  AnimationController? _controller;

  @override
  void initState() {
    super.initState();
    // _startTimer();
    print('qrExpiryTime ${widget.qrExpiryTime}');
    _controller = AnimationController(
        vsync: this, duration: Duration(seconds: widget.qrExpiryTime));
    _controller!.forward();
    _controller?.addListener(() {});
    _controller!.addStatusListener((AnimationStatus status) {
      if (status == AnimationStatus.completed && _controller!.isCompleted) {
        if (_isTimerComplete) {
          _isTimerComplete = false;

          // Toast.info(
          //     'Payment QR expired, If QR payment is under process, Please complete payment otherwise Please collect cash.');
          RouteHelper.pop(args: true);
        }
      }
    });

    _currentTaskID = context.read(latestTaskProvider.notifier).currentTask!.id!;

    // _currentTaskID = widget.upiAmount;

    _socketListener = context.read(taskBySocketProvider.notifier).addListener(
      (TaskStatusModel? taskStatus) {
        if (taskStatus?.type == Constants.TS_PAYMENT_SUCCESS) {
          _onPaymentSuccess();
        }
      },
      fireImmediately: false,
    );
  }

  // void _startTimer() {
  //   _countDownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
  //     setState(() {
  //       if (widget.qrExpiryTime == 0) {
  //         _countDownTimer.cancel();
  //       } else {
  //         widget.qrExpiryTime--;
  //       }
  //     });
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => Future.value(_isPaymentSuccess),
      child: Padding(
        padding: padding15,
        child: Material(
          color: Colors.white,
          child: _isPaymentSuccess ? _buildPaymentSuccess() : _buildQRView(),
        ),
      ),
    );
  }

  Widget _buildPaymentSuccess() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        sizedBoxH20,
        const CircleAvatar(
          radius: 40,
          backgroundColor: Colors.green,
          child: Icon(
            Icons.check,
            size: 60,
            color: Colors.white,
          ),
        ),
        sizedBoxH10,
        Text(
          "Payment Success",
          style: commonTextStyle(
            color: Colors.green,
            fontSize: 25,
            fontWeight: FontWeight.bold,
          ),
        ),
        sizedBoxH20,
        NewPrimaryButton(
          onPressed: () => widget.onPaymentSuccess?.call(),
          buttonTitle: "Complete Task",
          //width: MediaQuery.of(context).size.width * .7,
          fontSize: 18, activeColor: btnLightGreen,
          inactiveColor: buttonInActiveColor,
        )
      ],
    );
  }

  Widget _buildQRView() {
    return Stack(
      alignment: Alignment.center,
      children: [
        Image.network(
          widget.imageURL,
          fit: BoxFit.fitWidth,
          width: double.infinity,
          errorBuilder: (_, __, ___) => const Material(
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                "Something went wrong."
                "\nPlease make sure you have correct date and time in your phone and try again.",
              ),
            ),
          ),
          loadingBuilder: (_, Widget child, ImageChunkEvent? loadingProgress) {
            if (loadingProgress == null) {
              return child;
            } else {
              return const FDCircularLoader();
            }
          },
        ),
        Positioned(
          right: 0,
          left: 0,
          bottom: 0,
          height: 42,
          child: ColoredBox(
            color: AppColors.secondary,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "  Amount: ₹${widget.upiAmount}",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                PrimaryButton(
                  text: "Check status",
                  width: 140,
                  fontSize: 18,
                  onPressed: _checkStatus,
                )
              ],
            ),
          ),
        ),
        Positioned(
          right: 4,
          top: 4,
          child: Row(
            children: [
              PrimaryButton(
                text: "Close",
                width: 80,
                height: 40,
                color: AppColors.secondary,
                onPressed: () => RouteHelper.pop(),
              ),
            ],
          ),
        ),
        Positioned(
          top: 4,
          left: 4,
          child: PrimaryButton(
            text: "Create ticket",
            width: 160,
            fontSize: 18,
            onPressed: _createZendeskTicket,
          ),
        ),
        Positioned(
          left: 4,
          top: 4,
          child: Visibility(
            visible: widget.qrExpiryTime > 0,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Countdown(
                msg: 'Complete Payment within',
                animation: StepTween(
                  begin: widget.qrExpiryTime,
                  end: 0,
                ).animate(_controller!),
              ),
            ),
          ),
        )
      ],
    );
  }

  void _checkStatus() {
    Toast.popupLoadingFuture(
      future: () => context
          .read(taskUpdateProvider.notifier)
          .verifyPaymentQR(_currentTaskID),
      onSuccess: (bool isSuccess) {
        if (isSuccess) {
          _onPaymentSuccess();
        } else {
          Toast.info("Payment not successful yet.");
        }
      },
    );
  }

  void _createZendeskTicket() {
    Toast.popupLoadingFuture(
      future: () => context
          .read(taskUpdateProvider.notifier)
          .createZendeskTicket(
              _currentTaskID, widget.orderNo!, widget.upiAmount),
      onSuccess: (Map<String, dynamic>? value) {
        if (value != null && value['success']) {
          Toast.showInfoAlerter(value['message']);
          RouteHelper.pop();
        } else {
          Toast.error();
        }
      },
    );
  }

  void _onPaymentSuccess() {
    setState(() {
      _isPaymentSuccess = true;
    });
    SchedulerBinding.instance?.addPostFrameCallback((_) {
      Toast.showSuccessAlerter("Payment successful");
      widget.onPaymentSuccess?.call();
    });
  }

  @override
  void dispose() {
    _socketListener();
    _controller?.dispose();
    super.dispose();
  }
}
