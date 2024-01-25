import 'package:flutter/material.dart';
import 'package:fraazo_delivery/models/delivery/task_model.dart';
import 'package:fraazo_delivery/ui/utils/textview.dart';
import 'package:fraazo_delivery/ui/utils/widgets_and_attributes.dart';
import 'package:fraazo_delivery/utils/utils.dart';
import 'package:fraazo_delivery/values/custom_colors.dart';

class OrderDetailsWidget extends StatelessWidget {
  final Task? task;
  final OrderSeq orderSeq;
  const OrderDetailsWidget(this.orderSeq, this.task, {Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextView(
                  title: "ORDER #${orderSeq.orderNumber}",
                  textStyle: commonTextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                sizedBoxH10,
                TextView(
                  title: "Task ID : ${orderSeq.taskId}",
                  textStyle: commonTextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xffA9A9A9),
                  ),
                ),
              ],
            ),
            Container(
              padding:
                  const EdgeInsets.only(left: 10, right: 10, top: 8, bottom: 8),
              decoration: BoxDecoration(
                color: const Color(0xff3D3D3D),
                borderRadius: BorderRadius.circular(16.5),
              ),
              child: TextView(
                title: "COD ORDER: ₹${orderSeq.amount}",
                textStyle: commonTextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        sizedBoxH5,
        const Divider(
          thickness: 2,
          color: borderLineColor,
        ),
        sizedBoxH20,
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  height: px_10,
                  width: px_10,
                  decoration: const BoxDecoration(
                      color: Colors.white, shape: BoxShape.circle),
                ),
                sizedBoxW10,
                TextView(
                  title: "Pickup",
                  textStyle: commonTextStyle(
                    color: const Color(0xffAAAAAA),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(left: 20, top: 10),
              child: Text(
                task!.storeInfo!.storeName ?? '',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            )
          ],
        ),
      ],
    );
  }
}
