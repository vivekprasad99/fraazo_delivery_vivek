import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fraazo_delivery/providers/delivery/latest_task_provider.dart';
import 'package:fraazo_delivery/providers/location/location_provider.dart';
import 'package:fraazo_delivery/providers/user/profile/user_profile_provider.dart';
import 'package:fraazo_delivery/ui/screens/delivery/steps/local_widgets/dialogs/reached_darkstore_widget.dart';
import 'package:fraazo_delivery/ui/screens/home/local_widgets/delivery/active_delivery_widget.dart';
import 'package:fraazo_delivery/ui/utils/widgets_and_attributes.dart';
import 'package:fraazo_delivery/utils/globals.dart';
import 'package:fraazo_delivery/utils/utils.dart';
import 'package:fraazo_delivery/values/custom_colors.dart';

class GoOnlineAndTaskWidget extends StatelessWidget {
  const GoOnlineAndTaskWidget();
  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (_, watch, __) {
        final locationProviderValue = watch(locationProvider);
        watch(userProfileProvider);
        if (locationProviderValue.isServiceRunning) {
          if (Globals.user?.statusId == 5) {
            return ReachedDarkstoreWidget();
          } else {
            return const ActiveDeliveryWidget();
          }
        } else {
          return _buildGoOnlineCard(
            context,
            locationProviderValue.isLoading,
          );
        }
      },
    );
  }

  Widget _buildGoOnlineCard(BuildContext context, bool isLoading) {
    return GestureDetector(
      child: Container(
        margin: const EdgeInsets.only(top: 20, bottom: 20),
        height: 200,
        width: 200,
        alignment: Alignment.center,
        decoration: const BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.center,
                end: Alignment.bottomRight,
                colors: [
                  Color.fromRGBO(63, 62, 62, 1),
                  Color.fromRGBO(38, 38, 38, 1),
                  Color.fromRGBO(38, 38, 38, 0),
                ]),
            shape: BoxShape.circle),
        child: Container(
          padding: const EdgeInsets.only(top: 30),
          height: 160,
          width: 160,
          alignment: Alignment.center,
          decoration: BoxDecoration(
              border: Border.all(color: buttonColor, width: 3.5),
              shape: BoxShape.circle),
          child: Column(
            children: [
              Container(
                height: 5,
                width: 20,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color.fromRGBO(102, 234, 102, 1),
                        Color.fromRGBO(102, 234, 102, 0.68),
                      ]),
                  //color: buttonColor,
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
              sizedBoxH8,
              Text(
                "GO",
                style: commonPoppinsStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                "ONLINE",
                style: commonPoppinsStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
      onTap: () {
        context.read(locationProvider.notifier).startService();
      },
    );
  }

  void _onRefresh(BuildContext context) {
    if (Globals.isRiderAvailable) {
      context.read(userProfileProvider.notifier).getUserDetails();
      context.read(latestTaskProvider.notifier).getLatestTask();
    }
  }
}
