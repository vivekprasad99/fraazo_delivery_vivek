import 'package:bot_toast/bot_toast.dart';
import 'package:edge_alerts/edge_alerts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fraazo_delivery/helpers/extensions/string_extension.dart';
import 'package:fraazo_delivery/helpers/route/route_helper.dart';
import 'package:fraazo_delivery/utils/utils.dart';
import 'package:fraazo_delivery/values/custom_colors.dart';

class Toast {
  static void normal(String msg, {Alignment align = const Alignment(0, 0.75)}) {
    _buildCustomToast(msg, Colors.black87, align: align);
  }

  static void info(String msg, {Alignment align = const Alignment(0, 0.75)}) {
    _buildCustomToast(msg, Colors.black87, align: align);
  }

  static void error([String errorMsg = "Oops! Try Again."]) {
    _buildCustomToast(errorMsg, bgColor, isErrorType: true);
  }

  static void _buildCustomToast(String msg, Color bgColor,
      {Alignment align = const Alignment(0, 0.75), bool isErrorType = false}) {
    BotToast.showCustomText(
      onlyOne: true,
      duration: Duration(seconds: _getToastDuration(msg)),
      align: align,
      ignoreContentClick: true,
      toastBuilder: (_) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              color: bgColor,
              boxShadow: const [
                BoxShadow(blurRadius: 4, spreadRadius: 4, color: Colors.black26)
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SvgPicture.asset(
                  'ic_error'.svgImageAsset,
                  color: isErrorType ? errorTextColor : deliveredTextColors,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isErrorType ? 'Error' : 'Info',
                        style: commonPoppinsStyle(
                            fontSize: 15,
                            color: isErrorType
                                ? errorTextColor
                                : deliveredTextColors,
                            fontWeight: FontWeight.w700),
                        textAlign: TextAlign.center,
                      ),
                      Text(
                        msg,
                        style: commonTextStyle(
                            fontSize: 13, color: popupSubtitleColor),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static int _getToastDuration(String msg) {
    int toastDuration = msg.length ~/ 20;

    if (toastDuration < 2) {
      toastDuration = 2;
    } else if (toastDuration > 8) {
      toastDuration = 8;
    }
    return toastDuration;
  }

  static void showInfoAlerter(String title) {
    edgeAlert(RouteHelper.navigatorContext,
        title: title,
        // description: description,
        icon: Icons.info,
        backgroundColor: Colors.blueGrey);
  }

  static void showSuccessAlerter(String title) {
    edgeAlert(RouteHelper.navigatorContext,
        title: title,
        // description: description,
        icon: Icons.check_circle,
        backgroundColor: Colors.green);
  }

  static CancelFunc popupLoading(
      {bool clickClose = false, bool crossPage = false}) {
    return BotToast.showLoading(
      clickClose: clickClose,
      crossPage: crossPage,
    );
  }

  static Future<bool> popupLoadingFuture<T>(
      {required Future Function() future,
      Function(T data)? onSuccess,
      Function()? onFailure,
      bool clickClose = false,
      bool crossPage = false}) async {
    final popupLoadingFunc =
        popupLoading(clickClose: clickClose, crossPage: crossPage);
    try {
      final futureValue = await future();
      onSuccess?.call(futureValue);
      popupLoadingFunc();
      return true;
    } catch (e, _) {
      onFailure?.call();
      popupLoadingFunc();
      return false;
    }
  }
}
