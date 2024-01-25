import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fraazo_delivery/helpers/error/error_reporter.dart';
import 'package:fraazo_delivery/models/asset_management/rider_asset_model.dart';
import 'package:fraazo_delivery/services/api/asset_management/asset_management_service.dart';

final riderAssetProvider = StateNotifierProvider.autoDispose<RiderAssetProvider,
        AsyncValue<RiderAssetModel>>(
    (_) => RiderAssetProvider(const AsyncLoading()));

class RiderAssetProvider extends StateNotifier<AsyncValue<RiderAssetModel>> {
  RiderAssetProvider(AsyncValue<RiderAssetModel> state) : super(state);

  final AssetManagementService assetManagementService =
      AssetManagementService();

  Future getRiderAssetFetch() async {
    state = const AsyncLoading();
    try {
      final RiderAssetModel riderAsset =
          await assetManagementService.getRiderAsset();
      state = AsyncData(riderAsset);
    } catch (e, st) {
      state = AsyncError(e, st);
      ErrorReporter.error(e, st);
    }
  }
}
