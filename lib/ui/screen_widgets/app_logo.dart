import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:fraazo_delivery/helpers/extensions/string_extension.dart';
import 'package:fraazo_delivery/ui/utils/widgets_and_attributes.dart';

class AppLogo extends StatelessWidget {
  final Color? logoColor;
  const AppLogo({Key? key, this.logoColor}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Hero(
          tag: "app_logo",
          child: Image.asset(
            "fraazo_logo".pngImageAsset,
            color: logoColor,
            height: 72,
            width: 72,
          ),
        ),
        sizedBoxW5,
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Text(
              "Fraazo",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              "Delivery Partner",
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        sizedBoxW20,
      ],
    );
  }
}
