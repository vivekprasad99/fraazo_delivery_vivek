class ExtraUserDetailsModel {
  ExtraUserDetails? data;

  ExtraUserDetailsModel.fromJson(Map<String, dynamic> json) {
    data =
        json['data'] != null ? ExtraUserDetails.fromJson(json['data']) : null;
  }
}

class ExtraUserDetails {
  String? address;
  int? pincode;
  String? email;
  String? altMobile;
  String? city;
  int? vehicleTypeId;
  String? vehicleType;
  String? vehicleNo;
  String? martialStatus;
  String? fatherName;
  String? fatherNo;
  String? aadharCard;
  String? licence;
  String? shift;
  String? shiftTiming;

  ExtraUserDetails(
      {this.address,
      this.pincode,
      this.email,
      this.altMobile,
      this.city,
      this.vehicleTypeId,
      this.vehicleNo,
      this.martialStatus,
      this.fatherName,
      this.fatherNo,
      this.aadharCard,
      this.licence});

  ExtraUserDetails.fromJson(Map<String, dynamic> json) {
    address = json['address'];
    pincode = json['pincode'];
    email = json['email'];
    altMobile = json['alt_mobile'];
    city = json['city'];
    vehicleType = json['vehicle_type'];
    vehicleTypeId = json['vehicle_type_id'];
    vehicleNo = json['vehicle_no'];
    martialStatus = json['martial_status'];
    fatherName = json['father_name'];
    fatherNo = json['father_no'];
    aadharCard = json['aadhar_card'];
    licence = json['licence'];
    shift = json['shift'] ?? '';
    shiftTiming = json['shift_timing'] ?? '';
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['address'] = address;
    data['pincode'] = pincode;
    data['email'] = email;
    data['alt_mobile'] = altMobile;
    data['city'] = city;
    data['vehicle_type_id'] = vehicleTypeId;
    data['vehicle_no'] = vehicleNo;
    data['martial_status'] = martialStatus;
    data['father_name'] = fatherName;
    data['father_no'] = fatherNo;
    data['aadhar_card'] = aadharCard;
    data['licence'] = licence;
    data['shift'] = shift;
    data['shift_timing'] = shiftTiming;
    return data;
  }
}
