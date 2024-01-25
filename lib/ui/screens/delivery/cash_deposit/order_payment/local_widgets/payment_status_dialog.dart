import 'package:flutter/material.dart';
import 'package:fraazo_delivery/helpers/route/route_helper.dart';
import 'package:fraazo_delivery/ui/global_widgets/new_primary_button.dart';
import 'package:fraazo_delivery/ui/utils/app_colors.dart';
import 'package:fraazo_delivery/ui/utils/widgets_and_attributes.dart';
import 'package:fraazo_delivery/utils/utils.dart';
import 'package:fraazo_delivery/values/custom_colors.dart';

class PaymentStatusDialog extends StatelessWidget {
  final bool isSuccess;
  const PaymentStatusDialog({Key? key, this.isSuccess = true})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: isSuccess ? Colors.green : Colors.red,
              child: Icon(
                isSuccess ? Icons.check : Icons.close,
                size: 50,
                color: Colors.white,
              ),
            ),
            sizedBoxH15,
            Text(
              isSuccess ? "Payment Success" : "Payment Failure",
              style: commonTextStyle(
                color: isSuccess ? AppColors.primary : Colors.red,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            sizedBoxH30,
            NewPrimaryButton(
              onPressed: () => RouteHelper.pop(),
              buttonTitle: "OK",
              activeColor: btnLightGreen,
              inactiveColor: buttonInActiveColor,
              buttonRadius: 10,
            ),
          ],
        ),
      ),
    );
  }
}
