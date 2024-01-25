import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fraazo_delivery/helpers/extensions/string_extension.dart';
import 'package:fraazo_delivery/helpers/route/route_helper.dart';
import 'package:fraazo_delivery/helpers/route/routes.dart';
import 'package:fraazo_delivery/models/delivery/task_model.dart';
import 'package:fraazo_delivery/providers/delivery/latest_task_provider.dart';
import 'package:fraazo_delivery/ui/global_widgets/new_primary_button.dart';
import 'package:fraazo_delivery/ui/utils/widgets_and_attributes.dart';
import 'package:fraazo_delivery/utils/utils.dart';
import 'package:fraazo_delivery/values/custom_colors.dart';

class DeliveryNowDialog extends StatelessWidget {
  final String orderNumber;
  const DeliveryNowDialog({Key? key, required this.orderNumber})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => _onWillPop(context),
      child: Dialog(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(px_16),
                child: SvgPicture.asset(
                  'ic_deliver_now'.svgImageAsset,
                  height: 100,
                  width: 110,
                ),
              ),
              Text(
                "Customer is Available now !",
                style: commonPoppinsStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: primaryBlackColor),
              ),
              sizedBoxH10,
              Text(
                "The Customer is available right now, Kindly deliver the Order",
                textAlign: TextAlign.center,
                style: commonTextStyle(fontSize: 13, color: inActiveTextColor),
              ),
              sizedBoxH20,
              NewPrimaryButton(
                buttonTitle: "Deliver Now",
                onPressed: () => _onWillPop(context),
                activeColor: buttonColor,
                inactiveColor: buttonColor,
                buttonRadius: px_8,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<bool> _onWillPop(BuildContext context) {
    RouteHelper.pop();
    /*RouteHelper.pushReplacement(Routes.DELIVERY_TYPE_SELECTOR);*/

    final _taskList =
        context.read(latestTaskProvider.notifier).state.data?.value;

    final orderList = _taskList?.orderSeq
        ?.where((element) => element.orderNumber == orderNumber)
        .toList()
        .single;

    _taskList?.orderSeq?.clear();
    _taskList?.orderSeq?.add(orderList ?? OrderSeq());

    RouteHelper.push(
      Routes.DELIVERY_COMPLETED_SCREEN,
      args: _taskList,
    );

    return Future.value(false);
  }
}
