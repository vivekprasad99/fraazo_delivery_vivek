import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fraazo_delivery/helpers/route/route_helper.dart';
import 'package:fraazo_delivery/models/delivery/delivery_items_model.dart';
import 'package:fraazo_delivery/models/delivery/task.dart';
import 'package:fraazo_delivery/providers/delivery/latest_task_provider.dart';
import 'package:fraazo_delivery/providers/delivery/order/order_items_provider.dart';
import 'package:fraazo_delivery/providers/delivery/order/order_update_provider.dart';
import 'package:fraazo_delivery/ui/global_widgets/container_divider.dart';
import 'package:fraazo_delivery/ui/global_widgets/fd_circular_loader.dart';
import 'package:fraazo_delivery/ui/global_widgets/fd_error_widget.dart';
import 'package:fraazo_delivery/ui/screens/delivery/steps/local_widgets/new_slide_button.dart';
import 'package:fraazo_delivery/ui/utils/toast.dart';
import 'package:fraazo_delivery/ui/utils/widgets_and_attributes.dart';
import 'package:fraazo_delivery/utils/constants.dart';
import 'package:fraazo_delivery/utils/utils.dart';
import 'package:fraazo_delivery/values/custom_colors.dart';

import '../../../../global_widgets/new_app_bar.dart';

class OrderSkusSelectionSheetScreen extends StatefulWidget {
  final TaskModelHelper? taskModelHelper;
  const OrderSkusSelectionSheetScreen(this.taskModelHelper, {Key? key})
      : super(key: key);

  @override
  _OrderSkusSelectionSheetScreenState createState() =>
      _OrderSkusSelectionSheetScreenState();
}

class _OrderSkusSelectionSheetScreenState
    extends State<OrderSkusSelectionSheetScreen> {
  final _orderItemsProvider = StateNotifierProvider.autoDispose<
      OrderItemsProvider, AsyncValue<OrderItems>>((_) => OrderItemsProvider());

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance?.addPostFrameCallback((_) => _getOrderItems());
    WidgetsBinding.instance?.addPostFrameCallback(
        (_) => context.read(latestTaskProvider.notifier).getLatestTask());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: NewAppBar(
        isShowLogout: false,
        inPop: true,
        isShowBack: false,
        title: 'Order pickup - ID : ${widget.taskModelHelper?.id ?? ''}',
      ),
      body: _buildBody(),
    );
  }

  num? getTotalUnits(OrderItems orderItems) {
    return orderItems.lineItems.fold(0.0, (sum, item) => sum! + item.qty!);
  }

  Widget _buildBody() {
    return SizedBox(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      child: SafeArea(
        child: Column(
          children: [
            //   Container(
            //     padding:
            //         const EdgeInsets.only(left: px_24, right: px_24, top: px_40),
            //     child: TextView(
            //         title: "Order pickup",
            //         textStyle:
            //             commonTextStyle(fontSize: 18, color: Colors.white)),
            //   ),
            // sizedBoxH15,
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Color(0xFFFFFFFF),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20.0),
                    topRight: Radius.circular(20.0),
                  ),
                ),
                child: Consumer(
                  builder: (_, watch, __) {
                    return watch(_orderItemsProvider).when(
                      data: (OrderItems orderItems) {
                        getTotalUnits(orderItems);

                        return Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: px_16),
                              child: ListTile(
                                title: Text(
                                  "Items in the Order",
                                  style: commonTextStyle(
                                    color: primaryBlackColor,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                subtitle: Text(
                                  "Total Units: ${getTotalUnits(orderItems)!.toInt()}",
                                  style: commonTextStyle(
                                    color: const Color(0xFF8A8787),
                                    fontSize: 15,
                                  ),
                                ),
                                trailing: Container(
                                  padding: const EdgeInsets.only(
                                      left: 12, right: 12, top: 6, bottom: 6),
                                  decoration: BoxDecoration(
                                    color: codBgColor,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    "${(widget.taskModelHelper?.order?.isCod ?? false) ? "COD ORDER: " : "PAID ORDER: "} ₹${orderItems.nettAmount}",
                                    style: commonTextStyle(
                                      color: primaryBlackColor,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: ListView.separated(
                                itemCount: orderItems.lineItems.length,
                                padding: const EdgeInsets.only(bottom: 100),
                                itemBuilder: (_, int index) {
                                  return _buildSkuItem(
                                      orderItems.lineItems[index], index);
                                },
                                separatorBuilder: (_, __) => const Padding(
                                  padding: EdgeInsets.only(
                                      left: px_16,
                                      right: px_16,
                                      bottom: px_8,
                                      top: px_8),
                                  child: ContainerDivider(),
                                ),
                              ),
                            ),
                            Material(
                              elevation: 0,
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(16.0),
                                    topRight: Radius.circular(16.0),
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey,
                                      offset: Offset(
                                        8.0,
                                        8.0,
                                      ),
                                      blurRadius: 15.0,
                                      spreadRadius: 1.0,
                                    ),
                                  ],
                                ),
                                width: double.infinity,
                                child: Column(
                                  children: [
                                    Container(
                                      width: MediaQuery.of(context).size.width *
                                          0.916,
                                      // height: 75,
                                      padding: const EdgeInsets.only(
                                          left: 20,
                                          right: 20,
                                          bottom: 15,
                                          top: 15),
                                      decoration: BoxDecoration(
                                        color: bgColor,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Center(
                                        child: Text(
                                          "Make sure to Pickup all the items in the Order",
                                          style: commonTextStyle(
                                            color: textColor,
                                            fontSize: 15,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                    ),
                                    sizedBoxH30,
                                    NewSlideButton(
                                      action: () => _startOrderDelivery(),
                                      backgroundColor: buttonColor,
                                      height: 54,
                                      radius: 10,
                                      dismissible: false,
                                      label: Text(
                                        "Order Picked up",
                                        textAlign: TextAlign.center,
                                        style: commonTextStyle(
                                          fontSize: 15,
                                          color: textColor,
                                        ),
                                      ),
                                      width: MediaQuery.of(context).size.width *
                                          0.9,
                                    ),
                                  ],
                                ),
                              ),
                            )
                          ],
                        );
                      },
                      loading: () => const FDCircularLoader(
                        progressColor: bgColor,
                      ),
                      error: (e, __) => SizedBox(
                        width: double.maxFinite,
                        child: FDErrorWidget(
                          textColor: Colors.black,
                          onPressed: _getOrderItems,
                          errorType: e,
                          shouldHideErrorToast: false,
                        ),
                      ),
                    );
                  },
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildSkuItem(LineItem lineItem, int index) {
    return Column(
      children: [
        ListTile(
          leading: CachedNetworkImage(
            imageUrl: lineItem.imageUrl!,
            height: 40,
            width: 40,
            fit: BoxFit.fill,
            placeholder: (context, url) =>
                const Center(child: CircularProgressIndicator()),
            errorWidget: (context, url, error) => const Icon(Icons.error),
          ),
          title: Text(
            lineItem.name ?? "",
            style: commonTextStyle(
              color: primaryBlackColor,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          subtitle: Text(
            lineItem.packSize ?? "",
            style: commonTextStyle(fontWeight: FontWeight.w600),
          ),
          trailing: Column(
            children: [
              // InkWell(
              //   onTap: () => context
              //       .read(_orderItemsProvider.notifier)
              //       .checkBoxStateOrderSkuSelection(index),
              //   child: SvgPicture.asset(
              //     lineItem.isMissing
              //         ? 'ic_check'.svgImageAsset
              //         : 'ic_un_check'.svgImageAsset,
              //     width: 23,
              //     height: 23,
              //   ),
              // ),
              // sizedBoxH2,
              Text(
                "${lineItem.qty} Unit",
                style: commonTextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _startOrderDelivery() async {
    Toast.popupLoadingFuture(
      future: () =>
          context.read(orderUpdateProvider.notifier).updateOrderStatus(
                Constants.TS_PICKUP_STARTED,
                orderSeq: widget.taskModelHelper?.order,
              ),
      onSuccess: (_) {
        final currentOrder =
            context.read(orderUpdateProvider.notifier).currentOrder;

        if (currentOrder != null) {
          context.read(latestTaskProvider.notifier).getLatestTask();
          RouteHelper.pop();
        }
      },
    );
  }

  void _onPickUpOrder() async {
    /*await RouteHelper.push(Routes.REACHED_CUSTOMER,
        args: widget.taskModelHelper?.task);
    RouteHelper.pop();*/
  }

  void _getOrderItems() {
    context
        .read(_orderItemsProvider.notifier)
        .getOrderLineItems(widget.taskModelHelper?.id ?? 0);
  }
}
