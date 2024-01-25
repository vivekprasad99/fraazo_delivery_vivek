import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fraazo_delivery/helpers/error/error_reporter.dart';
import 'package:fraazo_delivery/models/user/service_details_model.dart';
import 'package:fraazo_delivery/services/api/user/user_service.dart';

class ServiceDetailProvider
    extends StateNotifier<AsyncValue<ServiceDetailModel>> {
  ServiceDetailProvider(AsyncValue<ServiceDetailModel> state) : super(state);

  Future postServiceDetail(Map<String, dynamic> serviceDetailData) {
    return UserService().posttServiceDetails(serviceDetailData);
  }

  Future getServiceDetailFetch() async {
    state = const AsyncLoading();
    try {
      final ServiceDetailModel serviceDetail =
          await UserService().getServiceDetails();
      state = AsyncData(serviceDetail);
    } catch (e, st) {
      state = AsyncError(e, st);
      ErrorReporter.error(e, st);
    }
  }
}
