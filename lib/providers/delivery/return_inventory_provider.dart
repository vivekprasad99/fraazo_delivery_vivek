import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fraazo_delivery/helpers/error/error_reporter.dart';
import 'package:fraazo_delivery/helpers/route/route_helper.dart';
import 'package:fraazo_delivery/models/return_inventory/return_inventory_model.dart';
import 'package:fraazo_delivery/providers/delivery/latest_task_provider.dart';
import 'package:fraazo_delivery/providers/user/profile/user_profile_provider.dart';
import 'package:fraazo_delivery/services/api/user/user_service.dart';
import 'package:fraazo_delivery/utils/globals.dart';

class ReturnInventoryProvider
    extends StateNotifier<AsyncValue<ReturnInventoryModel>> {
  ReturnInventoryProvider(AsyncValue<ReturnInventoryModel> state)
      : super(state);

  final _userService = UserService();

  Future getReturnInventoryFetch() async {
    state = const AsyncLoading();
    try {
      final ReturnInventoryModel returnInventory =
          await _userService.getReturnInventory();
      if (returnInventory.data!.isEmpty) {
        Globals.user!.disableOrderAssignment = false;
        RouteHelper.navigatorContext
            .read(userProfileProvider.notifier)
            .updateUser();
        RouteHelper.navigatorContext
            .read(latestTaskProvider.notifier)
            .getLatestTask();
      }
      state = AsyncData(returnInventory);
    } catch (e, st) {
      state = AsyncError(e, st);
      ErrorReporter.error(e, st);
    }
    // RouteHelper.navigatorContext
    //     .read(userProfileProvider.notifier)
    //     .getUserDetails();
  }
}
