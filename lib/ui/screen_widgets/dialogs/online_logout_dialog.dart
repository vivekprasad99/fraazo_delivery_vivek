import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fraazo_delivery/helpers/extensions/string_extension.dart';
import 'package:fraazo_delivery/ui/global_widgets/container_divider.dart';
import 'package:fraazo_delivery/utils/utils.dart';

import '../../../helpers/route/route_helper.dart';
import '../../../values/custom_colors.dart';
import '../../utils/widgets_and_attributes.dart';

class OnlineLogoutDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: bgColor,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(px_16),
            child: Row(
              children: [
                SvgPicture.asset(
                  'ic_logout'.svgImageAsset,
                ),
                sizedBoxW10,
                Text(
                  "Logout",
                  textAlign: TextAlign.center,
                  style: commonTextStyle(fontSize: 15, color: textColor),
                ),
              ],
            ),
          ),
          const ContainerDivider(),
          Padding(
            padding: const EdgeInsets.all(px_16),
            child: Text(
              "Are you sure you want to logout and go offline?",
              textAlign: TextAlign.center,
              style: commonTextStyle(fontSize: 13, color: Colors.white),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () {
                  RouteHelper.pop(args: false);
                },
                child: Text(
                  'Cancel',
                  style: commonTextStyle(color: Colors.white),
                ),
              ),
              sizedBoxW10,
              TextButton(
                onPressed: () {
                  RouteHelper.pop(args: true);
                },
                child: Text(
                  'Logout',
                  style: commonTextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ],
      ),
    );
    //   AlertDialog(
    //   title: const Text("Logout"),
    //   content: const Text("Are you sure you want to logout and go offline?"),
    //   actions: [
    //     TextButton(
    //         onPressed: () => RouteHelper.pop(args: false),
    //         child: const Text("No")),
    //     TextButton(
    //         onPressed: () => RouteHelper.pop(args: true),
    //         child: const Text("Yes")),
    //   ],
    // );
  }
}
