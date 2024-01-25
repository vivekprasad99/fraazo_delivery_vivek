import 'package:flutter/material.dart';
import 'package:fraazo_delivery/helpers/date/date_formatter.dart';
import 'package:fraazo_delivery/helpers/route/route_helper.dart';
import 'package:fraazo_delivery/helpers/route/routes.dart';
import 'package:fraazo_delivery/models/cash_deposit/transaction_model.dart';
import 'package:fraazo_delivery/ui/utils/widgets_and_attributes.dart';
import 'package:fraazo_delivery/utils/utils.dart';
import 'package:fraazo_delivery/values/custom_colors.dart';

class TransactionItemWidget extends StatefulWidget {
  final Transaction transaction;
  final bool isOnline;
  const TransactionItemWidget(this.transaction,
      {Key? key, this.isOnline = true})
      : super(key: key);

  @override
  _TransactionItemWidgetState createState() => _TransactionItemWidgetState();
}

class _TransactionItemWidgetState extends State<TransactionItemWidget> {
  late final String? paymentStatus = widget.isOnline
      ? widget.transaction.razorPayInfo?.status ?? ""
      : widget.transaction.status;

  @override
  Widget build(BuildContext context) {
    final dateTimeFormatter = DateFormatter();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15.0),
      child: InkWell(
        onTap: () {
          RouteHelper.push(Routes.TRANSACTION_DETAIL, args: widget.transaction);
        },
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.isOnline ? "Paid Via UPI" : "Paid Via COD",
                  style: commonTextStyle(
                    fontSize: 14,
                    color: settleCashListTitle,
                  ),
                ),
                Text(
                  widget.isOnline
                      ? "₹ ${widget.transaction.razorPayInfo!.amount! / 100}"
                      : "₹ ${widget.transaction.amount!}",
                  style: commonHindStyle(
                    fontSize: 14,
                  ),
                  /*  style: const TextStyle(
                          color: AppColors.secondary,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),*/
                ),
              ],
            ),
            sizedBoxH5,
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  dateTimeFormatter.dateStringToDateTimeWithAmPm(
                      widget.transaction.createdAt ?? ''),
                  /*dateTimeFormatter
                      .parseDateToDMY(widget.transaction.createdAt),*/
                  style: commonTextStyle(
                    color: settleCashListSubTitle,
                    fontSize: 9,
                  ),
                ),
                Text(
                  paymentStatus == "paid" || paymentStatus == "SETTLED"
                      ? 'Successful'
                      : 'Failure',
                  style: commonTextStyle(
                    fontSize: 9,
                    color: paymentStatus == "paid" || paymentStatus == "SETTLED"
                        ? greenStatusSetInCash
                        : orangeStatusSetInCash,
                  ),
                ),

                /*const Icon(
                        Icons.arrow_forward_ios,
                        size: 14,
                        color: AppColors.secondary,
                      )*/
              ],
            ),
            sizedBoxH5,
            Divider(
              color: dividerSetInCash.withOpacity(0.4),
            ),
          ],
        ),
      ),
    );
  }
}
