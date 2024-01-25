// class EarningAndDailyOrderModel {
//   ImageText? imageText;
//   int? orderCount;
//   int? taskCount;
//   num? codAmount;
//   num? earning;
//   bool? success;
//   String? message;

//   EarningAndDailyOrderModel({
//     this.imageText,
//     this.orderCount,
//     this.taskCount,
//     this.codAmount,
//     this.earning,
//     this.success,
//     this.message,
//   });

//   EarningAndDailyOrderModel.fromJson(Map<String, dynamic> json) {
//     imageText = json['image_text'] != null
//         ? ImageText.fromJson(json['image_text'])
//         : null;
//     orderCount = json['order_count'];
//     taskCount = json['task_count'];
//     codAmount = json['cod_amount'];
//     earning = json['earning'];
//     success = json['success'];
//     message = json['message'];
//   }

//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = <String, dynamic>{};
//     if (imageText != null) {
//       data['image_text'] = imageText!.toJson();
//     }
//     data['order_count'] = orderCount;
//     data['task_count'] = taskCount;
//     data['cod_amount'] = codAmount;
//     data['earning'] = earning;
//     data['success'] = success;
//     data['message'] = message;
//     return data;
//   }
// }

// class ImageText {
//   String? image;
//   String? text;

//   ImageText({this.image, this.text});

//   ImageText.fromJson(Map<String, dynamic> json) {
//     image = json['image'];
//     text = json['text'];
//   }

//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = <String, dynamic>{};
//     data['image'] = image;
//     data['text'] = text;
//     return data;
//   }
// }

class EarningAndDailyOrderModel {
  List<ImageText>? imageText;
  int? orderCount;
  int? taskCount;
  int? codAmount;
  int? earning;
  bool? success;
  String? message;

  EarningAndDailyOrderModel(
      {this.imageText,
      this.orderCount,
      this.taskCount,
      this.codAmount,
      this.earning,
      this.success,
      this.message});

  EarningAndDailyOrderModel.fromJson(Map<String, dynamic> json) {
    if (json['image_text'] != null) {
      imageText = [];
      json['image_text'].forEach((v) {
        imageText!.add(ImageText.fromJson(v));
      });
    }
    orderCount = json['order_count'];
    taskCount = json['task_count'];
    codAmount = json['cod_amount'];
    earning = json['earning'];
    success = json['success'];
    message = json['message'];
  }
}

class ImageText {
  List<String>? image;
  String? text;
  String? notificationType;

  ImageText({this.image, this.text, this.notificationType});

  ImageText.fromJson(Map<String, dynamic> json) {
    image = json['image'].cast<String>();
    text = json['text'];
    notificationType = json['notification_type'];
  }
}
