import 'package:fraazo_delivery/helpers/date/date_formatter.dart';
import 'package:fraazo_delivery/models/common/meta.dart';

class EarningModel {
  List<Earning>? data;
  Meta? meta;
  bool? success;

  EarningModel({this.data, this.meta, this.success});

  EarningModel.fromJson(Map<String, dynamic> json) {
    if (json['data'] != null) {
      data = [];
      json['data'].forEach((v) {
        data?.add(Earning.fromJson(v));
      });
    }
    meta = json['meta'] != null ? Meta.fromJson(json['meta']) : null;
    success = json['success'];
  }
}

class Earning {
  int? id;
  int? riderId;
  String? storeCode;
  int? partnerId;
  String? startDate;
  String? startDateFormatted;
  String? startDateInDMY;
  String? endDate;
  String? endDateFormatted;
  String? endDateInDMY;
  int? statusId;
  String? status;
  num? totalAmount;
  num? totalIncentive;
  num? totalDistance;
  num? totalFixedCost;
  num? totalMgBonus;
  num? weeklyBonusOrderLevel;
  num? loggedInHours;
  num? loggedinIncentive;
  int? totalOrders;
  num? totalDistanceEarning;
  String? updatedBy;
  List<EarningsRevamp>? earningsRevamp;

  Earning(
      {this.id,
      this.riderId,
      this.storeCode,
      this.partnerId,
      this.startDate,
      this.endDate,
      this.statusId,
      this.status,
      this.totalAmount,
      this.totalIncentive,
      this.totalDistance,
      this.totalFixedCost,
      this.totalOrders,
      this.totalDistanceEarning,
      this.updatedBy,
      this.earningsRevamp});

  Earning.fromJson(Map<String, dynamic> json) {
    final dateTimeFormatter = DateFormatter();
    id = json['id'];
    riderId = json['rider_id'];
    storeCode = json['store_code'];
    partnerId = json['partner_id'];
    startDate = json['start_date'];
    startDateFormatted =
        dateTimeFormatter.parseDateTimeYMDHM(startDate)['date'];
    startDateInDMY = dateTimeFormatter.parseDateToDMY(startDate);
    endDate = json['end_date'];
    endDateFormatted = dateTimeFormatter.parseDateTimeYMDHM(endDate)['date'];
    endDateInDMY = dateTimeFormatter.parseDateToDMY(endDate);

    statusId = json['status_id'];
    status = json['status'];
    totalAmount = json['total_amount'];
    totalIncentive = json['total_incentive'];
    totalDistance = json['total_distance'];
    totalFixedCost = json['total_fixed_cost'];
    totalMgBonus = json['total_mg_bonus'];
    weeklyBonusOrderLevel = json['weekly_bonus_order_level'];
    loggedInHours = json['logged_in_hours'];
    loggedinIncentive = json['loggedin_incentive'];
    totalOrders = json['total_orders'];
    totalDistanceEarning = json['total_distance_earning'];
    updatedBy = json['updated_by'];
    if (json['earnings_revamp'] != null) {
      earningsRevamp = [];
      json['earnings_revamp'].forEach((v) {
        earningsRevamp!.add(EarningsRevamp.fromJson(v));
      });
    }
  }
}

class EarningsRevamp {
  String? title;
  num? value;
  String? subValue;
  String? icon;

  EarningsRevamp({this.title, this.value, this.subValue, this.icon});

  EarningsRevamp.fromJson(Map<String, dynamic> json) {
    title = json['title'];
    value = json['value'];
    subValue = json['sub_value'];
    icon = json['icon'];
  }
}
