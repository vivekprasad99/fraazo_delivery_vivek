import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fraazo_delivery/helpers/api/api_call_helper.dart';
import 'package:fraazo_delivery/helpers/enums/app_update_type.dart';
import 'package:fraazo_delivery/helpers/error/error_reporter.dart';
import 'package:fraazo_delivery/helpers/route/route_helper.dart';
import 'package:fraazo_delivery/helpers/route/routes.dart';
import 'package:fraazo_delivery/helpers/shared_pref/pref_helper.dart';
import 'package:fraazo_delivery/helpers/shared_pref/pref_keys.dart';
import 'package:fraazo_delivery/models/user/landing_page_model.dart';
import 'package:fraazo_delivery/providers/app_info/app_update_checker_provider.dart';
import 'package:fraazo_delivery/providers/location/location_provider.dart';
import 'package:fraazo_delivery/providers/user/profile/user_profile_provider.dart';
import 'package:fraazo_delivery/screen_modules/onboarding/ui/onboarding_screen.dart';
import 'package:fraazo_delivery/services/location/background_location_service.dart';
import 'package:fraazo_delivery/services/sdk/firebase/crashlytics_service.dart';
import 'package:fraazo_delivery/services/sdk/firebase/firebase_notification_service.dart';
import 'package:fraazo_delivery/services/sdk/sentry/sentry_service.dart';
import 'package:fraazo_delivery/ui/screen_widgets/dialogs/app_update_dialog.dart';
import 'package:fraazo_delivery/ui/screens/delivery/steps/support/freshchat_service.dart';
import 'package:fraazo_delivery/ui/utils/toast.dart';
import 'package:fraazo_delivery/utils/globals.dart';
import 'package:get/get.dart';
import 'package:restart_app/restart_app.dart';

import '../../services/api/user/user_service.dart';
import '../../services/know_notification/know_notification_service.dart';
import '../../ui/screens/delivery/steps/support/freshchat_service.dart';

class AuthenticationProvider extends StateNotifier<AsyncValue> {
  AuthenticationProvider([AsyncValue state = const AsyncLoading()])
      : super(state);
  AutoDisposeFutureProvider? onBoardingProvider;
  LandingPageModel? landingPageModel;
  final _userService = UserService();
  Future checkIfUserExistsAndNavigate() async {
    state = const AsyncLoading();
    try {
      final bool isUpdateAvailable = await _isForcedUpdateAvailable();

      if (!isUpdateAvailable) {
        CrashlyticsService.instance.initialise();
        FreshchatService.instance.initialise();
        await PrefHelper.getInstance();
        await AppUpdateCheckerProvider().checkForAssetManagement();
        //await Future.delayed(const Duration(seconds: 10));

        if (PrefHelper.containsKey(PrefKeys.AUTHORIZATION)) {
          await onAuthentication();
        } else {
          if (PrefHelper.getBool(PrefKeys.IS_SESSION_EXPIRED)) {
            Toast.normal("Session is expired. Please login again.");
            PrefHelper.removeValue(PrefKeys.IS_SESSION_EXPIRED);
          }
          if (!PrefHelper.getBool(PrefKeys.IS_SESSION_EXPIRED)) {
            // RouteHelper.pushReplacement(Routes.ONBOARDING_SCREEN,
            //     args: landingPageModel);
            landingPageModel = await getLandingPageInfo();
            Navigator.pushReplacement(Get.context!,
                MaterialPageRoute(builder: (context) {
              return OnBoardingScreen(
                landingPageModel: landingPageModel!,
              );
            }));
          } else {
            RouteHelper.pushReplacement(Routes.LOGIN);
          }
        }
      }
      state = const AsyncData(true);
    } catch (e, st) {
      state = AsyncError(e, st);
      ErrorReporter.error(
          e, st, "AuthenticationProvider: checkIfUserExistsAndNavigate()");
    }
  }

  // void getLandingPageInfo() async {
  //   FutureProvider.autoDispose(
  //     (ref) => ref
  //         .read(userProfileProvider.notifier)
  //         .getLandingPageInfo()
  //         .then((value) {
  //       landingPageModel = value;
  //     }).onError((error, stackTrace) {
  //       print('onError ${error.toString()}');
  //     }),
  //   );
  // }

  Future<LandingPageModel> getLandingPageInfo() async {
    return _userService.getLandingPageInfo();
  }

  Future onAuthentication() async {
    final String? deviceToken =
        await FirebaseNotificationService().getDeviceToken();
    FreshchatService.instance.registerForPushNotification(deviceToken!);
    await ProviderContainer()
        .read(userProfileProvider.notifier)
        .getUserDetails(deviceToken: deviceToken);

    FirebaseNotificationService().createNotificationChannel();
    await PrefHelper.setValue(PrefKeys.MOBILE_NO, Globals.user?.mobile);
    CrashlyticsService.instance.setUserProperties(Globals.user!);
    SentryService().setUserProperties(Globals.user!);

    if (Globals.user!.isVerified) {
      RouteHelper.pushAndPopOthers(Routes.HOME);
    } else {
      RouteHelper.pushAndPopOthers(Routes.REGISTRATION_SCREEN, args: true);
    }
  }

  Future<bool> _isForcedUpdateAvailable() async {
    await AppUpdateCheckerProvider().checkForAppUpdate();

    if (Globals.appUpdateType == AppUpdateType.FORCED_APP_VERSION) {
      RouteHelper.openDialog(AppUpdateDialog(Globals.appUpdateType),
          barrierDismissible: false);
      return true;
    }
    return false;
  }

  Future logout({bool checkPermission = true}) async {
    try {
      final cancelFunc = Toast.popupLoading(clickClose: true);
      final locationProviderValue =
          RouteHelper.navigatorContext.read(locationProvider.notifier);
      bool isSuccess = true;
      if (locationProviderValue.isServiceRunning) {
        isSuccess = await locationProviderValue.stopService(
            shouldCheckPermission: checkPermission);
      }
      cancelFunc();
      if (isSuccess) {
        await _performOnLogout();
        Globals.user = null;
        RouteHelper.pushAndPopOthers(Routes.LOGIN);
      }
    } catch (e) {
      await _logoutOn401();
      await _performOnLogout();
      Globals.user = null;
      Restart.restartApp();
    }
  }

  Future _logoutOn401() async {
    // Can't access providers here so better to call service directly to stop it
    final backgroundService = BackgroundLocationService();
    if (await backgroundService.isServiceRunning()) {
      await backgroundService.stopLocationService();
    }
  }

  final knowNotificationService = KnowNotificationService();

  Future _performOnLogout() async {
    int? buildNo = PrefHelper.getInt(PrefKeys.APP_BUILD_NO);
    String? appVersion = PrefHelper.getString(PrefKeys.APP_VERSION);
    await PrefHelper.clearAll();
    PrefHelper.setValue(PrefKeys.APP_VERSION, appVersion);
    PrefHelper.setValue(PrefKeys.APP_BUILD_NO, buildNo);
    final apiCallHelper = ApiCallHelper();
    apiCallHelper.clearRequestsQueue();
    apiCallHelper.clearHeaders();
    knowNotificationService.knowSignOut();
  }
}
