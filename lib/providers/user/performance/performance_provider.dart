import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fraazo_delivery/helpers/error/error_reporter.dart';
import 'package:fraazo_delivery/models/user/profile/performance_model.dart';
import 'package:fraazo_delivery/services/api/user/user_service.dart';

class PerformanceProvider extends StateNotifier<AsyncValue<PerformanceModel>> {
  PerformanceProvider(AsyncValue<PerformanceModel> state) : super(state);

  final _userService = UserService();

  Future getPerformanceApiFetch(String date) async {
    state = const AsyncLoading();
    try {
      final PerformanceModel performance =
          await _userService.getRiderPerformance(date);
      state = AsyncData(performance);
    } catch (e, st) {
      state = AsyncError(e, st);
      ErrorReporter.error(e, st);
    }
  }
}
