import 'package:flutter/foundation.dart';

class Constants {
  // Passed arguments from AS configurations with --dart-define
  static const isProduction =
      String.fromEnvironment("env", defaultValue: "prod") == "prod";
  static const isProductionRelease = isProduction && kReleaseMode;
  static const isTestMode = !isProductionRelease;

  static const OS_CREATED = "CREATED";
  static const OS_DELIVERY_STARTED = "DELIVERY_STARTED";
  static const OS_DELIVERED = "DELIVERED";
  // static const OS_REJECTED_BY_CUSTOMER = "REJECTED_BY_CUSTOMER";
  static const OS_CUSTOMER_NOT_AVAILABLE = "CUSTOMER_NOT_AVAILABLE";
  static const OS_REATTEMPT_DELIVERY = "REATTEMPT_DELIVERY";
  static const OS_REACHED_CUSTOMER = "REACHED_CUSTOMER";
  static const OS_RESCHEDULED = "RESHEDULED";
  static const OS_CANCELLED_BY_FRZ = "CANCELLED_BY_FRAAZO";

  static const TS_RIDER_ASSIGNED = "RIDER_ASSIGNED";
  static const TS_PICKUP_STARTED = "PICKUP_STARTED";
  static const TS_DELIVERY_STARTED = "DELIVERY_STARTED";
  static const TS_COMPLETED = "COMPLETED";
  static const TS_DELETE = "DELETE";
  static const TS_PAYMENT_SUCCESS = "PAYMENT_SUCCESS";

  static const US_ONLINE = "ONLINE";
  static const US_BUSY = "BUSY";
  static const US_OFFLINE = "OFFLINE";
  static const US_APPROACHING = "APPROACHING";

  static const DH_START_DATE = "Start Date";
  static const DH_END_DATE = "End Date";

  static const SUPPORT_PHONE_NUMBER = "+918976919118";
  static String notificationType = '';

  //Device verification
  static const DV_DEVICE_DETAILS_MISSING = 'DEVICE_DETAILS_MISSING';
  static const DV_DEVICE_VERIFIED = 'DEVICE_VERIFIED';
  static const DV_ANOTHER_DEVICE_LOGIN = 'ANOTHER_DEVICE_LOGGEDIN';
}
