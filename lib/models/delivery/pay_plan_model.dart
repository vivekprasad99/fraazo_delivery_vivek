class PayPlanModel {
  bool? success;
  PayPlan? data;
  MetaPayPlan? meta;

  PayPlanModel({this.success, this.data, this.meta});

  PayPlanModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    data = json['data'] != null ? PayPlan.fromJson(json['data']) : null;
    meta = json['meta'] != null ? MetaPayPlan.fromJson(json['meta']) : null;
  }
}

class PayPlan {
  String? headingTittle1;
  String? headingTittle2;
  int? perOrderPay;
  int? fuelChargesAfter5kmsExtra;
  int? shiftLoginPay;
  List<ObjList>? objList;

  PayPlan(
      {this.headingTittle1,
      this.headingTittle2,
      this.perOrderPay,
      this.fuelChargesAfter5kmsExtra,
      this.shiftLoginPay,
      this.objList});

  PayPlan.fromJson(Map<String, dynamic> json) {
    headingTittle1 = json['heading_tittle_1'];
    headingTittle2 = json['heading_tittle_2'];
    perOrderPay = json['Per Order Pay'];
    fuelChargesAfter5kmsExtra = json['Fuel Charges(After 5kms Extra)'];
    shiftLoginPay = json['Shift login Pay'];
    if (json['obj_list'] != null) {
      objList = [];
      json['obj_list'].forEach((v) {
        objList!.add(ObjList.fromJson(v));
      });
    }
  }
}

class ObjList {
  String? orderThreshold;
  int? rate;

  ObjList({this.orderThreshold, this.rate});

  ObjList.fromJson(Map<String, dynamic> json) {
    orderThreshold = json['order_threshold'];
    rate = json['rate'];
  }
}

class MetaPayPlan {
  int? currentPage;
  int? totalPages;
  int? totalDataCount;

  MetaPayPlan({this.currentPage, this.totalPages, this.totalDataCount});

  MetaPayPlan.fromJson(Map<String, dynamic> json) {
    currentPage = json['current_page'];
    totalPages = json['total_pages'];
    totalDataCount = json['total_data_count'];
  }
}
