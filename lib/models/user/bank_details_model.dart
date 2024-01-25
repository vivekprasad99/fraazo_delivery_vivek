class BankDetailsModel {
  BankDetails? data;

  BankDetailsModel({this.data});

  BankDetailsModel.fromJson(Map<String, dynamic>? json) {
    data = json?['data'] != null ? BankDetails.fromJson(json?['data']) : null;
  }
}

class BankDetails {
  int? id;
  String? recipientName;
  String? accountNumber;
  String? pan;
  String? bankName;
  String? ifscCode;
  bool? isActive;
  String? verificationStatus;

  BankDetails({
    this.id,
    this.recipientName,
    this.accountNumber,
    this.pan,
    this.bankName,
    this.ifscCode,
    this.isActive,
    this.verificationStatus,
  });

  BankDetails.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    recipientName = json['recipient_name'];
    accountNumber = json['account_number'];
    pan = json['pan'];
    bankName = json['bank_name'];
    ifscCode = json['ifsc_code'];
    isActive = json['is_active'];
    verificationStatus = json['verification_status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['recipient_name'] = recipientName;
    data['account_number'] = accountNumber;
    data['pan'] = pan;
    data['bank_name'] = bankName;
    data['ifsc_code'] = ifscCode;
    data['is_active'] = isActive;
    return data;
  }

  Map<String, dynamic> toBasicJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['recipient_name'] = recipientName;
    data['account_number'] = accountNumber;
    data['pan'] = pan;
    data['bank_name'] = bankName;
    data['ifsc_code'] = ifscCode;
    return data;
  }
}
