import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fraazo_delivery/helpers/error/error_reporter.dart';
import 'package:fraazo_delivery/models/asset_management/rider_asset_model.dart';
import 'package:fraazo_delivery/services/api/asset_management/asset_management_service.dart';

class AssignedUpdateProvider
    extends StateNotifier<AsyncValue<List<RiderAsset>>> {
  AssignedUpdateProvider(AsyncValue<List<RiderAsset>> state) : super(state);

  final AssetManagementService assetManagementService =
      AssetManagementService();

  Future updateAssignedStatus(String requestId, String status) async {
    state = const AsyncLoading();
    try {
      final List<RiderAsset> riderAsset =
          await assetManagementService.postRiderAssetUpdate(requestId, status);
      state = AsyncData(riderAsset);
    } catch (e, st) {
      state = AsyncError(e, st);
      ErrorReporter.error(e, st);
    }
  }
}
