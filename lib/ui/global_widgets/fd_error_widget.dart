import 'dart:io';

import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:fraazo_delivery/ui/utils/widgets_and_attributes.dart';
import 'package:fraazo_delivery/utils/utils.dart';

class FDErrorWidget extends StatelessWidget {
  final VoidCallback onPressed;
  final bool canShowImage;
  final dynamic errorType;
  final bool shouldHideErrorToast;
  final Color textColor;
  const FDErrorWidget({
    Key? key,
    required this.onPressed,
    this.canShowImage = true,
    this.errorType,
    this.shouldHideErrorToast = true,
    this.textColor = Colors.white,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (shouldHideErrorToast) {
      BotToast.cleanAll();
    }
    String _message =
        "Something went wrong while processing.\nPlease try again";
    if (errorType == SocketException) {
      _message =
          "Could not connect to the internet.\nPlease check your network.";
    }
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if (canShowImage) ...[
            Icon(
              Icons.cloud_off,
              size: 40,
              color: textColor,
            ),
            sizedBoxH20,
          ],
          Text(
            _message,
            textAlign: TextAlign.center,
            style: commonTextStyle(
              // fontWeight: FontWeight.w400,
              color: textColor,
              fontSize: 14,
            ),
          ),
          sizedBoxH5,
          TextButton(
            onPressed: onPressed,
            child: Text(
              "Try again",
              style: commonTextStyle(
                  color: Color(0xFFF0576B),
                  fontSize: 16,
                  fontWeight: FontWeight.w700),
            ),
          )
        ],
      ),
    );
  }
}
