import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fraazo_delivery/helpers/route/route_helper.dart';
import 'package:fraazo_delivery/helpers/route/routes.dart';
import 'package:fraazo_delivery/models/cash_deposit/transaction_model.dart';
import 'package:fraazo_delivery/providers/cash_deposit/payment_history_provider.dart';
import 'package:fraazo_delivery/ui/global_widgets/fd_circular_loader.dart';
import 'package:fraazo_delivery/ui/global_widgets/fd_error_widget.dart';
import 'package:fraazo_delivery/ui/screen_widgets/no_data_widget.dart';
import 'package:fraazo_delivery/ui/screens/delivery/cash_deposit/local_widgets/transaction_item_widget.dart';
import 'package:fraazo_delivery/utils/utils.dart';
import 'package:fraazo_delivery/values/custom_colors.dart';

class UPIHistoryWidget extends StatefulWidget {
  final bool isAllTransaction;

  const UPIHistoryWidget({Key? key, this.isAllTransaction = true})
      : super(key: key);

  @override
  _UPIHistoryWidgetState createState() => _UPIHistoryWidgetState();
}

class _UPIHistoryWidgetState extends State<UPIHistoryWidget> {
  @override
  void initState() {
    super.initState();
    _getTransactionHistory();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (_, watch, __) {
        return watch(paymentHistoryProvider).when(
          data: (List<Transaction> paymentHistoryList) =>
              _buildTransactionList(paymentHistoryList),
          loading: () => const FDCircularLoader(progressColor: Colors.white),
          error: (e, _) => FDErrorWidget(
            onPressed: _getTransactionHistory,
            errorType: e,
            textColor: Colors.white,
          ),
        );
      },
    );
  }

  Widget _buildTransactionList(List<Transaction> paymentHistoryList) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!widget.isAllTransaction)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Recent Transactions",
                  style: commonTextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (paymentHistoryList.isNotEmpty) ...[
                  InkWell(
                    onTap: () => RouteHelper.push(Routes.TRANSACTION_HISTORY,
                        args: paymentHistoryList),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        "View All",
                        style: commonTextStyle(
                          color: greyViewAll,
                          fontSize: 11,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ),
                ]
              ],
            ),
          ),
        if (paymentHistoryList.isEmpty)
          const Expanded(child: NoDataWidget())
        else
          Expanded(
            child: Column(
              children: [
                Divider(
                  color: dividerSetInCash.withOpacity(0.4),
                ),
                Expanded(
                  child: ListView.builder(
                    //padding: padding5,

                    itemCount: widget.isAllTransaction
                        ? paymentHistoryList.length
                        : min(10, paymentHistoryList.length),
                    shrinkWrap: true,
                    itemBuilder: (_, int index) {
                      return Padding(
                        padding: EdgeInsets.zero,
                        child: TransactionItemWidget(paymentHistoryList[index]),
                      );
                    },
                  ),
                ),
              ],
            ),
          )
      ],
    );
  }

  Future _getTransactionHistory() {
    return context.read(paymentHistoryProvider.notifier).getPaymentHistory();
  }
}
