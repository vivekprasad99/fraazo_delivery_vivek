class ReturnInventoryModel {
  bool? success;
  String? message;
  List<ReturnInventoryData>? data;

  ReturnInventoryModel({this.success, this.message, this.data});

  ReturnInventoryModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    message = json['message'];
    if (json['data'] != null) {
      data = <ReturnInventoryData>[];
      json['data'].forEach((v) {
        data!.add(ReturnInventoryData.fromJson(v));
      });
    } else {
      data = <ReturnInventoryData>[];
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

class ReturnInventoryData {
  String? orderNumber;
  String? orderStatus;
  String? message;

  ReturnInventoryData({this.orderNumber, this.orderStatus, this.message});

  ReturnInventoryData.fromJson(Map<String, dynamic> json) {
    orderNumber = json['order_number'];
    orderStatus = json['order_status'];
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['order_number'] = orderNumber;
    data['order_status'] = orderStatus;
    data['message'] = message;
    return data;
  }
}

/*class ReturnInventoryModel {
  bool? success;
  String? message;
  ReturnInventory? returnInventory;

  ReturnInventoryModel({this.success, this.message, this.returnInventory});

  ReturnInventoryModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    message = json['message'];
    returnInventory =
        json['data'] != null ? ReturnInventory.fromJson(json['data']) : null;
  }
}

class ReturnInventory {
  String? orderNumber;
  String? orderStatus;
  String? message;

  ReturnInventory({this.orderNumber, this.orderStatus, this.message});

  ReturnInventory.fromJson(Map<String, dynamic> json) {
    orderNumber = json['order_number'];
    orderStatus = json['order_status'];
    message = json['message'];
  }
}*/
