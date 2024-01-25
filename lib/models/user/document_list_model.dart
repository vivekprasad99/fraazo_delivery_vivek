class DocumentListModel {
  bool? success;
  String? message;
  List<Document>? data;

  DocumentListModel({this.success, this.message, this.data});

  DocumentListModel.fromJson(Map<String, dynamic>? json) {
    success = json?['success'];
    message = json?['message'];
    if (json?['data'] != null) {
      data = <Document>[];
      json?['data'].forEach((v) {
        data!.add(Document.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['success'] = success;
    data['message'] = message;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Document {
  int? id;
  int? riderId;
  String? type;
  String? link;
  bool? isVerified;
  String? createdAt;
  String? modifiedAt;

  Document(
      {this.id,
      this.riderId,
      this.type,
      this.link,
      this.isVerified,
      this.createdAt,
      this.modifiedAt});

  Document.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    riderId = json['rider_id'];
    type = json['type'];
    link = json['link'];
    isVerified = json['is_verified'];
    createdAt = json['created_at'];
    modifiedAt = json['modified_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['rider_id'] = riderId;
    data['type'] = type;
    data['link'] = link;
    data['is_verified'] = isVerified;
    data['created_at'] = createdAt;
    data['modified_at'] = modifiedAt;
    return data;
  }
}
