import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fraazo_delivery/helpers/error/error_reporter.dart';
import 'package:fraazo_delivery/models/cash_deposit/transaction_model.dart';
import 'package:fraazo_delivery/services/api/cash_deposit/cash_deposit_service.dart';

final paymentHistoryProvider = StateNotifierProvider.autoDispose<
        PaymentHistoryProvider, AsyncValue<List<Transaction>>>(
    (_) => PaymentHistoryProvider(const AsyncLoading()));

class PaymentHistoryProvider
    extends StateNotifier<AsyncValue<List<Transaction>>> {
  PaymentHistoryProvider(AsyncValue<List<Transaction>> state) : super(state);

  final CashDepositService cashDepositService = CashDepositService();

  Future getPaymentHistory() async {
    state = const AsyncLoading();
    try {
      final List<Transaction> paymentHistoryList =
          await cashDepositService.getPaymentHistoryAmount();
      state = AsyncData(paymentHistoryList);
    } catch (e, st) {
      state = AsyncError(e, st);
      ErrorReporter.error(e, st);
    }
  }
}
