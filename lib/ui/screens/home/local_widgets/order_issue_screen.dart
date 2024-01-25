import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fraazo_delivery/helpers/route/route_helper.dart';
import 'package:fraazo_delivery/helpers/route/routes.dart';
import 'package:fraazo_delivery/helpers/shared_pref/pref_helper.dart';
import 'package:fraazo_delivery/helpers/shared_pref/pref_keys.dart';
import 'package:fraazo_delivery/models/delivery/task_model.dart';
import 'package:fraazo_delivery/providers/delivery/order/order_update_provider.dart';
import 'package:fraazo_delivery/ui/global_widgets/container_divider.dart';
import 'package:fraazo_delivery/ui/global_widgets/new_app_bar.dart';
import 'package:fraazo_delivery/ui/screens/delivery/steps/local_widgets/customer_not_available_screen.dart';
import 'package:fraazo_delivery/ui/utils/toast.dart';
import 'package:fraazo_delivery/ui/utils/widgets_and_attributes.dart';
import 'package:fraazo_delivery/utils/constants.dart';
import 'package:fraazo_delivery/utils/utils.dart';
import 'package:fraazo_delivery/values/custom_colors.dart';
import 'package:get/get.dart';

class OrderIssueScreen extends StatefulWidget {
  final Task? task;
  const OrderIssueScreen(this.task, {Key? key}) : super(key: key);

  @override
  State<OrderIssueScreen> createState() => _OrderIssueScreenState();
}

class _OrderIssueScreenState extends State<OrderIssueScreen> {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarBrightness: Brightness.dark,
    ));
    return Scaffold(
      backgroundColor: primaryBlackColor,
      appBar: const NewAppBar(),
      body: Container(
        height: Get.height,
        width: Get.width,
        decoration: const BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(px_16),
                topRight: Radius.circular(px_16))),
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(left: px_20, right: px_20, top: px_20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.error,
                    size: 24,
                    color: Colors.red[700],
                  ),
                  sizedBoxW10,
                  Text(
                    "Order Issues",
                    style: commonTextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              sizedBoxH5,
              Text(
                "Choose an issue relevant to your order",
                style: commonTextStyle(
                  color: Color(0xFF787878),
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        sizedBoxH20,
        if (widget.task!.orderSeq![0].isCod) ...[
          _buildIssuesDetails("Quality/Missing items"),
          //_buildIssuesDetails("Missing item"),
          //_buildIssuesDetails("Quality issues"),
        ],
        _buildIssuesDetails("Customer not available"),
        const ContainerDivider(),
      ],
    );
  }

  Widget _buildIssuesDetails(String label) {
    return Column(
      children: [
        const ContainerDivider(),
        GestureDetector(
          child: ListTile(
            title: Text(
              label,
              style: commonTextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
            ),
            trailing: const Icon(
              Icons.arrow_forward,
              color: Colors.white,
              size: 20,
            ),
          ),
          onTap: () {
            label == "Customer not available"
                ? _customerNotAvailableDialog()
                : RouteHelper.push(Routes.NEW_ORDER_REASON_SCREEN, args: {
                    'orderIssueType': label,
                    'orderSeq': widget.task?.orderSeq?.single
                  });
          },
        ),
      ],
    );
  }

  Future _customerNotAvailableDialog() async {
    Toast.popupLoadingFuture(
        future: () => context
            .read(orderUpdateProvider.notifier)
            .updateOrderStatus(Constants.OS_CUSTOMER_NOT_AVAILABLE,
                orderSeq: widget.task!.orderSeq!.single),
        onSuccess: (_) => _onCompleteOperations());
  }

  Future _onCompleteOperations() async {
    RouteHelper.openDialog(CustomerNotAvailableScreen(),
        barrierDismissible: false);
    PrefHelper.setValue(PrefKeys.IS_NEW_ORDER, false);
  }
}
