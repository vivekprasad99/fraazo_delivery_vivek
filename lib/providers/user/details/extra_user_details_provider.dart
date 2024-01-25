import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fraazo_delivery/helpers/error/error_reporter.dart';
import 'package:fraazo_delivery/models/user/profile/extra_user_details_model.dart';
import 'package:fraazo_delivery/services/api/user/user_service.dart';

class ExtraUserDetailsProvider
    extends StateNotifier<AsyncValue<ExtraUserDetails>> {
  ExtraUserDetailsProvider(
      [AsyncValue<ExtraUserDetails> state = const AsyncLoading()])
      : super(state);

  final _userService = UserService();

  Future getExtraUserDetails() async {
    state = const AsyncLoading();
    try {
      final ExtraUserDetails extraUserDetails =
          await _userService.getRiderDetails();
      state = AsyncData(extraUserDetails);
    } catch (e, st) {
      state = AsyncError(e, st);
      ErrorReporter.error(
          e, st, "ExtraUserDetailsProvider: getExtraUserDetails()");
    }
  }

  Future<bool> sendExtraUserDetails(ExtraUserDetails extraUserDetails) async {
    try {
      await _userService.putRiderDetails(extraUserDetails);
      return true;
    } catch (e, st) {
      ErrorReporter.error(
          e, st, "ExtraUserDetailsProvider: sendExtraUserDetails()");
      return false;
    }
  }
}
