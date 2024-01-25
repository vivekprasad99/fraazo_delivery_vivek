class TestimonialModel {
  TestimonialModel({
    this.success,
    this.message,
    this.data,
  });

  TestimonialModel.fromJson(dynamic json) {
    success = json['success'];
    message = json['message'];
    if (json['data'] != null) {
      data = [];
      json['data'].forEach((v) {
        data?.add(TestimonialData.fromJson(v));
      });
    }
  }
  bool? success;
  String? message;
  List<TestimonialData>? data;

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

class TestimonialData {
  TestimonialData({
    this.id,
    this.name,
    this.image,
    this.textBody,
    this.isActive,
    this.createdBy,
    this.updatedAt,
  });

  TestimonialData.fromJson(dynamic json) {
    id = json['id'];
    name = json['name'];
    image = json['image'];
    textBody = json['text_body'];
    isActive = json['is_active'];
    createdBy = json['created_by'];
    updatedAt = json['updated_at'];
  }
  int? id;
  String? name;
  String? image;
  String? textBody;
  bool? isActive;
  String? createdBy;
  String? updatedAt;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['name'] = name;
    map['image'] = image;
    map['text_body'] = textBody;
    map['is_active'] = isActive;
    map['created_by'] = createdBy;
    map['updated_at'] = updatedAt;
    return map;
  }
}
