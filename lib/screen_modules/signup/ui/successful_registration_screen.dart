import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fraazo_delivery/helpers/extensions/string_extension.dart';
import 'package:fraazo_delivery/ui/utils/textview.dart';
import 'package:fraazo_delivery/ui/utils/widgets_and_attributes.dart';
import 'package:fraazo_delivery/utils/utils.dart';
import 'package:fraazo_delivery/values/custom_colors.dart';
import 'package:get/get.dart';
import 'package:get/utils.dart';

class SuccessfulRegistrationScreen extends StatelessWidget {
  const SuccessfulRegistrationScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarBrightness: Brightness.dark,
    ));
    return Scaffold(
      backgroundColor: primaryBlackColor,
      body: SingleChildScrollView(
          child: Container(
        height: Get.height,
        width: Get.width,
        padding: const EdgeInsets.only(left: 25, right: 25, top: 60),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset('ic_congrats'.svgImageAsset),
            sizedBoxH60,
            FittedBox(
              child: TextView(
                  textAlign: TextAlign.center,
                  title: "Congratulations",
                  textStyle: commonTextStyle(
                      fontSize: px_20,
                      fontWeight: FontWeight.w700,
                      color: Colors.white)),
            ),
            sizedBoxH15,
            TextView(
                textAlign: TextAlign.center,
                title:
                    "Glad to have you registered as a rider. Our verification process takes around 2-3 hrs. We will notify you after the verifciation",
                textStyle: commonTextStyle(
                    fontSize: px_16,
                    fontWeight: FontWeight.w400,
                    color: inActiveTextColor)),
            // Container(
            //   margin: const EdgeInsets.only(bottom: px_10, top: px_50),
            //   child: Row(
            //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //     children: [
            //       Expanded(
            //         child: NewPrimaryButton(
            //           activeColor: buttonColor,
            //           inactiveColor: buttonInActiveColor,
            //           buttonTitle: "Continue",
            //           buttonRadius: px_8,
            //           onPressed: () {
            //             RouteHelper.push(Routes.TRAINING_SCREEN);
            //           },
            //         ),
            //       ),
            //     ],
            //   ),
            // )
          ],
        ),
      )),
    );
  }
}
