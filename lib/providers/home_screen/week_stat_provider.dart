import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fraazo_delivery/helpers/error/error_reporter.dart';
import 'package:fraazo_delivery/models/home_page/week_stat_model.dart';
import 'package:fraazo_delivery/services/api/home_page/home_page_service.dart';

final weekStatProvider =
    StateNotifierProvider<WeekStatProvider, AsyncValue<WeekModel?>>(
  (ref) => WeekStatProvider(),
);

class WeekStatProvider extends StateNotifier<AsyncValue<WeekModel?>> {
  WeekStatProvider() : super(const AsyncLoading());

  final HomePageService _homePageService = HomePageService();

  Future getWeekStats({
    required String fromDate,
    required String toDate,
  }) async {
    state = const AsyncLoading();
    try {
      final WeekModel? weekData = await _homePageService.getWeeklyEarnings(
        fromDate: fromDate,
        toDate: toDate,
      );
      state = AsyncData(weekData);
    } catch (e, st) {
      state = AsyncError(e, st);
      ErrorReporter.error(e, st);
    }
  }
}
