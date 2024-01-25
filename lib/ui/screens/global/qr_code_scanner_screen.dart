import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fraazo_delivery/helpers/extensions/string_extension.dart';
import 'package:fraazo_delivery/helpers/route/route_helper.dart';
import 'package:fraazo_delivery/helpers/route/routes.dart';
import 'package:fraazo_delivery/models/delivery/task_model.dart';
import 'package:fraazo_delivery/providers/delivery/latest_task_provider.dart';
import 'package:fraazo_delivery/ui/global_widgets/new_primary_button.dart';
import 'package:fraazo_delivery/ui/utils/textview.dart';
import 'package:fraazo_delivery/ui/utils/toast.dart';
import 'package:fraazo_delivery/ui/utils/widgets_and_attributes.dart';
import 'package:fraazo_delivery/utils/constants.dart';
import 'package:fraazo_delivery/utils/utils.dart';
import 'package:fraazo_delivery/values/custom_colors.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class QrCodeScannerScreen extends StatefulWidget {
  final Map<String, dynamic>? arguments;

  const QrCodeScannerScreen({Key? key, this.arguments}) : super(key: key);

  @override
  _QrCodeScannerScreenState createState() => _QrCodeScannerScreenState();
}

class _QrCodeScannerScreenState extends State<QrCodeScannerScreen> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? _qrController;

  bool _isResultPassed = false;

  late Task _task;

  late OrderSeq _orderSeq;

  bool _isPickedOrder = false;

  final _textController = TextEditingController();

  String? scanCode;

  late final List<OrderSeq>? _orderSeqList;

  @override
  void initState() {
    super.initState();

    _task = widget.arguments?['task'] as Task;

    if (widget.arguments?.containsKey('order') ?? false) {
      _orderSeq = widget.arguments?['order'] as OrderSeq;
    }
    _isPickedOrder = widget.arguments?.containsKey('isPicked') ?? false;
    /*if (kDebugMode) {
      Future.delayed(
        const Duration(seconds: 5),
        () => RouteHelper.pop(args: ''),
      );
    }*/

    if (!_isPickedOrder) {
      _orderSeqList = context.read(latestTaskProvider.notifier).getOrderSeq();
    }
  }

  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      _qrController!.pauseCamera();
    } else if (Platform.isIOS) {
      _qrController!.resumeCamera();
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        RouteHelper.removeUntil(Routes.HOME);
        context.read(latestTaskProvider.notifier).getLatestTask();
        return Future.value(true);
      },
      child: Scaffold(
        //appBar: const FDAppBar(titleText: "Scan QR Code"),
        body: Stack(
          alignment: Alignment.center,
          children: [
            QRView(
              key: qrKey,
              onQRViewCreated: _onQRViewCreated,
              overlay: QrScannerOverlayShape(
                borderRadius: 10,
                borderColor: Colors.white,
                cutOutSize: MediaQuery.of(context).size.width * 0.55, //0.72
              ),
              overlayMargin: EdgeInsets.only(
                bottom: MediaQuery.of(context).size.height * 0.0010, //0.15
              ),
            ),
            Positioned(
              top: 30,
              right: 0,
              left: 0,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (!_isPickedOrder) ...[
                    FutureBuilder<String>(
                      future: _getCounts(),
                      builder: (_, AsyncSnapshot<String?> snapshot) {
                        if (snapshot.hasData) {
                          return TextView(
                            title: "Scan QR  ${snapshot.data}",
                            alignment: Alignment.center,
                            textStyle: commonPoppinsStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 14,
                            ),
                          );
                        } else {
                          return const Center(
                            child: CircularProgressIndicator(
                              color: Colors.white,
                            ),
                          );
                        }
                      },
                    )
                  ] else ...[
                    TextView(
                      title: "Scan QR before Delivery",
                      alignment: Alignment.center,
                      textStyle: commonPoppinsStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                      ),
                    )
                  ],
                  sizedBoxH20,
                  ClipRRect(
                    borderRadius: BorderRadius.circular(25),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 15,
                        vertical: 15,
                      ),
                      color: borderLineColor.withOpacity(0.9),
                      child: SvgPicture.asset(
                        'ic_scan'.svgImageAsset,
                        height: 19,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  if (_isPickedOrder)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: TextView(
                        title:
                            "Scan QR Code of Order ID : ${_orderSeq.orderNumber}",
                        alignment: Alignment.center,
                        textStyle: commonTextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: Colors.white,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            //if (_isPickedOrder)
            Positioned(bottom: 0, right: 0, left: 0, child: _buildButtonView()),

            /*Positioned(
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
            )*/
          ],
        ),
      ),
    );
  }

  Widget _buildButtonView() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextView(
          title: "OR",
          alignment: Alignment.center,
          textStyle: commonTextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: Colors.white,
          ),
        ),
        sizedBoxH20,
        Container(
          padding:
              const EdgeInsets.only(top: 12, bottom: 16, left: 16, right: 16),
          width: MediaQuery.of(context).size.width,
          decoration: const BoxDecoration(
            color: cardLightBlack,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(12.0),
              topRight: Radius.circular(12.0),
            ),
          ),
          child: Column(
            children: [
              TextView(
                title: "Enter Invoice Number",
                alignment: Alignment.center,
                textStyle: commonTextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              sizedBoxH12,
              TextField(
                cursorColor: Colors.white,
                controller: _textController,
                cursorWidth: 1,
                onChanged: (text) {
                  setState(
                    () => _textController.value = TextEditingValue(
                      text: text,
                      selection: TextSelection(
                        baseOffset: text.length,
                        extentOffset: text.length,
                      ),
                    ),
                  );
                },
                style: commonTextStyle(color: Colors.white),
                scrollPadding: const EdgeInsets.only(bottom: 180),
                decoration: InputDecoration(
                  prefixText: 'FRZ-',
                  prefixStyle: commonTextStyle(color: Colors.white),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  focusedBorder: const OutlineInputBorder(
                      borderSide: BorderSide(
                    color: borderLineColor,
                  )),
                  enabledBorder: const OutlineInputBorder(
                    borderSide: BorderSide(
                      color: borderLineColor,
                    ),
                  ),
                  border: const OutlineInputBorder(
                    borderSide: BorderSide(
                      color: borderLineColor,
                    ),
                  ),
                  counterText: "",
                  alignLabelWithHint: true,
                ),
              ),
              sizedBoxH15,
              NewPrimaryButton(
                activeColor: buttonColor,
                inactiveColor: subText,
                buttonRadius: px_8,
                buttonWidth: MediaQuery.of(context).size.width * 0.2,
                buttonTitle: 'Proceed',
                isActive: _textController.text.trim().isNotEmpty,
                onPressed: () {
                  final _textValue = 'FRZ-${_textController.text.trim()}';

                  if (!_isPickedOrder) {
                    final _orderSeq = _orderSeqList
                        ?.where(
                          (orderSeq) => orderSeq.invoiceNumber == _textValue,
                        )
                        .toList();

                    if (_orderSeq != null && _orderSeq.isNotEmpty) {
                      if (_orderSeq.single.orderStatus !=
                          Constants.TS_PICKUP_STARTED) {
                        RouteHelper.pop(args: _orderSeq.single);
                      } else {
                        Toast.error("Order Already PickUp");
                      }
                    } else {
                      _elseBlock();
                    }
                  } else if (_textValue.isNotEmpty &&
                      _orderSeq.invoiceNumber == _textValue) {
                    RouteHelper.pop(args: _orderSeq.orderNumber /*''*/);
                  } else {
                    _elseBlock();
                  }
                },
                fontSize: 17,
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _elseBlock() => setState(() {
        Toast.error('Invalid Order!');
        _isResultPassed = false;
        _qrController!.pauseCamera();
        _qrController!.resumeCamera();
      });

  Future<String> _getCounts() {
    final _osCreated = _task.orderSeq
        ?.where((element) => element.orderStatus == Constants.TS_PICKUP_STARTED)
        .toList();

    return Future.value(
      '${(_osCreated?.length ?? 0) + 1}/${_task.orderSeq?.length}',
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    _qrController = controller;
    _qrController?.scannedDataStream.listen((scanData) {
      if (!_isResultPassed) {
        _isResultPassed = true;

        if (scanData.code != null && (scanData.code ?? '').isNotEmpty) {
          final int scannedCode = int.parse(scanData.code ?? '0') - 3000;
          scanCode = scannedCode.toString();
          //Format: 761273 + 3000;
          if (!_isPickedOrder) {
            final _orderSeq = _orderSeqList
                ?.where((orderSeq) => orderSeq.orderNumber == scanCode)
                .toList();
            if (_orderSeq != null && _orderSeq.isNotEmpty) {
              if (_orderSeq.single.orderStatus != Constants.TS_PICKUP_STARTED) {
                RouteHelper.pop(args: _orderSeq.single);
              } else {
                Toast.error("Order Already PickUp");
              }
            } else {
              _elseBlock();
            }
          } else if (_orderSeq.orderNumber == scannedCode.toString()) {
            RouteHelper.pop(args: scanData.code);
          } else {
            _elseBlock();
          }
        }
      }
    });
  }

  @override
  void dispose() {
    _qrController?.dispose();
    _textController.dispose();
    super.dispose();
  }
}
