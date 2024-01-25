import 'dart:async';

import 'package:dio/dio.dart';
import 'package:fraazo_delivery/helpers/api/api_call_helper.dart';
import 'package:fraazo_delivery/helpers/api/apis.dart';
import 'package:fraazo_delivery/helpers/shared_pref/pref_helper.dart';
import 'package:fraazo_delivery/helpers/shared_pref/pref_keys.dart';
import 'package:fraazo_delivery/models/delivery/day_wise_earning_model.dart';
import 'package:fraazo_delivery/models/delivery/delivery_history_model.dart';
import 'package:fraazo_delivery/models/delivery/delivery_items_model.dart';
import 'package:fraazo_delivery/models/delivery/earning_model.dart';
import 'package:fraazo_delivery/models/delivery/generate_qr_model.dart';
import 'package:fraazo_delivery/models/delivery/location.dart';
import 'package:fraazo_delivery/models/delivery/pay_plan_model.dart';
import 'package:fraazo_delivery/models/delivery/task_model.dart';
import 'package:fraazo_delivery/utils/constants.dart';
import 'package:fraazo_delivery/utils/globals.dart';

import '../../../models/misc/AppMappingModel.dart';

class DeliveryService {
  factory DeliveryService() {
    return _instance;
  }
  DeliveryService._();
  static final DeliveryService _instance = DeliveryService._();

  final _apiCallHelper = ApiCallHelper();

  final Map<String, CancelToken> _cancelTokenList = {};

  Future<Task?> getGetLatestTask() async {
    const String url = APIs.RIDER + APIs.GET_LATEST_TASK;
    final Map<String, dynamic> body = {"rider_id": Globals.user?.id};
    final Map<String, dynamic>? response =
        await _apiCallHelper.post(url, body: body);
    return TaskModel.fromJson(response).task;
  }

  Future<Task?> putTaskUpdate(int? taskId, String taskStatus) async {
    const String url = APIs.TASK + APIs.UPDATE;
    final Location riderLocation = await Globals.getAssignedLocation();
    final Map<String, dynamic> body = {
      "id": taskId,
      "status": taskStatus,
      "rider_id": Globals.user?.id,
      "lat": riderLocation.latitude,
      "lng": riderLocation.longitude
    };
    final response = await _apiCallHelper.put(url, body: body);
    return TaskModel.fromJson(response).task;
  }

  Future<OrderSeq> putOrderUpdate(
    String orderStatus,
    int? orderId, {
    double? customerLat,
    double? customerLng,
    String? deliveredTo,
    String? deliveryOTP,
  }) async {
    const String url = APIs.ORDER + APIs.UPDATE;
    final Location riderLocation = await Globals.getAssignedLocation();
    final Map<String, dynamic> body = {
      "id": orderId,
      "order_status": orderStatus,
      "lat": customerLat,
      "lng": customerLng,
      if (PrefHelper.getBool(PrefKeys.IS_TEMP_RIDER_LOCATION)) ...{
        "rider_lat": customerLat,
        "rider_lng": customerLng,
      } else ...{
        "rider_lat": riderLocation.latitude,
        "rider_lng": riderLocation.longitude,
      },
      if (orderStatus == Constants.OS_DELIVERED ||
          orderStatus == Constants.OS_CUSTOMER_NOT_AVAILABLE) ...{
        "delivered_to": deliveredTo,
        "delivery_otp": deliveryOTP ?? "",
      }
    };
    final response = await _apiCallHelper.put(url, body: body);
    return OrderSeq.fromJson(response!['data']);
  }

  Future<DeliveryHistory?> postGetTaskHistory(String from, String to,
      {String orderNumber = "", String taskId = ""}) async {
    const String url = APIs.TASK + APIs.GET_TASK_HISTORY;
    final Map<String, dynamic> body = {
      "rider_id": Globals.user?.id,
      "from": (orderNumber.isNotEmpty && taskId.isNotEmpty) ? '' : from,
      "to": (orderNumber.isNotEmpty && taskId.isNotEmpty) ? '' : to,
      "task_id": taskId,
      "order_number": orderNumber
    };
    final cancelToken = CancelToken();
    _cancelTokenList.putIfAbsent("DeliveryHistoryProvider", () => cancelToken);
    final Map<String, dynamic>? response =
        await _apiCallHelper.post(url, body: body, cancelToken: cancelToken);
    return DeliveryHistoryModel.fromJson(response).data;
  }

  Future<EarningModel> getEarningList(
      {int pageNo = 1, String? fromDate, String? toDate}) async {
    const String url = APIs.RIDER + APIs.EARNING__LIST;
    final Map<String, dynamic> queryParams = {
      "page": pageNo,
      "from_date": fromDate,
      "to_date": toDate,
    };
    final cancelToken = CancelToken();
    _cancelTokenList.putIfAbsent("EarningsProvider", () => cancelToken);
    final Map<String, dynamic>? response = await _apiCallHelper.get(url,
        queryParams: queryParams, cancelToken: cancelToken);
    return EarningModel.fromJson(response!);
  }

  Future postOrderImage(String? filePath, int? orderId) async {
    const String url = APIs.ORDER + APIs.IMAGE;
    final Location riderLocation = await Globals.getAssignedLocation();
    final fileName = filePath?.split("/").last;
    final FormData formData = FormData.fromMap({
      "document": await MultipartFile.fromFile(
        filePath!,
        filename: fileName,
      ),
      "order_id": orderId,
      "lat": riderLocation.latitude,
      "lng": riderLocation.longitude
    });
    final response = await _apiCallHelper.post(url, body: formData);
    return response;
  }

  Future callToCustomer(String? deliveryNumber) async {
    const String url = Constants.isProduction
        ? "https://api.fraazo.com/admin_dashboard/v1/fraazo_delivery_app/call_to_customer"
        : "https://api.staging.fraazo.com/admin_dashboard/v1/fraazo_delivery_app/call_to_customer";

    final Map<String, dynamic> body = {"delivery_number": deliveryNumber};
    final response =
        await _apiCallHelper.apiRequestCall("PUT", url, body: body);
    return response;
  }

  Future postDeliveryImage(String? filePath, int? orderId) async {
    const String url = APIs.DELIVERY + APIs.IMAGE;
    final fileName = filePath?.split("/").last;
    final FormData formData = FormData.fromMap({
      "document": await MultipartFile.fromFile(
        filePath!,
        filename: fileName,
      ),
      "order_id": orderId,
    });
    final response = await _apiCallHelper.post(url, body: formData);
    return response;
  }

  Future postDeliveryAmount({
    required num collectedAmount,
    required String orderNumber,
    required OrderItems orderItemList,
    bool isOther = false,
    String comment = "",
  }) async {
    const String url = APIs.DELIVERY + APIs.AMOUNT;

    final List<Map<String, dynamic>> itemList = [];
    for (final lineItem in orderItemList.lineItems) {
      itemList.add({
        ...lineItem.toJson(),
        "order_number": orderNumber,
        "other": isOther,
        "comment": comment,
      });
    }
    final Map<String, dynamic> body = {
      "collected_amount": collectedAmount,
      "items": itemList,
    };
    return _apiCallHelper.post(url, body: body);
  }

  Future postDeliverySMS(String? customerMobileNo, int? orderId) async {
    const String url = APIs.ORDER + APIs.DELIVERY_SMS;
    final Location riderLocation = await Globals.getAssignedLocation();
    final Map<String, dynamic> body = {
      "mobile": customerMobileNo,
      "order_id": orderId,
      "lat": riderLocation.latitude,
      "lng": riderLocation.longitude,
    };
    return _apiCallHelper.post(url, body: body);
  }

  Future<OrderItems> postOrderItems(int? orderId) async {
    const String url = APIs.ORDER + APIs.ITEMS;
    final Location riderLocation = await Globals.getAssignedLocation();
    final Map<String, dynamic> body = {
      "order_id": orderId,
      "lat": riderLocation.latitude,
      "lng": riderLocation.longitude,
    };
    final response = await _apiCallHelper.post(url, body: body);
    return OrderItemsModel.fromJson(response!).data!;
  }

  Future<List<DayEarning>> getDailyBills(int earningId) async {
    final String url = "${APIs.DAILY__BILLS}${"?weekly_bill_id=$earningId"}";
    final cancelToken = CancelToken();
    _cancelTokenList.putIfAbsent("DayWiseEarningProvider", () => cancelToken);
    final Map<String, dynamic>? response =
        await _apiCallHelper.get(url, cancelToken: cancelToken);
    return DayEarningModel.fromJson(response!).dayEarningList;
  }

  Future postAssignTaskQR(int orderID) {
    const String url = APIs.RIDER + APIs.ASSIGN_TASK_QR;
    final Map<String, dynamic> body = {"order_id": orderID};
    return _apiCallHelper.post(url, body: body);
  }

  Future<GenerateQRModel> postPaymentQRGenerate(
      {String? orderNumber, int? taskID, num? amount}) async {
    const String url = APIs.PAYMENT__QR_GENERATE;
    final Map<String, dynamic> body = {
      "order_number": orderNumber,
      "task_id": taskID,
      "amount": amount
    };
    final Map<String, dynamic>? response =
        await _apiCallHelper.post(url, body: body);
    return GenerateQRModel.fromJson(response!);
  }

  Future<bool> postQRPaymentVerify(int currentTaskID) async {
    const String url = APIs.QR__PAYMENT_VERIFY;
    final Map<String, dynamic> body = {
      "task_id": currentTaskID,
    };
    final Map<String, dynamic>? response =
        await _apiCallHelper.post(url, body: body);
    return response!['data']['payment_done'];
  }

  Future<Map<String, dynamic>> createZendeskTicket(
      int currentTaskID, String orderNo, num? amount) async {
    const String url = APIs.ZENDESK_TICKET;
    final Map<String, dynamic> body = {
      "task_id": currentTaskID,
      "order_number": orderNo,
      "amount": amount
    };
    final Map<String, dynamic>? response =
        await _apiCallHelper.post(url, body: body);
    return response!;
  }

  Future getStatusChangeApproaching() async {
    final String url =
        "${APIs.RIDER__STATUS_CHANGE__APPROACHING}?id=${Globals.user?.id}";
    final Location riderLocation = await Globals.getAssignedLocation();
    final Map<String, dynamic> body = {
      "latitude": riderLocation.latitude,
      "longitude": riderLocation.longitude,
    };
    return _apiCallHelper.put(url, body: body);
  }

  void cancelToken(String keyName) {
    _cancelTokenList[keyName]?.cancel();
    _cancelTokenList.remove(keyName);
  }

  Future<AppMappingModel> getAppMappingData() async {
    const String url = APIs.APP + APIs.MAPPING;
    final response = await _apiCallHelper.get(url);
    return AppMappingModel.fromJson(response);
  }

  Future<PayPlanModel?> getPayPlan() async {
    const String url = APIs.RIDER__PAYPLAN;
    final Map<String, dynamic> body = {"rider_id": Globals.user?.id};
    final Map<String, dynamic>? response =
        await _apiCallHelper.get(url, queryParams: body);
    return PayPlanModel.fromJson(response!);
  }
}
