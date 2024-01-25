import 'package:fraazo_delivery/helpers/api/api_call_helper.dart';
import 'package:fraazo_delivery/helpers/api/apis.dart';
import 'package:fraazo_delivery/models/cash_deposit/payment_history_model.dart';
import 'package:fraazo_delivery/models/cash_deposit/transaction_model.dart';
import 'package:fraazo_delivery/models/cash_deposit/unsettled_order_model.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

import '../../../models/cash_deposit/order_payment_model.dart';

class CashDepositService {
  final _apiCallHelper = ApiCallHelper();

  Future<UnsettledOrderModel> getRiderListOutstandingAmount() async {
    const String url = APIs.RIDER__LIST__OUTSTANDING__AMOUNT;
    final Map<String, dynamic>? response = await _apiCallHelper.get(url);
    return UnsettledOrderModel.fromJson(response!);
  }

  Future<List<Transaction>> getPaymentHistoryAmount() async {
    const String url = APIs.LIST__RIDER__RAZORPAY__PAYMENT__HISTORY;
    final Map<String, dynamic>? response = await _apiCallHelper.get(url);
    return PaymentHistoryModel.fromJson(response!).transactionList;
  }

  Future<Transaction?> postRiderCalculateAmountCreateRazorpayOrder(
      List<String> selectedOrderNumberList) async {
    const String url = APIs.RIDER__CALCULATE__AMOUNT__CREATE__RAZOR_PAY__ORDER;
    final body = {"order_numbers": selectedOrderNumberList};
    final Map<String, dynamic>? response =
        await _apiCallHelper.post(url, body: body);
    return TransactionModel.fromJson(response!).transaction;
  }

  Future<Transaction?> postRiderVerifyRazorpayPayment(
      PaymentSuccessResponse? paymentSuccessResponse) async {
    const String url = APIs.RIDER__VERIFY__RAZOR_PAY__PAYMENT;
    final body = {
      if (paymentSuccessResponse != null) ...{
        "razorpay_payment_id": paymentSuccessResponse.paymentId,
        "razorpay_order_id": paymentSuccessResponse.orderId,
        "razorpay_signature": paymentSuccessResponse.signature
      },
    };
    final Map<String, dynamic>? response =
        await _apiCallHelper.post(url, body: body);
    return TransactionModel.fromJson(response!).transaction;
  }

  Future<List<Transaction>> getCashOnDeliveryHistory() async {
    const String url = APIs.LIST__RIDER__COD__SETTLEMENT__HISTORY;
    final Map<String, dynamic>? response = await _apiCallHelper.get(url);
    return PaymentHistoryModel.fromJson(response!).transactionList;
  }

  Future<List<Data>?> getOrderPaymentHistory(int listId) async {
    const String url = APIs.ORDER_AMOUNT_HISTORY;
    final Map<String, dynamic>? response =
        await _apiCallHelper.get(url, queryParams: {"id": listId});
    return OrderPaymentModel.fromJson(response!).data;
  }
}
