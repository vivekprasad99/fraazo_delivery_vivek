import 'package:flutter/material.dart';
import 'package:fraazo_delivery/helpers/route/route_helper.dart';
import 'package:fraazo_delivery/ui/global_widgets/fd_app_bar.dart';
import 'package:fraazo_delivery/ui/global_widgets/flex_separated.dart';
import 'package:fraazo_delivery/ui/utils/app_colors.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class NoOrderQrCodeScannerScreen extends StatefulWidget {
  const NoOrderQrCodeScannerScreen({Key? key}) : super(key: key);

  @override
  _NoOrderQrCodeScannerScreenState createState() => _NoOrderQrCodeScannerScreenState();
}

class _NoOrderQrCodeScannerScreenState extends State<NoOrderQrCodeScannerScreen> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? _qrController;

  bool _isResultPassed = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const FDAppBar(titleText: "Scan QR Code"),
      body: Stack(
        alignment: Alignment.center,
        children: [
          QRView(
            key: qrKey,
            onQRViewCreated: _onQRViewCreated,
            overlay: QrScannerOverlayShape(
              cutOutSize: MediaQuery.of(context).size.width * 0.72,
            ),
            overlayMargin: EdgeInsets.only(
                bottom: MediaQuery.of(context).size.height * 0.15),
          ),
          Positioned(
            bottom: 80,
            right: 0,
            left: 0,
            child: FlexSeparated(
              spacing: 45,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FutureBuilder(
                  future: _qrController?.getFlashStatus(),
                  builder: (_, AsyncSnapshot<bool?> status) =>
                      FloatingActionButton(
                        onPressed: () => setState(() {
                          _qrController?.toggleFlash();
                        }),
                        backgroundColor: AppColors.primary,
                        child: Icon(
                          (status.data ?? false) ? Icons.flash_on : Icons.flash_off,
                        ),
                      ),
                ),
                FutureBuilder(
                  future: _qrController?.getCameraInfo(),
                  builder: (_, AsyncSnapshot<CameraFacing?> cameraFacing) =>
                      FloatingActionButton(
                        onPressed: () => setState(() {
                          _qrController?.flipCamera();
                        }),
                        backgroundColor: AppColors.primary,
                        child: Icon(
                          (cameraFacing.data == CameraFacing.back)
                              ? Icons.camera_rear
                              : Icons.camera_front,
                        ),
                      ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    _qrController = controller;
    controller.scannedDataStream.listen((scanData) {
      if (!_isResultPassed) {
        _isResultPassed = true;
        RouteHelper.pop(args: scanData.code);
      }
    });
  }

  @override
  void dispose() {
    _qrController?.dispose();
    super.dispose();
  }
}