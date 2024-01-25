import 'package:fraazo_delivery/utils/constants.dart';

mixin APIs {
  static const BASE = Constants.isProduction
      ? "api.rider.fraazo.com/v1"
      : "api.rider.staging.fraazo.com/v1";
  static const BASE_URL = "https://$BASE";
  static const RAZORPAY_BASE_URL = 'https://api.razorpay.com/v1';
  static const RIDER = "/rider";
  static const ADMIN = "/admin";
  static const APP = "/app";
  static const DASHBOARD = "/dashboard";
  static const UPDATED_BASE = Constants.isProduction
      ? "api.rider.fraazo.com/v2"
      : "api.rider.staging.fraazo.com/v1";
  static const UPDATED_BASE_URL = "https://$UPDATED_BASE";

  // Login
  static const SEND_OTP = "/send-otp";
  static const VERIFY_OTP = "/verify-otp";
  static const LOGIN = "/login";
  static const SIGNUP = "/signup";
  static const NEW_SIGNUP = "/new-ui/signup";

  static const RESET_PASSWORD = "/reset-password";
  static const UPDATE_PASSWORD = "/update-password";
  static const VERIFY_SIGNUP_OTP = "/verify-signup-otp";
  static const DELIVERY_PARTNERS = "/delivery-partners";
  static const STORES = "/stores";
  static const DEVICE_VERIFY = "/verify/rider/device";
  static const ADD_DEVICE = "/add/device";

  // User
  static const GO_ONLINE = "/go-online";
  static const LOCATION = "/location";
  static const DOCUMENT = "/document";
  static const GET_ORDER_COUNT = "/get-order-count";
  static const ACCOUNT = "/account";
  static const PENNY_CHECK = "/penny/check";
  static const RIDER_DETAILS = "/rider-details";
  static const VEHICLE_TYPE = "/vehicle-type";
  static const CITIES = "/cities";
  static const CREATE_PASSWORD = "/create-password";
  static const SETTLEMENT_CODE = "/settlement_code";
  static const RIDER__ACCEPT_TNC = "/rider/accept-tnc";
  static const RIDER__SHIFT_TIME = "/rider/shift-time";
  static const RIDER__DETAILS__INSERTION = "/rider/details/insertion";
  static const RIDER__DETAILS__GET = "/rider/details/get";
  static const RIDER__APPDISPLAY__TRAINING =
      "/rider/appdisplay/Test_Training_video1";
  static const SELFIE = "/selfie";
  static const LOGIN_HOURS = "/login-dash";
  static const MAPPING = "/mapping";

  static const PAYMENT__QR_GENERATE = "/payment/qr-generate";
  static const QR__PAYMENT_VERIFY = "/qr/payment-verify";
  static const RIDER__PERFORMANCE = "/rider/performance";
  static const RIDER__APP__FLAGS = "/rider/app/flags";
  // Cash Deposit
  static const RIDER__LIST__OUTSTANDING__AMOUNT =
      "/rider/list/outstanding/amount";
  static const LIST__RIDER__RAZORPAY__PAYMENT__HISTORY =
      "/list/rider/razorpay/payment/history";
  static const RIDER__CALCULATE__AMOUNT__CREATE__RAZOR_PAY__ORDER =
      "/rider/calculate/amount/create/razor_pay/order";
  static const RIDER__VERIFY__RAZOR_PAY__PAYMENT =
      "/rider/verify/razor_pay/payment";
  static const LIST__RIDER__COD__SETTLEMENT__HISTORY =
      "/list/rider/cod/settlement/history";

  static const ORDER_AMOUNT_HISTORY =
      "/list/rider/razorpay/payment/order-amount-history";

  // Delivery
  static const ORDER = "/order";
  static const DELIVERY = "/delivery";
  static const AMOUNT = "/amount";
  static const UPDATE = "/update";
  static const TASK = "/task";
  static const GET_LATEST_TASK = "/get-latest-task";
  static const GET_TASK_HISTORY = "/get-task-history";
  static const IMAGE = "/image";
  static const EARNING__LIST = "/earning/list";
  static const DELIVERY_SMS = "/delivery-sms";
  static const ITEMS = "/items";
  static const DAILY__BILLS = "/daily/bills";
  static const ASSIGN_TASK_QR = "/assign/task/qr";
  static const RIDER__STATUS_CHANGE__APPROACHING =
      "/rider/status-change/approaching";
  static const RIDER__PAYPLAN = "/rider/payplan";

  // Asset Management
  static const RIDER_ASSET__INVENTORY__FETCH__MUM_DC_3 =
      '/rider-asset/inventory/fetch/Mum-DC-3';
  static const RIDER_ASSET__FETCH = '/rider-asset/fetch';
  static const RIDER_ASSET__UPDATESTATUS = '/rider-asset/updatestatus';
  static const RIDER_ASSET__FETCH__ACCEPTED = '/rider-asset/fetch/accepted';
  static const RIDER_ASSET__INITIATE = '/rider-asset/initiate';
  static const RIDER_ASSET__UPDATE = '/rider-asset/update';

  // Return Inventory
  static const RIDER__TASK__ORDER = '/rider/task/multi-order';
  // Home page
  static const EARNINGS_ORDERS_DAILY = '/rider/homescreen/data';
  static const WEEKLY_EARNINGS = '/rider/earning/list';

  // WebSocket URL
  static const WS__GET_TASK = "wss://$BASE/ws/get-task";
  static const BANKLIST = '/list/bank/list';

  static const RELATIONLIST = '/relation/types';
  static const AVATAR = '/appdisplay/';
  static const DEATILS = '/details';
  static const BASIC_INFO_INSERT = '/insert';
  static const GET_TESTIMONIAL = '/testimonial/template/get';
  static const GET_LANDING_PAGE_INFO = '/appdisplay/landing_page';
  static const ZENDESK_TICKET = '/payment/qr-refund/zendesk-ticket';

  static const SELFIE_ENABLED_STATUS = '/feature/';
  static const PROXIMITY_VALIDATE = '/proximity-validate';
}
