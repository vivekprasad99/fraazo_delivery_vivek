import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:battery_plus/battery_plus.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fraazo_delivery/helpers/date/date_formatter.dart';
import 'package:fraazo_delivery/helpers/enums/app_update_type.dart';
import 'package:fraazo_delivery/helpers/error/error_reporter.dart';
import 'package:fraazo_delivery/helpers/extensions/string_extension.dart';
import 'package:fraazo_delivery/helpers/route/route_helper.dart';
import 'package:fraazo_delivery/helpers/route/routes.dart';
import 'package:fraazo_delivery/helpers/shared_pref/pref_helper.dart';
import 'package:fraazo_delivery/helpers/shared_pref/pref_keys.dart';
import 'package:fraazo_delivery/models/delivery/task_model.dart';
import 'package:fraazo_delivery/models/delivery/task_status_model.dart';
import 'package:fraazo_delivery/models/home_page/earning_daily_order_model.dart';
import 'package:fraazo_delivery/models/home_page/week_stat_model.dart';
import 'package:fraazo_delivery/models/user/device_verification_model.dart';
import 'package:fraazo_delivery/models/user/profile/user_model.dart';
import 'package:fraazo_delivery/permission_handler/device_tagging_handler.dart';
import 'package:fraazo_delivery/permission_handler/phone_permission_handler.dart';
import 'package:fraazo_delivery/providers/asset_management/rider_asset_provider.dart';
import 'package:fraazo_delivery/providers/delivery/latest_task_provider.dart';
import 'package:fraazo_delivery/providers/delivery/order/order_update_provider.dart';
import 'package:fraazo_delivery/providers/delivery/task_by_socket_provider.dart';
import 'package:fraazo_delivery/providers/delivery/task_update_provider.dart';
import 'package:fraazo_delivery/providers/home_button_tab/home_button_tab_provider.dart';
import 'package:fraazo_delivery/providers/home_screen/earning_daily_order_provider.dart';
import 'package:fraazo_delivery/providers/home_screen/week_stat_provider.dart';
import 'package:fraazo_delivery/providers/location/location_provider.dart';
import 'package:fraazo_delivery/providers/misc/api_logger_provider.dart';
import 'package:fraazo_delivery/providers/user/profile/user_profile_provider.dart';
import 'package:fraazo_delivery/services/api/delivery/delivery_service.dart';
import 'package:fraazo_delivery/services/api/user/user_service.dart';
import 'package:fraazo_delivery/services/know_notification/know_notification_service.dart';
import 'package:fraazo_delivery/services/location/gps_service.dart';
import 'package:fraazo_delivery/services/media/sound/feedback_service.dart';
import 'package:fraazo_delivery/services/sdk/firebase/firebase_notification_service.dart';
import 'package:fraazo_delivery/ui/global_widgets/fd_circular_loader.dart';
import 'package:fraazo_delivery/ui/global_widgets/fd_error_widget.dart';
import 'package:fraazo_delivery/ui/screen_widgets/dialogs/app_update_dialog.dart';
import 'package:fraazo_delivery/ui/screen_widgets/dialogs/asset_assign_dialog.dart';
import 'package:fraazo_delivery/ui/screen_widgets/dummy_location_switch.dart';
import 'package:fraazo_delivery/ui/screen_widgets/stat_widget.dart';
import 'package:fraazo_delivery/ui/screens/delivery/steps/delivery_type_process/local_widgets/delivery_now_dialog.dart';
import 'package:fraazo_delivery/ui/screens/delivery/steps/support/freshchat_service.dart';
import 'package:fraazo_delivery/ui/screens/home/local_widgets/drawer_menu.dart';
import 'package:fraazo_delivery/ui/screens/home/local_widgets/go_online_and_task_widget.dart';
import 'package:fraazo_delivery/ui/screens/home/local_widgets/home_appbar.dart';
import 'package:fraazo_delivery/ui/screens/home/local_widgets/home_button_widget.dart';
import 'package:fraazo_delivery/ui/screens/home/local_widgets/password_input_dialog.dart';
import 'package:fraazo_delivery/ui/screens/home/local_widgets/terms_and_conditions_dialog.dart';
import 'package:fraazo_delivery/ui/screens/home/performance/performance_screen.dart';
import 'package:fraazo_delivery/ui/screens/user/local_widgets/device_verification_alert.dart';
import 'package:fraazo_delivery/ui/screens/user/login/login_screen.dart';
import 'package:fraazo_delivery/ui/utils/textview.dart';
import 'package:fraazo_delivery/ui/utils/toast.dart';
import 'package:fraazo_delivery/ui/utils/widgets_and_attributes.dart';
import 'package:fraazo_delivery/utils/constants.dart';
import 'package:fraazo_delivery/utils/globals.dart';
import 'package:fraazo_delivery/utils/utils.dart';
import 'package:fraazo_delivery/values/custom_colors.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../../models/misc/AppMappingModel.dart';

final buttonChooseProvider =
    ChangeNotifierProvider((ref) => HomeButtonTabProvider());

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  bool _isNewStatusReceived = false;
  final knowNotificationService = KnowNotificationService();
  final _userService = UserService();
  RefreshController? _refreshController;

  final Battery _battery = Battery();
  final _deliveryService = DeliveryService();
  final _phonePermissionHandler = PhonePermissionHandler();

  @override
  void initState() {
    _refreshController = RefreshController(initialRefresh: false);
    super.initState();
    callMapping();
    _getWeekStatsFromApi();
    _getEarningDailyOrdersApi();
    _userService.getSelfieEnableStatus();
    context.read(locationProvider.notifier).init();
    Globals.checkAndShowMockLocationDialog();
    _checkAppUpdateOrForPassword();
    FreshchatService.instance.setUserProperties(Globals.user!);
    _setSocketListener();
    FirebaseNotificationService.onNewNotificationInForeground(
      onNewNotification: _onNewNotification,
    );
    if (!Globals.user!.tncAccepted) {
      SchedulerBinding.instance?.addPostFrameCallback((_) {
        _openTermsAndConditionsDialog();
      });
    }
    initialisedKnow();
    isDeviceTagged();
    getModel();
    if (Globals.isRiderAvailable) {}
    WidgetsBinding.instance?.addObserver(this);
  }

  final _deviceTaggingHandler = DeviceTaggingHandler();
  Map<String, String> deviceModelNo = {};

  Future getModel() async {
    deviceModelNo = await _phonePermissionHandler.getModel();
  }

  void _getWeekStatsFromApi() {
    final dateFormatter = DateFormatter();
    context.read(weekStatProvider.notifier).getWeekStats(
          fromDate: dateFormatter.firstDateOfTheWeek(),
          toDate: dateFormatter.lastDateOfTheWeek(),
        );
  }

  void _getEarningDailyOrdersApi() async {
    final int batteryLevel = await _battery.batteryLevel;
    await context.read(dailyEarningProvider.notifier).getEarningAndOrdersDaily(
        riderId: Globals.user?.id ?? 0, batteryLevel: batteryLevel);
    // Future.delayed(const Duration(seconds: 3));
    _refreshController?.refreshFailed();
  }

  Future getNotificationInfo() async {
    FirebaseMessaging.instance.getInitialMessage().then((value) {
      if (value != null && value.data.containsKey('classification_type')) {
        final Map<String, String> notificationInfo = {
          "type": value.data["classification_type"],
          "id": value.data["nugget_id"],
        };
        knowNotificationService.knowReadEvent(notificationInfo);
        knowNotificationService.openNotificationList();
      }
    });
  }

  void initialisedKnow() {
    final Map<String, String?> userInfo = {
      'mobileNo': Globals.user?.mobile,
      'id': Globals.user?.id.toString(),
      'firstName': Globals.user?.firstName,
      'lastName': Globals.user?.lastName,
      'city': Globals.user?.city ?? '',
      'store': Globals.user?.storeName,
      'shift': Globals.user?.storeName,
      'status': Globals.user?.status,
    };

    // tags.add("City")
    // tags.add("Dark store")
    // tags.add("Shift")
    // tags.add("Rider Status")
    knowNotificationService.initialise(userInfo);
    getNotificationInfo();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarBrightness: Brightness.dark,
      ),
    );
    return WillPopScope(
      onWillPop: _onBackPressed,
      child: Scaffold(
        backgroundColor: bgColor,
        appBar: HomeAppbar(knowNotificationService: knowNotificationService),
        drawer: const DrawerMenu(),
        body: _buildBody(),
        bottomNavigationBar: const DummyLocationSwitch(),
      ),
    );
  }

  Widget _buildBody() {
    return Column(
      children: [
        //const OfflineWarningWidget(),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: TextView(
            title: "Namaste, ${Globals.user?.firstName}",
            textStyle: commonTextStyle(fontSize: 22, color: Colors.white),
          ),
        ),
        const Divider(
          color: borderLineColor,
        ),

        Expanded(
          child: SmartRefresher(
            enablePullUp: false,
            enablePullDown: true,
            controller: _refreshController!,
            header: const MaterialClassicHeader(color: bgColor),
            onRefresh: () async {
              callMapping();
              _getWeekStatsFromApi();
              _getEarningDailyOrdersApi();
              context.read(latestTaskProvider.notifier).getLatestTask();
              context.read(userProfileProvider.notifier).getUserDetails();
              context.read(riderAssetProvider.notifier).getRiderAssetFetch();
            },
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Stack(
                    children: [
                      Visibility(
                        visible: Globals.user!.billingEnabled!,
                        child: Consumer(
                          builder: (_, watch, __) {
                            final locationProviderValue =
                                watch(locationProvider);
                            final buttonChoose = watch(buttonChooseProvider);
                            if (locationProviderValue.isServiceRunning) {
                              return (buttonChoose.isSelectedButton[0])
                                  ? Positioned(
                                      right: 20,
                                      top: 4,
                                      child: Hero(
                                        tag: "rider_logo",
                                        child: SvgPicture.asset(
                                          'rider_online'.svgImageAsset,
                                          height: 95,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    )
                                  : const SizedBox();
                            } else {
                              return (buttonChoose.isSelectedButton[0])
                                  ? Positioned(
                                      right: 20,
                                      top: -4,
                                      child: SvgPicture.asset(
                                        'rider_offline'.svgImageAsset,
                                        height: 140,
                                        fit: BoxFit.cover,
                                      ),
                                    )
                                  : const SizedBox();
                            }
                          },
                        ),
                      ),
                      Consumer(
                        builder: (_, watch, __) {
                          final buttonChoose = watch(buttonChooseProvider);
                          return Column(
                            children: [
                              const HomeButtonWidget(),
                              sizedBoxH5,
                              if (buttonChoose.isSelectedButton[0]) ...[
                                _buildHomeTab()
                              ] else ...[
                                const PerformanceScreen()
                              ],
                            ],
                          );
                        },
                      )
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _thisWeekStats() {
    return Consumer(
      builder: (_, watch, __) {
        return watch(weekStatProvider).when(
          data: (WeekModel? weekModel) {
            final weekData = weekModel?.data;
            return Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                //color: buttonInActiveColor,
                gradient: const LinearGradient(
                  colors: [
                    Color.fromRGBO(255, 255, 255, 0.24),
                    Color.fromRGBO(255, 255, 255, 0.08),
                  ],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  IntrinsicHeight(
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              TextView(
                                title: "Earnings",
                                textStyle: commonTextStyle(
                                  fontSize: 10,
                                  color: Colors.white70,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              TextView(
                                title: "₹${weekData?.totalAmount ?? 0}",
                                textOverflow: TextOverflow.ellipsis,
                                textStyle: commonPoppinsStyle(
                                  fontSize: 13,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                        sizedBoxW30,
                        const VerticalDivider(
                          color: Color(0xff6F6F6F),
                          thickness: 1,
                        ),
                        sizedBoxW30,
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              TextView(
                                title: "Orders",
                                textStyle: commonTextStyle(
                                  fontSize: 10,
                                  color: Colors.white70,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              TextView(
                                title: "${weekData?.totalOrders ?? 0}",
                                textStyle: commonPoppinsStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                        sizedBoxW30,
                        const VerticalDivider(
                          color: Color(0xff6F6F6F),
                          thickness: 1,
                        ),
                        sizedBoxW30,
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              FittedBox(
                                child: TextView(
                                  title: "Days Present",
                                  textStyle: commonTextStyle(
                                    fontSize: 10,
                                    color: Colors.white70,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              TextView(
                                title: '${weekData?.loggedInHours ?? 0}',
                                textAlign: TextAlign.center,
                                textOverflow: TextOverflow.ellipsis,
                                textStyle: commonPoppinsStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                ),
                                /*textStyle: const TextStyle(
                                  fontSize: 24,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),*/
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Visibility(
                    visible: weekData?.bannerIncentive != 0,
                    child: Column(
                      children: [
                        sizedBoxH15,
                        Container(
                          width: double.maxFinite,
                          padding: const EdgeInsets.all(9),
                          decoration: BoxDecoration(
                            color: const Color(0xffE9E9E9),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: FittedBox(
                            fit: BoxFit.fitWidth,
                            child: TextView(
                              title:
                                  "Be available everyday to get an incentive up to ₹${weekData?.bannerIncentive ?? 0}",
                              textStyle: commonTextStyle(
                                fontSize: 11,
                                color: const Color(0xff303030),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
          loading: () => const FDCircularLoader(
            progressColor: Colors.white,
          ),
          error: (e, _) => FDErrorWidget(
            textColor: Colors.white,
            onPressed: _getWeekStatsFromApi,
            errorType: e,
          ),
        );
      },
    );
  }

  Widget _takeBreakWidget(EarningAndDailyOrderModel? weekData) {
    return Consumer(
      builder: (_, watch, __) {
        final locationProviderValue = watch(locationProvider);
        return CarouselSlider(
          items: weekData!.imageText!.map((element) {
            return Container(
              padding: const EdgeInsets.all(8),
              height: 60,
              decoration: locationProviderValue.isServiceRunning
                  ? BoxDecoration(
                      color: element.notificationType == 'GREET_BIRTHDAY'
                          ? const Color(0xff6259DC)
                          : (element.notificationType == 'NEW_JOINEES')
                              ? const Color(0xff7F58B7)
                              : const Color(0xff555555),
                      borderRadius: BorderRadius.circular(5),
                    )
                  : BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color.fromRGBO(198, 51, 51, 1),
                          Color.fromRGBO(171, 31, 31, 1),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(5),
                    ),
              child: Row(
                children: [
                  Visibility(
                    visible: !locationProviderValue.isServiceRunning,
                    child: SvgPicture.asset(
                      'offline_person'.svgImageAsset,
                      height: 45,
                    ),
                  ),
                  ...List.generate(min(2, element.image?.length ?? 0), (index) {
                    return Visibility(
                      visible: locationProviderValue.isServiceRunning,
                      child: element.image![index].contains('svg')
                          ? SvgPicture.network(
                              element.image![index],
                              height: 45,
                              width: 45,
                              placeholderBuilder: (BuildContext context) =>
                                  const Icon(
                                Icons.error,
                                color: textColor,
                                size: 20,
                              ),
                              fit: BoxFit.cover,
                            )
                          : Visibility(
                              visible: element.notificationType !=
                                      'GREET_BIRTHDAY' &&
                                  element.notificationType != 'NEW_JOINEES',
                              child: ClipOval(
                                child: CachedNetworkImage(
                                  imageUrl: element.image![index],
                                  height: 45,
                                  width: 45,
                                  fit: BoxFit.fill,
                                  placeholder: (context, url) => const Center(
                                      child: Padding(
                                    padding: EdgeInsets.all(4.0),
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                    ),
                                  )),
                                  errorWidget: (context, url, error) =>
                                      const Icon(Icons.error),
                                ),
                              ),
                            ),
                    );
                  }),
                  sizedBoxW10,
                  if (locationProviderValue.isServiceRunning) ...[
                    Expanded(
                      child: Column(
                        children: [
                          Visibility(
                            visible:
                                element.notificationType == 'GREET_BIRTHDAY' ||
                                    element.notificationType == 'NEW_JOINEES',
                            child: Expanded(
                              child: TextView(
                                title:
                                    element.notificationType == 'GREET_BIRTHDAY'
                                        ? "Happy Birthday"
                                        : "Welcoming New Partners",
                                textStyle: commonPoppinsStyle(
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: TextView(
                              title: "${element.text}",
                              textStyle: element.notificationType ==
                                          'GREET_BIRTHDAY' ||
                                      element.notificationType == 'NEW_JOINEES'
                                  ? commonPoppinsStyle(
                                      fontSize: 9,
                                    )
                                  : commonPoppinsStyle(
                                      fontSize: 13,
                                    ),
                            ),
                          ),
                        ],
                      ),
                    )
                  ] else ...[
                    Expanded(
                      child: TextView(
                        title:
                            "You are offline currently, Go online to start getting orders",
                        textStyle: commonTextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                  sizedBoxW10,
                  ...List.generate(min(2, element.image?.length ?? 0), (index) {
                    return Visibility(
                      visible: locationProviderValue.isServiceRunning,
                      child: Visibility(
                        visible: element.notificationType == 'GREET_BIRTHDAY' ||
                            element.notificationType == 'NEW_JOINEES',
                        child: ClipOval(
                          child: CachedNetworkImage(
                            imageUrl: element.image![index],
                            height: 45,
                            width: 45,
                            fit: BoxFit.fill,
                            placeholder: (context, url) => const Center(
                                child: Padding(
                              padding: EdgeInsets.all(4.0),
                              child: CircularProgressIndicator(
                                color: Colors.white,
                              ),
                            )),
                            errorWidget: (context, url, error) =>
                                const Icon(Icons.error),
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            );
          }).toList(),
          options: CarouselOptions(
              height: 60,
              viewportFraction: 1,
              autoPlay: true,
              autoPlayInterval: const Duration(seconds: 30)),
        );
      },
    );
  }

  Widget _buildHomeTab() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Visibility(
            visible: Globals.user!.billingEnabled!,
            child: Column(
              children: [
                TextView(
                  title: "This Week",
                  textStyle: commonTextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                sizedBoxH10,
                _thisWeekStats(),
              ],
            ),
          ),
          sizedBoxH15,
          Consumer(
            builder: (_, watch, __) {
              return watch(dailyEarningProvider).when(
                data: (EarningAndDailyOrderModel? earningAndDailyOrderModel) {
                  return Column(
                    children: [
                      _takeBreakWidget(earningAndDailyOrderModel),
                      sizedBoxH15,
                      StatWidget(earningAndDailyOrderModel, isClickable: true),
                    ],
                  );
                },
                loading: () => const FDCircularLoader(),
                error: (e, _) => FDErrorWidget(
                  onPressed: _getEarningDailyOrdersApi,
                  errorType: e,
                ),
              );
            },
          ),
          sizedBoxH20,
          const GoOnlineAndTaskWidget(),
          sizedBoxH15,
        ],
      ),
    );
  }

  void _checkAppUpdateOrForPassword() {
    if (Globals.appUpdateType == AppUpdateType.RECOMMENDED_APP_VERSION) {
      SchedulerBinding.instance?.addPostFrameCallback((timeStamp) {
        RouteHelper.openDialog(AppUpdateDialog(Globals.appUpdateType));
      });
    } else {
      _openPasswordInputDialog();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.resumed:
        context.read(locationProvider).checkForGPSStatus();
        Globals.checkAndShowMockLocationDialog();
        if (PrefHelper.getBool('notification_type')) {
          PrefHelper.setValue('notification_type', false);
          context.read(locationProvider.notifier).markOfflineWithNotification();
          context.read(locationProvider.notifier).isServiceRunning = false;
          context.read(locationProvider.notifier).notify();
        } else if (PrefHelper.getBool('isAsset_type') &&
            PrefHelper.getBool(PrefKeys.IS_ASSET_ENABLE)) {
          PrefHelper.setValue('isAsset_type', false);
          Globals.notificationType = '';
          _openAssetManagementDialog();
        }
        break;
      default:
        break;
    }
  }

  Future<bool> _onBackPressed() async {
    try {
      WidgetsBinding.instance?.removeObserver(this);
      if (Constants.isTestMode) {
        ApiLoggerProvider().dispose();
      }
      context.read(taskBySocketProvider.notifier).close();

      GPSService().dispose();
    } catch (e, st) {
      ErrorReporter.error(e, st, "HomeScreen: _onBackPressed()");
    }
    return true;
  }

  void _setSocketListener() {
    context.read(taskBySocketProvider.notifier)
      ..open()
      ..addListener(
        (TaskStatusModel? taskStatus) {
          _onNewStatus(taskStatus?.type, orderNumber: taskStatus?.orderNumber);
          context
              .read(latestTaskProvider.notifier)
              .setNewTask(taskStatus?.task);
          if (taskStatus?.task != null && taskStatus?.type == "") {
            FeedbackService().triggerAlert();
          }
        },
        fireImmediately: false,
      );
  }

  Future _onNewNotification(String? taskStatus, {String? orderNumber}) async {
    if (taskStatus == 'Please open app.') {
      context.read(locationProvider.notifier).notify();
      PrefHelper.setValue(PrefKeys.IS_NEW_NOTIFICATION, true);
    } else if (Globals.notificationType == 'ASSET_ASSIGN' &&
        PrefHelper.getBool(PrefKeys.IS_ASSET_ENABLE)) {
      Globals.notificationType = '';
      _openAssetManagementDialog();
    } else if (Globals.notificationType == 'MARK_OFFLINE') {
      Globals.notificationType = '';
      // context
      //     .read(locationProvider.notifier)
      //     .setOnlineStatus(Constants.US_OFFLINE, '');
      context.read(locationProvider.notifier).markOfflineWithNotification();
      context.read(locationProvider.notifier).isServiceRunning = false;
      context.read(locationProvider.notifier).notify();
    } else if (Globals.returnInventory.contains('rescheduled')) {
      _onTaskCompleted(
          orderNumber: orderNumber ?? '',
          orderStatus: Constants.OS_RESCHEDULED);
    } else if (Globals.returnInventory.contains('completed')) {
      _onTaskCompleted(
          orderNumber: orderNumber ?? '', orderStatus: Constants.OS_DELIVERED);
    } else if (Globals.returnInventory.contains('Task cancelled')) {
      _onTaskCompleted(
          orderNumber: orderNumber ?? '', orderStatus: Constants.TS_DELETE);
    } else {
      // if (orderNumber == null || orderNumber.isEmpty) {
      //   context.read(userProfileProvider.notifier).getUserDetails();
      //
      //   context.read(latestTaskProvider.notifier).setNewTask(null);
      //   return;
      // }

      final _orderSeqList =
          context.read(latestTaskProvider.notifier).state.data?.value?.orderSeq;

      final OrderSeq? _orderSeq = _orderSeqList
          ?.where((element) => element.orderNumber == orderNumber)
          .toList()
          .single;

      if (taskStatus == Constants.TS_PAYMENT_SUCCESS) {
        context.read(orderUpdateProvider.notifier).endOrderDelivery(
              context.read(latestTaskProvider.notifier).currentTask!.id!,
              orderSeq: _orderSeq,
            );
      }
      final Task? task =
          await context.read(latestTaskProvider.notifier).getLatestTask();
      context.read(userProfileProvider.notifier).getUserDetails();
      context.read(riderAssetProvider.notifier).getRiderAssetFetch();

      if (task != null) {
        final OrderSeq? orderSeq = task.orderSeq
            ?.where((element) => element.orderNumber == orderNumber)
            .single;
        _onNewStatus(
          orderSeq?.orderStatus ?? '',
          orderNumber: orderNumber,
        );
      }
    }
  }

  void _onNewStatus(String? status, {String? orderNumber}) {
    if (!_isNewStatusReceived) {
      _isNewStatusReceived = true;
      if (status == Constants.OS_DELIVERED ||
          status == Constants.OS_CANCELLED_BY_FRZ ||
          status == Constants.OS_RESCHEDULED) {
        _onTaskCompleted(
          orderNumber: orderNumber ?? '',
          orderStatus: status == Constants.OS_RESCHEDULED ? (status ?? '') : '',
        );
      } else if (status == Constants.TS_DELETE) {
        _onTaskCompleted(
            orderNumber: orderNumber ?? '', orderStatus: status ?? '');
      } else if (status == Constants.OS_REATTEMPT_DELIVERY) {
        _showDeliveryNowDialog(orderNumber: orderNumber ?? '');
      }
      Future.delayed(const Duration(seconds: 2), () {
        _isNewStatusReceived = false;
      });
    }

    if (status == Constants.OS_CREATED) {
      PrefHelper.setValue(PrefKeys.IS_NEW_ORDER, true);
      PrefHelper.setValue(PrefKeys.IS_CALL_ENABLE, false);
    }
  }

  void _openAssetManagementDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) =>
          Container(height: double.maxFinite, child: const AssetAssignDialog()),
    );
  }

  void _openPasswordInputDialog() {
    SchedulerBinding.instance?.addPostFrameCallback((_) {
      if (!(Globals.user?.passwordSet ?? true)) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => const PasswordInputDialog(),
        );
      }
    });
  }

  Future _showDeliveryNowDialog({required String orderNumber}) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => DeliveryNowDialog(
        orderNumber: orderNumber,
      ),
    );
  }

  Future _openTermsAndConditionsDialog() {
    return showDialog(
      context: context,
      builder: (_) => const TermsAndConditionsDialog(),
    );
  }

  Future _onTaskCompleted({
    required String orderNumber,
    String orderStatus = '',
  }) async {
    await context.read(latestTaskProvider.notifier).getLatestTask();
    final List<OrderSeq> orderSeqList =
        context.read(latestTaskProvider.notifier).state.data?.value?.orderSeq ??
            [];
    // final bool isSignleOrder = orderSeqList!=null?orderSeqList.length == 1:false;

    if (orderSeqList.isNotEmpty) {
      if (orderSeqList.last.orderStatus == Constants.OS_DELIVERED ||
          orderSeqList.last.orderStatus == Constants.OS_CANCELLED_BY_FRZ ||
          orderSeqList.last.orderStatus == Constants.OS_RESCHEDULED) {
        return context.read(taskUpdateProvider.notifier).onTaskComplete(
            orderSeqList.last.taskId,
            orderNumber: '',
            orderStatus: orderStatus,
            isSingleOrder: orderSeqList.length == 1);
      } else {
        return context.read(taskUpdateProvider.notifier).onCompleteOperations(
            orderNumber: orderNumber,
            orderStatus: orderStatus,
            isSingleOrder: orderSeqList.length == 1);
      }
    } else {
      return context.read(taskUpdateProvider.notifier).onCompleteOperations(
          orderNumber: orderNumber,
          orderStatus: orderStatus,
          isSingleOrder: true);
    }
  }

  Future<void> isDeviceTagged() async {
    List<String> _list = <String>[];
    final _isPermissionAccepted =
        await _phonePermissionHandler.isPermissionAccepted();
    if (_isPermissionAccepted) {
      _list = await _phonePermissionHandler.getIMEIs();
    }
    await context.read(userProfileProvider.notifier).getUserDetails();
    UserModel userModel = context.read(userProfileProvider.notifier).userModel;
    if (!(userModel.deviceTagged ?? true)) {
      _deviceTaggingHandler.errorResponse(
        "home",
        _list,
        deviceModelNo['modelNo'] ?? '',
        mobileNo: Globals.user!.mobile,
      );
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance?.removeObserver(this);
    super.dispose();
  }

  void callMapping() async {
    try {
      AppMappingModel appMapping = await _deliveryService.getAppMappingData();
      Globals.mappingData = appMapping.data!;
    } on Exception catch (e) {
      // TODO
    }
  }
}
