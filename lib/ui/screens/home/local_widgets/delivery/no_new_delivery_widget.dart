import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fraazo_delivery/helpers/route/route_helper.dart';
import 'package:fraazo_delivery/helpers/route/routes.dart';
import 'package:fraazo_delivery/providers/delivery/latest_task_provider.dart';
import 'package:fraazo_delivery/ui/global_widgets/new_primary_button.dart';
import 'package:fraazo_delivery/ui/screen_widgets/shadow_card.dart';
import 'package:fraazo_delivery/ui/utils/toast.dart';
import 'package:fraazo_delivery/ui/utils/widgets_and_attributes.dart';
import 'package:fraazo_delivery/utils/globals.dart';
import 'package:fraazo_delivery/utils/utils.dart';
import 'package:fraazo_delivery/values/custom_colors.dart';

class NoNewDeliveryWidget extends StatelessWidget {
  final VoidCallback onCheckAgainTap;
  const NoNewDeliveryWidget({required this.onCheckAgainTap});
  @override
  Widget build(BuildContext context) {
    final bool shouldEnableQRScan = Globals.user?.enableQrScanning ?? false;
    return ShadowCard(
      child: SizedBox(
        width: double.infinity,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Text(
                "No Order Assigned",
                style: commonTextStyle(
                  color: const Color(0xffA9A9A9),
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              sizedBoxH5,
              const Divider(
                color: borderLineColor,
              ),
              sizedBoxH15,
              Icon(
                shouldEnableQRScan ? Icons.qr_code_scanner : Icons.cloud_off,
                size: 45,
                color: Colors.white,
              ),
              sizedBoxH15,
              Text(
                shouldEnableQRScan
                    ? "Scan the QR present on the challan to get new orders"
                    : "Be ready, New orders will be assigned soon",
                textAlign: TextAlign.center,
                style: commonTextStyle(
                  color: const Color(0xffC1C1C1),
                  fontSize: 14,
                ),
              ),
              sizedBoxH20,
              NewPrimaryButton(
                activeColor: buttonColor,
                inactiveColor: buttonInActiveColor,
                buttonTitle: shouldEnableQRScan ? "Scan QR code" : "Refresh",
                buttonRadius: px_8,
                onPressed: () => _onCheckOrScanButtonTap(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future _onCheckOrScanButtonTap(BuildContext context) async {
    if (Globals.user!.enableQrScanning) {
      final String? orderID = await RouteHelper.push(
        Routes.NO_ORDER_QR_CODE_SCANNER,
      ); //Routes.QR_CODE_SCANNER);
      if (orderID != null) {
        final bool isSuccess = await Toast.popupLoadingFuture(
          future: () => context
              .read(latestTaskProvider.notifier)
              .assignTaskByQR(int.parse(orderID)),
        );
        if (isSuccess) {
          context.read(latestTaskProvider.notifier).getLatestTask();
        }
      }
    } else {
      onCheckAgainTap();
    }
  }
}
