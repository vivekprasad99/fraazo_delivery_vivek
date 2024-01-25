import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fraazo_delivery/helpers/error/error_reporter.dart';
import 'package:fraazo_delivery/models/misc/rider_login_hours_model.dart';
import 'package:fraazo_delivery/services/api/user/user_service.dart';

class RiderLoginHoursProvider
    extends StateNotifier<AsyncValue<RiderLoginHoursModel>> {
  RiderLoginHoursProvider(AsyncValue<RiderLoginHoursModel> state)
      : super(state);

  final _userService = UserService();

  Future getLoginHours(String startDate, String endDate) async {
    state = const AsyncLoading();
    try {
      final RiderLoginHoursModel riderLoginHoursModel = await _userService
          .getRiderLoginHours(startDate: startDate, endDate: endDate);
      state = AsyncData(riderLoginHoursModel);
    } catch (e, st) {
      state = AsyncError(e, st);
      ErrorReporter.error(e, st);
    }
  }
}
