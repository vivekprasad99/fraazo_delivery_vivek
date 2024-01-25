class TransactionModel {
  Transaction? transaction;

  TransactionModel({this.transaction});

  TransactionModel.fromJson(Map<String, dynamic> json) {
    transaction =
        json['data'] != null ? Transaction.fromJson(json['data']) : null;
  }
}

class Transaction {
  int? id;
  int? riderId;
  String? paymentId;
  String? razorPayOrderId;
  List<String>? orderNumbers;
  String? paymentSignature;
  String? status;
  num? amount;
  String? createdAt;
  String? updatedAt;
  RazorPayInfo? razorPayInfo;

  Transaction(
      {this.id,
      this.riderId,
      this.paymentId,
      this.razorPayOrderId,
      this.orderNumbers,
      this.paymentSignature,
      this.status,
      this.amount,
      this.razorPayInfo});

  Transaction.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    riderId = json['rider_id'];
    paymentId = json['payment_id'];
    razorPayOrderId = json['razor_pay_order_id'];
    orderNumbers = json['order_numbers'].cast<String>();
    paymentSignature = json['payment_signature'];
    status = json['status'];
    amount = json['amount'] ?? json['amount_collected'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    razorPayInfo = json['razor_pay_info'] != null
        ? RazorPayInfo.fromJson(json['razor_pay_info'])
        : null;
  }
}

class RazorPayInfo {
  String? id;
  String? entity;
  int? amount;
  int? amountPaid;
  int? amountDue;
  String? currency;
  String? receipt;
  String? status;
  int? attempts;

  RazorPayInfo({
    this.id,
    this.entity,
    this.amount,
    this.amountPaid,
    this.amountDue,
    this.currency,
    this.receipt,
    this.status,
    this.attempts,
  });

  RazorPayInfo.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    entity = json['entity'];
    amount = json['amount'];
    amountPaid = json['amount_paid'];
    amountDue = json['amount_due'];
    currency = json['currency'];
    receipt = json['receipt'];
    status = json['status'];
    attempts = json['attempts'];
  }
}
