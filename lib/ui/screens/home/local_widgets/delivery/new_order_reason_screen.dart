import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fraazo_delivery/helpers/error/error_reporter.dart';
import 'package:fraazo_delivery/helpers/extensions/num_extension.dart';
import 'package:fraazo_delivery/helpers/extensions/string_extension.dart';
import 'package:fraazo_delivery/helpers/shared_pref/pref_helper.dart';
import 'package:fraazo_delivery/helpers/shared_pref/pref_keys.dart';
import 'package:fraazo_delivery/models/delivery/delivery_items_model.dart';
import 'package:fraazo_delivery/models/delivery/task_model.dart';
import 'package:fraazo_delivery/providers/delivery/order/order_items_provider.dart';
import 'package:fraazo_delivery/providers/delivery/order/order_update_provider.dart';
import 'package:fraazo_delivery/ui/global_widgets/container_divider.dart';
import 'package:fraazo_delivery/ui/global_widgets/fd_circular_loader.dart';
import 'package:fraazo_delivery/ui/global_widgets/fd_error_widget.dart';
import 'package:fraazo_delivery/ui/global_widgets/new_app_bar.dart';
import 'package:fraazo_delivery/ui/screens/home/local_widgets/collect_cash_widget.dart';
import 'package:fraazo_delivery/ui/screens/home/local_widgets/quality_issue_attachments.dart';
import 'package:fraazo_delivery/ui/utils/toast.dart';
import 'package:fraazo_delivery/ui/utils/widgets_and_attributes.dart';
import 'package:fraazo_delivery/utils/utils.dart';
import 'package:fraazo_delivery/values/custom_colors.dart';

late final collectedAmountProvider = StateProvider<num>((ref) => 0);

class NewOrderReasonScreen extends StatefulWidget {
  final Map<String, dynamic> arguments;
  const NewOrderReasonScreen(this.arguments);

  @override
  State<NewOrderReasonScreen> createState() => _NewOrderReasonScreenState();
}

class _NewOrderReasonScreenState extends State<NewOrderReasonScreen> {
  final GlobalKey<QualityIssueAttachmentsState> _imageAttachmentKey =
      GlobalKey<QualityIssueAttachmentsState>();

  late OrderItems _orderItemList;
  late num _collectedAmount;
  bool _areIssueDetailsSubmitted = false;

  late AutoDisposeStateNotifierProvider<OrderItemsProvider,
      AsyncValue<OrderItems>> _orderItemsProvider;

  late bool _shouldShowQuality =
      false; //= widget.orderIssueType == 'Quality issues';

  late OrderSeq _orderSeq;

  @override
  void initState() {
    super.initState();
    _orderSeq = widget.arguments['orderSeq'];

    _orderItemsProvider = StateNotifierProvider.autoDispose<OrderItemsProvider,
        AsyncValue<OrderItems>>((ref) => OrderItemsProvider(providerRef: ref));
    _getOrderItems();
  }

  final cashTypeProvider = StateProvider<int>((ref) => -1);

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarBrightness: Brightness.dark,
      ),
    );
    return Scaffold(
      appBar: const NewAppBar(
        isShowBack: false,
        title: 'Quality/Missing items',
      ),
      backgroundColor: bgColor,
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    return SizedBox(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /* Padding(
              padding: const EdgeInsets.only(left: 24, bottom: 20),
              child: Text(
                '', //widget.orderIssueType,
                style: commonTextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),*/
            Padding(
              padding: const EdgeInsets.only(left: 24, bottom: 20, right: 15),
              child: Text(
                widget.arguments['label'] == 'Missing item'
                    ? 'Select the items which are missing from the order'
                    : 'Select the items which has quality issues',
                style: commonTextStyle(
                  color: const Color(0xff787878),
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Color(0xFFFFFFFF),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(24.0),
                    topRight: Radius.circular(24.0),
                  ),
                ),
                child: Consumer(
                  builder: (_, watch, __) {
                    return watch(_orderItemsProvider).when(
                      data: (OrderItems orderItems) {
                        _orderItemList = orderItems;
                        return Column(
                          children: [
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(
                                  left: 16,
                                  right: 16,
                                  top: 16,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          "Items in the Order",
                                          style: commonTextStyle(
                                            color: primaryBlackColor,
                                            fontSize: 20,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.only(
                                            left: 12,
                                            right: 12,
                                            top: 8,
                                            bottom: 8,
                                          ),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFFCE80B),
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          child: Text(
                                            "COD ORDER: ₹${orderItems.nettAmount}",
                                            style: commonTextStyle(
                                              color: primaryBlackColor,
                                              fontSize: 11,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Expanded(
                                      child: Text(
                                        "Total Units: ${orderItems.lineItems.length}",
                                        style: commonTextStyle(
                                          color: const Color(0xFF8A8787),
                                          fontSize: 15,
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                            Expanded(
                              flex: _shouldShowQuality ? 3 : 4,
                              child: ListView.separated(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 14),
                                shrinkWrap: true,
                                itemCount: _orderItemList.lineItems.length,
                                itemBuilder: (context, index) {
                                  return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      _buildMissingItem(index),
                                    ],
                                  );
                                },
                                separatorBuilder: (_, __) =>
                                    const ContainerDivider(),
                              ),
                            ),
                            if (_orderItemList.lineItems.any(
                                (lineItem) => lineItem.hasQualityIssue)) ...[
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 5),
                                child: QualityIssueAttachments(
                                  key: _imageAttachmentKey,
                                ),
                              )
                            ] else ...[
                              _clearImageList()
                            ],
                            Expanded(
                              flex: 3,
                              child: Consumer(
                                builder: (_, watch, __) {
                                  _collectedAmount =
                                      watch(collectedAmountProvider).state;
                                  final _cashType =
                                      watch(cashTypeProvider).state;
                                  return CollectCashWidget(
                                      collectedCash: getPositiveValueToShow(
                                        _collectedAmount.toString(),
                                      ),
                                      orderSeq: _orderSeq,
                                      onMarkDeliveredTap: _onSubmitButtonTap,
                                      tab: _cashType,
                                      firstTabSelected: _onFirstTabSelected,
                                      secondTabSelected: _onSecondTabSelected);
                                },
                              ),
                            ),
                          ],
                        );
                      }, //CollectCashWidget
                      loading: () => const FDCircularLoader(),
                      error: (e, __) => SizedBox(
                        width: double.maxFinite,
                        child: FDErrorWidget(
                          onPressed: _getOrderItems,
                          errorType: e,
                          shouldHideErrorToast: false,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMissingItem(int index) {
    final lineItem = _orderItemList.lineItems[index];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 15),
      child: Row(
        children: [
          ColoredBox(
            color: const Color(0xFFF6F6F6),
            child: Padding(
              padding: const EdgeInsets.all(3.0),
              child: CachedNetworkImage(
                imageUrl: lineItem.imageUrl!,
                height: 37,
                width: 37,
                fit: BoxFit.fill,
                placeholder: (context, url) => const Center(
                  child: Padding(
                    padding: EdgeInsets.all(25),
                    child: FDCircularLoader(),
                  ),
                ),
                errorWidget: (context, url, error) => const Icon(Icons.error),
              ),
            ),
          ),
          sizedBoxW20,
          Expanded(
            flex: 5,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  lineItem.name ?? '',
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                  style: commonTextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                sizedBoxH5,
                Row(
                  children: [
                    Text(
                      "Qty: ${lineItem.qty}",
                      style: commonTextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Text(
                        "|",
                        style: commonTextStyle(
                          fontSize: 11,
                          color: settleCashListTitle,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Text(
                      '${lineItem.packSize} units',
                      style: commonTextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Spacer(),
          sizedBoxW10,

          //Commented June 13-22,
          /*if (lineItem.isMissing) ...[
            Expanded(flex: 3, child: _buildUnitIncDec(index)),
            sizedBoxW12,
          ] else ...[
            const SizedBox()
          ],*/

          if ((!lineItem.isMissing && !lineItem.hasQualityIssue) ||
              (lineItem.isMissing && !lineItem.hasQualityIssue)) ...[
            Expanded(
              child: _buildMissingCheckBox(
                index,
                isEnabled: lineItem.isMissing,
                checkBoxTitle: 'Missing',
                isMissingCheckBox: true,
              ),
            ),
          ] else ...[
            const SizedBox()
          ],
          sizedBoxW10,
          if ((!lineItem.hasQualityIssue && !lineItem.isMissing) ||
              (lineItem.hasQualityIssue && !lineItem.isMissing)) ...[
            Expanded(
              child: _buildMissingCheckBox(
                index,
                isEnabled: lineItem.hasQualityIssue,
                checkBoxTitle: 'Quality',
              ),
            ),
          ] else ...[
            const SizedBox()
          ],
        ],
      ),
    );
  }

  Widget _clearImageList() {
    (_imageAttachmentKey.currentState?.imagePathList ?? []).clear();
    return const SizedBox();
  }

  Widget _buildUnitIncDec(int index) {
    final lineItem = _orderItemList.lineItems[index];
    final qty = lineItem.qty ?? 0;
    final incDecQty = lineItem.incDecQty ?? 0;

    final _decrement = (incDecQty > 1) && (incDecQty <= qty);
    final _increment = (incDecQty > 0) && (incDecQty < qty);
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        border: Border.all(color: tcTxtColor),
        borderRadius: const BorderRadius.all(Radius.circular(4)),
      ),
      child: Row(
        children: [
          InkWell(
            onTap: () => _decrement
                ? context
                    .read(_orderItemsProvider.notifier)
                    .incDecItem(index: index)
                : null,
            child: Icon(
              Icons.remove,
              color: _decrement ? tcTxtColor : greyViewAll,
              size: 15,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0),
            child: Text(
              "${lineItem.incDecQty}",
              style: commonTextStyle(
                fontSize: 11,
              ),
            ),
          ),
          InkWell(
            onTap: () => _increment
                ? context
                    .read(_orderItemsProvider.notifier)
                    .incDecItem(index: index, isIncrement: true)
                : null,
            child: Icon(
              Icons.add,
              color: _increment ? tcTxtColor : greyViewAll,
              size: 15,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMissingCheckBox(
    int index, {
    bool isEnabled = false,
    required String checkBoxTitle,
    bool isMissingCheckBox = false,
  }) {
    return Column(
      children: [
        InkWell(
          onTap: () => context.read(_orderItemsProvider.notifier).checkBoxState(
                index: index,
                isMissingCheckBox: isMissingCheckBox,
              ),
          child: SvgPicture.asset(
            isEnabled ? 'ic_check'.svgImageAsset : 'ic_un_check'.svgImageAsset,
            width: 23,
            height: 23,
          ),
        ),
        sizedBoxH2,
        FittedBox(
          child: Text(
            checkBoxTitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: commonTextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  void _getOrderItems() {
    context.read(_orderItemsProvider.notifier).getOrderLineItems(
          _orderSeq.id ?? 0,
        );
  }

  String getPositiveValueToShow(String value) {
    final newValue = double.tryParse(value) ?? 0;
    if (newValue <= 0 || newValue <= 0.0) {
      return "0";
    } else {
      return newValue.trimTo2Digits();
    }
  }

  Future<String> getCollectedCash() async {
    final lineItems = _orderItemList.lineItems;
    num totalAmount = 0;
    await Future.forEach(lineItems, (LineItem lineItem) {
      totalAmount += lineItem.incDecQty ?? 0;
    });
    return getPositiveValueToShow(totalAmount.toString());
  }

  Future _onSubmitButtonTap() async {
    _shouldShowQuality =
        _orderItemList.lineItems.any((lineItem) => lineItem.hasQualityIssue);

    final _isMissingItem =
        _orderItemList.lineItems.any((lineItem) => lineItem.isMissing);

    final _imageAttachments =
        _imageAttachmentKey.currentState?.imagePathList ?? [];
    if (_shouldShowQuality && _imageAttachments.isEmpty) {
      Toast.info("Please add photos of quality issue items.");
      return;
    } else if (!_isMissingItem) {
      Toast.info("Please select at-least one Missing/Quality items.");
      return;
    }

    final popupLoading = Toast.popupLoading();
    try {
      if (!_areIssueDetailsSubmitted) {
        final orderProvider = context.read(orderUpdateProvider.notifier);
        await orderProvider.updateCollectedOrderAmount(
          collectedAmount: _collectedAmount.toString(),
          orderNumber: _orderSeq.orderNumber!,
          orderItemList: _orderItemList,
        );
        if (_shouldShowQuality) {
          await orderProvider.uploadQualityIssueImages(
            _orderSeq.id,
            _imageAttachments,
          );
        }
      }
      popupLoading();
      _areIssueDetailsSubmitted = true;
      context.read(orderUpdateProvider.notifier).endOrderDelivery(
            PrefHelper.getInt(PrefKeys.CURRENT_TASK_ID) ?? 0,
            orderSeq: _orderSeq,
          );
    } catch (e, st) {
      popupLoading();
      ErrorReporter.error(e, st);
    }
  }

  void _onFirstTabSelected() {
    context.read(cashTypeProvider).state = 0;
  }

  void _onSecondTabSelected() {
    context.read(cashTypeProvider).state = 1;
  }
}
