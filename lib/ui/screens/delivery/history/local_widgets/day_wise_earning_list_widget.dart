import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fraazo_delivery/models/delivery/day_wise_earning_model.dart';
import 'package:fraazo_delivery/providers/delivery/earnings/day_wise_earning_provider.dart';
import 'package:fraazo_delivery/ui/global_widgets/fd_circular_loader.dart';
import 'package:fraazo_delivery/ui/global_widgets/fd_error_widget.dart';
import 'package:fraazo_delivery/ui/utils/widgets_and_attributes.dart';

import 'day_earning_item_widget.dart';

class DayWiseEarningListWidget extends StatefulWidget {
  final int weekEarningId;
  const DayWiseEarningListWidget(this.weekEarningId, {Key? key})
      : super(key: key);

  @override
  _DayWiseEarningListWidgetState createState() =>
      _DayWiseEarningListWidgetState();
}

class _DayWiseEarningListWidgetState extends State<DayWiseEarningListWidget>
    with AutomaticKeepAliveClientMixin {
  final AutoDisposeStateNotifierProvider<DayWiseEarningProvider,
          AsyncValue<List<DayEarning>>> _dayWiseEarningProvider =
      StateNotifierProvider.autoDispose((_) => DayWiseEarningProvider());

  @override
  void initState() {
    super.initState();
    _getEarning();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Consumer(builder: (_, watch, __) {
      return watch(_dayWiseEarningProvider).when(
        data: (List<DayEarning> dayEarningList) =>
            _buildDayWiseList(dayEarningList),
        loading: () => const FDCircularLoader(),
        error: (_, __) => FDErrorWidget(
          onPressed: _getEarning,
        ),
      );
    });
  }

  Widget _buildDayWiseList(List<DayEarning> dayEarningList) {
    return ListView.separated(
      itemCount: dayEarningList.length,
      padding: const EdgeInsets.fromLTRB(4, 4, 4, 80),
      shrinkWrap: true,
      itemBuilder: (_, int index) =>
          DayEarningItemWidget(dayEarningList[index]),
      separatorBuilder: (_, __) => sizedBoxH15,
    );
  }

  void _getEarning() {
    context
        .read(_dayWiseEarningProvider.notifier)
        .getDayWiseEarning(widget.weekEarningId);
  }

  @override
  bool get wantKeepAlive => true;
}
