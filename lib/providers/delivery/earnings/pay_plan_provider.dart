import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fraazo_delivery/helpers/error/error_reporter.dart';
import 'package:fraazo_delivery/models/delivery/pay_plan_model.dart';
import 'package:fraazo_delivery/services/api/delivery/delivery_service.dart';

class PayPlanProvider extends StateNotifier<AsyncValue<PayPlanModel>> {
  PayPlanProvider([AsyncValue<PayPlanModel> state = const AsyncLoading()])
      : super(state);
  // PayPlanProvider(AsyncValue<PayPlanModel> state) : super(state);

  final _deliveryService = DeliveryService();

  Future getPayoutStructure() async {
    state = const AsyncLoading();
    try {
      final PayPlanModel? payPlan = await _deliveryService.getPayPlan();
      state = AsyncData(payPlan!);
    } catch (e, st) {
      state = AsyncError(e, st);
      ErrorReporter.error(e, st);
    }
  }
}
