import 'package:fraazo_delivery/helpers/date/date_formatter.dart';
import 'package:fraazo_delivery/helpers/extensions/num_extension.dart';
import 'package:fraazo_delivery/utils/globals.dart';

class TaskModel {
  bool? success;
  String? message;
  Task? task;

  TaskModel({this.success, this.message, this.task});

  TaskModel.fromJson(Map<String, dynamic>? json) {
    success = json?['success'];
    message = json?['message'];
    task = json?['data'] != null ? Task.fromJson(json?['data']) : null;
  }
}

class Task {
  String? type;
  int? id;
  int? taskId;
  String? createdAt;
  String? updatedAt;
  String? updatedAtFormatted;
  int? riderId;
  String? status;
  int? eta;
  List<OrderSeq>? orderSeq;
  StoreInfo? storeInfo;
  int? expiresIn;
  Earning? earning;
  num? dkToFirstOrder;
  num? lastOrderToDk;
  num? totalTripDistance;
  num? totalTripAmount;
  bool? alertFlag;
  int? statusColorCode;
  Task(
      {this.type,
      this.id,
      this.createdAt,
      this.updatedAt,
      this.riderId,
      this.status,
      this.eta,
      this.orderSeq,
      this.storeInfo,
      this.expiresIn,
      this.dkToFirstOrder,
      this.lastOrderToDk,
      this.totalTripDistance,
      this.totalTripAmount,
      this.alertFlag,
      this.statusColorCode});

  Task.fromJson(Map<String, dynamic> json) {
    type = json['type'];
    id = json['id'];
    taskId = json['task_id'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    alertFlag = json['alert_flag'] ?? false;
    final dateTimeFormatted = DateFormatter().parseDateTimeYMDHM(updatedAt);
    updatedAtFormatted =
        "${dateTimeFormatted['date']} ${dateTimeFormatted['time']}";
    riderId = json['rider_id'];
    status = json['status'];
    eta = json['eta'];
    if (json['order_seq'] != null) {
      orderSeq = <OrderSeq>[];
      json['order_seq'].forEach((v) {
        orderSeq!.add(OrderSeq.fromJson(v));
      });
    }
    storeInfo = json['store_info'] != null
        ? StoreInfo.fromJson(json['store_info'])
        : null;
    expiresIn = json['expires_in'] ?? 0;

    earning =
        json['earning'] != null ? Earning.fromJson(json['earning']) : null;
    dkToFirstOrder = json['dk_to_firstorder'] ?? 0;
    lastOrderToDk = json['lastorder_to_dk'] ?? 0;
    totalTripDistance = json['total_trip_distance'] ?? 0;
    totalTripAmount = json['total_trip_amount'] ?? 0;
    statusColorCode = json['status_color_code'] ?? 0;
  }
}

class OrderSeq {
  String? type;
  int? id;
  int? taskId;
  String? orderNumber;
  double? lat;
  double? lng;
  int? rating;
  String? mobile;
  String? address;
  int? rank;
  String? orderStatus;
  String? custName;
  late bool isCod;
  num? amount;
  String? amountTruncated;
  String? details;
  late num zendeskTicketId;
  num? darkstoreDistance;
  bool? callEnabled;
  bool? supportEnabled;
  String? invoiceNumber;
  String? etaDelivery;
  String? updatedAt;
  num? etaInSeconds;
  OrderSeq(
      {this.type,
      this.id,
      this.taskId,
      this.orderNumber,
      this.lat,
      this.lng,
      this.rating,
      this.mobile,
      this.address,
      this.rank,
      this.orderStatus,
      this.custName,
      this.isCod = false,
      this.amount,
      this.details,
      this.darkstoreDistance,
      this.callEnabled,
      this.invoiceNumber,
      this.etaDelivery,
      this.updatedAt,
      this.supportEnabled,
      this.etaInSeconds});

  OrderSeq.fromJson(Map<String, dynamic> json) {
    type = json['type'];
    id = json['id'];
    taskId = json['task_id'];
    orderNumber = json['order_number'];
    lat = json['lat'].toDouble();
    lng = json['lng'].toDouble();
    rating = json['rating'];
    mobile = json['mobile'];
    address = json['address'];
    rank = json['rank'];
    orderStatus = json['order_status'];
    custName = json['cust_name'];
    isCod = json['is_cod'] ?? false;
    amount = json['amount'].toDouble();
    etaInSeconds = json['eta_in_seconds'] ?? 0;
    amountTruncated = amount?.trimTo2Digits();
    details = json['details'];
    darkstoreDistance = json['darkstore_distance'].toDouble();
    zendeskTicketId = json['zendesk_ticket_id'] ?? 0;
    callEnabled = json['call_enabled'] ?? false;
    invoiceNumber = json['invoice_number'] ?? '';
    etaDelivery = json['eta_delivery'] ?? '';
    updatedAt = json['updated_at'] ?? '';
    supportEnabled = json['support_enabled'] ?? false;
    Globals.isSupportEnable = supportEnabled!;
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['order_status'] = orderStatus;
    _data['order_number'] = orderNumber;
    _data['support_enabled'] = supportEnabled;
    _data['call_enabled'] = callEnabled;
    return _data;
  }
}

class StoreInfo {
  int? storeId;
  String? storeName;
  double? storeLat;
  double? storeLng;
  String? storeCode;

  StoreInfo(
      {this.storeId,
      this.storeName,
      this.storeLat,
      this.storeLng,
      this.storeCode});

  StoreInfo.fromJson(Map<String, dynamic> json) {
    storeId = json['store_id'];
    storeName = json['store_name'];
    storeLat = json['store_lat'].toDouble();
    storeLng = json['store_lng'].toDouble();
    storeCode = json['store_code'];
  }
}

class Earning {
  num? total;
  num? incentive;
  num? distance;
  num? fixed;
  num? perKmPrice;

  Earning(
      {this.total, this.incentive, this.distance, this.fixed, this.perKmPrice});

  Earning.fromJson(Map<String, dynamic> json) {
    total = json['total'];
    incentive = json['incentive'];
    distance = json['distance'];
    fixed = json['fixed'];
    perKmPrice = json['per_km_price'];
  }
}

class Task1 {
  String? type;
  int? id;
  int? taskId;
  String? createdAt;
  String? updatedAt;
  String? updatedAtFormatted;
  int? riderId;
  String? status;
  int? eta;
  List<OrderSeq>? orderSeq;
  StoreInfo? storeInfo;
  int? expiresIn;
  Earning? earning;
  num? dkToFirstOrder;
  num? lastOrderToDk;
  num? totalTripDistance;
  num? totalTripAmount;
  bool? alertFlag;
  int? statusColorCode;

  Task1(
      {this.type,
      this.id,
      this.createdAt,
      this.updatedAt,
      this.riderId,
      this.status,
      this.eta,
      this.orderSeq,
      this.storeInfo,
      this.expiresIn,
      this.dkToFirstOrder,
      this.lastOrderToDk,
      this.totalTripDistance,
      this.totalTripAmount,
      this.alertFlag,
      this.statusColorCode});

  Task1.fromJson(Map<String, dynamic> json) {
    if (json["data"] != null) {
      orderSeq = <OrderSeq>[];
      json["data"].forEach((v) {
        OrderSeq.fromJson(v);
      });
    }
  }
}
