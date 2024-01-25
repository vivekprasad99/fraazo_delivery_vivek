import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fraazo_delivery/helpers/error/error_reporter.dart';
import 'package:fraazo_delivery/models/user/stat_model.dart';
import 'package:fraazo_delivery/services/api/user/user_service.dart';

final todaysStatsProvider = StateNotifierProvider.autoDispose<
    TodaysStatsProvider, AsyncValue<StatModel>>((_) => TodaysStatsProvider());

class TodaysStatsProvider extends StateNotifier<AsyncValue<StatModel>> {
  TodaysStatsProvider([AsyncValue<StatModel> state = const AsyncLoading()])
      : super(state) {
    getStats();
  }

  final _userService = UserService();

  num? codAmount = 0;

  Future getStats() async {
    try {
      state = const AsyncLoading();
      final StatModel statModel = await _userService.postGetOrderCount();
      codAmount = statModel.codAmount;
      state = AsyncData(statModel);
    } catch (e, st) {
      state = AsyncError(e, st);
      ErrorReporter.error(e, st, "TodaysStatsProvider: getStats()");
    }
  }
}
