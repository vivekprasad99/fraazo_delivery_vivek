import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fraazo_delivery/helpers/error/error_reporter.dart';
import 'package:fraazo_delivery/models/user/profile/store_list_model.dart';
import 'package:fraazo_delivery/services/api/authentication/authentication_service.dart';

class StoreSelectorListProvider extends StateNotifier<AsyncValue<List<Store>>> {
  StoreSelectorListProvider(
      [AsyncValue<List<Store>> state = const AsyncLoading()])
      : super(state);

  final _authenticationService = AuthenticationService();

  Future getStoreList(String cityCode) async {
    state = const AsyncLoading();
    try {
      final List<Store> storeList =
          await _authenticationService.getDashboardStores(cityCode);
      state = AsyncData(storeList);
    } catch (e, st) {
      state = AsyncError(e, st);
      ErrorReporter.error(e, st, "StoreSelectorListProvider: getStoreList()");
    }
  }
}
