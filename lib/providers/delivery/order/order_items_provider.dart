import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fraazo_delivery/helpers/error/error_reporter.dart';
import 'package:fraazo_delivery/models/delivery/delivery_items_model.dart';
import 'package:fraazo_delivery/services/api/delivery/delivery_service.dart';
import 'package:fraazo_delivery/ui/screens/home/local_widgets/delivery/new_order_reason_screen.dart';

class OrderItemsProvider extends StateNotifier<AsyncValue<OrderItems>> {
  OrderItemsProvider({this.providerRef}) : super(const AsyncLoading());

  final _deliveryService = DeliveryService();
  late OrderItems _orderItems;
  late ProviderReference? providerRef;

  Future<void> _init() async {
    final lineItems = _orderItems.lineItems;
    num totalAmount = 0;
    await Future.forEach(lineItems, (LineItem lineItem) {
      totalAmount += lineItem.nettAmount ?? 0;
    });
    providerRef?.read(collectedAmountProvider).state = totalAmount;
  }

  Future getOrderLineItems(int orderId) async {
    state = const AsyncLoading();
    try {
      final OrderItems orderItems =
          await _deliveryService.postOrderItems(orderId);
      _orderItems = orderItems;
      state = AsyncData(orderItems);
      if (providerRef != null) {
        _init();
      }
    } catch (e, st) {
      state = AsyncError(e, st);
      ErrorReporter.error(e, st, "OrderItemsProvider: getOrderLineItems()");
    }
  }

  Future<void> incDecItem({
    bool isIncrement = false,
    required int index,
  }) async {
    final lineItems = _orderItems.lineItems;
    final incDecQty = lineItems[index].incDecQty ?? 0;
    final _collectCashAmount =
        providerRef?.read(collectedAmountProvider).state ?? 0;

    final amountPerUnit =
        (lineItems[index].nettAmount ?? 0) / (lineItems[index].qty ?? 0);

    num calculatedAmount;

    if (isIncrement) {
      lineItems[index].incDecQty = incDecQty + 1;
      calculatedAmount = _collectCashAmount - amountPerUnit;
    } else {
      lineItems[index].incDecQty = incDecQty - 1;
      calculatedAmount = _collectCashAmount + amountPerUnit;
    }
    _orderItems.lineItems = lineItems;
    state = AsyncData(_orderItems);
    providerRef?.read(collectedAmountProvider).state = calculatedAmount;
  }

  void checkBoxState(
      {bool isChecked = false,
      required int index,
      required bool isMissingCheckBox}) {
    final _collectCashAmount =
        providerRef?.read(collectedAmountProvider).state ?? 0;

    final lineItems = _orderItems.lineItems;
    final lineItem = lineItems[index];

    final totalAmount = lineItem.nettAmount ?? 0;
    final lineItemQty = lineItem.qty ?? 0;
    final incDecQty = lineItem.incDecQty ?? 0;

    /***
     *
     *  Only added( || lineItem.hasQualityIssue),
     *  because increment/decrement UI commented Jan13,22,
     *  otherwise only !lineItem.isMissing used
     *
     *
     ***/
    if (lineItem.isMissing || lineItem.hasQualityIssue) {
      lineItem.incDecQty = lineItem.qty;

      providerRef?.read(collectedAmountProvider).state =
          _collectCashAmount + (totalAmount / lineItemQty) * incDecQty;

      /*providerRef?.read(collectedAmountProvider).state = _collectCashAmount -
          (totalAmount / lineItemQty) * (lineItem.incDecQty ?? 0);*/
    } else {
      providerRef?.read(collectedAmountProvider).state =
          _collectCashAmount - (totalAmount / lineItemQty) * lineItemQty;
      /*providerRef?.read(collectedAmountProvider).state =
          _collectCashAmount + (totalAmount / lineItemQty) * incDecQty;*/
    }

    if (isMissingCheckBox) {
      lineItem.isMissing = !lineItem.isMissing;
    } else {
      lineItem.hasQualityIssue = !lineItem.hasQualityIssue;
    }
    lineItems.replaceRange(index, index + 1, [lineItem]);
    _orderItems.lineItems = lineItems;
    state = AsyncData(_orderItems);
  }

  void checkBoxStateOrderSkuSelection(int index) {
    _orderItems.lineItems[index].isMissing =
        !_orderItems.lineItems[index].isMissing;
    state = AsyncData(_orderItems);
  }
}
