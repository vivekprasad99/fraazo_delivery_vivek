import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fraazo_delivery/helpers/extensions/text_editing_controller_extension.dart';
import 'package:fraazo_delivery/helpers/route/route_helper.dart';
import 'package:fraazo_delivery/models/delivery/task_model.dart';
import 'package:fraazo_delivery/providers/delivery/task_update_provider.dart';
import 'package:fraazo_delivery/ui/global_widgets/fd_textfield.dart';
import 'package:fraazo_delivery/ui/screen_widgets/dialog_button_bar.dart';
import 'package:fraazo_delivery/ui/screen_widgets/otp_timer_and_resend_widget.dart';
import 'package:fraazo_delivery/ui/screens/delivery/steps/local_widgets/dialogs/delivery_pin_otp.dart';
import 'package:fraazo_delivery/ui/utils/toast.dart';
import 'package:fraazo_delivery/ui/utils/widgets_and_attributes.dart';
import 'package:fraazo_delivery/utils/globals.dart';

class DeliveryOtpDialog extends StatefulWidget {
  final OrderSeq order;
  final Function(String otp) onOTPSent;
  const DeliveryOtpDialog({required this.order, required this.onOTPSent});
  @override
  _DeliveryOtpDialogState createState() => _DeliveryOtpDialogState();
}

class _DeliveryOtpDialogState extends State<DeliveryOtpDialog> {
  final _otpTEC = TextEditingController();
  String dialogMsg =
      'Please enter the 4 digit OTP sent to the customer for order';
  String dialogTitle = 'Enter OTP';
  bool _shouldShowEnterOTPView = false;
  bool _shouldTimer = true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    for (final element in Globals.mappingData) {
      if (element.key == 'delivery_pin_msg') {
        dialogMsg = element.value!;
      } else if (element.key == 'delivery_pin_title') {
        dialogTitle = element.value!;
      } else if (element.key == 'enable_send_otp_box') {
        _shouldShowEnterOTPView = element.value == 'true';
        _shouldTimer = !_shouldShowEnterOTPView;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12.0))),
      content: _shouldShowEnterOTPView
          ? DeliveryPinOtp(onOTPSent: widget.onOTPSent)
          : _buildSendOTPView(),
    );
  }

  Widget _buildSendOTPView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        ..._buildTitleAndSubtitle("Send OTP?",
            "Do you want to send the OTP to the customer in order to mark the delivery of the order #${widget.order.orderNumber} ?"),
        DialogButtonBar(
          confirmText: "Yes",
          onConfirmTap: _onSendOTPTap,
          cancelText: "No",
          onCancelTap: () => RouteHelper.pop(),
        ),
      ],
    );
  }

  Widget _buildEnterOTPView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        ..._buildTitleAndSubtitle(
            dialogTitle, "$dialogMsg #${widget.order.orderNumber}"),
        FDTextField(
          controller: _otpTEC,
          isAutoFocus: true,
          labelText: _shouldTimer ? "OTP" : "PIN",
          isNumber: true,
          maxLength: 4,
        ),
        sizedBoxH20,
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Visibility(
              visible: _shouldTimer,
              child: OtpTimerAndResendWidget(
                onResend: () => _onSendOTPTap(isResend: true),
              ),
            ),
            DialogButtonBar(
              onConfirmTap: _onSubmitOTPTap,
              onCancelTap: () => RouteHelper.pop(),
            ),
          ],
        ),
      ],
    );
  }

  List<Widget> _buildTitleAndSubtitle(String title, String subtitle) {
    return [
      Text(
        title,
        style: Theme.of(context).textTheme.headline6,
      ),
      sizedBoxH15,
      Text(
        subtitle,
        style: Theme.of(context).textTheme.subtitle1,
      ),
      sizedBoxH20,
    ];
  }

  Future _onSendOTPTap({bool isResend = false}) async {
    final cancelFunc = Toast.popupLoading();
    try {
      await context
          .read(taskUpdateProvider.notifier)
          .sendDeliveryVerificationOTP(widget.order.mobile, widget.order.id);
      if (isResend) {
        _otpTEC.clear();
      } else {
        setState(() {
          _shouldShowEnterOTPView = true;
        });
      }
    } finally {
      cancelFunc();
    }
  }

  Future _onSubmitOTPTap() async {
    if (_otpTEC.isEqLength(4)) {
      widget.onOTPSent(_otpTEC.text);
    } else {
      Toast.normal("Please enter valid 4 digit OTP.");
    }
  }

  @override
  void dispose() {
    _otpTEC.dispose();
    super.dispose();
  }
}
