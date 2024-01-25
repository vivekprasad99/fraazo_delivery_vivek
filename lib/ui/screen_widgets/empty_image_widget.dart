import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fraazo_delivery/helpers/extensions/string_extension.dart';
import 'package:fraazo_delivery/ui/utils/textview.dart';
import 'package:fraazo_delivery/ui/utils/widgets_and_attributes.dart';
import 'package:fraazo_delivery/utils/utils.dart';
import 'package:fraazo_delivery/values/custom_colors.dart';

class EmptyImageWidget extends StatelessWidget {
  final String noImageText;
  const EmptyImageWidget({this.noImageText = ''});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SvgPicture.asset(
          "add_photo".svgImageAsset,
        ),
        sizedBoxW5,
        TextView(
          title: noImageText,
          textStyle: commonTextStyle(color: inActiveTextColor, fontSize: 13),
        ),
      ],
    );
  }
}
