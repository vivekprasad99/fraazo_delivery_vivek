import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fraazo_delivery/helpers/extensions/string_extension.dart';
import 'package:fraazo_delivery/helpers/route/route_helper.dart';
import 'package:fraazo_delivery/helpers/route/routes.dart';
import 'package:fraazo_delivery/ui/global_widgets/new_primary_button.dart';
import 'package:fraazo_delivery/ui/utils/widgets_and_attributes.dart';
import 'package:fraazo_delivery/utils/constants.dart';
import 'package:fraazo_delivery/utils/globals.dart';
import 'package:fraazo_delivery/utils/utils.dart';

class TaskCompleteDialog extends StatelessWidget {
  final String orderNumber;
  final String orderStatus;
  final bool isSingleOrder;

  const TaskCompleteDialog(
      {Key? key,
      required this.orderNumber,
      this.orderStatus = '',
      this.isSingleOrder = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    Globals.isCurrentTaskCompletedDialogShown = true;
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            // height: MediaQuery.of(context).copyWith().size.height * 0.45,
            padding:
                const EdgeInsets.only(top: 20, bottom: 20, left: 16, right: 16),
            width: MediaQuery.of(context).size.width,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12.0),
                topRight: Radius.circular(12.0),
              ),
            ),
            child: Column(
              children: [
                SvgPicture.asset(
                  'new_order_completed'.svgImageAsset,
                  height: 150,
                  fit: BoxFit.cover,
                ),
                sizedBoxH10,
                if (orderStatus.isNotEmpty &&
                    orderStatus == Constants.OS_RESCHEDULED &&
                    orderNumber.isNotEmpty) ...[
                  _buildOrderMessageView(
                    orderMessage: 'Order number: #$orderNumber on hold',
                  ),
                ] else if (orderNumber.isNotEmpty) ...[
                  _buildOrderMessageView(
                    orderMessage:
                        'Order number: #$orderNumber ${orderStatus == Constants.OS_CANCELLED_BY_FRZ || orderStatus == Constants.TS_DELETE ? 'Cancelled' : 'Delivered'}',
                  ),
                ] else ...[
                  _buildOrderMessageView(
                    orderMessage: 'Task Completed, Good Job !',
                  ),
                ],
                /*Text(
                  orderNumber.isNotEmpty
                      ? 'Order number: #$orderNumber Delivered'
                      : "Task Completed, Good Job !",
                  style: commonTextStyle(
                    color: const Color(0xff090808),
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),*/
                sizedBoxH10,
                Text(
                  orderStatus.isNotEmpty &&
                          orderStatus == Constants.OS_RESCHEDULED &&
                          orderNumber.isNotEmpty
                      ? isSingleOrder
                          ? 'The order is on hold, please complete your task.'
                          : 'The order is on hold, please proceed to deliver the next order.'
                      : orderNumber.isNotEmpty
                          ? isSingleOrder
                              ? 'More Orders are waiting for you at the Darkstore'
                              : 'Quickly get back to the new order in the task'
                          : "More Orders are waiting for you at the Darkstore",
                  style: commonTextStyle(
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
                sizedBoxH30,
                NewPrimaryButton(
                  activeColor: Colors.black,
                  inactiveColor: Colors.black,
                  buttonTitle: "Ok",
                  buttonRadius: px_8,
                  fontSize: px_18,
                  onPressed: () => _onOrderComplete(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderMessageView({required String orderMessage}) => Text(
        orderMessage,
        style: commonTextStyle(
          color: const Color(0xff090808),
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
      );

  Future<bool> _onWillPop() {
    return Future.value(false);
  }

  // Future<bool> _onWillPop() {
  //   RouteHelper.popUntil(Routes.HOME);
  //   Future.delayed(const Duration(seconds: 5), () {
  //     Globals.isCurrentTaskCompletedDialogShown = false;
  //   });
  //   return Future.value(false);
  // }
  void _onOrderComplete() {
    RouteHelper.removeUntil(Routes.HOME);
    Future.delayed(const Duration(seconds: 5), () {
      Globals.isCurrentTaskCompletedDialogShown = false;
    });
  }
}
