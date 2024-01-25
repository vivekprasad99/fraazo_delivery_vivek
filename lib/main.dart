import 'dart:async';
import 'dart:io';
import 'dart:isolate';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:fraazo_delivery/services/sdk/firebase/firebase_notification_service.dart';
import 'package:fraazo_delivery/services/sdk/sentry/sentry_service.dart';

import 'fraazo_delivery.dart';
import 'helpers/error/error_reporter.dart';

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

Future<void> main() async {
  HttpOverrides.global = MyHttpOverrides();
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(
      FirebaseNotificationService.backgroundMessageHandler);

  runZonedGuarded<Future<void>>(() async {
    // The following lines are the same as previously explained in "Handling uncaught errors"
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;

    await SentryService().initialise(
      () => runApp(FraazoDelivery()),
    );
  }, (error, st) {
    ErrorReporter.error(error, st, "main: main() - runZonedGuarded");
  });

  Isolate.current.addErrorListener(RawReceivePort((pair) async {
    final List<dynamic> errorAndStacktrace = pair as List<dynamic>;
    ErrorReporter.error(
      errorAndStacktrace.first,
      errorAndStacktrace.last as StackTrace,
      "main: main() - Isolate",
    );
  }).sendPort);
}
