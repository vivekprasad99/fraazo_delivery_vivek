class TrainingListModel {
  bool? success;
  String? message;
  List<Training>? trainingList = [];

  TrainingListModel({this.success, this.message, this.trainingList});

  TrainingListModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    message = json['message'];
    if (json['data'] != null) {
      json['data'].forEach((v) {
        trainingList!.add(Training.fromJson(v));
      });
    }
  }
}

class Training {
  int? id;
  String? type;
  String? text;
  String? imageUrl;
  bool? isActive;
  String? createdAt;
  int? orderNo;

  Training({
    this.id,
    this.type,
    this.text,
    this.imageUrl,
    this.isActive,
    this.createdAt,
    this.orderNo,
  });

  Training.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    type = json['type'];
    text = json['text'];
    imageUrl = json['image_url'];
    isActive = json['is_active'];
    createdAt = json['created_at'];
    orderNo = json['order_no'];
  }
}
