import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fraazo_delivery/helpers/extensions/string_extension.dart';
import 'package:fraazo_delivery/ui/utils/textview.dart';
import 'package:fraazo_delivery/ui/utils/widgets_and_attributes.dart';
import 'package:fraazo_delivery/utils/utils.dart';
import 'package:fraazo_delivery/values/custom_colors.dart';
import 'package:get/get.dart';

class ContainerBox extends GetView {
  final double connerRadius;
  final Color containerbgColor;
  final String? label;
  final String? imagePath;
  ContainerBox(
      {this.connerRadius = px_8,
      this.containerbgColor = containerBgColor,
      required this.label,
      required this.imagePath});

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Container(
      padding: const EdgeInsets.all(px_20),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(connerRadius),
          color: containerbgColor),
      child: Column(
        children: [
          SvgPicture.asset(
            imagePath.svgImageAsset,
            height: px_60,
            width: px_60,
          ),
          TextView(
              margin: const EdgeInsets.only(top: px_10),
              title: label!,
              textAlign: TextAlign.center,
              textStyle: commonTextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 15))
        ],
      ),
    );
  }
}
