import 'package:fraazo_delivery/helpers/api/api_call_helper.dart';
import 'package:fraazo_delivery/helpers/api/apis.dart';
import 'package:fraazo_delivery/helpers/type_aliases/json.dart';
import 'package:fraazo_delivery/models/home_page/earning_daily_order_model.dart';
import 'package:fraazo_delivery/models/home_page/week_stat_model.dart';

class HomePageService {
  final _apiCallHelper = ApiCallHelper();

  Future<WeekModel?> getWeeklyEarnings({
    required String fromDate,
    required String toDate,
  }) async {
    const String url = APIs.WEEKLY_EARNINGS;
    final JsonMap queryParams = {
      "from_date": fromDate,
      "to_date": toDate,
    };
    final response = await _apiCallHelper.get(url, queryParams: queryParams);
    return WeekModel.fromJson(response!);
  }

  Future<EarningAndDailyOrderModel?> getEarningAndOrdersDailyApi(
      {required int riderId, required int batteryLevel}) async {
    const String url = APIs.EARNINGS_ORDERS_DAILY;
    final JsonMap queryParams = {
      "rider_id": riderId,
      "battery_precentage": batteryLevel
    };
    final response = await _apiCallHelper.get(url, queryParams: queryParams);
    return EarningAndDailyOrderModel.fromJson(response!);
  }
}
