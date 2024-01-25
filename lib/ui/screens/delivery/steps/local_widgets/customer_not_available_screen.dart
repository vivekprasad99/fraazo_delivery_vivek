import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fraazo_delivery/helpers/route/route_helper.dart';
import 'package:fraazo_delivery/helpers/route/routes.dart';
import 'package:fraazo_delivery/providers/delivery/latest_task_provider.dart';
import 'package:fraazo_delivery/screen_modules/signup/ui/local_widgets/rider_go_online_widget.dart';

class CustomerNotAvailableScreen extends StatefulWidget {
  const CustomerNotAvailableScreen({Key? key}) : super(key: key);

  @override
  State<CustomerNotAvailableScreen> createState() =>
      _CustomerNotAvailableScreenState();
}

class _CustomerNotAvailableScreenState
    extends State<CustomerNotAvailableScreen> {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarBrightness: Brightness.dark,
    ));
    return _buildBody();
  }

  Widget _buildBody() {
    return WillPopScope(
        onWillPop: () {
          RouteHelper.removeUntil(Routes.HOME);
          context.read(latestTaskProvider.notifier).getLatestTask();
          return Future.value(true);
        },
        child: const RiderGoOnlineWidget(
          msg1: 'Please Wait !',
          msg2: 'the Support team will get back to you in few mins.',
          imgName: 'please_wait',
          showButton: false,
        ));
  }
}
