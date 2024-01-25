class PerformanceModel {
  Performance? data;
  bool? success;
  String? message;

  PerformanceModel({this.data, this.success, this.message});

  PerformanceModel.fromJson(Map<String, dynamic> json) {
    data = json['data'] != null ? Performance.fromJson(json['data']) : null;
    success = json['success'];
    message = json['message'];
  }
}

class Performance {
  int? behaviorIssuesCount;
  int? markedDelivered;
  int? undelivered;
  List<BehaviorIssues>? behaviorIssues;
  List<MarkedDeliveredOrder>? markedDeliveredOrder;
  List<UndeliveredOrder>? undeliveredOrder;

  Performance(
      {this.behaviorIssuesCount,
      this.markedDelivered,
      this.undelivered,
      this.behaviorIssues,
      this.markedDeliveredOrder,
      this.undeliveredOrder});

  Performance.fromJson(Map<String, dynamic> json) {
    behaviorIssuesCount = json['behavior_issues_count'];
    markedDelivered = json['marked_delivered'];
    undelivered = json['undelivered'];
    if (json['behavior_issues'] != null) {
      behaviorIssues = <BehaviorIssues>[];
      json['behavior_issues'].forEach((v) {
        behaviorIssues!.add(new BehaviorIssues.fromJson(v));
      });
    }
    if (json['marked_delivered_order'] != null) {
      markedDeliveredOrder = <MarkedDeliveredOrder>[];
      json['marked_delivered_order'].forEach((v) {
        markedDeliveredOrder!.add(new MarkedDeliveredOrder.fromJson(v));
      });
    }
    if (json['undelivered_order'] != null) {
      undeliveredOrder = <UndeliveredOrder>[];
      json['undelivered_order'].forEach((v) {
        undeliveredOrder!.add(UndeliveredOrder.fromJson(v));
      });
    }
  }
}

class BehaviorIssues {
  int? id;
  int? riderId;
  String? issueType;
  String? description;
  String? reportedBy;

  BehaviorIssues(
      {this.id,
      this.riderId,
      this.issueType,
      this.description,
      this.reportedBy});

  BehaviorIssues.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    riderId = json['rider_id'];
    issueType = json['issue_type'];
    description = json['description'];
    reportedBy = json['reported_by'];
  }
}

class MarkedDeliveredOrder {
  int? riderId;
  int? taskId;
  String? orderNumber;
  String? customerName;

  MarkedDeliveredOrder(
      {this.riderId, this.taskId, this.orderNumber, this.customerName});

  MarkedDeliveredOrder.fromJson(Map<String, dynamic> json) {
    riderId = json['rider_id'];
    taskId = json['task_id'];
    orderNumber = json['order_number'];
    customerName = json['customer_name'];
  }
}

class UndeliveredOrder {
  int? riderId;
  int? taskId;
  String? orderNumber;
  String? customerName;

  UndeliveredOrder(
      {this.riderId, this.taskId, this.orderNumber, this.customerName});

  UndeliveredOrder.fromJson(Map<String, dynamic> json) {
    riderId = json['rider_id'];
    taskId = json['task_id'];
    orderNumber = json['order_number'];
    customerName = json['customer_name'];
  }
}
