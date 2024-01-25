import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fraazo_delivery/helpers/extensions/string_extension.dart';
import 'package:fraazo_delivery/providers/delivery/task_update_provider.dart';
import 'package:fraazo_delivery/providers/user/profile/user_profile_provider.dart';
import 'package:fraazo_delivery/ui/screen_widgets/shadow_card.dart';
import 'package:fraazo_delivery/ui/screens/delivery/steps/local_widgets/dialogs/return_inventory_widget.dart';
import 'package:fraazo_delivery/ui/screens/delivery/steps/local_widgets/new_slide_button.dart';
import 'package:fraazo_delivery/ui/utils/toast.dart';
import 'package:fraazo_delivery/ui/utils/widgets_and_attributes.dart';
import 'package:fraazo_delivery/utils/device_app_launcher.dart';
import 'package:fraazo_delivery/utils/globals.dart';
import 'package:fraazo_delivery/utils/utils.dart';
import 'package:fraazo_delivery/values/custom_colors.dart';

class ReachedDarkstoreWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Visibility(
          visible: Globals.user!.disableOrderAssignment!,
          child: Column(
            children: const [
              ShadowCard(
                child: ReturnInventoryWidget(),
              ),
              sizedBoxH10
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "More orders, More Earnings",
                textAlign: TextAlign.center,
                style: commonTextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xffE4E4E4),
                ),
              ),
              sizedBoxH10,
              Text(
                "Get back to your Dark store",
                textAlign: TextAlign.center,
                style: commonTextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xffE4E4E4),
                ),
              ),
              sizedBoxH24,
              InkWell(
                onTap: () => DeviceAppLauncher().launchByUrl(
                  "http://maps.google.com/maps?daddr=${Globals.user?.storeLat},${Globals.user?.storeLng}",
                ),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xff00A1F2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SvgPicture.asset(
                        'location_arrow'.svgImageAsset,
                        height: 14,
                        fit: BoxFit.cover,
                      ),
                      sizedBoxW5,
                      Text(
                        "Navigate to Darkstore",
                        style: commonTextStyle(
                          fontSize: 14,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              sizedBoxH30,
              _buildNewActionButton(context),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNewActionButton(BuildContext context) {
    return NewSlideButton(
      action: () => _onReachedDarkstore(context),
      backgroundColor: buttonColor,
      height: 54,
      radius: 10,
      dismissible: false,
      label: Text(
        "Reached Darkstore",
        style: commonTextStyle(
          fontSize: 15,
          color: textColor,
        ),
      ),
      width: MediaQuery.of(context).size.width * 0.9,
      alignLabel: const Alignment(0.1, 0),
    );
  }

  _onReachedDarkstore(BuildContext context) {
    Toast.popupLoadingFuture(
      future: () => context
          .read(taskUpdateProvider.notifier)
          .updateReachedDarkStore()
          .then(
            (value) =>
                context.read(userProfileProvider.notifier).getUserDetails(),
          ),
    );
  }
}
