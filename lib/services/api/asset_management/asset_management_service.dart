import 'package:fraazo_delivery/helpers/api/api_call_helper.dart';
import 'package:fraazo_delivery/helpers/api/apis.dart';
import 'package:fraazo_delivery/models/asset_management/rider_asset_model.dart';
import 'package:fraazo_delivery/services/sdk/firebase/firebase_notification_service.dart';
import 'package:fraazo_delivery/utils/globals.dart';

class AssetManagementService {
  final _apiCallHelper = ApiCallHelper();

  Future<RiderAssetModel> getRiderAsset() async {
    final String url = "${APIs.RIDER_ASSET__FETCH}/${Globals.user!.id}";
    final Map<String, dynamic>? response = await _apiCallHelper.get(url);
    return RiderAssetModel.fromJson(response!);
  }

  Future<List<RiderAsset>> postRiderAssetUpdate(
      String? requestId, String status) async {
    final String url = "${APIs.RIDER_ASSET__UPDATESTATUS}/$requestId/$status";
    final Map<String, dynamic>? response = await _apiCallHelper.put(url);
    return RiderAssetModel.fromJson(response!).riderAssetList;
  }

  Future<RiderAssetModel> getRiderAssetAccepted() async {
    final String url =
        "${APIs.RIDER_ASSET__FETCH__ACCEPTED}/${Globals.user!.id}";
    final Map<String, dynamic>? response = await _apiCallHelper.get(url);
    return RiderAssetModel.fromJson(response!);
  }

  Future<List<RiderAsset>> postRiderAssetReturn(
      List<Map<String, dynamic>> returnAsset) async {
    final String? deviceToken =
        await FirebaseNotificationService().getDeviceToken();
    const String url = APIs.RIDER_ASSET__INITIATE;
    final Map<String, dynamic> body = {
      "asset_details": returnAsset,
      "rider_id": Globals.user!.id,
      "device_id": deviceToken,
      "assignee_role": "rider",
    };
    final Map<String, dynamic>? response =
        await _apiCallHelper.post(url, body: body);
    return RiderAssetModel.fromJson(response!).riderAssetList;
  }
}
