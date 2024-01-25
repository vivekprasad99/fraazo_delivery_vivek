class UserModel {
  bool? success;
  String? message;
  User? data;
  bool? deviceTagged;

  UserModel({this.success, this.message, this.data, this.deviceTagged});

  UserModel.fromJson(Map<String, dynamic>? json) {
    success = json?['success'];
    message = json?['message'];
    data = json?['data'] != null ? User.fromJson(json?['data']) : null;
    deviceTagged = json?['device_tagged'];
  }
}

class User {
  int? id;
  String? firstName;
  String? lastName;
  String? mobile;
  String? email;
  bool? isActive;
  late bool isVerified;
  String? status;
  int? statusId;
  String? storeCode;
  String? storeName;
  num? storeLat;
  num? storeLng;
  String? city;
  String? vendor;
  int? vendorId;
  bool? billingEnabled;
  String? password;
  late bool passwordSet;
  late bool enableQrScanning;
  late bool tncAccepted;
  late bool qrEnable;
  String? tncPath;
  String? profilePic;
  bool? disableOrderAssignment;
  bool? reachedCx;

  String? fullName; // extra added
  bool? isPasswordVerification;
  bool? isLogin; // extra added
  bool? batchingQr;
  User(
      {this.id,
      this.firstName,
      this.lastName,
      this.mobile,
      this.isActive,
      this.status,
      this.statusId,
      this.vendorId,
      this.storeCode,
      this.password,
      this.isPasswordVerification = false,
      this.tncAccepted = false,
      this.profilePic,
      this.disableOrderAssignment = false,
      this.reachedCx = false,
      this.isLogin = false,
      this.batchingQr});

  User.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    firstName = json['first_name'];
    lastName = json['last_name'];
    mobile = json['mobile'];
    email = json['email'];
    isActive = json['is_active'];
    isVerified = json['is_verified'] ?? isActive;
    status = json['status'];
    statusId = json['status_id'];
    storeName = json['store_name'];
    storeLat = json['store_lat'];
    storeLng = json['store_lng'];
    storeCode = json['store_code'];
    city = json['city'];
    vendor = json['vendor'];
    vendorId = json['vendor_id'];
    billingEnabled = json["billing_enabled"] ?? true;
    passwordSet = json["password_set"] ?? true;
    enableQrScanning = json["enable_qr_scanning"] ?? false;
    tncAccepted = json['tnc_accepted'] ?? true;
    qrEnable = json['qr_enable'] ?? false;
    tncPath = json['tnc_path'];
    profilePic = json['profile_pic'] ?? '';
    fullName = "$firstName $lastName";
    disableOrderAssignment = json['disable_order_assignment'] ?? false;
    reachedCx = json['reached_cx'] ?? false;
    batchingQr = json['batching_qr'] ?? false;
  }
}
