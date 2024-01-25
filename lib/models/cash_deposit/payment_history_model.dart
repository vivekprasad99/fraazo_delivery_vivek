import 'package:fraazo_delivery/models/cash_deposit/transaction_model.dart';

class PaymentHistoryModel {
  num? amount;
  List<Transaction> transactionList = [];

  PaymentHistoryModel({this.amount, required this.transactionList});

  PaymentHistoryModel.fromJson(Map<String, dynamic> json) {
    amount = json['amount'];
    if (json['data'] != null) {
      json['data'].forEach((v) {
        transactionList.add(Transaction.fromJson(v));
      });
    }
  }
}
