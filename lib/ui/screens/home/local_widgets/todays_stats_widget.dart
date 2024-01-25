import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fraazo_delivery/models/user/stat_model.dart';
import 'package:fraazo_delivery/providers/user/todays_stats_provider.dart';
import 'package:fraazo_delivery/ui/global_widgets/fd_circular_loader.dart';
import 'package:fraazo_delivery/ui/global_widgets/fd_error_widget.dart';
import 'package:fraazo_delivery/ui/screen_widgets/stat_widget.dart';

//Not In use, StatWidget directly using on HomeScreen with other provider
class TodaysStatsWidget extends StatelessWidget {
  const TodaysStatsWidget();

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (_, watch, __) => watch(todaysStatsProvider).when(
        data: (StatModel stat) => const StatWidget(null, isClickable: true),
        loading: () => const FDCircularLoader(
          progressColor: Colors.white,
        ),
        error: (_, __) => FDErrorWidget(
          onPressed: () =>
              context.read(todaysStatsProvider.notifier).getStats(),
          canShowImage: false,
        ),
      ),
    );
  }
}
