import 'package:flutter/material.dart';
import 'package:fraazo_delivery/models/cash_deposit/transaction_model.dart';
import 'package:fraazo_delivery/ui/global_widgets/new_app_bar.dart';
import 'package:fraazo_delivery/ui/screens/delivery/cash_deposit/local_widgets/latest_transaction_widget.dart';
import 'package:fraazo_delivery/ui/screens/delivery/cash_deposit/transaction/history/local_widgets/cod_history_widget.dart';
import 'package:fraazo_delivery/ui/utils/widgets_and_attributes.dart';
import 'package:fraazo_delivery/utils/utils.dart';
import 'package:fraazo_delivery/values/custom_colors.dart';

class TransactionHistoryWidget extends StatefulWidget {
  final List<Transaction> paymentHistoryList;
  const TransactionHistoryWidget({Key? key, required this.paymentHistoryList})
      : super(key: key);

  @override
  State<TransactionHistoryWidget> createState() =>
      _TransactionHistoryWidgetState();
}

class _TransactionHistoryWidgetState extends State<TransactionHistoryWidget> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: const NewAppBar(
        title: "Transaction History",
      ),
      body: _buildTabs(),
    );
  }

  Widget _buildTabs() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: DefaultTabController(
          length: 2,
          child: Column(
            children: [
              Container(
                height: 42,
                padding: const EdgeInsets.all(4.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(6),
                  boxShadow: const [
                    BoxShadow(blurRadius: 3, color: Colors.grey)
                  ],
                ),
                child: TabBar(
                  indicatorSize: TabBarIndicatorSize.tab,
                  indicator: BoxDecoration(
                      color: bgColor, borderRadius: BorderRadius.circular(6)),
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.black,
                  labelStyle: commonTextStyle(fontWeight: FontWeight.w600),
                  unselectedLabelStyle: commonTextStyle(),
                  tabs: const [
                    Tab(
                        child: Text(
                      "UPI",
                    )),
                    Tab(
                        child: Text(
                      "Cash on Delivery",
                    )),
                  ],
                ),
              ),
              sizedBoxH5,
              const Expanded(
                child: TabBarView(
                  children: [
                    UPIHistoryWidget(),
                    CODHistoryWidget(),
                  ],
                ),
              )
            ],
          )),
    );
  }
}
