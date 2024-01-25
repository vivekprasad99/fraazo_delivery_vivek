import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fraazo_delivery/helpers/route/route_helper.dart';
import 'package:fraazo_delivery/helpers/route/routes.dart';
import 'package:fraazo_delivery/providers/home_button_tab/home_button_tab_provider.dart';
import 'package:fraazo_delivery/providers/location/location_provider.dart';
import 'package:fraazo_delivery/ui/global_widgets/new_primary_button.dart';
import 'package:fraazo_delivery/ui/screens/home/home_screen.dart';
import 'package:fraazo_delivery/ui/screens/home/performance/performance_screen.dart';
import 'package:fraazo_delivery/ui/utils/widgets_and_attributes.dart';

class HomeButtonWidget extends StatefulWidget {
  const HomeButtonWidget({Key? key}) : super(key: key);

  @override
  _HomeButtonWidgetState createState() => _HomeButtonWidgetState();
}

class _HomeButtonWidgetState extends State<HomeButtonWidget> {
  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (_, watch, __) {
        final buttonChoosen = watch(buttonChooseProvider);
        final locationProviderValue = watch(locationProvider);
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  NewPrimaryButton(
                    buttonHeight: px_26,
                    buttonRadius: px_16,
                    buttonTitle: "Home",
                    fontColor: (buttonChoosen.isSelectedButton[0])
                        ? Colors.black
                        : Colors.white,
                    fontSize: px_14,
                    activeColor: (buttonChoosen.isSelectedButton[0])
                        ? Colors.white
                        : const Color(0xff2E2E2E),
                    inactiveColor: const Color(0xff2E2E2E),
                    onPressed: () {
                      context.read(buttonChooseProvider).selectButton(0);
                    },
                  ),
                  sizedBoxW10,
                  NewPrimaryButton(
                    buttonHeight: px_26,
                    buttonRadius: px_16,
                    buttonTitle: "Performance",
                    fontColor: (buttonChoosen.isSelectedButton[1])
                        ? Colors.black
                        : Colors.white,
                    fontSize: px_14,
                    activeColor: (buttonChoosen.isSelectedButton[1])
                        ? Colors.white
                        : const Color(0xff2E2E2E),
                    inactiveColor: const Color(0xff2E2E2E),
                    onPressed: () {
                      context.read(buttonChooseProvider).selectButton(1);
                    },
                  ),
                ],
              ),
            )
            // if (buttonChoosen.isSelectedButton[1]) ...[
            //   const PerformanceScreen(),
            // ]
          ],
        );
      },
    );
  }
}
