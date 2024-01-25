import 'package:flutter/material.dart';
import 'package:fraazo_delivery/helpers/date/date_formatter.dart';
import 'package:fraazo_delivery/models/cash_deposit/cod_history_model.dart';
import 'package:fraazo_delivery/ui/global_widgets/fd_app_bar.dart';
import 'package:fraazo_delivery/ui/global_widgets/flex_separated.dart';
import 'package:fraazo_delivery/ui/utils/widgets_and_attributes.dart';

class CODTransactionDetailScreen extends StatefulWidget {
  final CodHistory codHistoryData;
  const CODTransactionDetailScreen({Key? key, required this.codHistoryData})
      : super(key: key);

  @override
  _CODTransactionDetailScreenState createState() =>
      _CODTransactionDetailScreenState();
}

class _CODTransactionDetailScreenState
    extends State<CODTransactionDetailScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const FDAppBar(
        titleText: "Transaction Details",
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    final dateTimeFormatter = DateFormatter();
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 60),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FlexSeparated(
            direction: Axis.vertical,
            children: [
              _buildTransactionDetailsRow(
                "Date:",
                dateTimeFormatter
                    .parseDateToDMY(widget.codHistoryData.createdAt),
              ),
              _buildTransactionDetailsRow(
                "Amount:",
                "₹${widget.codHistoryData.amountCollected}",
              ),
              _buildTransactionDetailsRow(
                "Status:",
                widget.codHistoryData.status == "SETTLED"
                    ? 'Successful (Paid)'
                    : 'Failure',
              ),
              _buildTransactionDetailsRow(
                "Orders:",
                "#${widget.codHistoryData.orderNumbers?.join(",  #")}",
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildTransactionDetailsRow(String label, String? value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.black54,
            fontWeight: FontWeight.w500,
            fontSize: 16,
          ),
        ),
        sizedBoxW10,
        Expanded(
          child: Text(
            value!,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
          ),
        ),
      ],
    );
  }
}
