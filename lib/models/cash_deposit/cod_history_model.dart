class CodHistoryModel {
  bool? success;
  String? message;
  num? amount;
  num? limit;
  String? referenceId;
  List<CodHistory> codHistoryList = [];

  CodHistoryModel(
      {this.success,
      this.message,
      this.amount,
      this.limit,
      this.referenceId,
      required this.codHistoryList});

  CodHistoryModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    message = json['message'];
    amount = json['amount'];
    limit = json['limit'];
    referenceId = json['reference_id'];
    if (json['data'] != null) {
      json['data'].forEach((v) {
        codHistoryList.add(CodHistory.fromJson(v));
      });
    }
  }
}

class CodHistory {
  int? id;
  int? riderId;
  String? riderName;
  String? storeCode;
  int? orderCount;
  List<String>? orderNumbers;
  int? amountCollected;
  String? status;
  String? settlementCode;
  String? acceptedBy;
  String? createdAt;

  CodHistory(
      {this.id,
      this.riderId,
      this.riderName,
      this.storeCode,
      this.orderCount,
      this.orderNumbers,
      this.amountCollected,
      this.status,
      this.settlementCode,
      this.acceptedBy,
      this.createdAt});

  CodHistory.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    riderId = json['rider_id'];
    riderName = json['rider_name'];
    storeCode = json['store_code'];
    orderCount = json['order_count'];
    orderNumbers = json['order_numbers'].cast<String>();
    amountCollected = json['amount_collected'];
    status = json['status'];
    settlementCode = json['settlement_code'];
    acceptedBy = json['accepted_by'];
    createdAt = json['created_at'];
  }
}
