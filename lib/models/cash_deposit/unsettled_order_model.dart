class UnsettledOrderModel {
  late num amount;
  late num limit;
  List<UnsettledOrder> unsettledOrderList = [];

  UnsettledOrderModel({required this.unsettledOrderList});

  UnsettledOrderModel.fromJson(Map<String, dynamic> json) {
    if (json['data'] != null) {
      json['data'].forEach((v) {
        unsettledOrderList.add(UnsettledOrder.fromJson(v));
      });
    }
    amount = json['amount'] ?? 0;
    limit = json['limit'] ?? 0;
  }
}

class UnsettledOrder {
  int? id;
  int? riderId;
  int? riderCashLedgerId;
  String? riderName;
  String? storeCode;
  String? status;
  String? orderNumbers;
  num? amountCollected;
  String? createdAt;
  String? updatedAt;
  String? updatedBy;
  String? chalanReciept;
  bool? dispute;
  num? chalanRecieptAmount;
  num? deficitAmount;

  UnsettledOrder(
      {this.id,
      this.riderId,
      this.riderCashLedgerId,
      this.riderName,
      this.storeCode,
      this.status,
      this.orderNumbers,
      this.amountCollected,
      this.createdAt,
      this.updatedAt,
      this.updatedBy,
      this.chalanReciept,
      this.dispute,
      this.chalanRecieptAmount,
      this.deficitAmount});

  UnsettledOrder.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    riderId = json['rider_id'];
    riderCashLedgerId = json['rider_cash_ledger_id'];
    riderName = json['rider_name'];
    storeCode = json['store_code'];
    status = json['status'];
    orderNumbers = json['order_numbers'];
    amountCollected = json['amount_collected'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    updatedBy = json['updated_by'];
    chalanReciept = json['chalan_reciept'];
    dispute = json['dispute'];
    chalanRecieptAmount = json['chalan_reciept_amount'];
    deficitAmount = json['deficit_amount'];
  }
}
