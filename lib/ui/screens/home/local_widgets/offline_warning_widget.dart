import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fraazo_delivery/providers/location/location_provider.dart';
import 'package:fraazo_delivery/ui/global_widgets/colored_sizedbox.dart';
import 'package:fraazo_delivery/ui/utils/widgets_and_attributes.dart';

class OfflineWarningWidget extends StatelessWidget {
  const OfflineWarningWidget();
  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (_, watch, __) {
        return watch(locationProvider).isServiceRunning
            ? const SizedBox()
            : ColoredSizedBox(
                color: Colors.red,
                width: double.infinity,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.cloud_off,
                        size: 30,
                        color: Colors.white,
                      ),
                      sizedBoxW15,
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "You are offline!",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Row(
                            children: const [
                              Text(
                                "Go online to start accepting tasks",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                ),
                              ),
                              sizedBoxW5,
                              RotationTransition(
                                turns: AlwaysStoppedAnimation(45 / 360),
                                child: Icon(
                                  Icons.arrow_upward,
                                  color: Colors.white,
                                ),
                              )
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
      },
    );
  }
}
