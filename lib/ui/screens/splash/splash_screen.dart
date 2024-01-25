import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fraazo_delivery/helpers/extensions/string_extension.dart';
import 'package:fraazo_delivery/providers/splash/authentication_provider.dart';
import 'package:fraazo_delivery/ui/global_widgets/fd_circular_loader.dart';
import 'package:fraazo_delivery/ui/screen_widgets/app_version_widget.dart';
import 'package:fraazo_delivery/ui/screens/splash/log_overlay.dart';
import 'package:fraazo_delivery/ui/utils/widgets_and_attributes.dart';
import 'package:fraazo_delivery/utils/constants.dart';
import 'package:fraazo_delivery/values/custom_colors.dart';
import 'package:imei_plugin/imei_plugin.dart';
import 'package:permission_handler/permission_handler.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen();

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final _authenticationProvider =
      StateNotifierProvider.autoDispose<AuthenticationProvider, AsyncValue>(
          (_) => AuthenticationProvider());

  @override
  void initState() {
    super.initState();
    // Toast.error('Showing info toast msg');
    _checkForValidUser();
    _buildLoggerButtonOverlay();
  }

  void permissionServiceCall() {
    permissionServices().then(
      (value) {
        if (value.isNotEmpty) {
          if (value[Permission.phone]?.isGranted ?? false) {
            initPlatformState();
          } else {
            permissionServiceCall();
          }
        }
      },
    );
  }

  Future<void> initPlatformState() async {
    String? platformImei;
    String? idunique;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      platformImei = await ImeiPlugin.getImei();
      final List<String>? multiImei = await ImeiPlugin.getImeiMulti();
      debugPrint('initPlatformState: $multiImei');
      idunique = await ImeiPlugin.getId();
    } on PlatformException {
      platformImei = 'Failed to get platform version.';
      debugPrint('initPlatformState: $platformImei');
    }
  }

  /*Permission services*/
  Future<Map<Permission, PermissionStatus>> permissionServices() async {
    // You can request multiple permissions at once.
    final Map<Permission, PermissionStatus> statuses = await [
      Permission.phone,
    ].request();

    if (statuses[Permission.phone]?.isPermanentlyDenied ?? false) {
      await openAppSettings().then(
        (value) async {
          if (value) {
            if (await Permission.storage.status.isPermanentlyDenied == true &&
                await Permission.storage.status.isGranted == false) {
              openAppSettings();
              /* opens app settings until permission is granted */
            }
          }
        },
      );
    } else {
      if (statuses[Permission.phone]?.isPermanentlyDenied ?? false) {
        permissionServiceCall();
      }
    }
    /*{Permission.phone}*/
    return statuses;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: _buildBody(),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildLoaderOrRetry(),
          const AppVersionWidget(),
        ],
      ),
    );
  }

  Widget _buildBody() {
    return Center(
      child: SizedBox(
        width: 200,
        height: 200,
        child: SvgPicture.asset(
          'rider_logo'.svgImageAsset,
        ),
      ),
    );
  }

  Widget _buildLoaderOrRetry() {
    return Consumer(
      builder: (_, watch, __) {
        return watch(_authenticationProvider).when(
          data: (_) => sizedBoxH40,
          loading: () => const FDCircularLoader(
            size: 35,
            progressColor: Colors.white,
          ),
          error: (_, __) => TextButton(
            onPressed: _checkForValidUser,
            child: const Text(
              "Retry",
              style: TextStyle(color: Colors.red, fontSize: 16),
            ),
          ),
        );
      },
    );
  }

  void _checkForValidUser() {
    context
        .read(_authenticationProvider.notifier)
        .checkIfUserExistsAndNavigate();
  }

  void _buildLoggerButtonOverlay() {
    if (Constants.isTestMode) {
      SchedulerBinding.instance?.addPostFrameCallback((timeStamp) {
        final OverlayEntry overlayEntry = OverlayEntry(
          builder: (_) => const LogOverlay(),
        );
        Overlay.of(context)?.insert(overlayEntry);
      });
    }
  }
}
