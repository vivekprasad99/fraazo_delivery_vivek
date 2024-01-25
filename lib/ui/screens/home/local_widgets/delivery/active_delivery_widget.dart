import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fraazo_delivery/models/delivery/task_model.dart';
import 'package:fraazo_delivery/models/delivery/task_status_model.dart';
import 'package:fraazo_delivery/providers/delivery/latest_task_provider.dart';
import 'package:fraazo_delivery/providers/delivery/task_by_socket_provider.dart';
import 'package:fraazo_delivery/providers/user/profile/user_profile_provider.dart';
import 'package:fraazo_delivery/services/media/sound/feedback_service.dart';
import 'package:fraazo_delivery/ui/global_widgets/fd_circular_loader.dart';
import 'package:fraazo_delivery/ui/global_widgets/fd_error_widget.dart';
import 'package:fraazo_delivery/ui/screens/delivery/steps/local_widgets/dialogs/return_inventory_widget.dart';
import 'package:fraazo_delivery/ui/screens/home/local_widgets/delivery/new_delivery_widget.dart';
import 'package:fraazo_delivery/ui/screens/home/local_widgets/delivery/no_new_delivery_widget.dart';
import 'package:fraazo_delivery/utils/globals.dart';

class ActiveDeliveryWidget extends StatefulWidget {
  const ActiveDeliveryWidget();

  @override
  _ActiveDeliveryWidgetState createState() => _ActiveDeliveryWidgetState();
}

class _ActiveDeliveryWidgetState extends State<ActiveDeliveryWidget> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addPostFrameCallback((_) => _getLatestTask());
    _onNewTaskOnSocket();
  }

  @override
  Widget build(BuildContext context) {
    print('object ${Globals.user!.disableOrderAssignment!}');
    return Consumer(
      builder: (_, watch, __) {
        return watch(latestTaskProvider).when(
          data: (Task? task) => task != null
              ? NewDeliveryWidget(task, _getLatestTask)
              : Globals.user!.disableOrderAssignment!
                  ? const ReturnInventoryWidget()
                  : NoNewDeliveryWidget(
                      onCheckAgainTap: _getLatestTask,
                    ),
          loading: () => const FDCircularLoader(
            size: 195,
          ),
          error: (_, __) => FDErrorWidget(
            onPressed: _getLatestTask,
          ),
        );
      },
    );
  }

  void _getLatestTask() {
    context.read(userProfileProvider.notifier).getUserDetails();
    context.read(latestTaskProvider.notifier).getLatestTask();
  }

  void _onNewTaskOnSocket() {
    context.read(taskBySocketProvider.notifier).addListener(
        (TaskStatusModel? taskStatus) {
      context.read(latestTaskProvider.notifier).setNewTask(taskStatus?.task);
      if (taskStatus?.task != null) {
        FeedbackService().triggerAlert();
      }
    }, fireImmediately: false);
  }
}
