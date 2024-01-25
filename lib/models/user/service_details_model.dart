class ServiceDetailModel {
  bool? success;
  String? message;
  ServiceDetail? serviceDetail;

  ServiceDetailModel({this.success, this.message, required this.serviceDetail});

  ServiceDetailModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    message = json['message'];
    serviceDetail =
        json['data'] != null ? ServiceDetail.fromJson(json['data']) : null;
  }
}

class ServiceDetail {
  String? vehicleNumber;
  int? vehicleTypeId;
  String? deliveryPartner;
  String? shift;
  String? shiftText;
  String? shiftTime;
  String? storeName;
  int? shiftId;

  ServiceDetail(
      {this.vehicleNumber,
      this.vehicleTypeId,
      this.deliveryPartner,
      this.shift,
      this.shiftText,
      this.shiftTime,
      this.storeName,
      this.shiftId});

  ServiceDetail.fromJson(Map<String, dynamic> json) {
    vehicleNumber = json['vehicle_number'];
    vehicleTypeId = json['vehicle_type_id'];
    deliveryPartner = json['delivery_partner'];
    shift = json['shift'];
    shiftText = json['shift_text'];
    shiftTime = json['shift_time'];
    storeName = json['store_name'];
    shiftId = json['shift_id'];
  }
}
