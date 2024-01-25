import 'package:fraazo_delivery/models/delivery/task_model.dart';
import 'package:fraazo_delivery/models/user/stat_model.dart';

class DeliveryHistoryModel {
  DeliveryHistory? data;
  DeliveryHistoryModel({this.data});

  DeliveryHistoryModel.fromJson(Map<String, dynamic>? json) {
    data =
        json?['data'] != null ? DeliveryHistory.fromJson(json?['data']) : null;
  }
}

class DeliveryHistory {
  List<Task>? tasks;
  StatModel? stat;

  DeliveryHistory({this.tasks, this.stat});

  DeliveryHistory.fromJson(Map<String, dynamic> json) {
    if (json['tasks'] != null) {
      tasks = <Task>[];
      json['tasks'].forEach((v) {
        tasks!.add(Task.fromJson(v));
      });
    }
    stat = json['stat'] != null ? StatModel.fromJson(json['stat']) : null;
  }
}
