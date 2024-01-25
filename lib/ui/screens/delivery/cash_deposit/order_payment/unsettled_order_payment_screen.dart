import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fraazo_delivery/helpers/route/route_helper.dart';
import 'package:fraazo_delivery/helpers/route/routes.dart';
import 'package:fraazo_delivery/models/cash_deposit/unsettled_order_model.dart';
import 'package:fraazo_delivery/providers/cash_deposit/unsettled_order_provider.dart';
import 'package:fraazo_delivery/ui/global_widgets/fd_app_bar.dart';
import 'package:fraazo_delivery/ui/global_widgets/fd_circular_loader.dart';
import 'package:fraazo_delivery/ui/global_widgets/fd_error_widget.dart';
import 'package:fraazo_delivery/ui/global_widgets/new_primary_button.dart';
import 'package:fraazo_delivery/ui/screen_widgets/no_data_widget.dart';
import 'package:fraazo_delivery/ui/screen_widgets/shadow_card.dart';
import 'package:fraazo_delivery/ui/utils/toast.dart';
import 'package:fraazo_delivery/ui/utils/widgets_and_attributes.dart';
import 'package:fraazo_delivery/utils/utils.dart';
import 'package:fraazo_delivery/values/custom_colors.dart';

class UnsettledOrderPaymentScreen extends StatefulWidget {
  const UnsettledOrderPaymentScreen({Key? key}) : super(key: key);

  @override
  _UnsettledOrderPaymentScreenState createState() =>
      _UnsettledOrderPaymentScreenState();
}

class _UnsettledOrderPaymentScreenState
    extends State<UnsettledOrderPaymentScreen> {
  final List<String> _selectedOrderNumberList = [];
  double _selectedOrderAmount = 0;

  @override
  void initState() {
    super.initState();
    _getUnsettledOrderList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: const FDAppBar(
        titleText: "Settle cash in hand",
      ),
      body: _buildBody(),
      bottomNavigationBar: ShadowCard(
        child: Padding(
          padding: const EdgeInsets.all(25),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Total Amount",
                    style: commonTextStyle(
                      color: settleCashListSubTitle,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    "₹${_selectedOrderAmount.toStringAsFixed(2)}",
                    style: commonTextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              sizedBoxH30,
              NewPrimaryButton(
                activeColor: buttonColor,
                inactiveColor: buttonColor,
                buttonTitle: "Proceed to payment",
                buttonRadius: px_8,
                fontSize: px_18,
                onPressed: _selectedOrderAmount <= 0
                    ? null
                    : () => _onProceedToPayTap(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Divider(
            color: dividerSetInCash.withOpacity(0.4),
          ),
          ListTile(
            leading: Text(
              "Select the orders you want to settle via UPI",
              style: commonTextStyle(
                color: lightBlackTxtColor,
                fontSize: 15,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          //sizedBoxH10,
          Divider(
            color: dividerSetInCash.withOpacity(0.2),
          ),
          //sizedBoxH10,
          SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 100),
            child: _buildUnsettledOrderListConsumer(),
          ),
        ],
      ),
    );
  }

  Widget _buildUnsettledOrderListConsumer() {
    return Consumer(
      builder: (_, watch, __) {
        return watch(unsettledOrderProvider).when(
          data: (UnsettledOrderModel unsettledOrder) =>
              _buildUnsettledOrderList(unsettledOrder),
          loading: () => const FDCircularLoader(),
          error: (e, _) => FDErrorWidget(
            onPressed: _getUnsettledOrderList,
            errorType: e,
          ),
        );
      },
    );
  }

  Widget _buildUnsettledOrderList(UnsettledOrderModel unsettledOrder) {
    return unsettledOrder.unsettledOrderList.isEmpty
        ? const Expanded(child: NoDataWidget())
        : Column(
            children: [
              ListView.separated(
                itemCount: unsettledOrder.unsettledOrderList.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (_, int index) {
                  return _buildUnsettledOrders(
                      unsettledOrder.unsettledOrderList[index]);
                },
                separatorBuilder: (_, __) => Divider(
                  color: dividerSetInCash.withOpacity(0.2),
                ),
              ),
            ],
          );
  }

  Widget _buildUnsettledOrders(UnsettledOrder unsettledOrder) {
    //final dateTimeFormatter = DateFormatter();
    return CheckboxListTile(
      controlAffinity: ListTileControlAffinity.leading,
      tileColor: Colors.transparent,
      contentPadding: const EdgeInsets.only(left: 15, right: 25),
      selectedTileColor: buttonColor,
      title: Row(
        children: [
          Expanded(
            child: Text(
              "Order Id : ${unsettledOrder.orderNumbers}",
              style: commonTextStyle(
                  color: settleCashListTitle,
                  fontSize: 15,
                  fontWeight: FontWeight.w400),
            ),
          ),
          Visibility(
            visible: unsettledOrder.dispute == true,
            child: Text(
              " (Dispute Raised)",
              style: commonTextStyle(
                  color: Colors.red, fontSize: 15, fontWeight: FontWeight.w500),
            ),
          )
        ],
      ),
      // Text(
      //   "#${unsettledOrder.orderNumbers} ${unsettledOrder.dispute == true ? 'Dispute Raised' : ''}",
      //   style: const TextStyle(
      //       color: Colors.black87, fontSize: 15, fontWeight: FontWeight.w500),
      // ),
      // subtitle: Column(
      //   crossAxisAlignment: CrossAxisAlignment.start,
      //   children: [
      //     Text(
      //       dateTimeFormatter.parseDateToDMY(unsettledOrder.createdAt),
      //       style: const TextStyle(
      //           color: AppColors.black02,
      //           fontSize: 12,
      //           fontWeight: FontWeight.w500),
      //     ),
      //     Visibility(
      //       visible: unsettledOrder.dispute == true,
      //       child: const Text(
      //         "(Reach out to CM for resolution)",
      //         style: TextStyle(
      //             color: Colors.red, fontSize: 12, fontWeight: FontWeight.w400),
      //       ),
      //     )
      //   ],
      // ),
      secondary: Text(
        "₹${unsettledOrder.amountCollected}",
        style: commonTextStyle(fontSize: 15, color: Colors.white),
      ),
      activeColor: buttonColor,
      checkColor: Colors.black,
      value: _selectedOrderNumberList.contains(unsettledOrder.orderNumbers),
      onChanged: unsettledOrder.dispute == true
          ? null
          : (bool? isChecked) => setState(() {
                if (isChecked!) {
                  _selectedOrderNumberList.add(unsettledOrder.orderNumbers!);
                  _selectedOrderAmount += unsettledOrder.amountCollected!;
                } else {
                  _selectedOrderNumberList.remove(unsettledOrder.orderNumbers);
                  _selectedOrderAmount -= unsettledOrder.amountCollected!;
                }
              }),
    );
  }

  Future _getUnsettledOrderList() {
    return context.read(unsettledOrderProvider.notifier).getUnsettledOrders();
  }

  Future _onProceedToPayTap() async {
    Toast.popupLoadingFuture(
      future: () => context
          .read(unsettledOrderProvider.notifier)
          .initiateOrderTransaction(_selectedOrderNumberList),
      onSuccess: (dynamic transaction) async {
        if (transaction != null) {
          final bool? shouldRefresh =
              await RouteHelper.push(Routes.TRANSACTION, args: transaction);
          if (shouldRefresh != null && shouldRefresh) {
            _getUnsettledOrderList();
            setState(() {
              _selectedOrderNumberList.clear();
              _selectedOrderAmount = 0;
            });
          }
        } else {
          Toast.info("Something went wrong. Please try again");
        }
      },
    );
  }
}
