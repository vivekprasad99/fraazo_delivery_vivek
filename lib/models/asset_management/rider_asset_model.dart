class RiderAssetModel {
  List<RiderAsset> riderAssetList = [];
  bool? success;
  String? message;
  bool? returnRequest;

  RiderAssetModel(
      {required this.riderAssetList,
      this.success,
      this.message,
      this.returnRequest});

  RiderAssetModel.fromJson(Map<String, dynamic> json) {
    if (json['data'] != null) {
      json['data'].forEach((v) {
        riderAssetList.add(RiderAsset.fromJson(v));
      });
    }
    success = json['success'];
    message = json['message'];
    returnRequest = json['return_request'];
  }
}

class RiderAsset {
  int? assetId;
  String? name;
  String? assignedBy;
  int? quantity;
  String? requestId;
  String? createdAt;
  bool? isReturn;
  int? returnQuantity;
  int changeQuantity = 0;

  RiderAsset({
    this.assetId,
    this.name,
    this.quantity,
    this.requestId,
    this.assignedBy,
    this.createdAt,
    this.isReturn,
    this.returnQuantity,
    this.changeQuantity = 0,
  });

  RiderAsset.fromJson(Map<String, dynamic> json) {
    assetId = json['asset_id'];
    name = json['name'];
    assignedBy = json['assigned_by'];
    quantity = json['quantity'];
    requestId = json['request_id'];
    createdAt = json['created_at'];
    isReturn = json['is_return'];
    returnQuantity = json['return_quantity'];
    changeQuantity = json['change_quantity'] ?? 0;
  }
}
