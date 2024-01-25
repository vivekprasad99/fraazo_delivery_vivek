import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fraazo_delivery/helpers/extensions/string_extension.dart';
import 'package:fraazo_delivery/providers/delivery/latest_task_provider.dart';
import 'package:fraazo_delivery/ui/global_widgets/fd_app_bar.dart';
import 'package:fraazo_delivery/ui/global_widgets/new_primary_button.dart';
import 'package:fraazo_delivery/ui/screens/delivery/steps/support/freshchat_service.dart';
import 'package:fraazo_delivery/ui/utils/toast.dart';
import 'package:fraazo_delivery/ui/utils/widgets_and_attributes.dart';
import 'package:fraazo_delivery/utils/constants.dart';
import 'package:fraazo_delivery/utils/device_app_launcher.dart';
import 'package:fraazo_delivery/utils/utils.dart';
import 'package:fraazo_delivery/values/custom_colors.dart';

class SupportScreen extends StatelessWidget {
  const SupportScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: const FDAppBar(
        backgroundColor: Colors.black,
        titleText: "Support",
      ),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    return Column(
      children: [
        Divider(
          color: dividerSetInCash.withOpacity(0.4),
        ),
        sizedBoxH30,
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: SvgPicture.asset(
            'ic_support_logo'.svgImageAsset,
            height: 220,
          ),
        ),
        sizedBoxH20,
        Text(
          'Need Assistance ?  We are happy to help',
          maxLines: 1,
          style: commonTextStyle(
            color: inActiveTextColor,
            fontSize: 14,
            lineHeight: 1.4,
          ),
        ),
        sizedBoxH10,
        _btnChatWithUs(context),
        sizedBoxH15,
        const Expanded(child: SizedBox()),
        Text(
          'Chat not helpful ? Then use Emergency',
          maxLines: 1,
          style: commonTextStyle(
            color: inActiveTextColor,
            fontSize: 14,
            lineHeight: 1.4,
          ),
        ),
        sizedBoxH12,
        TextButton(
          onPressed: _onCallUsTap,
          child: Text(
            'Emergency',
            maxLines: 1,
            style: commonTextStyle(
              decoration: TextDecoration.underline,
              color: lightBlackTxtColor,
              fontSize: 14,
              lineHeight: 1.4,
            ),
          ),
        ),
        sizedBoxH30,
      ],
    );
  }

  Widget _btnChatWithUs(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16.0),
      child: NewPrimaryButton(
        buttonHeight: MediaQuery.of(context).size.height * 0.065,
        activeColor: btnLightGreen,
        inactiveColor: buttonInActiveColor,
        buttonRadius: px_8,
        buttonTitle: 'Chat with us',
        onPressed: () => _onChatWithUsTap(context),
      ),
    );
  }

  void _onCallUsTap() =>
      DeviceAppLauncher().callPhoneNumber(Constants.SUPPORT_PHONE_NUMBER);

  Future _onChatWithUsTap(BuildContext context) async {
    final order =
        context.read(latestTaskProvider.notifier).currentTask?.orderSeq?.first;
    if (order != null) {
      Toast.normal("Order number copied for reference.");
      Clipboard.setData(ClipboardData(text: order.orderNumber!));
      await Future.delayed(const Duration(milliseconds: 600));
    }
    // final zendeskService = ZendeskSupportService();
    // final bool isSuccess =
    //     await zendeskService.initialise(SDKKeys.ZENDESK_CHANNEL_KEY);
    // if (isSuccess) {
    //   zendeskService.openZendeskMessaging();
    // } else {
    //   Toast.info("Something went wrong. Please try again");
    // }
    FreshchatService.instance.openChat();
  }
}
