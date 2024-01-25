import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fraazo_delivery/helpers/date/date_formatter.dart';
import 'package:fraazo_delivery/models/cash_deposit/transaction_model.dart';
import 'package:fraazo_delivery/providers/cash_deposit/order_history_provider.dart';
import 'package:fraazo_delivery/ui/global_widgets/fd_app_bar.dart';
import 'package:fraazo_delivery/utils/utils.dart';
import 'package:fraazo_delivery/values/custom_colors.dart';

import '../../../../../models/cash_deposit/order_payment_model.dart';
import '../../../../global_widgets/fd_circular_loader.dart';
import '../../../../global_widgets/fd_error_widget.dart';

class TransactionDetailWidget extends StatefulWidget {
  final Transaction? transaction;
  final bool isOnline;

  TransactionDetailWidget({Key? key, this.transaction, this.isOnline = true})
      : super(key: key);

  @override
  State<TransactionDetailWidget> createState() =>
      _TransactionDetailWidgetState();
}

class _TransactionDetailWidgetState extends State<TransactionDetailWidget> {
  final _orderHisotyProvider = StateNotifierProvider.autoDispose<
      OrderHistoryProvider,
      AsyncValue<List<Data>>>((_) => OrderHistoryProvider());

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getOrderPaymentList();
  }

  Future _getOrderPaymentList() async {
    return context
        .read(_orderHisotyProvider.notifier)
        .getOrderPaymentHistory(widget.transaction!.id!);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: const FDAppBar(
        titleText: "Settle cash in hand",
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    final dateTimeFormatter = DateFormatter();
    // final String paymentStatus = transaction?.razorPayInfo?.status ?? "";
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Divider(
          color: dividerSetInCash.withOpacity(0.4),
        ),
        ListTile(
          leading: Text(
            widget.transaction?.razorPayInfo != null
                ? "Paid Via UPI"
                : "Paid Via COD",
            style: commonTextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: settleCashListTitle,
            ),
          ),
          trailing: Text(
            dateTimeFormatter.dateStringToDateTimeWithAmPm(
                widget.transaction?.createdAt ?? ''),
            /*dateTimeFormatter
                      .parseDateToDMY(widget.transaction.createdAt),*/
            style: commonTextStyle(
              color: settleCashListSubTitle,
              fontSize: 12,
            ),
          ),
        ),
        Divider(
          color: dividerSetInCash.withOpacity(0.4),
        ),
        Expanded(
          child: Consumer(builder: (_, watch, __) {
            return watch(_orderHisotyProvider).when(
              data: (List<Data> dataList) {
                return ListView.separated(
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      return ListTile(
                        leading: Text(
                          "Order ID : ${dataList[index].orderNumber}",
                          style: commonTextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: settleCashListTitle,
                          ),
                        ),
                        trailing: Text(
                          "₹  ${dataList[index].collectedAmount}",
                          style: commonTextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: settleCashListTitle,
                          ),
                        ),
                      );
                    },
                    separatorBuilder: (context, index) {
                      return Divider(
                        color: dividerSetInCash.withOpacity(0.4),
                      );
                    },
                    itemCount: dataList.length);
              },
              loading: () => const FDCircularLoader(
                progressColor: Colors.white,
              ),
              error: (e, _) => FDErrorWidget(
                onPressed: _getOrderPaymentList,
                errorType: e,
                textColor: Colors.white,
              ),
            );
          }),
        )
      ],
    );
  }
}
