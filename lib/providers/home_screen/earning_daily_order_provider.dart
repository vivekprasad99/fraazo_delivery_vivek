import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fraazo_delivery/helpers/error/error_reporter.dart';
import 'package:fraazo_delivery/models/home_page/earning_daily_order_model.dart';
import 'package:fraazo_delivery/services/api/home_page/home_page_service.dart';

final dailyEarningProvider = StateNotifierProvider<DailyEarningProvider,
    AsyncValue<EarningAndDailyOrderModel?>>(
  (ref) => DailyEarningProvider(),
);

class DailyEarningProvider
    extends StateNotifier<AsyncValue<EarningAndDailyOrderModel>> {
  DailyEarningProvider() : super(const AsyncLoading());

  final HomePageService _homePageService = HomePageService();

  Future getEarningAndOrdersDaily(
      {required int riderId, required int batteryLevel}) async {
    state = const AsyncLoading();
    try {
      final EarningAndDailyOrderModel? earningAndDailOrder =
          await _homePageService.getEarningAndOrdersDailyApi(
              riderId: riderId, batteryLevel: batteryLevel);
      state = AsyncData(earningAndDailOrder!);
    } catch (e, st) {
      state = AsyncError(e, st);
      ErrorReporter.error(e, st);
    }
  }
}
