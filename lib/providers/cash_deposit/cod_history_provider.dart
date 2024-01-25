import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fraazo_delivery/helpers/error/error_reporter.dart';
import 'package:fraazo_delivery/services/api/cash_deposit/cash_deposit_service.dart';

import '../../models/cash_deposit/transaction_model.dart';

class CodHistoryProvider extends StateNotifier<AsyncValue<List<Transaction>>> {
  CodHistoryProvider(AsyncValue<List<Transaction>> state) : super(state);

  final CashDepositService cashDepositService = CashDepositService();

  Future getCodPaymentHistory() async {
    state = const AsyncLoading();
    try {
      final List<Transaction> codHistory =
          await cashDepositService.getCashOnDeliveryHistory();
      state = AsyncData(codHistory);
    } catch (e, st) {
      state = AsyncError(e, st);
      ErrorReporter.error(e, st);
    }
  }
}
