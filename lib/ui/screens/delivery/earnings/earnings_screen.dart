import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fraazo_delivery/helpers/date/date_formatter.dart';
import 'package:fraazo_delivery/models/delivery/earning_model.dart';
import 'package:fraazo_delivery/providers/delivery/earnings/earnings_provider.dart';
import 'package:fraazo_delivery/ui/global_widgets/fd_app_bar.dart';
import 'package:fraazo_delivery/ui/global_widgets/fd_circular_loader.dart';
import 'package:fraazo_delivery/ui/global_widgets/fd_error_widget.dart';
import 'package:fraazo_delivery/ui/screen_widgets/no_data_widget.dart';
import 'package:fraazo_delivery/ui/screens/delivery/earnings/local_widgets/earning_item_widget.dart';
import 'package:fraazo_delivery/ui/screens/delivery/history/local_widgets/date_filter_dialog.dart';
import 'package:fraazo_delivery/ui/utils/widgets_and_attributes.dart';
import 'package:fraazo_delivery/utils/constants.dart';
import 'package:fraazo_delivery/values/custom_colors.dart';
import 'package:loadmore/loadmore.dart';

import '../../../../utils/utils.dart';

class EarningsScreen extends StatefulWidget {
  const EarningsScreen({Key? key}) : super(key: key);

  @override
  _EarningsScreenState createState() => _EarningsScreenState();
}

class _EarningsScreenState extends State<EarningsScreen> {
  final _earningsProvider = StateNotifierProvider.autoDispose<EarningsProvider,
      AsyncValue<List<Earning>>>((ref) => EarningsProvider());

  final Map<String, String> _selectedDatesFormatted = {};
  late final Map<String, DateTime> _selectedDateTimes = {};

  @override
  void initState() {
    super.initState();
    _getEarnings();
  }

  DateTimeRange dateRange =
      DateTimeRange(start: DateTime.now(), end: DateTime.now());
  final dateTimeFormatter = DateFormatter();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: const FDAppBar(
        titleText: "Payouts",
      ),
      body: _buildBody(),
      floatingActionButton: _buildFilterButton(),
    );
  }

  Widget _buildBody() {
    return Consumer(
      builder: (_, watch, __) {
        return watch(_earningsProvider).when(
          data: (List<Earning> earningList) {
            return _buildEarningsListView(earningList);
          },
          loading: () => const FDCircularLoader(),
          error: (_, __) => FDErrorWidget(
            onPressed: () => _getEarnings(),
          ),
        );
      },
    );
  }

  Widget _buildEarningsListView(List<Earning> earningList) {
    if (earningList.isEmpty) {
      return const NoDataWidget();
    }

    final earningProvider = context.read(_earningsProvider.notifier);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_selectedDatesFormatted.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(8.0, 8, 8, 0),
            child: Text(
                "Showing tasks from ${_selectedDatesFormatted[Constants.DH_START_DATE]} to ${_selectedDatesFormatted[Constants.DH_END_DATE] ?? _selectedDatesFormatted[Constants.DH_START_DATE]}"),
          ),
        ],
        Expanded(
          child: LoadMore(
            isFinish: earningProvider.isFinished,
            onLoadMore: earningProvider.onLoadMore,
            textBuilder: DefaultLoadMoreTextBuilder.english,
            child: ListView.separated(
              itemCount: earningList.length,
              padding: const EdgeInsets.all(16),
              itemBuilder: (_, int index) {
                return EarningItemWidget(earningList[index]);
              },
              separatorBuilder: (_, __) => sizedBoxH15,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFilterButton() {
    return FloatingActionButton(
      backgroundColor: textColor,
      onPressed: pickDateRange,
      tooltip: "Select by date",
      child: const Icon(
        Icons.date_range_rounded,
        color: Colors.black,
      ),
    );
  }

  void _onFilterButtonTap() {
    showDialog(
      context: context,
      builder: (_) => DateFilterDialog(
        selectedDatesFormatted: _selectedDatesFormatted,
        selectedDateTimes: _selectedDateTimes,
        onUpdate: _getEarnings,
      ),
    );
  }

  Future pickDateRange() async {
    DateTimeRange? newDateRange = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2021, 6),
      lastDate: DateTime.now(),
      helpText: 'Select A Date Range',
      fieldStartHintText: 'Start date',
      fieldEndHintText: 'End date',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
                primary: bgColor, // header background color
                onPrimary: Colors.white, // header text color
                onSurface: bgColor,
                surface: bgColor // body text color
                ),
            dialogBackgroundColor: bgColor,
            textTheme: TextTheme(
                bodyText1: commonTextStyle(fontSize: 15),
                bodyText2: commonTextStyle(fontSize: 15),
                overline: commonTextStyle(fontSize: 15)),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                  primary: Colors.red,
                  textStyle: commonTextStyle() // button text color
                  ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (newDateRange == null) return;
    setState(() {
      dateRange = newDateRange;
    });
    _getEarnings(isFilter: true);
    // print(dateRange);
  }

  void _getEarnings({bool isFilter = false}) {
    String startDate = '';
    String endDate = '';
    if (!isFilter) {
      startDate = _selectedDatesFormatted[Constants.DH_START_DATE] ?? "";
      endDate = _selectedDatesFormatted[Constants.DH_END_DATE] ?? "";
      // if (startDate.isEmpty) {
      //   startDate = dateTimeFormatter.firstDateOfTheWeek();
      //   endDate = dateTimeFormatter.lastDateOfTheWeek();
      // }
    } else {
      startDate = dateTimeFormatter.parseDateTimeToDate(dateRange.start);
      endDate = dateTimeFormatter.parseDateTimeToDate(dateRange.end);
    }

    context
        .read(_earningsProvider.notifier)
        .getEarnings(fromDate: startDate, toDate: endDate);
  }
}
