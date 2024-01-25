class DeviceVerificationModel {
  bool? success;
  String? message;
  String? status;
  DeviceVerificationData? data;

  DeviceVerificationModel({this.success, this.message, this.status, this.data});

  DeviceVerificationModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    message = json['message'];
    status = json.containsKey('status') ? json['status'] : '';
    data = json['data'] != null
        ? DeviceVerificationData.fromJson(json['data'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['success'] = success;
    data['message'] = message;
    data['status'] = status;
    if (this.data != null) {
      data['data'] = this.data?.toJson();
    }
    return data;
  }
}

class DeviceVerificationData {
  String? mobile;
  String? deviceTagId;
  List<String>? imeiNumbers;

  DeviceVerificationData({this.mobile, this.deviceTagId, this.imeiNumbers});

  DeviceVerificationData.fromJson(Map<String, dynamic> json) {
    mobile = json['mobile'];
    deviceTagId = json['device_tag_id'];
    imeiNumbers = json['imei_numbers'].cast<String>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['mobile'] = mobile;
    data['device_tag_id'] = deviceTagId;
    data['imei_numbers'] = imeiNumbers;
    return data;
  }
}
