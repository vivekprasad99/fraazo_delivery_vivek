import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fraazo_delivery/helpers/route/route_helper.dart';
import 'package:fraazo_delivery/models/delivery/generate_qr_model.dart';
import 'package:fraazo_delivery/providers/delivery/latest_task_provider.dart';
import 'package:fraazo_delivery/providers/delivery/task_update_provider.dart';
import 'package:fraazo_delivery/ui/screens/delivery/steps/local_widgets/dialogs/pod_qr_code_dialog.dart';
import 'package:fraazo_delivery/ui/utils/toast.dart';
import 'package:google_fonts/google_fonts.dart';

TextStyle commonTextStyle({
  Color color = Colors.black,
  double fontSize = 12,
  TextDecoration decoration = TextDecoration.none,
  double? lineHeight,
  FontWeight fontWeight = FontWeight.w500,
}) {
  return GoogleFonts.quicksand(
    textStyle: TextStyle(
      color: color,
      height: lineHeight,
      fontWeight: fontWeight,
      fontSize: fontSize,
      letterSpacing: 0.4,
      decoration: decoration,
    ),
  );
}

TextStyle commonHindStyle({
  Color color = Colors.white,
  double fontSize = 12,
  TextDecoration decoration = TextDecoration.none,
  FontStyle fontStyle = FontStyle.normal,
  FontWeight fontWeight = FontWeight.w500,
}) {
  return GoogleFonts.hind(
    textStyle: TextStyle(
      color: color,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      fontSize: fontSize,
      letterSpacing: 0.4,
      decoration: decoration,
    ),
  );
}

TextStyle commonPoppinsStyle({
  Color color = Colors.white,
  double fontSize = 12,
  TextDecoration decoration = TextDecoration.none,
  FontStyle fontStyle = FontStyle.normal,
  FontWeight fontWeight = FontWeight.w500,
}) {
  return GoogleFonts.poppins(
    textStyle: TextStyle(
      color: color,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      fontSize: fontSize,
      letterSpacing: 0.4,
      decoration: decoration,
    ),
  );
}

void generateQr({
  required String orderNumber,
  required num amount,
  required Function() onGenerateTap,
}) {
  final context = RouteHelper.navigatorContext;
  Toast.popupLoadingFuture<GenerateQRModel>(
    future: () =>
        context.read(taskUpdateProvider.notifier).generateQRCodeForCOD(
              orderNumber: orderNumber,
              taskID: context.read(latestTaskProvider.notifier).currentTask?.id,
              amount: amount,
            ),
    onSuccess: (GenerateQRModel generateQRModel) async {
      if (generateQRModel.success) {
        if (generateQRModel.data != null) {
          await RouteHelper.openDialog(
            PodQrCodeDialog(generateQRModel.data?.imageUrl ?? "",
                upiAmount: generateQRModel.amount,
                onPaymentSuccess: onGenerateTap,
                orderNo: orderNumber,
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
          displayDialog(context, generateQRModel.message!);
          // Toast.info(generateQRModel.message!);
        }
      } else {
        Toast.info("Failed to generate QR. Please collect cash.");
      }
    },
  );
}

Future displayDialog(BuildContext context, String msg) async {
  return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('QR Expire'),
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
