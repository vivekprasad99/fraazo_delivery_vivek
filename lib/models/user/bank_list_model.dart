class BankListModel {
  BankListModel({
    this.success,
    this.message,
    this.data,
  });

  BankListModel.fromJson(dynamic json, {String? keyName}) {
    success = json['success'];
    message = json['message'];
    if (json['data'] != null) {
      data = [];
      json['data'].forEach((v) {
        data?.add(Data.fromJson(v));
      });
    }
  }
  bool? success;
  String? message;
  List<Data>? data;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['success'] = success;
    map['message'] = message;
    if (data != null) {
      map['data'] = data?.map((v) => v.toJson()).toList();
    }
    return map;
  }
}

class Data {
  Data({
    this.id,
    this.bankName,
    this.bankLogo,
    this.createdAt,
  });

  Data.fromJson(dynamic json) {
    id = json['id'];
    bankName = json['bank_name '];
    bankLogo = json['bank_logo '];
    createdAt = json['created_at'];
  }
  int? id;
  String? bankName;
  String? bankLogo;
  String? createdAt;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['bank_name '] = bankName;
    map['bank_logo '] = bankLogo;
    map['created_at'] = createdAt;
    return map;
  }
}
