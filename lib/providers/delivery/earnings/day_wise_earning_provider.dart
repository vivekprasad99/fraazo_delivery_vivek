import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fraazo_delivery/helpers/error/error_reporter.dart';
import 'package:fraazo_delivery/models/delivery/day_wise_earning_model.dart';
import 'package:fraazo_delivery/services/api/delivery/delivery_service.dart';

class DayWiseEarningProvider
    extends StateNotifier<AsyncValue<List<DayEarning>>> {
  DayWiseEarningProvider(
      [AsyncValue<List<DayEarning>> state = const AsyncLoading()])
      : super(state);

  final _deliveryService = DeliveryService();

  Future getDayWiseEarning(int earningId) async {
    state = const AsyncLoading();
    try {
      final List<DayEarning> dayEarningList =
          await _deliveryService.getDailyBills(earningId);
      state = AsyncData(dayEarningList);
    } catch (e, st) {
      state = AsyncError(e, st);
      ErrorReporter.error(e, st, "DayWiseEarningProvider: getDayWiseEarning()");
    }
  }

  @override
  void dispose() {
    _deliveryService.cancelToken("DayWiseEarningProvider");
    super.dispose();
  }
}
