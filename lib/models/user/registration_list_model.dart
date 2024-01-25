class RegistrationListModel {
  bool? success;
  String? message;
  RegistrationList? data;

  RegistrationListModel({this.success, this.message, this.data});

  RegistrationListModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    message = json['message'];
    data = json['data'] != null ? RegistrationList.fromJson(json['data']) : null;
  }
}

class RegistrationList {
  bool? basicInfoFlag;
  bool? serviceInfoFlag;
  bool? setPasswordFlag;
  bool? documentFlag;
  bool? bankInfoFlag;
  bool? documentVerified;
  bool? bankDetailsVerifiedFlag;
  bool? passwordVerified;

  RegistrationList(
      {this.basicInfoFlag,
      this.serviceInfoFlag,
      this.setPasswordFlag,
      this.documentFlag,
      this.bankInfoFlag,
      this.documentVerified,
      this.bankDetailsVerifiedFlag,
      this.passwordVerified});

  RegistrationList.fromJson(Map<String, dynamic> json) {
    basicInfoFlag = json['basic_info_flag'];
    serviceInfoFlag = json['service_info_flag'];
    setPasswordFlag = json['set_password_flag'];
    documentFlag = json['document_flag'];
    bankInfoFlag = json['bank_info_flag'];
    documentVerified = json['document_verified'];
    bankDetailsVerifiedFlag = json['bank_details_verified_flag'];
    passwordVerified = json['password_verified'];
  }
}
