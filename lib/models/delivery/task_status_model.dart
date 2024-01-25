import 'package:fraazo_delivery/models/delivery/task_model.dart';

class TaskStatusModel {
  String? type;
  String? orderNumber;
  Task? task;
  TaskStatusModel();

  TaskStatusModel.fromJson(Map<String, dynamic>? json) {
    type = json?['type'];
    orderNumber = json?['order_number'];
    task = json != null ? Task.fromJson(json) : null;
  }
}
