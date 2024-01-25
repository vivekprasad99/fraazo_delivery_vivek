import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fraazo_delivery/helpers/error/error_reporter.dart';
import 'package:fraazo_delivery/models/user/profile/shift_time_model.dart';
import 'package:fraazo_delivery/services/api/user/user_service.dart';

class ShiftTimeListProvider
    extends StateNotifier<AsyncValue<List<ShiftTime>?>> {
  ShiftTimeListProvider(AsyncValue<List<ShiftTime>> state) : super(state);

  Future getShiftTimeList() async {
    state = const AsyncLoading();
    try {
      final List<ShiftTime>? shiftTime = await UserService().getShiftTime();
      state = AsyncData(shiftTime);
    } catch (e, st) {
      state = AsyncError(e, st);
      ErrorReporter.error(e, st);
    }
  }
}
