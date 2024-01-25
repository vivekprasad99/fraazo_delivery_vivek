import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fraazo_delivery/helpers/extensions/string_extension.dart';
import 'package:fraazo_delivery/helpers/route/route_helper.dart';
import 'package:fraazo_delivery/models/delivery/generate_qr_model.dart';
import 'package:fraazo_delivery/models/delivery/task_model.dart';
import 'package:fraazo_delivery/providers/delivery/latest_task_provider.dart';
import 'package:fraazo_delivery/providers/delivery/task_update_provider.dart';
import 'package:fraazo_delivery/ui/global_widgets/primary_button.dart';
import 'package:fraazo_delivery/ui/utils/toast.dart';
import 'package:fraazo_delivery/ui/utils/widgets_and_attributes.dart';
import 'package:fraazo_delivery/utils/utils.dart';

import 'dialogs/pod_qr_code_dialog.dart';

class CashOrQrCodeWidget extends StatelessWidget {
  final OrderSeq? order;
  final VoidCallback? onGenerateTap;
  final bool shouldShowQRIcon;
  final bool Function()? isValidToGenerate;
  final num? amount;

  const CashOrQrCodeWidget(
    this.order, {
    Key? key,
    this.onGenerateTap,
    this.shouldShowQRIcon = false,
    this.isValidToGenerate,
    this.amount,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (shouldShowQRIcon) {
      return InkWell(
          onTap: () =>
              // order!.orderStatus == Constants.OS_DELIVERY_STARTED
              //     ? null
              //     :
              _openQRCodeDialog(context),
          child: Row(
            children: [
              Container(
                decoration: BoxDecoration(border: Border.all()),
                child: SvgPicture.asset(
                  'new_qr_code'.svgImageAsset,
                  height: 24,
                  fit: BoxFit.cover,
                ),
              ),
              sizedBoxW10,
              Text(
                "Generate QR",
                style: commonTextStyle(
                  fontSize: 14,
                ),
              ),
            ],
          ));
    } else {
      return PrimaryButton(
        onPressed: () => _openQRCodeDialog(context),
        text: "Generate UPI QR",
        fontSize: 17,
      );
    }
  }

  void _openQRCodeDialog(BuildContext context) {
    if (isValidToGenerate == null || isValidToGenerate!()) {
      Toast.popupLoadingFuture<GenerateQRModel>(
        future: () => context
            .read(taskUpdateProvider.notifier)
            .generateQRCodeForCOD(
              orderNumber: order?.orderNumber,
              taskID: context.read(latestTaskProvider.notifier).currentTask?.id,
              amount: amount ?? order?.amount,
            ),
        onSuccess: (GenerateQRModel generateQRModel) async {
          if (generateQRModel.success) {
            if (generateQRModel.data != null) {
              dynamic value = await RouteHelper.openDialog(
                PodQrCodeDialog(generateQRModel.data?.imageUrl ?? "",
                    upiAmount: generateQRModel.amount,
                    onPaymentSuccess: onGenerateTap,
                    orderNo: order?.orderNumber,
                    qrExpiryTime: 0
                    // DateFormatter()
                    //     .parseDateTimeToSecond(generateQRModel.qrExpiry!),
                    ),
                barrierDismissible: false,
              );
              // if (value != null) {
              //   _displayDialog(context,
              //       'Your request for payment via QR has been expired. Kindly collect cash from the customer');
              // }
            } else {
              _displayDialog(context, generateQRModel.message!);
              // Toast.info(generateQRModel.message!);
            }
          } else {
            Toast.info("Failed to generate QR. Please collect cash.");
          }
        },
      );
    }
  }

  _displayDialog(BuildContext context, String msg) async {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('QR Expire'),
            content: Text(msg),
            actions: <Widget>[
              ElevatedButton(
                child: const Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              )
            ],
          );
        });
  }
}
