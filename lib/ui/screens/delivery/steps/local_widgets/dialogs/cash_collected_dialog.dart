import 'package:flutter/material.dart';
import 'package:fraazo_delivery/helpers/route/route_helper.dart';
import 'package:fraazo_delivery/ui/screen_widgets/dialog_button_bar.dart';

class CashCollectedDialog extends StatelessWidget {
  final num? amount;
  const CashCollectedDialog(this.amount);
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Please collect ₹$amount"),
      content: Text(
          "Have you collected the ₹$amount cash from customer for this COD order?"),
      actions: [
        DialogButtonBar(
          confirmText: "Collected",
          onConfirmTap: () => RouteHelper.pop(args: true),
          onCancelTap: () => RouteHelper.pop(args: false),
        ),
      ],
    );
  }
}
