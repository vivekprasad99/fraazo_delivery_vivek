import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fraazo_delivery/helpers/extensions/string_extension.dart';
import 'package:fraazo_delivery/helpers/route/route_helper.dart';
import 'package:fraazo_delivery/providers/splash/authentication_provider.dart';
import 'package:fraazo_delivery/ui/global_widgets/container_divider.dart';
import 'package:fraazo_delivery/ui/global_widgets/new_primary_button.dart';
import 'package:fraazo_delivery/ui/utils/widgets_and_attributes.dart';
import 'package:fraazo_delivery/utils/utils.dart';
import 'package:fraazo_delivery/values/custom_colors.dart';

class DeviceVerificationConfirmAlert extends StatelessWidget {
  final bool isHome;
  const DeviceVerificationConfirmAlert({this.isHome = false});
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: AlertDialog(
        insetPadding: const EdgeInsets.only(right: 20, left: 20),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(18.0)),
        ),
        backgroundColor: Colors.white,
        title: Stack(
          clipBehavior: Clip.none,
          children: [
            Column(
              children: [
                sizedBoxH15,
                Text(
                  "Device Confirmation",
                  style: commonPoppinsStyle(
                    fontSize: 15,
                    color: Colors.black,
                  ),
                ),
                sizedBoxH10,
                const ContainerDivider(
                  color: Color(0xFFDEDEDE),
                ),
                sizedBoxH10,
                Text(
                  "Please confirm if this is your permanent device for using the Fraazo Rider App",
                  style: commonTextStyle(
                    color: orderSeqColor,
                    fontSize: 14,
                  ),
                  //textAlign: TextAlign.center,
                ),
                sizedBoxH20,
                Text(
                  "If not, please Login with your Permanent Device",
                  style: commonTextStyle(
                    color: orderSeqColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  //textAlign: TextAlign.center,
                ),
              ],
            ),
            Positioned(
              top: -70,
              left: 0,
              right: 0,
              child: SvgPicture.asset(
                "device_tagging_phone".svgImageAsset,
              ),
            )
          ],
        ),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              TextButton(
                onPressed: () {
                  if (isHome) {
                    AuthenticationProvider().logout();
                  } else {
                    RouteHelper.exitApp();
                  }
                },
                child: Text(
                  "No, Logout",
                  style: commonTextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF4B4B4B),
                  ),
                ),
              ),
              NewPrimaryButton(
                buttonHeight: 38,
                buttonRadius: 4,
                activeColor: Colors.black,
                inactiveColor: Colors.black,
                buttonTitle: "Confirm",
                fontSize: 14,
                fontWeight: FontWeight.w600,
                onPressed: () => RouteHelper.pop(args: true),
              )
            ],
          )
        ],
      ),
    );
  }

  Future<bool> _onWillPop() {
    return Future.value(false);
  }
}
