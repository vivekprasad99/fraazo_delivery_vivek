import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fraazo_delivery/helpers/error/error_reporter.dart';
import 'package:fraazo_delivery/models/asset_management/rider_asset_model.dart';
import 'package:fraazo_delivery/services/api/asset_management/asset_management_service.dart';

class RiderAssetAcceptedProvider
    extends StateNotifier<AsyncValue<RiderAssetModel>> {
  RiderAssetAcceptedProvider(AsyncValue<RiderAssetModel> state) : super(state);

  final AssetManagementService assetManagementService =
      AssetManagementService();

  Future getRiderAcceptedAsset() async {
    state = const AsyncLoading();
    try {
      final RiderAssetModel riderAsset =
          await assetManagementService.getRiderAssetAccepted();
      state = AsyncData(riderAsset);
    } catch (e, st) {
      state = AsyncError(e, st);
      ErrorReporter.error(e, st);
    }
  }
}
