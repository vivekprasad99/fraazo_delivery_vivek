import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fraazo_delivery/ui/utils/widgets_and_attributes.dart';

// ignore: avoid_classes_with_only_static_members
mixin RouteHelper {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static BuildContext get navigatorContext => navigatorKey.currentContext!;

  static Future push(String routeName, {Object? args}) async {
    return Navigator.of(navigatorContext).pushNamed(
      routeName,
      arguments: args,
    );
  }

  static Future pushReplacement(String routeName, {Object? args}) async {
    return Navigator.of(navigatorContext).pushReplacementNamed(
      routeName,
      arguments: args,
    );
  }

  static Future pushAndPopOthers(String routeName, {Object? args}) async {
    return Navigator.of(navigatorContext).pushNamedAndRemoveUntil(
      routeName,
      (Route<dynamic> route) => false,
      arguments: args,
    );
  }

  static void pop({dynamic args}) {
    Navigator.of(navigatorContext).pop(args);
  }

  static bool canPop() {
    return Navigator.of(navigatorContext).canPop();
  }

  static Future<void> maybePop() {
    return Navigator.of(navigatorContext).maybePop();
  }

  static void popUntil(String routesName) {
    Navigator.of(navigatorContext).popUntil(ModalRoute.withName(routesName));
  }

  static void removeUntil(String routesName) {
    Navigator.of(navigatorContext)
        .pushNamedAndRemoveUntil(routesName, (Route<dynamic> route) => false);
  }

  static Future exitApp() {
    return SystemNavigator.pop();
  }

  static Future<T?> openDialog<T>(Widget child,
      {bool barrierDismissible = true}) {
    return showDialog<T?>(
      barrierColor: Colors.black.withOpacity(.7),
      context: navigatorContext,
      builder: (_) => child,
      barrierDismissible: barrierDismissible,
    );
  }

  static void openBottomSheet(Widget child, {bool barrierDismissible = true}) {
    showModalBottomSheet(
      isDismissible: false,
      context: navigatorContext,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(px_16),
          topLeft: Radius.circular(px_16),
        ),
      ),
      builder: (_) => child,
    );
  }
}
