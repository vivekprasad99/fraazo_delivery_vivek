class OrderItemsModel {
  OrderItems? data;

  OrderItemsModel({this.data});

  OrderItemsModel.fromJson(Map<String, dynamic> json) {
    data = json['data'] != null ? OrderItems.fromJson(json['data']) : null;
  }
}

class OrderItems {
  String? deliveryNumber;
  int? totalSkus;
  num? nettAmount;

  List<LineItem> lineItems = [];

  // OrderItems({this.deliveryNumber, this.totalSkus, this.lineItems});

  OrderItems.fromJson(Map<String, dynamic> json) {
    deliveryNumber = json['delivery_number'];
    nettAmount = json['nett_amount'];
    totalSkus = json['total_skus'];
    if (json['line_items'] != null) {
      json['line_items'].forEach((v) {
        lineItems.add(LineItem.fromJson(v));
      });
    }
  }
}

class LineItem {
  int? id;
  num? qty;
  String? name;
  String? sku;
  String? packSize;
  String? imageUrl;
  num? nettAmount;
  num? moqEffectiveUnitPrice;
  num? incDecQty;

  // Extra added;
  bool isMissing = false;
  bool hasQualityIssue = false;

  LineItem(
      {this.id, this.qty, this.name, this.sku, this.packSize, this.incDecQty});

  LineItem.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    qty = json['qty'];
    incDecQty = qty;
    name = json['name'];
    sku = json['sku'];
    packSize = json['pack_size'];
    imageUrl = json['image_url'];
    nettAmount = json['nett_amount'];
    moqEffectiveUnitPrice = json['moq_effective_unit_price'];
  }

  Map<String, dynamic> toJson() => {
        'line_item_id': id,
        'qty': qty,
        'name': name,
        'sku': sku,
        'is_bad_quality': hasQualityIssue,
        'is_missing': isMissing,
        'pack_size': packSize,
        'image_url': imageUrl,
        'nett_amount': nettAmount,
        'unit_price': moqEffectiveUnitPrice,
        'incDecQty': incDecQty,
      };
}
