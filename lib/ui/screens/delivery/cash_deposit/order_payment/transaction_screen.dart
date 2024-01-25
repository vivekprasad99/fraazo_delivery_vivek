import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fraazo_delivery/helpers/route/route_helper.dart';
import 'package:fraazo_delivery/models/cash_deposit/transaction_model.dart';
import 'package:fraazo_delivery/models/cash_deposit/unsettled_order_model.dart';
import 'package:fraazo_delivery/providers/cash_deposit/unsettled_order_provider.dart';
import 'package:fraazo_delivery/ui/screens/delivery/cash_deposit/order_payment/local_widgets/payment_status_dialog.dart';
import 'package:fraazo_delivery/ui/utils/toast.dart';
import 'package:fraazo_delivery/utils/globals.dart';
import 'package:fraazo_delivery/utils/sdk_keys.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

class TransactionScreen extends StatefulWidget {
  final Transaction transaction;
  const TransactionScreen({Key? key, required this.transaction})
      : super(key: key);

  @override
  _TransactionScreenState createState() => _TransactionScreenState();
}

class _TransactionScreenState extends State<TransactionScreen> {
  final _unsettledOrderProvider = StateNotifierProvider<UnsettledOrderProvider,
          AsyncValue<UnsettledOrderModel>>(
      (_) => UnsettledOrderProvider(const AsyncLoading()));

  final _razorpay = Razorpay();
  @override
  void initState() {
    super.initState();
    _setRazorpayListeners();
    _initTransaction();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: _buildBody()),
    );
  }

  Widget _buildBody() {
    return const Center(
      child: Text("Please wait..."),
    );
  }

  void _setRazorpayListeners() {
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    Toast.popupLoadingFuture(
      future: () => context
          .read(_unsettledOrderProvider.notifier)
          .checkPaymentStatus(response),
      onSuccess: (transaction) {
        if (transaction is Transaction?) {
          if (transaction?.razorPayInfo?.status == "paid") {
            _onPaymentStatus(true);
          } else {
            _onPaymentStatus(false);
          }
        } else {
          _onPaymentStatus(true);
        }
      },
      onFailure: () => _onPaymentStatus(false),
    );
  }

  Future _handlePaymentError(PaymentFailureResponse response) async {
    _onPaymentStatus(false);
  }

  Future _onPaymentStatus(bool paymentStatus) async {
    await _openPaymentStatusDialog(paymentStatus);
    RouteHelper.pop(args: paymentStatus);
  }

  void _initTransaction() {
    final Map<String, dynamic> options = {
      'key': SDKKeys.RAZORPAY_KEY,
      'amount': widget.transaction.razorPayInfo?.amount,
      'name': Globals.user?.fullName,
      'currency': "INR",
      'order_id': widget.transaction.razorPayOrderId,
      'description': 'ForOrders#${widget.transaction.orderNumbers}',
      'prefill': {
        'contact': Globals.user?.mobile,
        if (Globals.user?.email != null) 'email': Globals.user?.email,
      },
      "method": {
        "netbanking": false,
        "card": false,
        "wallet": false,
        "upi": true
      },
    };
    _razorpay.open(options);
  }

  Future _openPaymentStatusDialog(bool isSuccess) {
    return showDialog(
      context: context,
      builder: (_) => PaymentStatusDialog(
        isSuccess: isSuccess,
      ),
    );
  }

  @override
  void deactivate() {
    context.read(_unsettledOrderProvider.notifier).dispose();
    super.deactivate();
  }

  @override
  void dispose() {
    _razorpay.clear(); // Removes all listeners
    super.dispose();
  }
}
