import 'package:flutter/material.dart';
import 'package:fraazo_delivery/helpers/enums/partial_amount_type.dart';
import 'package:fraazo_delivery/helpers/route/routes.dart';
import 'package:fraazo_delivery/models/cash_deposit/cod_history_model.dart';
import 'package:fraazo_delivery/models/cash_deposit/transaction_model.dart';
import 'package:fraazo_delivery/models/delivery/task.dart';
import 'package:fraazo_delivery/models/delivery/task_model.dart';
import 'package:fraazo_delivery/models/user/profile/user_model.dart';
import 'package:fraazo_delivery/screen_modules/signup/ui/new_signup_page.dart';
import 'package:fraazo_delivery/screen_modules/signup/ui/registration_screen.dart';
import 'package:fraazo_delivery/screen_modules/signup/ui/set_password_screen.dart';
import 'package:fraazo_delivery/screen_modules/signup/ui/successful_registration_screen.dart';
import 'package:fraazo_delivery/screen_modules/signup/ui/training_screen.dart';
import 'package:fraazo_delivery/services/sdk/firebase/crashlytics_service.dart';
import 'package:fraazo_delivery/ui/screens/attendance/rider_attendance/rider_attendance_screen.dart';
import 'package:fraazo_delivery/ui/screens/delivery/cash_deposit/floating_cash_screen.dart';
import 'package:fraazo_delivery/ui/screens/delivery/cash_deposit/order_payment/transaction_screen.dart';
import 'package:fraazo_delivery/ui/screens/delivery/cash_deposit/order_payment/unsettled_order_payment_screen.dart';
import 'package:fraazo_delivery/ui/screens/delivery/cash_deposit/transaction/cod_detail_screen.dart';
import 'package:fraazo_delivery/ui/screens/delivery/cash_deposit/transaction/history/transaction_history_screen.dart';
import 'package:fraazo_delivery/ui/screens/delivery/cash_deposit/transaction/transaction_detail_screen.dart';
import 'package:fraazo_delivery/ui/screens/delivery/earnings/earnings_screen.dart';
import 'package:fraazo_delivery/ui/screens/delivery/history/history_screen.dart';
import 'package:fraazo_delivery/ui/screens/delivery/steps/delivery_steps_screen.dart';
import 'package:fraazo_delivery/ui/screens/delivery/steps/delivery_type_process/delivery_type_selector_screen.dart';
import 'package:fraazo_delivery/ui/screens/delivery/steps/delivery_type_process/partial_amount/partial_amount_reason_screen.dart';
import 'package:fraazo_delivery/ui/screens/delivery/steps/delivery_type_process/support_call_screen.dart';
import 'package:fraazo_delivery/ui/screens/delivery/steps/local_widgets/customer_not_available_screen.dart';
import 'package:fraazo_delivery/ui/screens/delivery/steps/new_order_sku_selection_sheet/new_map_screen.dart';
import 'package:fraazo_delivery/ui/screens/delivery/steps/new_order_sku_selection_sheet/order_sku_selection_sheet_screen.dart';
import 'package:fraazo_delivery/ui/screens/global/no_order_qr_code_scanner_screen.dart';
import 'package:fraazo_delivery/ui/screens/global/qr_code_scanner_screen.dart';
import 'package:fraazo_delivery/ui/screens/home/home_screen.dart';
import 'package:fraazo_delivery/ui/screens/home/local_widgets/delivery/delivery_completed_screen.dart';
import 'package:fraazo_delivery/ui/screens/home/local_widgets/delivery/new_order_reason_screen.dart';
import 'package:fraazo_delivery/ui/screens/home/local_widgets/new_terms_condition.dart';
import 'package:fraazo_delivery/ui/screens/home/local_widgets/order_issue_screen.dart';
import 'package:fraazo_delivery/ui/screens/home/local_widgets/support.dart';
import 'package:fraazo_delivery/ui/screens/home/performance/performance_screen.dart';
import 'package:fraazo_delivery/ui/screens/user/details/local_widgets/asset_details_widget.dart';
import 'package:fraazo_delivery/ui/screens/user/details/local_widgets/bank_details_widget.dart';
import 'package:fraazo_delivery/ui/screens/user/details/local_widgets/document/document_details.dart';
import 'package:fraazo_delivery/ui/screens/user/details/local_widgets/extra_user_details_widget.dart';
import 'package:fraazo_delivery/ui/screens/user/details/user_details_screen.dart';
import 'package:fraazo_delivery/ui/screens/user/local_widgets/basic_user_details_widget.dart';
import 'package:fraazo_delivery/ui/screens/user/login/login_screen.dart';
import 'package:fraazo_delivery/ui/screens/user/login/otp_verification/otp_verification_screen.dart';
import 'package:fraazo_delivery/ui/screens/user/login/password_reset_screen.dart';
import 'package:fraazo_delivery/ui/screens/user/service_details/service_details_screen.dart';

import '../../ui/screens/delivery/steps/new_order_sku_selection_sheet/order_sku_selection_sheet_screen.dart';

// ignore_for_file: cast_nullable_to_non_nullable
class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    final String? routeName = settings.name;
    Widget widget;
    switch (routeName) {
      case Routes.LOGIN:
        widget = const LoginScreen();
        break;
      case Routes.OTP_VERIFICATION:
        widget = OtpVerificationScreen(settings.arguments! as User);
        break;
      case Routes.PASSWORD_RESET:
        widget = PasswordResetScreen(settings.arguments! as String);
        break;
      case Routes.SIGN_UP:
        widget = const NewSignUpPage();
        break;
      case Routes.HOME:
        widget = const HomeScreen();
        break;
      case Routes.ExtraUserDetailsWidget:
        widget = const ExtraUserDetailsWidget();
        break;
      case Routes.DELIVERY_STEPS:
        widget = DeliveryStepsScreen(settings.arguments as Task?);
        break;
      case Routes.DELIVERY_TYPE_SELECTOR:
        widget = const DeliveryTypeSelectorScreen();
        break;

      case Routes.PARTIAL_AMOUNT_REASON:
        widget = PartialAmountReasonScreen(
            partialAmountType: settings.arguments as PartialAmountType);
        break;
      case Routes.SUPPORT_CALL_SCREEN:
        widget = const SupportCallScreen();
        break;
      case Routes.FLOATING_CASH:
        widget = const FloatingCashScreen();
        break;
      case Routes.UNSETTLED_ORDER_PAYMENT:
        widget = const UnsettledOrderPaymentScreen();
        break;
      case Routes.TRANSACTION:
        widget =
            TransactionScreen(transaction: settings.arguments as Transaction);
        break;
      case Routes.TRANSACTION_DETAIL:
        widget = TransactionDetailWidget(
            transaction: settings.arguments as Transaction);
        break;
      case Routes.TRANSACTION_HISTORY:
        widget = TransactionHistoryWidget(
          paymentHistoryList: settings.arguments as List<Transaction>,
        );
        break;
      case Routes.COD_TRANSACTION_DETAIL:
        widget = CODTransactionDetailScreen(
          codHistoryData: settings.arguments as CodHistory,
        );
        break;
      case Routes.HISTORY:
        widget = HistoryScreen(
            arguments: settings.arguments as Map<String, dynamic>?);
        break;
      case Routes.EARNINGS:
        widget = const EarningsScreen();
        break;
      case Routes.RIDER_ATTENDANCE:
        widget = const RiderAttendanceScreen();
        break;
      case Routes.USER_DETAILS:
        widget = const UserDetailScreen();
        break;

      case Routes.NO_ORDER_QR_CODE_SCANNER:
        widget = const NoOrderQrCodeScannerScreen();
        break;

      case Routes.QR_CODE_SCANNER:
        widget = QrCodeScannerScreen(
            arguments: settings.arguments as Map<String, dynamic>);
        break;

      case Routes.REGISTRATION_SCREEN:
        widget = RegistrationScreen(value: settings.arguments as bool);
        break;

      case Routes.TRAINING_SCREEN:
        widget = TrainingScreen();
        break;

      case Routes.SUCCESSFUL_REGISTRATION_SCREEN:
        widget = const SuccessfulRegistrationScreen();
        break;

      case Routes.BANK_DETAILS:
        widget = BankDetailsWidget();
        break;
      case Routes.DOCUMENT_DETAILS:
        widget = const DocumentDetails();
        break;
      case Routes.SERVICE_DETAILS:
        widget = const ServiceDetailScreen();
        break;
      case Routes.SET_PASSWORD_SCREEN:
        widget = const SetPasswordScreen();
        break;
      case Routes.BASIC_DETAILS:
        widget = const BasicUserDetailsWidget();
        break;
      case Routes.TERMS_CONDITIONS_SCREEN:
        widget = const NewTermsAndConditionsScreen();
        break;
      case Routes.SUPPORT_SCREEN:
        widget = const SupportScreen();
        break;
      case Routes.ASSET_MANAGEMENT_SCREEN:
        widget = const AssetDetailsWidget();
        break;
      case Routes.HOME_SCREEN:
        widget = const HomeScreen();
        break;
      case Routes.PERFORMANCE:
        widget = const PerformanceScreen();
        break;
      case Routes.REACHED_CUSTOMER:
        widget = NewMapScreen(settings.arguments as Task?);
        break;
      case Routes.DELIVERY_COMPLETED_SCREEN:
        widget = DeliveryCompletedScreen(settings.arguments as Task?);
        break;
      case Routes.ORDER_ISSUE_SCREEN:
        widget = OrderIssueScreen(settings.arguments as Task?);
        break;
      case Routes.NEW_ORDER_REASON_SCREEN:
        widget = NewOrderReasonScreen(
          settings.arguments as Map<String, dynamic>,
        );
        break;
      case Routes.CUSTOMER_NOT_AVAILABLE_SCREEN:
        widget = const CustomerNotAvailableScreen();
        break;
      case Routes.ORDER_PICKUP_SCREEN:
        widget = OrderSkusSelectionSheetScreen(
            settings.arguments as TaskModelHelper?);
        break;

      default:
        widget = const LoginScreen();
        break;
    }
    CrashlyticsService.instance.log("Route Name: $routeName");
    return MaterialPageRoute(
      builder: (context) => widget,
      settings: RouteSettings(name: routeName),
    );
  }
}
