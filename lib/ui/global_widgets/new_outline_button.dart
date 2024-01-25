import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:fraazo_delivery/ui/utils/textview.dart';
import 'package:fraazo_delivery/utils/utils.dart';
import 'package:fraazo_delivery/values/custom_colors.dart';
import 'package:get/get.dart';

class NewOutlineButton extends GetView {
  final Color activeColor;
  final Color inactiveColor;
  final String buttonTitle;
  final VoidCallback? onPressed;
  final bool isActive;
  final double buttonRadius;
  final double buttonHeight;
  final double buttonWidth;
  final double fontSize;
  final FontWeight fontWeight;
  final Color fontColor;
  final double borderWidth;
  final Color buttonBgColor;

  const NewOutlineButton({
    required this.activeColor,
    required this.inactiveColor,
    this.buttonTitle = '',
    this.onPressed,
    this.isActive = true,
    this.buttonRadius = 0,
    this.buttonHeight = 50,
    this.buttonWidth = 50,
    this.fontSize = 15,
    this.fontWeight = FontWeight.w500,
    this.fontColor = Colors.white,
    this.borderWidth = 1.0,
    this.buttonBgColor = Colors.transparent,
  });

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return MaterialButton(
      onPressed: isActive ? onPressed : null,
      color: buttonBgColor,
      height: buttonHeight,
      minWidth: buttonWidth,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(buttonRadius),
          side: BorderSide(
              width: borderWidth,
              color: isActive ? activeColor : inactiveColor)),
      child: TextView(
        title: buttonTitle,
        alignment: Alignment.center,
        textStyle: commonTextStyle(
            fontWeight: fontWeight, fontSize: fontSize, color: fontColor),
      ),
    );
  }
}
