import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fraazo_delivery/ui/utils/textview.dart';
import 'package:fraazo_delivery/utils/utils.dart';
import 'package:fraazo_delivery/values/custom_colors.dart';

class OtpTimerAndResendWidget extends StatefulWidget {
  final VoidCallback onResend;

  const OtpTimerAndResendWidget({Key? key, required this.onResend})
      : super(key: key);

  @override
  _OtpTimerAndResendWidgetState createState() =>
      _OtpTimerAndResendWidgetState();
}

class _OtpTimerAndResendWidgetState extends State<OtpTimerAndResendWidget> {
  late Timer _countDownTimer;
  int _currentSeconds = 60;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  Widget build(BuildContext context) {
    String countDownText = _currentSeconds.toString();
    if (countDownText.length == 1) {
      countDownText = "0$_currentSeconds";
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Visibility(
          visible: _countDownTimer.isActive,
          child: TextView(
            title: "Time remaining  00:$countDownText",
            textStyle: commonTextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: inActiveTextColor),
          ),
        ),
        TextButton(
          onPressed: () => _onResentTap(),
          style: const ButtonStyle(
              tapTargetSize: MaterialTapTargetSize.shrinkWrap),
          child: TextView(
            title: "Resend OTP",
            textStyle: commonTextStyle(
                fontSize: 13, fontWeight: FontWeight.w600, color: buttonColor),
          ),
        ),
      ],
    );
  }

  void _startTimer() {
    _countDownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_currentSeconds == 0) {
          _countDownTimer.cancel();
        } else {
          _currentSeconds--;
        }
      });
    });
  }

  void _onResentTap() {
    _currentSeconds = 60;
    if (_countDownTimer.isActive) {
      _countDownTimer.cancel();
    }
    _startTimer();
    widget.onResend();
  }

  @override
  void dispose() {
    _countDownTimer.cancel();
    super.dispose();
  }
}
