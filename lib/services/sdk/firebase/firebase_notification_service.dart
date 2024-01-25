import 'dart:typed_data';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fraazo_delivery/services/know_notification/know_notification_service.dart';
import 'package:fraazo_delivery/ui/screens/delivery/steps/support/freshchat_service.dart';
import 'package:fraazo_delivery/utils/constants.dart';
import 'package:fraazo_delivery/utils/globals.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FirebaseNotificationService {
  factory FirebaseNotificationService() {
    return _instance;
  }

  static final _instance = FirebaseNotificationService._();

  FirebaseNotificationService._();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  static late final AndroidNotificationChannel _androidChannel =
      AndroidNotificationChannel(
    'new_assigned_task', // id
    'New Task', // title
    'This channel is used for new upcoming task.', // description
    importance: Importance.high,
    vibrationPattern: Int64List.fromList([150, 150, 150, 150, 150, 150]),
    sound: const RawResourceAndroidNotificationSound("alert"),
    enableLights: true,
  );

  static late final FlutterLocalNotificationsPlugin flutterLocalNotifications =
      FlutterLocalNotificationsPlugin();

  Future<String?> getDeviceToken() {
    try {
      return _messaging.getToken();
    } catch (e) {
      return Future.value("");
    }
  }

  Future<void> createNotificationChannel() async {
    await Firebase.initializeApp();
    final FlutterLocalNotificationsPlugin flutterLocalNotifications =
        FlutterLocalNotificationsPlugin();

    flutterLocalNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_androidChannel);
  }

  static void onNewNotificationInForeground(
      {Function(String? taskStatus, {String? orderNumber})?
          onNewNotification}) {
    FirebaseMessaging.onMessage.listen(
      (RemoteMessage message) {
        FreshchatService.instance.handlePushNotification(message.data);
        debugPrint('onNotificationReceived:');
        if (callNuggetReadEvent(message.data)) {
          // flutterLocalNotifications.show(
          //   message.hashCode,
          //   message.data['title'],
          //   message.data['body'],
          //   NotificationDetails(
          //     android: AndroidNotificationDetails(
          //       _androidChannel.id,
          //       _androidChannel.name,
          //       _androidChannel.description,
          //       sound: _androidChannel.sound,
          //       importance: _androidChannel.importance,
          //       enableLights: _androidChannel.enableLights,
          //       vibrationPattern: _androidChannel.vibrationPattern,
          //       icon: "ic_notification",
          //     ),
          //   ),
          // );
          onNewNotification?.call('Please open app.');
        } else {
          Globals.notificationType = message.data['notification_type'] ?? '';
          Globals.returnInventory = message.notification!.title ?? '';
          Globals.checkRiderLocation = message.notification!.title ?? '';
          final RemoteNotification? notification = message.notification;
          final AndroidNotification? android = message.notification?.android;
          if (notification != null && android != null) {
            final String? taskStatus = (notification.body ?? "").contains("##")
                ? notification.body?.split("##")[1]
                : message.data.containsKey('classification_type')
                    ? "Please open app."
                    : null;
            flutterLocalNotifications.show(
              notification.hashCode,
              notification.title,
              notification.body?.split("##").first,
              NotificationDetails(
                android: AndroidNotificationDetails(
                  _androidChannel.id,
                  _androidChannel.name,
                  _androidChannel.description,
                  sound: _androidChannel.sound,
                  importance: _androidChannel.importance,
                  enableLights: _androidChannel.enableLights,
                  vibrationPattern: _androidChannel.vibrationPattern,
                  icon: "ic_notification",
                ),
              ),
            );

            onNewNotification?.call(
              taskStatus,
              orderNumber: message.data.containsKey('order_number')
                  ? message.data['order_number']
                  : null,
            );
          }
        }
      },
    );
  }

  static Future backgroundMessageHandler(RemoteMessage message) async {
    await Firebase.initializeApp();
    FreshchatService().handlePushNotification(message.data);
    callNuggetReadEvent(message.data);
    SharedPreferences sf = await SharedPreferences.getInstance();
    if (message.data['notification_type'] == 'MARK_OFFLINE') {
      Constants.notificationType = message.data['notification_type'] ?? '';

      sf.setBool("notification_type", true);
      print('Shared ${sf.getBool('notification_type')}');
      print('Shared pref process ends');
    } else if (message.data['notification_type'] == 'ASSET_ASSIGN') {
      sf.setBool("isAsset_type", true);
    }
  }

  static bool callNuggetReadEvent(Map<String, dynamic> data) {
    final KnowNotificationService knowNotificationService =
        KnowNotificationService();
    if (data.containsKey('classification_type')) {
      final Map<String, String> notificationInfo = {
        "type": data["classification_type"],
        "id": data["nugget_id"],
      };
      knowNotificationService.knowReadEvent(notificationInfo);
      return true;
    }
    return false;
  }
}
