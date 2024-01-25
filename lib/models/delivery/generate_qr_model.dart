class GenerateQRModel {
  Data? data;
  late bool success;
  num? amount;
  String? qrExpiry;
  String? message;

  GenerateQRModel({this.data, this.success = false, this.qrExpiry});

  GenerateQRModel.fromJson(Map<String, dynamic> json) {
    data = json['data'] != null ? Data.fromJson(json['data']) : null;
    success = json['success'] ?? false;
    message = json['message'] ?? '';
    amount = json['amount'];
    qrExpiry = json['qr_expiry'] ?? '0';
  }
}

class Data {
  String? imageUrl;

  Data({this.imageUrl});

  Data.fromJson(Map<String, dynamic> json) {
    imageUrl = json['image_url'];
  }
}
