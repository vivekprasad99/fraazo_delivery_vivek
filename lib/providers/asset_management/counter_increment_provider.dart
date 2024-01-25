import 'package:flutter/material.dart';
import 'package:fraazo_delivery/models/asset_management/rider_asset_model.dart';

class CounterValue extends ChangeNotifier {
  int _counter = 0;
  int _index = 0;
  int get getCounterValue => _counter;
  int get getIndexValue => _index;
  RiderAsset? _assetDetail;
  RiderAsset? get getRiderAssetDetail => _assetDetail;

  void increment(int index, RiderAsset assetDetail, String returnData) {
    _counter += 1;
    _index = index;
    int quantity = int.parse(returnData);
    if (int.parse(returnData) > 1) {
      assetDetail.changeQuantity = quantity + 1;
      _assetDetail = assetDetail;
    } else if (int.parse(returnData) == 1) {
      assetDetail.changeQuantity = quantity + 1;
      _assetDetail = assetDetail;
    } else if (int.parse(returnData) == 0) {
      assetDetail.changeQuantity = quantity + 1;
      _assetDetail = assetDetail;
    }
    notifyListeners();
  }

  void decrement(int index, RiderAsset assetDetail, String returnData) {
    _counter -= 1;
    _index = index;
    if (returnData == '1') {
      assetDetail.changeQuantity = 0;
      _assetDetail = assetDetail;
    } else if (int.parse(returnData) > 1) {
      int quantity = int.parse(returnData);
      assetDetail.changeQuantity = quantity - 1;
      _assetDetail = assetDetail;
    } else {
      assetDetail.changeQuantity -= 1;
      _assetDetail = assetDetail;
    }

    notifyListeners();
  }
}
