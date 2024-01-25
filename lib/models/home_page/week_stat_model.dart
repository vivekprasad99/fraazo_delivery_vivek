class WeekModel {
  bool? success;
  WeekData? data;
  Meta? meta;

  WeekModel({this.success, this.data, this.meta});

  WeekModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    if (json.containsKey('data')) {
      if (json['data'] != null) {
        json['data'].forEach((v) {
          data = WeekData.fromJson(v);
        });
      }
    }
    meta = json['meta'] != null ? Meta.fromJson(json['meta']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['success'] = success;
    if (this.data != null) {
      data['data'] = this.data;
    }
    if (meta != null) {
      data['meta'] = meta!.toJson();
    }
    return data;
  }
}

class WeekData {
  int? id;
  int? riderId;
  String? riderName;
  String? storeCode;
  int? partnerId;
  int? billId;
  String? partnerName;
  String? startDate;
  String? endDate;
  String? status;
  int? statusId;
  num? totalAmount;
  num? totalDistance;
  num? totalTimelyIncentive;
  num? totalFixedCost;
  num? totalMgBonus;
  num? dailyBonusOrderLevel;
  num? weeklyBonusOrderLevel;
  num? totalOrders;
  num? loggedInHours;
  num? loggedInIncentive;
  num? totalDistanceEarning;
  String? updatedBy;
  String? createdAt;
  String? updatedAt;
  num? bannerIncentive;

  WeekData(
      {this.id,
      this.riderId,
      this.riderName,
      this.storeCode,
      this.partnerId,
      this.billId,
      this.partnerName,
      this.startDate,
      this.endDate,
      this.status,
      this.statusId,
      this.totalAmount,
      this.totalTimelyIncentive,
      this.totalDistance,
      this.totalFixedCost,
      this.totalMgBonus,
      this.dailyBonusOrderLevel,
      this.weeklyBonusOrderLevel,
      this.totalOrders,
      this.loggedInHours,
      this.loggedInIncentive,
      this.totalDistanceEarning,
      this.updatedBy,
      this.createdAt,
      this.updatedAt,
      this.bannerIncentive});

  WeekData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    riderId = json['rider_id'];
    riderName = json['rider_name'];
    storeCode = json['store_code'];
    partnerId = json['partner_id'];
    billId = json['bill_id'];
    partnerName = json['partner_name'];
    startDate = json['start_date'];
    endDate = json['end_date'];
    status = json['status'];
    statusId = json['status_id'];
    totalAmount = json['total_amount'];
    totalTimelyIncentive = json['total_timely_incentive'];
    totalDistance = json['total_distance'];
    totalFixedCost = json['total_fixed_cost'];
    totalMgBonus = json['total_mg_bonus'];
    dailyBonusOrderLevel = json['daily_bonus_order_level'];
    weeklyBonusOrderLevel = json['weekly_bonus_order_level'];
    totalOrders = json['total_orders'];
    loggedInHours = json['logged_in_hours'];
    loggedInIncentive = json['loggedin_incentive'];
    totalDistanceEarning = json['total_distance_earning'];
    updatedBy = json['updated_by'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    bannerIncentive = json['banner_incentive'] ?? 0;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['rider_id'] = riderId;
    data['rider_name'] = riderName;
    data['store_code'] = storeCode;
    data['partner_id'] = partnerId;
    data['bill_id'] = billId;
    data['partner_name'] = partnerName;
    data['start_date'] = startDate;
    data['end_date'] = endDate;
    data['status'] = status;
    data['status_id'] = statusId;
    data['total_amount'] = totalAmount;
    data['total_timely_incentive'] = totalTimelyIncentive;
    data['total_distance'] = totalDistance;
    data['total_fixed_cost'] = totalFixedCost;
    data['total_mg_bonus'] = totalMgBonus;
    data['daily_bonus_order_level'] = dailyBonusOrderLevel;
    data['weekly_bonus_order_level'] = weeklyBonusOrderLevel;
    data['total_orders'] = totalOrders;
    data['logged_in_hours'] = loggedInHours;
    data['loggedin_incentive'] = loggedInIncentive;
    data['total_distance_earning'] = totalDistanceEarning;
    data['updated_by'] = updatedBy;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    data['banner_incentive'] = bannerIncentive;
    return data;
  }
}

class Meta {
  int? currentPage;
  int? totalPages;
  int? totalDataCount;

  Meta({this.currentPage, this.totalPages, this.totalDataCount});

  Meta.fromJson(Map<String, dynamic> json) {
    currentPage = json['current_page'];
    totalPages = json['total_pages'];
    totalDataCount = json['total_data_count'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['current_page'] = currentPage;
    data['total_pages'] = totalPages;
    data['total_data_count'] = totalDataCount;
    return data;
  }
}
