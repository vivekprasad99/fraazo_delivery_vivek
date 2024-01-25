class LandingPageModel {
  LandingPageModel({
    this.success,
    this.message,
    this.data,
  });

  LandingPageModel.fromJson(dynamic json) {
    success = json['success'];
    message = json['message'];
    if (json['data'] != null) {
      data = [];
      json['data'].forEach((v) {
        data?.add(LandingData.fromJson(v));
      });
    }
  }
  bool? success;
  String? message;
  List<LandingData>? data;

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

class LandingData {
  LandingData({
    this.id,
    this.type,
    this.text,
    this.imageUrl,
    this.isActive,
    this.createdAt,
    this.orderNo,
  });

  LandingData.fromJson(dynamic json) {
    id = json['id'];
    type = json['type'];
    text = json['text'];
    imageUrl = json['image_url'];
    isActive = json['is_active'];
    createdAt = json['created_at'];
    orderNo = json['order_no'];
  }
  int? id;
  String? type;
  String? text;
  String? imageUrl;
  bool? isActive;
  String? createdAt;
  int? orderNo;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['type'] = type;
    map['text'] = text;
    map['image_url'] = imageUrl;
    map['is_active'] = isActive;
    map['created_at'] = createdAt;
    map['order_no'] = orderNo;
    return map;
  }
}
