import 'package:fraazo_delivery/helpers/api/api_call_helper.dart';
import 'package:fraazo_delivery/helpers/api/apis.dart';
import 'package:fraazo_delivery/models/delivery/location.dart';
import 'package:fraazo_delivery/models/misc/id_name_list_model.dart';
import 'package:fraazo_delivery/models/user/device_verification_model.dart';
import 'package:fraazo_delivery/models/user/profile/store_list_model.dart';
import 'package:fraazo_delivery/models/user/profile/user_model.dart';
import 'package:fraazo_delivery/services/sdk/firebase/firebase_notification_service.dart';
import 'package:fraazo_delivery/utils/globals.dart';

class AuthenticationService {
  final _apiCallHelper = ApiCallHelper();

  Future postSendOTP(String? mobileNo, String? deviceId, String? deviceName,
      Map<String, String>? location) async {
    const String url = APIs.SEND_OTP;

    final Location riderLocation = await Globals.getAssignedLocation();

    final Map<String, dynamic> body = {
      "mobile": mobileNo,
      "lat": riderLocation.latitude,
      "lng": riderLocation.longitude,
      "device_tag_id": deviceId,
      "device_type": deviceName,
      "current_area": location!['current_area'],
      "current_city": location['current_city']
    };

    final response = await _apiCallHelper.post(url, body: body);
    return response;
  }

  Future<User?> postRiderSignup(
      {User? user, String phoneNo = '', bool isRevamp = false}) async {
    String url = '';
    Map<String, dynamic> body = {};
    if (!isRevamp) {
      url = APIs.RIDER + APIs.SIGNUP;
      body = {
        "first_name": user?.firstName,
        "last_name": user?.lastName,
        "mobile": user?.mobile,
        "store_code": user?.storeCode,
        "vendor": user?.vendorId,
        "password": user?.password,
      };
    } else {
      url = APIs.RIDER + APIs.NEW_SIGNUP;
      body = {
        "mobile": phoneNo,
      };
    }
    final response = await _apiCallHelper.post(url, body: body);
    return UserModel.fromJson(response).data;
  }

  Future postVerifyOTP(int mobileNo, String otp, String? deviceId) async {
    const String url = APIs.VERIFY_OTP;
    final Map<String, dynamic> body = {
      "mobile": mobileNo,
      "otp": otp,
      "device_id": deviceId
    };
    final response =
        await _apiCallHelper.post(url, body: body, shouldSaveHeaders: true);
    return response;
  }

  Future postLogin(String mobileNo, String password, String deviceId,
      String? deviceName, Map<String, String>? location) async {
    const String url = APIs.RIDER + APIs.LOGIN;
    final Map<String, dynamic> body = {
      "mobile": mobileNo,
      "password": password,
      "device_tag_id": deviceId,
      "device_type": deviceName,
      "current_area": location!['current_area'],
      "current_city": location['current_city']
    };

    final response =
        await _apiCallHelper.post(url, body: body, shouldSaveHeaders: true);
    return response;
  }

  Future postVerifySignUpOTP(int mobileNo, String otp) async {
    const String url = APIs.RIDER + APIs.VERIFY_SIGNUP_OTP;
    final Map<String, dynamic> body = {"mobile": mobileNo, "otp": otp};
    final response =
        await _apiCallHelper.post(url, body: body, shouldSaveHeaders: true);
    return response;
  }

  Future<List<Store>> getDashboardStores(String cityCode) async {
    String url = APIs.DASHBOARD + APIs.STORES;
    if (cityCode.isNotEmpty) {
      url += "?by_city=$cityCode";
    }
    final response = await _apiCallHelper.get(url);
    return StoreListModel.fromJson(response!).storeList;
  }

  Future<List<IdName>> getDeliveryPartners() async {
    const String url = APIs.ADMIN + APIs.DELIVERY_PARTNERS;
    final response = await _apiCallHelper.get(url);
    return IdNameModel.fromJson(response!).idNameList;
  }

  Future postResetPassword(String mobileNo) async {
    const String url = APIs.RIDER + APIs.RESET_PASSWORD;
    final Map<String, dynamic> body = {
      "mobile": mobileNo,
    };
    final response = await _apiCallHelper.post(url, body: body);
    return response;
  }

  Future postUpdatePassword(
      {required String mobileNo,
      required String otp,
      required String password}) async {
    const String url = APIs.RIDER + APIs.UPDATE_PASSWORD;
    final Map<String, dynamic> body = {
      "mobile": mobileNo,
      "otp": otp,
      "password": password,
    };
    final response = await _apiCallHelper.post(url, body: body);
    return response;
  }

  Future postIMEIsWithId({
    required String mobileNo,
    required List<String> imeiS,
  }) async {
    const String url = APIs.DEVICE_VERIFY;
    final deviceId = imeiS.last;
    final Map<String, dynamic> body = {
      "mobile": mobileNo,
      "device_tag_id": deviceId,
      "imei_numbers": imeiS.removeLast(),
    };
    final response = await _apiCallHelper.post(url, body: body);
    return DeviceVerificationModel.fromJson(response ?? {});
  }

  Future addDevice({
    required String mobileNo,
    required String deviceModelNo,
    required List<String> imeiS,
  }) async {
    const String url = APIs.RIDER + APIs.ADD_DEVICE;
    final deviceId = imeiS.last;
    final String? deviceToken =
        await FirebaseNotificationService().getDeviceToken();

    imeiS.removeAt(imeiS.length - 1);

    final Map<String, dynamic> body = {
      "mobile": mobileNo,
      "device_tag_id": deviceId,
      "imei_numbers": imeiS,
      "device_type": deviceModelNo,
      "device_token": deviceToken
    };

    final response = await _apiCallHelper.post(url, body: body);
    return DeviceVerificationModel.fromJson(response ?? {});
  }

  ///rider/add/device
}
