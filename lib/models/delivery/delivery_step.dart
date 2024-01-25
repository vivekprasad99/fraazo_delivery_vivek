// Not used to parsing
import 'location.dart';
import 'task_model.dart';

class DeliveryStep {
  String? label;
  String? description;
  OrderSeq? order;
  Location? location;
  bool isStarted;
  String buttonText;

  DeliveryStep({
    this.label,
    this.description,
    this.order,
    this.location,
    this.isStarted = false,
    this.buttonText = "",
  });
}
