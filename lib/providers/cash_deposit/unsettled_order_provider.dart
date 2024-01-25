import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fraazo_delivery/helpers/error/error_reporter.dart';
import 'package:fraazo_delivery/models/cash_deposit/transaction_model.dart';
import 'package:fraazo_delivery/models/cash_deposit/unsettled_order_model.dart';
import 'package:fraazo_delivery/services/api/cash_deposit/cash_deposit_service.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

final unsettledOrderProvider = StateNotifierProvider.autoDispose<
        UnsettledOrderProvider, AsyncValue<UnsettledOrderModel>>(
    (_) => UnsettledOrderProvider(const AsyncLoading()));

class UnsettledOrderProvider
    extends StateNotifier<AsyncValue<UnsettledOrderModel>> {
  UnsettledOrderProvider(AsyncValue<UnsettledOrderModel> state) : super(state);

  final CashDepositService cashDepositService = CashDepositService();

  Future getUnsettledOrders() async {
    state = const AsyncLoading();
    try {
      final UnsettledOrderModel unsettledOrder =
          await cashDepositService.getRiderListOutstandingAmount();
      state = AsyncData(unsettledOrder);
    } catch (e, st) {
      state = AsyncError(e, st);
      ErrorReporter.error(e, st);
    }
  }

  Future<Transaction?> initiateOrderTransaction(
      List<String> selectedOrderNumberList) {
    return cashDepositService
        .postRiderCalculateAmountCreateRazorpayOrder(selectedOrderNumberList);
  }

  Future<Transaction?> checkPaymentStatus(
      PaymentSuccessResponse? paymentSuccessResponse) {
    return cashDepositService
        .postRiderVerifyRazorpayPayment(paymentSuccessResponse);
  }
}
