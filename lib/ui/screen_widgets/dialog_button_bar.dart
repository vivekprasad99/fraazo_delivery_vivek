import 'package:flutter/material.dart';
import 'package:fraazo_delivery/helpers/route/route_helper.dart';
import 'package:fraazo_delivery/ui/global_widgets/primary_button.dart';
import 'package:fraazo_delivery/ui/utils/widgets_and_attributes.dart';

class DialogButtonBar extends StatelessWidget {
  final VoidCallback onConfirmTap;
  final String? confirmText;
  final String? cancelText;
  final VoidCallback? onCancelTap;
  const DialogButtonBar({
    Key? key,
    required this.onConfirmTap,
    this.confirmText = "Submit",
    this.cancelText = "Cancel",
    this.onCancelTap,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          TextButton(
            onPressed: onCancelTap ?? RouteHelper.pop,
            child: Text(
              cancelText!,
              style: const TextStyle(color: Colors.grey),
            ),
          ),
          sizedBoxW5,
          PrimaryButton(
            onPressed: onConfirmTap,
            text: confirmText!,
            width: 100,
            height: 35,
            fontSize: 14,
          ),
        ],
      ),
    );
  }
}
