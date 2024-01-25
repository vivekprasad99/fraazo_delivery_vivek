import 'package:fraazo_delivery/helpers/date/date_formatter.dart';

class DayEarningModel {
  List<DayEarning> dayEarningList = [];

  DayEarningModel.fromJson(Map<String, dynamic> json) {
    if (json['data'] != null) {
      json['data'].forEach((v) {
        dayEarningList.add(DayEarning.fromJson(v));
      });
    }
  }
}

class DayEarning {
  int? id;
  String? storeCode;
  int? statusId;
  num? totalAmount;
  num? totalIncentive;
  num? totalDistance;
  num? totalFixedCost;
  int? totalOrders;
  num? loggedInHours;
  num? mgBonus;
  num? totalDistanceEarning;
  String? createdAt;
  String? createdAtParsed;
  String? updatedAt;

  DayEarning(
      {this.id,
      this.storeCode,
      this.statusId,
      this.totalAmount,
      this.totalIncentive,
      this.totalDistance,
      this.totalFixedCost,
      this.totalOrders,
      this.loggedInHours,
      this.mgBonus,
      this.totalDistanceEarning,
      this.createdAt,
      this.updatedAt});

  DayEarning.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    storeCode = json['store_code'];
    statusId = json['status_id'];
    totalAmount = json['total_amount'];
    totalIncentive = json['total_incentive'];
    totalDistance = json['total_distance'];
    totalFixedCost = json['total_fixed_cost'];
    totalOrders = json['total_orders'];
    loggedInHours = json['logged_in_hours'];
    mgBonus = json['mg_bonus'];
    totalDistanceEarning = json['total_distance_earning'];
    createdAt = json['created_at'];
    createdAtParsed = DateFormatter().parseDateTimeYMDHM(createdAt)['date'];
    updatedAt = json['updated_at'];
  }
}
