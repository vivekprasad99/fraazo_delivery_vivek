class BasicDetails {
  BasicDetails({
    required this.success,
    required this.message,
    required this.data,
  });
  late final bool success;
  late final String message;
  late final Data data;

  BasicDetails.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    message = json['message'];
    data = Data.fromJson(json['data']);
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['success'] = success;
    _data['message'] = message;
    _data['data'] = data.toJson();
    return _data;
  }
}

class Data {
  Data({
    required this.firstName,
    required this.lastName,
    required this.mobile,
    required this.altMobile,
    required this.gender,
    required this.avatarId,
    required this.martialStatus,
    required this.noOfChildren,
    required this.address,
    required this.city,
    required this.pincode,
    required this.link,
    required this.contactName,
    required this.contactNumber,
    required this.relation,
  });
  late final String firstName;
  late final String lastName;
  late final String mobile;
  late final String altMobile;
  late final String gender;
  late final int avatarId;
  late final String martialStatus;
  late final int noOfChildren;
  late final String address;
  late final String city;
  late final int pincode;
  late final String link;
  late final String contactName;
  late final String contactNumber;
  late final String relation;

  Data.fromJson(Map<String, dynamic> json) {
    firstName = json['first_name'];
    lastName = json['last_name'];
    mobile = json['mobile'];
    altMobile = json['alt_mobile'];
    gender = json['gender'] ?? '';
    avatarId = json['avatar_id'];
    martialStatus = json['martial_status'];
    noOfChildren = json['no_of_children'];
    address = json['address'];
    city = json['city'];
    pincode = json['pincode'];
    link = json['link'];
    contactName = json['contact_name'];
    contactNumber = json['contact_number'];
    relation = json['relation'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['first_name'] = firstName;
    _data['last_name'] = lastName;
    _data['mobile'] = mobile;
    _data['alt_mobile'] = altMobile;
    _data['gender'] = gender;
    _data['avatar_id'] = avatarId;
    _data['martial_status'] = martialStatus;
    _data['no_of_children'] = noOfChildren;
    _data['address'] = address;
    _data['city'] = city;
    _data['pincode'] = pincode;
    _data['link'] = link;
    _data['contact_name'] = contactName;
    _data['contact_number'] = contactNumber;
    _data['relation'] = relation;
    return _data;
  }
}
