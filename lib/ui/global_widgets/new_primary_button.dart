import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:fraazo_delivery/ui/utils/textview.dart';
import 'package:fraazo_delivery/utils/utils.dart';
import 'package:get/get.dart';

import '../../values/custom_colors.dart';

class NewPrimaryButton extends GetView {
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
  final Color fontInActiveColor;
  final isLoading;

  const NewPrimaryButton(
      {required this.activeColor,
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
      this.fontInActiveColor = inActiveTextColor,
      this.isLoading = false});

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return MaterialButton(
      onPressed: isActive ? onPressed : null,
      color: isActive ? activeColor : inactiveColor,
      height: buttonHeight,
      minWidth: buttonWidth,
      disabledColor: inactiveColor,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(buttonRadius)),
      child: isLoading
          ? const Center(
              child: SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation(Colors.white),
                ),
              ),
            )
          : TextView(
              title: buttonTitle,
              alignment: Alignment.center,
              textStyle: commonTextStyle(
                  fontWeight: fontWeight,
                  fontSize: fontSize,
                  color: isActive ? fontColor : fontInActiveColor),
            ),
    );
  }
}
