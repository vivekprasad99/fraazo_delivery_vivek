import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fraazo_delivery/helpers/enums/partial_amount_type.dart';
import 'package:fraazo_delivery/helpers/error/error_reporter.dart';
import 'package:fraazo_delivery/helpers/extensions/num_extension.dart';
import 'package:fraazo_delivery/helpers/route/route_helper.dart';
import 'package:fraazo_delivery/models/delivery/delivery_items_model.dart';
import 'package:fraazo_delivery/providers/delivery/order/order_items_provider.dart';
import 'package:fraazo_delivery/providers/delivery/order/order_update_provider.dart';
import 'package:fraazo_delivery/ui/global_widgets/fd_app_bar.dart';
import 'package:fraazo_delivery/ui/global_widgets/fd_circular_loader.dart';
import 'package:fraazo_delivery/ui/global_widgets/fd_error_widget.dart';
import 'package:fraazo_delivery/ui/global_widgets/fd_textfield.dart';
import 'package:fraazo_delivery/ui/global_widgets/flex_separated.dart';
import 'package:fraazo_delivery/ui/global_widgets/primary_button.dart';
import 'package:fraazo_delivery/ui/screen_widgets/dialogs/document_picker_dialog.dart';
import 'package:fraazo_delivery/ui/screen_widgets/horizontal_product_card.dart';
import 'package:fraazo_delivery/ui/screens/delivery/steps/local_widgets/cash_or_qr_code_widget.dart';
import 'package:fraazo_delivery/ui/utils/app_colors.dart';
import 'package:fraazo_delivery/ui/utils/toast.dart';
import 'package:fraazo_delivery/ui/utils/widgets_and_attributes.dart';
import 'package:fraazo_delivery/utils/globals.dart';

class PartialAmountReasonScreen extends StatefulWidget {
  final PartialAmountType partialAmountType;
  const PartialAmountReasonScreen({Key? key, required this.partialAmountType})
      : super(key: key);

  @override
  _PartialAmountReasonScreenState createState() =>
      _PartialAmountReasonScreenState();
}

class _PartialAmountReasonScreenState extends State<PartialAmountReasonScreen> {
  final _orderItemsProvider = StateNotifierProvider.autoDispose<
      OrderItemsProvider, AsyncValue<OrderItems>>((_) => OrderItemsProvider());

  late final _collectedAmountProvider =
      StateProvider.autoDispose<String>((ref) => _actualOrderAmount.toString());
  late final List<String> _imagePathList = [];

  late final num _actualOrderAmount =
      context.read(orderUpdateProvider.notifier).currentOrder.amount ?? 0;
  late num _newCalculatedTotalAmount = _actualOrderAmount;
  late String _calculatedAmount = _actualOrderAmount.toString();

  late final _collectedAmountTEC =
      TextEditingController(text: _actualOrderAmount.toString());
  late final _otherReasonTEC = TextEditingController();

  late final bool _shouldShowMissing =
      widget.partialAmountType == PartialAmountType.MISSING ||
          widget.partialAmountType == PartialAmountType.BOTH;

  late final bool _shouldShowQuality =
      widget.partialAmountType == PartialAmountType.QUALITY ||
          widget.partialAmountType == PartialAmountType.BOTH;

  late final bool _isOtherCollectionType =
      widget.partialAmountType == PartialAmountType.OTHER;

  late OrderItems _orderItemList;

  bool _areIssueDetailsSubmitted = false;

  @override
  void initState() {
    super.initState();
    _getOrderItems();
    _collectedAmountTEC.addListener(() {
      context.read(_collectedAmountProvider).state =
          getPositiveValueToShow(_collectedAmountTEC.text);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const FDAppBar(titleText: "Partial Amount Collection"),
      body: _buildBody(),
      bottomNavigationBar: _buildSubmitButton(),
    );
  }

  Widget _buildBody() {
    return Consumer(
      builder: (_, watch, __) {
        return watch(_orderItemsProvider).when(
          data: (OrderItems orderItemList) {
            _orderItemList = orderItemList;
            return _buildSkuSelection();
          },
          loading: () => const FDCircularLoader(),
          error: (e, __) => FDErrorWidget(
            onPressed: _getOrderItems,
            errorType: e,
            shouldHideErrorToast: false,
          ),
        );
      },
    );
  }

  Widget _buildSkuSelection() {
    return SingleChildScrollView(
      padding: padding15.copyWith(bottom: 60),
      child: FlexSeparated(
        crossAxisAlignment: CrossAxisAlignment.start,
        direction: Axis.vertical,
        spacing: 15,
        children: [
          Text(
            _getReasonTypeHeaderText(),
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.5,
            ),
          ),
          if (widget.partialAmountType != PartialAmountType.OTHER)
            _buildTable(_orderItemList.lineItems),
          if (_shouldShowQuality) ...[
            const Text("Add photos which has quality issue."),
            _buildImageSelectedList(),
          ],
          _buildAmountTextBox(true),
          if (_isOtherCollectionType)
            Row(
              children: [
                _buildAmountTextBox(false),
                sizedBoxW20,
                _buildCollectedAmountField(),
              ],
            ),
          FDTextField(
            controller: _otherReasonTEC,
            height: null,
            maxLines: 4,
            labelText: _isOtherCollectionType
                ? "Please mention other reason*"
                : "Feedback",
            textCapitalization: TextCapitalization.characters,
          ),
        ],
      ),
    );
  }

  Widget _buildTable(List<LineItem> lineItemList) {
    return Table(
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      border: TableBorder.all(
        color: Colors.black54,
        borderRadius: const BorderRadius.all(Radius.circular(4)),
      ),
      columnWidths: const {
        // 0: FractionColumnWidth(0.64),
        1: FractionColumnWidth(0.18),
        2: FractionColumnWidth(0.18),
      },
      children: [
        TableRow(
          children: [
            _buildTableHeader("Items"),
            if (_shouldShowMissing) _buildTableHeader("Missing"),
            if (_shouldShowQuality) _buildTableHeader("Quality"),
          ],
        ),
        ...List.generate(
          lineItemList.length,
          (int index) => _buildSelectionItem(
            lineItemList[index],
          ),
        ),
      ],
    );
  }

  Widget _buildTableHeader(String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  TableRow _buildSelectionItem(LineItem lineItem) {
    return TableRow(
      children: [
        HorizontalProductCard(
          lineItem,
          shouldShowAmount: true,
        ),
        if (_shouldShowMissing)
          Checkbox(
            onChanged: (bool? value) {
              lineItem.isMissing = value ?? false;
              _onCheckBoxTap(lineItem, value!);
            },
            value: lineItem.isMissing,
          ),
        if (_shouldShowQuality)
          Checkbox(
            onChanged: (bool? value) {
              lineItem.hasQualityIssue = value ?? false;
              _onCheckBoxTap(lineItem, value!);
            },
            value: lineItem.hasQualityIssue,
          ),
      ],
    );
  }

  Widget _buildImageSelectedList() {
    return Wrap(
      children: [
        ...List.generate(
          _imagePathList.length,
          (int index) => _buildImageTile(index),
        ),
        _buildImageTile(-1),
      ],
    );
  }

  Widget _buildImageTile(int index) {
    return InkWell(
      onTap: () => _onImageTileTap(index),
      child: Container(
        width: 90,
        height: 90,
        margin: const EdgeInsets.all(2),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
            color: Colors.black38,
          ),
        ),
        child: index >= 0
            ? Image.file(
                File(
                  _imagePathList[index],
                ),
              )
            : const Icon(
                Icons.add_a_photo,
                size: 35,
                color: Colors.grey,
              ),
      ),
    );
  }

  Widget _buildAmountTextBox(bool isActualAmount) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.15),
        borderRadius: const BorderRadius.all(Radius.circular(4)),
        border: Border.all(color: AppColors.primary),
      ),
      child: Text(
        isActualAmount
            ? "Amount to be collected: ₹${getPositiveValueToShow(_newCalculatedTotalAmount.toString())}"
            : "New Amount To Collect: ₹",
        style: TextStyle(
          color: isActualAmount ? AppColors.primary : AppColors.secondary,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildCollectedAmountField() {
    return FDTextField(
      height: 38,
      width: 80,
      controller: _collectedAmountTEC,
      isNumber: true,
    );
  }

  Widget _buildSubmitButton() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        boxShadow: const [
          BoxShadow(
            spreadRadius: 2,
            blurRadius: 4,
            offset: Offset(1, 0),
            color: Colors.grey,
          ),
        ],
      ),
      child: Consumer(
        builder: (_, watch, __) {
          final String collectedAmount = watch(_collectedAmountProvider).state;
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text(
                    "Amount to be collected :  ",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Consumer(
                    builder: (_, watch, __) => Text(
                      "₹$collectedAmount",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
              sizedBoxH10,
              FlexSeparated(
                children: [
                  if (Globals.user!.qrEnable && collectedAmount != "0")
                    Expanded(
                      child: CashOrQrCodeWidget(
                        context.read(orderUpdateProvider.notifier).currentOrder,
                        isValidToGenerate: _isValidToSubmit,
                        onGenerateTap: () =>
                            _onSubmitButtonTap(shouldShowQRDialog: true),
                        amount: _newCalculatedTotalAmount,
                      ),
                    ),
                  Expanded(
                    child: PrimaryButton(
                      text: collectedAmount == "0" ? "Submit" : "Collect Cash",
                      onPressed: _onSubmitButtonTap,
                      color: AppColors.secondary,
                    ),
                  )
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  String _getReasonTypeHeaderText() {
    switch (widget.partialAmountType) {
      case PartialAmountType.MISSING:
        return "Please select missing items";
      case PartialAmountType.QUALITY:
        return "Please select quality issue items ";
      case PartialAmountType.BOTH:
        return "Please select missing and quality issue items";
      case PartialAmountType.OTHER:
        return "Please enter collected amount and mention other reason";
    }
  }

  void _onImageTileTap(int index) {
    showDialog(
      context: context,
      builder: (_) => DocumentPickerDialog(
        onImagePicked: (String path) {
          setState(() {
            if (index >= 0) {
              _imagePathList[index] = path;
            } else {
              _imagePathList.add(path);
            }
          });
        },
        shouldDirectlyOpenCamera: true,
      ),
    );
  }

  // Below things can be improved, currently I have no time for it.
  void _onCheckBoxTap(LineItem lineItem, bool value) {
    if (widget.partialAmountType == PartialAmountType.MISSING) {
      if (lineItem.isMissing) {
        _newCalculatedTotalAmount -= lineItem.nettAmount!;
      } else {
        _newCalculatedTotalAmount += lineItem.nettAmount!;
      }
    } else if (widget.partialAmountType == PartialAmountType.QUALITY) {
      if (lineItem.hasQualityIssue) {
        _newCalculatedTotalAmount -= lineItem.nettAmount!;
      } else {
        _newCalculatedTotalAmount += lineItem.nettAmount!;
      }
    } else if (widget.partialAmountType == PartialAmountType.BOTH) {
      if (value && lineItem.hasQualityIssue && !lineItem.isMissing) {
        _newCalculatedTotalAmount -= lineItem.nettAmount!;
      } else if (value && !lineItem.hasQualityIssue && lineItem.isMissing) {
        _newCalculatedTotalAmount -= lineItem.nettAmount!;
      } else if (!value && !lineItem.hasQualityIssue && !lineItem.isMissing) {
        _newCalculatedTotalAmount += lineItem.nettAmount!;
      }
    }
    _collectedAmountTEC.text =
        getPositiveValueToShow(_newCalculatedTotalAmount.trimTo2Digits());
    _calculatedAmount = _newCalculatedTotalAmount.trimTo2Digits();
    setState(() {});
  }

  void _getOrderItems() {
    context.read(_orderItemsProvider.notifier).getOrderLineItems(
        context.read(orderUpdateProvider.notifier).currentOrder.id!);
  }

  String getPositiveValueToShow(String value) {
    final newValue = double.tryParse(value) ?? 0;
    if (newValue <= 0) {
      return "0";
    } else {
      return newValue.trimTo2Digits();
    }
  }

  Future _onSubmitButtonTap({bool shouldShowQRDialog = false}) async {
    if (_isValidToSubmit()) {
      final popupLoading = Toast.popupLoading();
      try {
        if (!_areIssueDetailsSubmitted) {
          final orderProvider = context.read(orderUpdateProvider.notifier);
          await orderProvider.updateCollectedOrderAmount(
            collectedAmount: _isOtherCollectionType
                ? _collectedAmountTEC.text
                : _calculatedAmount,
            orderNumber: orderProvider.currentOrder.orderNumber!,
            orderItemList: _orderItemList,
            isOther: _isOtherCollectionType,
            comment: _otherReasonTEC.text,
          );
          if (_shouldShowQuality) {
            await orderProvider.uploadQualityIssueImages(
              orderProvider.currentOrder.id,
              _imagePathList,
            );
          }
        }
        popupLoading();
        _areIssueDetailsSubmitted = true;
        if (shouldShowQRDialog) {
          RouteHelper.pop(args: true);
        }
        RouteHelper.pop(args: true);
      } catch (e, st) {
        popupLoading();
        ErrorReporter.error(e, st);
      }
    }
  }

  bool _isValidToSubmit() {
    if (_actualOrderAmount <=
        (num.tryParse(_collectedAmountTEC.text) ?? _actualOrderAmount)) {
      Toast.info(
          "If collected amount is same as order amount then please use Full Amount payment option.");
      return false;
    } else if (_shouldShowQuality && _imagePathList.isEmpty) {
      Toast.info("Please add photos of quality issue items.");
      return false;
    } else if (_isOtherCollectionType && _otherReasonTEC.text.isEmpty) {
      Toast.info("Please mention other reason.");
      return false;
    }
    return true;
  }

  @override
  void dispose() {
    _collectedAmountTEC.dispose();
    _otherReasonTEC.dispose();
    super.dispose();
  }
}
