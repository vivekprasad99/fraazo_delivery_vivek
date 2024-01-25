import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fraazo_delivery/screen_modules/signup/binding/signup_binding.dart';
import 'package:fraazo_delivery/ui/screens/splash/splash_screen.dart';
import 'package:fraazo_delivery/utils/constants.dart';
import 'package:get/get.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import 'helpers/route/route_generator.dart';
import 'helpers/route/route_helper.dart';
import 'ui/screens/splash/splash_screen.dart';

class FraazoDelivery extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(builder: (_, child) {
      return ProviderScope(
        child: GetMaterialApp(
          title: Constants.isProduction
              ? 'Fraazo Delivery Partner'
              : 'Fraazo Delivery Partner Staging',
          navigatorKey: RouteHelper.navigatorKey,
          debugShowCheckedModeBanner: false,
          builder: (BuildContext context, Widget? child) {
            final botToastBuilder = BotToastInit();
            final MediaQueryData data = MediaQuery.of(context);

            return MediaQuery(
              data: data.copyWith(textScaleFactor: data.textScaleFactor),
              child: Constants.isProduction
                  ? botToastBuilder(context, child)
                  : Banner(
                      message: "STAGING",
                      color: Colors.deepOrange,
                      location: BannerLocation.topStart,
                      child: botToastBuilder(context, child),
                    ),
            );
          },
          navigatorObservers: [
            BotToastNavigatorObserver(),
            SentryNavigatorObserver()
          ],
          theme: ThemeData(
              primarySwatch: Colors.teal,
              visualDensity: VisualDensity.adaptivePlatformDensity,
              scaffoldBackgroundColor: const Color(0xFFF7F8FA),
              unselectedWidgetColor: const Color(0xFF787878)),
          onGenerateRoute: RouteGenerator.generateRoute,
          //initialRoute: Routes.SIGNUPPAGE,
          //getPages: AppPages.routes,
          initialBinding: SignupBinding(),
          home: const SplashScreen(),
        ),
      );
    });
  }
}
