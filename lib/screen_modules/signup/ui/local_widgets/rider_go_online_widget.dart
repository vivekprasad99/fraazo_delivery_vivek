import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fraazo_delivery/helpers/extensions/string_extension.dart';
import 'package:fraazo_delivery/ui/global_widgets/new_primary_button.dart';
import 'package:fraazo_delivery/ui/utils/widgets_and_attributes.dart';
import 'package:fraazo_delivery/utils/globals.dart';
import 'package:fraazo_delivery/utils/utils.dart';
import 'package:fraazo_delivery/values/custom_colors.dart';

class RiderGoOnlineWidget extends StatelessWidget {
  final String msg1, msg2, imgName;
  final bool showButton;
  const RiderGoOnlineWidget(
      {required this.msg1,
      required this.msg2,
      required this.imgName,
      required this.showButton,
      Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Wrap(
        children: [
          Container(
            //height: 350,
            margin: const EdgeInsets.only(left: 30, right: 30),
            padding: const EdgeInsets.only(top: 20, left: 15, right: 15),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                SvgPicture.asset(
                  imgName.svgImageAsset,
                ),
                sizedBoxH10,
                Text(
                  msg1,
                  style: commonTextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                sizedBoxH10,
                Padding(
                  padding: const EdgeInsets.only(left: 20, right: 20),
                  child: Text(
                    "${Globals.user?.firstName} $msg2",
                    //"${Globals.user?.firstName} you are on time, Good luck in Delivering and Drive Safe",
                    textAlign: TextAlign.center,
                    style: commonTextStyle(
                      color: const Color(0xff858597),
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                sizedBoxH20,
                if (showButton) ...[
                  NewPrimaryButton(
                    activeColor: buttonColor,
                    inactiveColor: buttonColor,
                    buttonTitle: "Done",
                    buttonRadius: px_12,
                    fontSize: px_16,
                    onPressed: () => Navigator.pop(context, true),
                  ),
                  sizedBoxH30
                ]
              ],
            ),
          ),
        ],
      ),
    );
  }
}
