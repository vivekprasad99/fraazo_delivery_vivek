import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fraazo_delivery/helpers/route/route_helper.dart';
import 'package:fraazo_delivery/providers/delivery/latest_task_provider.dart';
import 'package:fraazo_delivery/ui/screens/delivery/steps/support/freshchat_service.dart';
import 'package:fraazo_delivery/ui/utils/toast.dart';
import 'package:fraazo_delivery/ui/utils/widgets_and_attributes.dart';
import 'package:fraazo_delivery/utils/constants.dart';
import 'package:fraazo_delivery/utils/device_app_launcher.dart';

class SupportDialog extends StatelessWidget {
  const SupportDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Connect with?",
                  style: Theme.of(context).textTheme.headline6,
                ),
                IconButton(
                    onPressed: () {
                      RouteHelper.pop();
                    },
                    icon: const Icon(
                      Icons.close_rounded,
                      color: Colors.black,
                    ))
              ],
            ),
            sizedBoxH20,
            const Text(
              "Use chat open to get support quickly",
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
            ),
            sizedBoxH10,
            SizedBox(
              width: double.infinity,
              height: 40,
              child: ElevatedButton.icon(
                onPressed: () => _onChatWithUsTap(context),
                icon: const Icon(Icons.chat),
                label: const Text(
                  "CHAT",
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
            sizedBoxH30,
            const Text("Chat not helping? Then use emergency"),
            sizedBoxH5,
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: _onCallUsTap,
                child: const Text(
                  "EMERGENCY",
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onCallUsTap() {
    DeviceAppLauncher().callPhoneNumber(Constants.SUPPORT_PHONE_NUMBER);
  }

  Future _onChatWithUsTap(BuildContext context) async {
    final order =
        context.read(latestTaskProvider.notifier).currentTask?.orderSeq?.first;
    if (order != null) {
      Toast.normal("Order number copied for reference.");
      Clipboard.setData(ClipboardData(text: order.orderNumber!));
      await Future.delayed(const Duration(milliseconds: 600));
    }
    FreshchatService.instance.openChat();
    // final zendeskService = ZendeskSupportService();
    // final bool isSuccess =
    //     await zendeskService.initialise(SDKKeys.ZENDESK_CHANNEL_KEY);
    // if (isSuccess) {
    //   zendeskService.openZendeskMessaging();
    // } else {
    //   Toast.info("Something went wrong. Please try again");
    // }
  }
}
