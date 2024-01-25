import 'package:fraazo_delivery/helpers/extensions/num_extension.dart';

class StatModel {
  int? orderCount;
  int? taskCount;
  num? codAmount;
  num? earning;
  num? distance;
  num? distanceCost;
  num? loginHours;
  num? loginIncentive;
  String? earningTruncated;

  StatModel(
      {this.orderCount,
      this.taskCount,
      this.codAmount,
      this.earning,
      this.distance,
      this.distanceCost,
      this.loginHours,
      this.earningTruncated,
      this.loginIncentive});

  StatModel.fromJson(Map<String, dynamic>? json) {
    orderCount = json?['order_count'];
    taskCount = json?['task_count'];
    codAmount = json?['cod_amount'];
    earning = json?['earning'] ?? 0;
    distance = json?['distance'];
    distanceCost = json?['distance_cost'];
    loginHours = json?['login_hours'];
    loginIncentive = json?['login_incentive'];
    earningTruncated = earning?.trimTo2Digits();
  }
}
