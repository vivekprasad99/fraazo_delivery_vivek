import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fraazo_delivery/helpers/error/error_reporter.dart';
import 'package:fraazo_delivery/models/cash_deposit/order_payment_model.dart';
import 'package:fraazo_delivery/services/api/cash_deposit/cash_deposit_service.dart';

class OrderHistoryProvider extends StateNotifier<AsyncValue<List<Data>>> {
  OrderHistoryProvider([AsyncValue<List<Data>> state = const AsyncLoading()])
      : super(state);

  final CashDepositService cashDepositService = CashDepositService();

  Future getOrderPaymentHistory(int listId) async {
    state = const AsyncLoading();
    try {
      final List<Data>? paymentHistory =
          await cashDepositService.getOrderPaymentHistory(listId);
      state = AsyncData(paymentHistory!);
    } catch (e, st) {
      state = AsyncError(e, st);
      ErrorReporter.error(e, st);
    }
  }
}
