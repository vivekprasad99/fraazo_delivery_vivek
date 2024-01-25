import 'package:flutter/material.dart';
import 'package:fraazo_delivery/helpers/route/route_helper.dart';
import 'package:fraazo_delivery/ui/screen_widgets/dialog_button_bar.dart';
import 'package:intl/intl.dart';

class DeliveredToDialog extends StatefulWidget {
  @override
  _DeliveredToDialogState createState() => _DeliveredToDialogState();
}

class _DeliveredToDialogState extends State<DeliveredToDialog> {
  static const _deliveredToTypes = [
    "handed_to_customer",
    "handed_to_security",
    "left_on_society_gate"
  ];
  String? _selectedType = "handed_to_customer";

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(10, 16, 10, 5),
            child: Text(
              "Order is delivered to?",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ...List.generate(
            3,
            (index) => RadioListTile(
              value: _deliveredToTypes[index],
              groupValue: _selectedType,
              onChanged: (String? type) => setState(() {
                _selectedType = type;
              }),
              title: Text(
                toBeginningOfSentenceCase(
                    _deliveredToTypes[index].replaceAll("_", " "))!,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                DialogButtonBar(
                  onConfirmTap: () => RouteHelper.pop(args: _selectedType),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
