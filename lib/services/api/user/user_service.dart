import 'dart:async';

import 'package:dio/dio.dart';
import 'package:fraazo_delivery/helpers/api/api_call_helper.dart';
import 'package:fraazo_delivery/helpers/api/apis.dart';
import 'package:fraazo_delivery/helpers/shared_pref/pref_helper.dart';
import 'package:fraazo_delivery/helpers/shared_pref/pref_keys.dart';
import 'package:fraazo_delivery/helpers/type_aliases/json.dart';
import 'package:fraazo_delivery/models/delivery/location.dart';
import 'package:fraazo_delivery/models/misc/id_name_list_model.dart';
import 'package:fraazo_delivery/models/misc/rider_login_hours_model.dart'
    as LoginData;
import 'package:fraazo_delivery/models/return_inventory/return_inventory_model.dart';
import 'package:fraazo_delivery/models/selfie_status/selfie_status_model.dart';
import 'package:fraazo_delivery/models/user/bank_details_model.dart';
import 'package:fraazo_delivery/models/user/basic_details.dart';
import 'package:fraazo_delivery/models/user/document_list_model.dart';
import 'package:fraazo_delivery/models/user/landing_page_model.dart';
import 'package:fraazo_delivery/models/user/profile/extra_user_details_model.dart';
import 'package:fraazo_delivery/models/user/profile/shift_time_model.dart';
import 'package:fraazo_delivery/models/user/profile/user_model.dart';
import 'package:fraazo_delivery/models/user/registration_list_model.dart';
import 'package:fraazo_delivery/models/user/service_details_model.dart';
import 'package:fraazo_delivery/models/user/stat_model.dart';
import 'package:fraazo_delivery/models/user/testimonial_model.dart';
import 'package:fraazo_delivery/models/user/training_list_model.dart';
import 'package:fraazo_delivery/utils/globals.dart';

import '../../../models/user/profile/performance_model.dart';

class UserService {
  static bool isAppURL = true;
  String? _selfieUrl;
  factory UserService({bool urlType = true}) {
    isAppURL = urlType;
    return _instance;
  }
  UserService._();
  static final UserService _instance = UserService._();

  final _apiCallHelper = ApiCallHelper();

  Future<UserModel?> getRider(String? deviceId, Map<String, String> location,
      Map<String, String> deviceModelNo,
      {String? deviceToken}) async {
    const String url = APIs.RIDER;

    final JsonMap queryParams = {
      if (deviceToken != null) "device_token": deviceToken,
      "app_version": Globals.appVersion,
      "app_build_number": Globals.appBuildNumber,
      "device_id": deviceId,
      "device_type": deviceModelNo['deviceName'],
      "current_area": location['current_area'],
      "current_city": location['current_city']
    };
    final response = await _apiCallHelper.get(url, queryParams: queryParams);
    return UserModel.fromJson(response);
  }

  Future getSelfieEnableStatus({String? deviceToken}) async {
    String url =
        '${APIs.RIDER}${APIs.SELFIE_ENABLED_STATUS}${Globals.user?.storeCode}';
    final response = await _apiCallHelper.get(url);
    Globals.isSelfieEnabled =
        (SelfieStatusModel.fromJson(response!).data?.selfieEnabled) ?? false;
  }

  Future postRiderLocation() async {
    const String url = APIs.RIDER + APIs.LOCATION;
    final Location riderLocation = await Globals.getAssignedLocation();
    final JsonMap body = {
      "latitude": riderLocation.latitude,
      "longitude": riderLocation.longitude,
      "delivery_task": PrefHelper.getInt(PrefKeys.CURRENT_TASK_ID)
    };
    final response = await _apiCallHelper.post(url, body: body);
    return response;
  }

  Future<JsonMap?> putRiderGoOnline(
      String riderStatus, String selfieUrl) async {
    const String url = APIs.RIDER + APIs.GO_ONLINE;
    final Location riderLocation = await Globals.getAssignedLocation();
    final JsonMap body = {
      "status": riderStatus,
      "latitude": riderLocation.latitude,
      "longitude": riderLocation.longitude,
      "selfie_url": selfieUrl,
    };
    final response = await _apiCallHelper.put(url, body: body);
    // Toast.normal(response?['message']);
    return response;
  }

  Future<JsonMap?> putGeoFencingValidation(String riderStatus) async {
    const String url = APIs.RIDER + APIs.PROXIMITY_VALIDATE;
    final Location riderLocation = await Globals.getAssignedLocation();
    final JsonMap body = {
      "status": riderStatus,
      "latitude": riderLocation.latitude,
      "longitude": riderLocation.longitude
    };
    final response = await _apiCallHelper.put(url, body: body);
    // Toast.normal(response?['message']);
    return response;
  }

  Future postRiderSelfie(String? filePath) async {
    const String selfie_url = APIs.RIDER + APIs.SELFIE;
    final fileName = filePath?.split("/").last;
    final fileMultipart = await MultipartFile.fromFile(
      filePath!,
      filename: fileName,
    );
    final FormData formData = FormData.fromMap({"image": fileMultipart});
    final response = await _apiCallHelper.post(selfie_url, body: formData);
    // _selfieUrl = response?['Data'];
    return response?['Data'];
  }

  Future getRiderLoginHours({String? startDate, String? endDate}) async {
    const String url = APIs.RIDER + APIs.LOGIN_HOURS;
    final JsonMap queryParams = {
      "start_date": startDate,
      "end_date": endDate,
    };
    final response = await _apiCallHelper.get(url, queryParams: queryParams);
    return LoginData.RiderLoginHoursModel.fromJson(response!);
  }

  Future<List<Document>?> getRiderDocument() async {
    const String url = APIs.RIDER + APIs.DOCUMENT;
    final response = await _apiCallHelper.get(url);
    return DocumentListModel.fromJson(response).data;
  }

  Future<StatModel> postGetOrderCount() async {
    const String url = APIs.TASK + APIs.GET_ORDER_COUNT;
    final JsonMap body = {"rider_id": Globals.user?.id};
    final response = await _apiCallHelper.post(url, body: body);
    return StatModel.fromJson(response);
  }

  Future postRiderDocument(String? filePath, String documentType) async {
    const String url = APIs.RIDER + APIs.DOCUMENT;

    final fileName = filePath?.split("/").last;
    final FormData formData = FormData.fromMap({
      "document": await MultipartFile.fromFile(
        filePath!,
        filename: fileName,
      ),
      "type": documentType
    });
    final response = await _apiCallHelper.post(url, body: formData);
    JsonMap? body = response;
    return body!['data']['link'];
  }

  Future<BankDetails> getRiderAccount() async {
    const String url = APIs.RIDER + APIs.ACCOUNT;
    final response = await _apiCallHelper.get(url);
    return BankDetailsModel.fromJson(response).data!;
  }

  Future<BankDetails> putRiderAccount(BankDetails bankDetails) async {
    const String url = APIs.RIDER + APIs.ACCOUNT;
    final JsonMap body = bankDetails.toBasicJson();
    final response = await _apiCallHelper.put(url, body: body);
    return BankDetailsModel.fromJson(response).data!;
  }

  Future<ExtraUserDetails> getRiderDetails() async {
    const String url = APIs.RIDER_DETAILS;
    final response = await _apiCallHelper.get(url);
    return ExtraUserDetailsModel.fromJson(response!).data!;
  }

  Future<ExtraUserDetails> putRiderDetails(
      ExtraUserDetails extraUserDetails) async {
    const String url = APIs.RIDER_DETAILS;
    final JsonMap body = extraUserDetails.toJson();
    final response = await _apiCallHelper.put(url, body: body);
    return ExtraUserDetailsModel.fromJson(response!).data!;
  }

  Future postPennyCheck() async {
    const String url = APIs.RIDER + APIs.ACCOUNT + APIs.PENNY_CHECK;
    final response = await _apiCallHelper.post(url);
    return response;
  }

  Future<List<IdName>> getVehicleType() async {
    const String url = APIs.DASHBOARD + APIs.RIDER + APIs.VEHICLE_TYPE;
    final response = await _apiCallHelper.get(url);
    return IdNameModel.fromJson(response!, keyName: "vehicle_type").idNameList;
  }

  Future<List<IdName>> getCities() async {
    const String url = APIs.ADMIN + APIs.CITIES;
    final response = await _apiCallHelper.get(url);
    return IdNameModel.fromJson(response!, keyName: "city").idNameList;
  }

  Future postCreatePassword(String password) async {
    const String url = APIs.RIDER + APIs.CREATE_PASSWORD;
    final JsonMap body = {"password": password};
    final response = await _apiCallHelper.post(url, body: body);
    return response;
  }

  Future<String> getSettlementCode() async {
    const String url = APIs.RIDER + APIs.SETTLEMENT_CODE;
    final response = await _apiCallHelper.get(url);
    return response?['settlement_code'] as String;
  }

  Future putAcceptTNC() async {
    const String url = APIs.RIDER__ACCEPT_TNC;
    final JsonMap body = {"accepted": true};
    final response = await _apiCallHelper.put(url, body: body);
    return response;
  }

  Future<List<IdName>?> getBankList() async {
    const String url = APIs.BANKLIST;
    final response = await _apiCallHelper.get(url);
    return IdNameModel.fromJson(response!, keyName: "bank_name").idNameList;
  }

  Future<List<IdName>?> getRelationList() async {
    const String url = APIs.RIDER + APIs.RELATIONLIST;
    final response = await _apiCallHelper.get(url);
    return IdNameModel.fromJson(response!, keyName: "relation").idNameList;
  }

  Future<List<IdName>?> getAvatarList(String avatarType) async {
    const String url = APIs.RIDER + APIs.AVATAR;
    final response = await _apiCallHelper.get('$url$avatarType');
    return IdNameModel.fromJson(response!, keyName: "image_url").idNameList;
  }

  Future<BasicDetails> getBasicDetails() async {
    const String url = APIs.RIDER + APIs.DEATILS;
    final response = await _apiCallHelper.get(url);
    return BasicDetails.fromJson(response!);
  }

  Future saveBasicInfo(Data basicDetails) async {
    const String url = APIs.RIDER + APIs.BASIC_INFO_INSERT;
    // final Map<String, dynamic> body = serviceDetailData;
    final response =
        await _apiCallHelper.post(url, body: basicDetails.toJson());
    return response;
  }

  Future<List<ShiftTime>?> getShiftTime() async {
    const String url = APIs.RIDER__SHIFT_TIME;
    final response = await _apiCallHelper.get(url);
    return ShiftTimeModel.fromJson(response!).shiftTimeList;
  }

  Future posttServiceDetails(
    Map<String, dynamic> serviceDetailData,
  ) async {
    const String url = APIs.RIDER__DETAILS__INSERTION;
    final Map<String, dynamic> body = serviceDetailData;
    final response = await _apiCallHelper.post(url, body: body);
    return response;
  }

  Future<ServiceDetailModel> getServiceDetails() async {
    const String url = APIs.RIDER__DETAILS__GET;
    final response = await _apiCallHelper.get(url);
    return ServiceDetailModel.fromJson(response!);
  }

  Future<TrainingListModel> getTraining() async {
    const String url = APIs.RIDER__APPDISPLAY__TRAINING;
    final response = await _apiCallHelper.get(url);
    return TrainingListModel.fromJson(response!);
  }

  Future<TestimonialModel> getTestimonial() async {
    const String url = APIs.GET_TESTIMONIAL;
    final response = await _apiCallHelper.get(url);
    return TestimonialModel.fromJson(response);
  }

  Future<LandingPageModel> getLandingPageInfo() async {
    const String url = APIs.RIDER + APIs.GET_LANDING_PAGE_INFO;
    final response = await _apiCallHelper.get(url);
    return LandingPageModel.fromJson(response);
  }

  Future<ReturnInventoryModel> getReturnInventory() async {
    const String url = APIs.RIDER__TASK__ORDER;
    final Map<String, dynamic>? response = await _apiCallHelper.get(url);
    return ReturnInventoryModel.fromJson(response!);
  }

  Future<PerformanceModel> getRiderPerformance(String date) async {
    const String url = APIs.RIDER__PERFORMANCE;
    final Map<String, dynamic> queryParams = {
      "date": date,
    };
    final response = await _apiCallHelper.get(url, queryParams: queryParams);
    return PerformanceModel.fromJson(response!);
  }

  Future<RegistrationListModel> getRegistrationList() async {
    const String url = APIs.RIDER__APP__FLAGS;
    final response = await _apiCallHelper.get(url);
    return RegistrationListModel.fromJson(response!);
  }
}
