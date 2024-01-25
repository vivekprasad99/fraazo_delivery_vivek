class OrderPaymentModel {
  OrderPaymentModel({
    bool? success,
    String? message,
    int? id,
    List<Data>? data,
  }) {
    _success = success;
    _message = message;
    _id = id;
    _data = data;
  }

  OrderPaymentModel.fromJson(dynamic json) {
    _success = json['success'];
    _message = json['message'];
    _id = json['ID'];
    if (json['data'] != null) {
      _data = [];
      json['data'].forEach((v) {
        _data?.add(Data.fromJson(v));
      });
    }
  }
  bool? _success;
  String? _message;
  int? _id;
  List<Data>? _data;

  bool? get success => _success;
  String? get message => _message;
  int? get id => _id;
  List<Data>? get data => _data;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['success'] = _success;
    map['message'] = _message;
    map['ID'] = _id;
    if (_data != null) {
      map['data'] = _data?.map((v) => v.toJson()).toList();
    }
    return map;
  }
}

class Data {
  Data({
    String? orderNumber,
    int? collectedAmount,
  }) {
    _orderNumber = orderNumber;
    _collectedAmount = collectedAmount;
  }

  Data.fromJson(dynamic json) {
    _orderNumber = json['order_number'];
    _collectedAmount = json['collected_amount'];
  }
  String? _orderNumber;
  int? _collectedAmount;

  String? get orderNumber => _orderNumber;
  int? get collectedAmount => _collectedAmount;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['order_number'] = _orderNumber;
    map['collected_amount'] = _collectedAmount;
    return map;
  }
}
