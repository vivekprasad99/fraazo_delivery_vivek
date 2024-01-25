class StoreListModel {
  final List<Store> storeList = [];

  StoreListModel.fromJson(Map<String, dynamic> json) {
    if (json['data'] != null) {
      json['data'].forEach((v) {
        storeList.add(Store.fromJson(v));
      });
    }
  }
}

class Store {
  int? storeId;
  String? storeName;
  String? storeCode;

  Store({this.storeId, this.storeName, this.storeCode});

  Store.fromJson(Map<String, dynamic> json) {
    storeId = json['store_id'];
    storeName = json['store_name'];
    storeCode = json['store_code'];
  }
}
