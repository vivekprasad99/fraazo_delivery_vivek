import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fraazo_delivery/helpers/date/date_formatter.dart';
import 'package:fraazo_delivery/helpers/extensions/string_extension.dart';
import 'package:fraazo_delivery/helpers/route/route_helper.dart';
import 'package:fraazo_delivery/helpers/route/routes.dart';
import 'package:fraazo_delivery/models/delivery/task.dart';
import 'package:fraazo_delivery/models/delivery/task_model.dart';
import 'package:fraazo_delivery/providers/delivery/latest_task_provider.dart';
import 'package:fraazo_delivery/providers/delivery/order/order_update_provider.dart';
import 'package:fraazo_delivery/providers/delivery/task_update_provider.dart';
import 'package:fraazo_delivery/ui/global_widgets/container_divider.dart';
import 'package:fraazo_delivery/ui/global_widgets/new_primary_button.dart';
import 'package:fraazo_delivery/ui/utils/textview.dart';
import 'package:fraazo_delivery/ui/utils/toast.dart';
import 'package:fraazo_delivery/ui/utils/widgets_and_attributes.dart';
import 'package:fraazo_delivery/utils/constants.dart';
import 'package:fraazo_delivery/utils/globals.dart';
import 'package:fraazo_delivery/utils/utils.dart';
import 'package:fraazo_delivery/values/custom_colors.dart';
import 'package:get/get.dart';

class NewDeliveryWidget extends StatefulWidget {
  final Task task;
  final VoidCallback onCheckAgainTap;

  const NewDeliveryWidget(this.task, this.onCheckAgainTap);

  @override
  State<NewDeliveryWidget> createState() => _NewDeliveryWidgetState();
}

class _NewDeliveryWidgetState extends State<NewDeliveryWidget> {
  late final Task _task = widget.task;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 12, top: 12, bottom: 12, right: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: SizedBox(
        width: double.infinity,
        child: Column(
          children: [
            _buildNewDeliveryHeader(),
            sizedBoxH10,
            _buildTaskList(),
            //_buildNewDeliveryDetailsWidget(),
            _buildGoToTaskButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildNewDeliveryHeader() {
    final dateTimeFormatter = DateFormatter();

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /*TextView(
            title: "Order ID : ${widget.task.orderSeq![0].orderNumber}",
            textStyle: commonTextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: const Color(0xff515151),
            ),
          ),
          const VerticalDivider(
            width: px_20,
            color: Color(0xffCFCFCF),
          ),*/
          Expanded(
            child: TextView(
              title: "Task ID : ${widget.task.id}",
              textStyle: commonTextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: const Color(0xff515151),
              ),
            ),
          ),
          TextView(
            title: widget.task.createdAt != null
                ? dateTimeFormatter.dateStringToDateTime(widget.task.createdAt!)
                : '',
            textStyle: commonTextStyle(
              fontWeight: FontWeight.w600,
              color: const Color(0xff8D8D8D),
            ),
          ),
        ],
      ),
    );
  }

  //height: MediaQuery.of(context).size.height * 0.20,
  Widget _buildTaskList() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const ContainerDivider(
          color: Color(0xffECECEC),
        ),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: widget.task.orderSeq?.length ?? 0,
          separatorBuilder: (_, __) => const ContainerDivider(
            color: Color(0xffECECEC),
          ),
          itemBuilder: (_, int index) {
            final orderSeq = widget.task.orderSeq?[index];
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextView(
                    title: "Order Number : ${orderSeq?.orderNumber}",
                    textStyle: commonTextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xff515151),
                    ),
                  ),
                  if (orderSeq?.orderStatus == Constants.OS_CREATED)
                    Visibility(
                      visible: Globals.user!.batchingQr!,
                      child: SvgPicture.asset(
                        'ic_scan'.svgImageAsset,
                        fit: BoxFit.cover,
                      ),
                    )
                  else
                    Flexible(
                      child: Container(
                        margin: const EdgeInsets.only(left: 10),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: buttonColor,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Text(
                          orderSeq?.orderStatus == Constants.TS_PICKUP_STARTED
                              ? 'Picked'
                              : '${orderSeq?.orderStatus?.replaceAll('_', ' ')}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: commonTextStyle(
                            fontSize: 10,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ) /*SizedBox(
                            height: MediaQuery.of(context).size.height * 0.034,
                            child: NewPrimaryButton(
                              activeColor: buttonColor,
                              inactiveColor: buttonColor,
                              buttonRadius: px_14,
                              buttonWidth:
                                  MediaQuery.of(context).size.width * 0.2,
                              buttonTitle: 'CUSTOMER_NOT_AVAILABLE',
                              fontSize: 12,
                            ),
                          )*/
                ],
              ),
            );
          },
        ),
        sizedBoxH5,
      ],
    );
  }

  Widget _buildNewDeliveryDetailsWidget() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        //horizontal: 8,
        vertical: 20,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SvgPicture.asset(
                'pickup_onbutton'.svgImageAsset,
                height: 20,
                width: 10,
                fit: BoxFit.cover,
              ),
              sizedBoxW10,
              Text(
                "Pickup",
                style: commonTextStyle(
                  color: const Color(0xff373737),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              //_buildDeliveryStepItem("Pickup", task.storeInfo?.storeName ?? ""),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(left: 25, top: 10),
            child: Text(
              widget.task.storeInfo?.storeName ?? "",
              style: commonTextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: const Color(0xff515151),
              ),
            ),
          )
        ],
      ),
    );
  }

// Widget _buildDeliveryHeader() {
  Widget _buildGoToTaskButton() {
    final orderSeq = _getOrder();
    return NewPrimaryButton(
      activeColor: buttonColor,
      inactiveColor: buttonColor,
      buttonRadius: px_8,
      buttonHeight: 45,
      buttonWidth: Get.width,
      buttonTitle: orderSeq?.orderStatus == Constants.OS_CREATED
          ? !Globals.user!.batchingQr!
              ? 'Start Pickup'
              : 'Scan & Pickup'
          : 'Start Delivery',
      onPressed: _openDeliveryStepsScreen,
      fontSize: px_18,
    );

    /*return Consumer(
      builder: (context, watch, __) {
        watch(taskUpdateProvider);
        return [
          Constants.TS_PICKUP_STARTED,
          Constants.OS_DELIVERY_STARTED,
          Constants.TS_RIDER_ASSIGNED,
        ].contains(widget.task.status)
            ? NewPrimaryButton(
                activeColor: buttonColor,
                inactiveColor: buttonColor,
                buttonRadius: px_8,
                buttonHeight: 45,
                buttonWidth: Get.width,
                buttonTitle: 'Scan & Pickup',
                onPressed: _openDeliveryStepsScreen,
                fontSize: px_18,
              )
            // PrimaryButton(
            //     text: "Go to Task",
            //     color: AppColors.secondary,
            //     onPressed: _openDeliveryStepsScreen,
            //   )
            : Text("Task is ${widget.task.status}");
      },
    );*/
  }

  Future _openDeliveryStepsScreen() async {
    final orderSeq = _getOrder();
    if (orderSeq?.orderStatus == Constants.OS_CREATED) {
      if (Globals.user!.batchingQr!) {
        final OrderSeq? _orderSeq = await RouteHelper.push(
          Routes.QR_CODE_SCANNER,
          args: {
            'task': widget.task,
            'order': orderSeq,
          },
        );

        if (_orderSeq != null) {
          RouteHelper.push(
            Routes.ORDER_PICKUP_SCREEN,
            args: TaskModelHelper(
              id: _orderSeq.id,
              order: _orderSeq,
            ),
          );
        }
      } else {
        if (orderSeq != null) {
          RouteHelper.push(
            Routes.ORDER_PICKUP_SCREEN,
            args: TaskModelHelper(
              id: orderSeq.id,
              order: orderSeq,
            ),
          );
        }
      }
    } else if (orderSeq?.orderStatus == Constants.OS_DELIVERED ||
        orderSeq?.orderStatus == Constants.OS_RESCHEDULED ||
        orderSeq?.orderStatus == Constants.OS_CANCELLED_BY_FRZ) {
      await context.read(taskUpdateProvider.notifier).onTaskComplete(
            orderSeq?.taskId,
            orderNumber: orderSeq?.orderNumber ?? '',
            isSingleOrder: widget.task.orderSeq!.length == 1,
          );
    } else if (orderSeq?.orderStatus == Constants.OS_CUSTOMER_NOT_AVAILABLE) {
      await RouteHelper.push(
        Routes.CUSTOMER_NOT_AVAILABLE_SCREEN,
        args: addTaskListInitial(orderSeq),
      );
    } else if (orderSeq?.orderStatus == Constants.OS_REACHED_CUSTOMER ||
        orderSeq?.orderStatus == Constants.OS_REATTEMPT_DELIVERY) {
      //Reattempt added
      String? qrCode;
      if (Globals.user!.batchingQr!) {
        qrCode = await RouteHelper.push(
          Routes.QR_CODE_SCANNER,
          args: {'task': widget.task, 'order': orderSeq, 'isPicked': true},
        );
      } else {
        qrCode = "";
      }

      if (qrCode != null) {
        await RouteHelper.push(
          Routes.DELIVERY_COMPLETED_SCREEN,
          args: addTaskListInitial(orderSeq),
        );
      }
    } else if (orderSeq?.orderStatus == Constants.TS_PICKUP_STARTED ||
        orderSeq?.orderStatus == Constants.OS_DELIVERY_STARTED) {
      if (widget.task.status == Constants.TS_RIDER_ASSIGNED) {
        context.read(taskUpdateProvider.notifier).updateTask(
              widget.task.id,
              Constants.OS_DELIVERY_STARTED,
            );
      }
      if (orderSeq?.orderStatus == Constants.TS_PICKUP_STARTED) {
        await Toast.popupLoadingFuture(
          future: () =>
              context.read(orderUpdateProvider.notifier).updateOrderStatus(
                    Constants.OS_DELIVERY_STARTED,
                    orderSeq: orderSeq,
                  ),
          onSuccess: (_) async {
            final OrderSeq orderSeq =
                context.read(orderUpdateProvider.notifier).currentOrder;

            await RouteHelper.push(
              Routes.REACHED_CUSTOMER,
              args: addTaskListInitial(orderSeq),
            );
          },
          onFailure: () async {},
        );
      } else {
        await RouteHelper.push(
          Routes.REACHED_CUSTOMER,
          args: addTaskListInitial(orderSeq),
        );
      }
    }
    /*else {
      await RouteHelper.push(Routes.ORDER_PICKUP_SCREEN, args: widget.task);
    }*/
    context.read(latestTaskProvider.notifier).getLatestTask();

    //On status delivered task should be completed
  }

  OrderSeq? _getOrder() {
    final orderSeqList = widget.task.orderSeq ?? [];

    OrderSeq? orderSeq;
    if (orderSeqList
        .any((element) => element.orderStatus == Constants.OS_CREATED)) {
      orderSeq = orderSeqList.firstWhereOrNull(
        (element) => element.orderStatus == Constants.OS_CREATED,
      );
    } else if (orderSeqList.any(
      (element) => element.orderStatus == Constants.OS_CUSTOMER_NOT_AVAILABLE,
    )) {
      orderSeq = orderSeqList.firstWhereOrNull(
        (element) => element.orderStatus == Constants.OS_CUSTOMER_NOT_AVAILABLE,
      );
    } else if (orderSeqList.any(
      (element) =>
          element.orderStatus == Constants.OS_REACHED_CUSTOMER ||
          element.orderStatus == Constants.OS_REATTEMPT_DELIVERY,
    )) {
      orderSeq = orderSeqList.firstWhereOrNull(
        (element) =>
            element.orderStatus == Constants.OS_REACHED_CUSTOMER ||
            element.orderStatus == Constants.OS_REATTEMPT_DELIVERY,
      );
    } else if (orderSeqList.any(
      (element) => element.orderStatus == Constants.OS_DELIVERY_STARTED,
    )) {
      orderSeq = orderSeqList.firstWhereOrNull(
        (element) => element.orderStatus == Constants.OS_DELIVERY_STARTED,
      );
    } else if (orderSeqList
        .any((element) => element.orderStatus == Constants.TS_PICKUP_STARTED)) {
      orderSeq = orderSeqList.firstWhereOrNull(
        (element) => element.orderStatus == Constants.TS_PICKUP_STARTED,
      );
    } else if (orderSeqList.any(
      (element) => element.orderStatus == Constants.OS_REATTEMPT_DELIVERY,
    )) {
      //Added, null status returning on REATTEMPT_DELIVERY status
      orderSeq = orderSeqList.firstWhereOrNull(
        (element) => element.orderStatus == Constants.OS_REATTEMPT_DELIVERY,
      );
    } else if (orderSeqList.last.orderStatus == Constants.OS_DELIVERED ||
        orderSeqList.last.orderStatus == Constants.OS_CANCELLED_BY_FRZ ||
        orderSeqList.last.orderStatus == Constants.OS_RESCHEDULED) {
      orderSeq = orderSeqList.last;
    } else {
      orderSeq = orderSeqList.firstWhereOrNull(
        (element) => element.orderStatus == Constants.OS_DELIVERED,
      );
    }
    return orderSeq;
  }

  Task addTaskListInitial(OrderSeq? orderSeq) {
    _task.orderSeq?.clear();
    _task.orderSeq?.add(orderSeq!);
    return _task;
  }
}
