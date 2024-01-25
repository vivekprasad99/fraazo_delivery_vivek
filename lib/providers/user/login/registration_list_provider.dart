import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fraazo_delivery/helpers/error/error_reporter.dart';
import 'package:fraazo_delivery/models/user/registration_list_model.dart';
import 'package:fraazo_delivery/services/api/user/user_service.dart';

class RegistrationListProvider extends StateNotifier<AsyncValue<RegistrationListModel>> {
  RegistrationListProvider(AsyncValue<RegistrationListModel> state) : super(state);

  final _userService = UserService();

  Future getRegistrationListApiFetch() async {
    state = const AsyncLoading();
    try {
      final RegistrationListModel registrationList =
          await _userService.getRegistrationList();
      state = AsyncData(registrationList);
    } catch (e, st) {
      state = AsyncError(e, st);
      ErrorReporter.error(e, st);
    }
  }
}