import 'package:fraazo_delivery/models/user/profile/user_model.dart';
import 'package:freshchat_sdk/freshchat_sdk.dart';
import 'package:freshchat_sdk/freshchat_user.dart';

import '../../../../../helpers/error/error_reporter.dart';
import '../../../../../services/sdk/base_analytics.dart';
import '../../../../../utils/sdk_keys.dart';

class FreshchatService extends BaseAnalytics {
  factory FreshchatService() {
    return instance;
  }

  FreshchatService._();

  static final FreshchatService instance = FreshchatService._();

  @override
  void initialise() {
    Freshchat.init(
      SDKKeys.FRESHDESK_APP_ID,
      SDKKeys.FRESHDESK_APP_KEY,
      "msdk.freshchat.com",
    );
  }

  @override
  Future setUserProperties(User user) async {
    try {
      // final user = uap.user;
      final FreshchatUser freshchatUser = await Freshchat.getUser;
      if (user.firstName != null) {
        freshchatUser.setFirstName(user.firstName ?? "");
        freshchatUser.setLastName(user.lastName ?? "");
        freshchatUser.setEmail(user.email ?? "");
      }
      freshchatUser.setPhone("+91", user.mobile!);
      Freshchat.setUser(freshchatUser);
      Freshchat.identifyUser(externalId: user.mobile!);
    } catch (e, st) {
      ErrorReporter.error(
        e,
        st,
        "FreshchatService: setUserProperties()",
      );
    }
  }

  void openChat() =>
      Freshchat.showConversations(filteredViewTitle: "Rider Support", tags: [
        "rider_support",
        "rider_help_support",
        "genral_query",
        "payout",
        "cod/upi"
      ]);

  void sendMessage(String message) =>
      Freshchat.sendMessage("Fraazo Support", message);

  // void openFAQs() => Freshchat.showFAQ();

  void registerForPushNotification(String deviceToken) {
    Freshchat.setPushRegistrationToken(
      deviceToken,
    );
    _setNotificationClickHandler();
  }

/*  static void onNewPush() {
    final notificationInterceptStream = Freshchat.onNotificationIntercept;
    notificationInterceptStream.listen((event) {
      print("Freshchat Notification Intercept detected");
      Freshchat.openFreshchatDeeplink(event["url"]);
    });
  }*/

  Future handlePushNotification(Map pushPayload) async {
    if (await Freshchat.isFreshchatNotification(pushPayload)) {
      // {msg_alias: ae1eaf86-95e3-4511-927f-aba090732a8d, target_user_alias: 3bf6d4b7-cbc3-4bbf-b764-0c7acad92a81, user_name: Vikram Devda, notif_type: 1,
      // source: freshchat_user, body: hi, channel_id: 97754, app_id: 329929862216909, conv_id: 600375578800984, timestamp: 1649341543740}
      Freshchat.handlePushNotification(pushPayload);
      _setNotificationClickHandler();
    }
  }

  void _setNotificationClickHandler() {
    Freshchat.setNotificationConfig(
      notificationInterceptionEnabled: false,
      smallIcon: "ic_notification",
      largeIcon: "ic_launcher",
    );

/*    final notificationInterceptStream = Freshchat.onNotificationIntercept;
    notificationInterceptStream.listen((event) {
      print("event.toString()");
      print(event.toString());
      Freshchat.openFreshchatDeeplink(event?["url"]);
    });*/
  }

  @override
  void logoutReset() {
    Freshchat.resetUser();
  }

  @override
  void log(String name) {
    // TODO: implement log
  }
}
