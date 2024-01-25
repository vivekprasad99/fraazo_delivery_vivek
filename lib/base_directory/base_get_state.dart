import 'dart:async';
import 'dart:ui';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:fraazo_delivery/utils/enums.dart';
import 'package:get/get.dart';

abstract class BaseGetState<T extends StatefulWidget> extends State<T> {
  performBack({dynamic result}) {
    backPressedForTracking();

    if (overrideBackBehaviour()) {
      onBackPressManual(context);
    } else {
      if (Navigator.of(context).canPop()) {
        Get.back(result: result);
      } else {
        SystemNavigator.pop();
      }
    }
  }

  String getString(String tag) {
    return tag.tr;
  }

  void showAppBottomSheet(
    Widget child, {
    Function? onBottomSheetClosed,
    Color barrierColor = Colors.black54,
    bool closeOnOutsideClick = true,
    ShapeBorder? shape,
    bool isScrollControlled = false,
  }) {
    Get.bottomSheet(child,
            barrierColor: barrierColor,
            isDismissible: closeOnOutsideClick,
            shape: shape,
            isScrollControlled: isScrollControlled)
        .then((value) {
      if (onBottomSheetClosed != null) {
        Future.delayed(Duration(milliseconds: 250), () {
          onBottomSheetClosed();
        });
      }
    });
  }

  bool overrideBackBehaviour() {
    return false;
  }

  void onBackPressManual(BuildContext context) {}

  void onScreenReady(BuildContext context);

  void onConnected(BuildContext context) {}

  void onDisConnected(BuildContext context) {}

  void onPreBuild(BuildContext context) {}

  PreferredSizeWidget? getToolBar(BuildContext context) {
    return null;
  }

  Widget? getFloatingButton(BuildContext context) {
    return null;
  }

  void setState(VoidCallback fn) {}

  FloatingActionButtonLocation getFloatingActionButtonLocation(
      BuildContext context) {
    return FloatingActionButtonLocation.endFloat;
  }

  Color? getScreenColor() {
    return null;
  }

  Drawer? getDrawer(BuildContext context) {
    return null;
  }

  Drawer? getEndDrawer(BuildContext context) {
    return null;
  }

  bool resizeToAvoidBottomInset() {
    return true;
  }

  bool showCobrowseSessionWidget() {
    return true;
  }

  Widget getBuildWidget(BuildContext context);

  Widget? getBottomNavigationBar(BuildContext context) {
    return null;
  }

  backPressedForTracking() {}

  bool isProgressBarShowing() {
    return _showLoader.value;
  }

  showProgressBar(bool b) {
    _showLoader.value = b;
  }

  bool _firstLaunch = true;
  bool _firstTimeNet = true;
  PreviousNetStatus _previousNetStatus = PreviousNetStatus.NONE;
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<ConnectivityResult>? _connectivitySubscription;
  RxBool _showLoader = false.obs;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    SchedulerBinding.instance!.addPostFrameCallback((timeStamp) {
      onScreenReady(context);
    });
    _initConnectivity();
    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
  }

  Future<void> _initConnectivity() async {
    ConnectivityResult? result;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      result = await _connectivity.checkConnectivity();
    } on PlatformException catch (e) {
      print(e.toString());
    }
    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    if (!mounted) {
      return Future.value(null);
    }

    return _updateConnectionStatus(result!);
  }

  Future<void> _updateConnectionStatus(ConnectivityResult result) async {
    switch (result) {
      case ConnectivityResult.wifi:
        if (!_firstTimeNet) {
          if (_previousNetStatus != PreviousNetStatus.CONNECTED) {
            onConnected(context);
          }
          _previousNetStatus = PreviousNetStatus.CONNECTED;
        } else {
          _previousNetStatus = PreviousNetStatus.CONNECTED;
          _firstTimeNet = false;
        }
        break;
      case ConnectivityResult.mobile:
        if (!_firstTimeNet) {
          if (_previousNetStatus != PreviousNetStatus.CONNECTED) {
            onConnected(context);
          }
          _previousNetStatus = PreviousNetStatus.CONNECTED;
        } else {
          _previousNetStatus = PreviousNetStatus.CONNECTED;
          _firstTimeNet = false;
        }
        break;
      case ConnectivityResult.none:
        if (!_firstTimeNet) {
          if (_previousNetStatus != PreviousNetStatus.DISCONNECTED) {
            onDisConnected(context);
          }
          _previousNetStatus = PreviousNetStatus.DISCONNECTED;
        } else {
          _previousNetStatus = PreviousNetStatus.DISCONNECTED;
          _firstTimeNet = false;
        }
        break;
      default:
        if (!_firstTimeNet) {
          if (_previousNetStatus != PreviousNetStatus.DISCONNECTED) {
            onDisConnected(context);
          }
          _previousNetStatus = PreviousNetStatus.DISCONNECTED;
        } else {
          _previousNetStatus = PreviousNetStatus.DISCONNECTED;
          _firstTimeNet = false;
        }
        break;
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _connectivitySubscription?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    if (_firstLaunch) {
      _firstLaunch = false;
      onPreBuild(context);
    }

    return Stack(
      children: [
        Scaffold(
          appBar: getToolBar(context),
          floatingActionButton: getFloatingButton(context),
          floatingActionButtonLocation:
              getFloatingActionButtonLocation(context),
          body: GestureDetector(
            onTap: () {
              FocusScope.of(context).requestFocus(FocusNode());
            },
            child: Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              child:
                  Column(children: [Expanded(child: getBuildWidget(context))]),
            ),
          ),
          backgroundColor: getScreenColor(),
          drawer: getDrawer(context),
          endDrawer: getEndDrawer(context),
          bottomNavigationBar: getBottomNavigationBar(context),
          resizeToAvoidBottomInset: resizeToAvoidBottomInset(),
          endDrawerEnableOpenDragGesture: false,
          drawerEnableOpenDragGesture: false,
        ),
        Obx(() {
          return _showLoader.value
              ? Container(
                  alignment: Alignment.center,
                  color: Colors.black26,
                  height: Get.height,
                  width: Get.width,
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                )
              : Container(
                  height: 0,
                  width: 0,
                );
        })
      ],
    );
  }
}
