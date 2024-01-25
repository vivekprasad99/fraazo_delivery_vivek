import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fraazo_delivery/helpers/date/date_formatter.dart';
import 'package:fraazo_delivery/helpers/extensions/string_extension.dart';
import 'package:fraazo_delivery/models/delivery/delivery_history_model.dart';
import 'package:fraazo_delivery/providers/delivery/delivery_history_provider.dart';
import 'package:fraazo_delivery/ui/global_widgets/container_divider.dart';
import 'package:fraazo_delivery/ui/global_widgets/fd_app_bar.dart';
import 'package:fraazo_delivery/ui/global_widgets/fd_circular_loader.dart';
import 'package:fraazo_delivery/ui/global_widgets/fd_error_widget.dart';
import 'package:fraazo_delivery/ui/screen_widgets/no_data_widget.dart';
import 'package:fraazo_delivery/ui/screens/delivery/history/local_widgets/date_filter_dialog.dart';
import 'package:fraazo_delivery/ui/utils/app_colors.dart';
import 'package:fraazo_delivery/ui/utils/textview.dart';
import 'package:fraazo_delivery/ui/utils/widgets_and_attributes.dart';
import 'package:fraazo_delivery/utils/constants.dart';
import 'package:fraazo_delivery/utils/utils.dart';
import 'package:fraazo_delivery/values/custom_colors.dart';

import 'local_widgets/day_wise_earning_list_widget.dart';
import 'local_widgets/history_item_widget.dart';

final AutoDisposeStateNotifierProvider<DeliveryHistoryProvider,
        AsyncValue<DeliveryHistory>?> deliveryHistoryProvider =
    StateNotifierProvider.autoDispose((_) => DeliveryHistoryProvider());

class HistoryScreen extends StatefulWidget {
  final Map<String, dynamic>? arguments;

  const HistoryScreen({this.arguments});

  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final Map<String, String> _selectedDatesFormatted = {};
  late final Map<String, DateTime> _selectedDateTimes = {};
  final _searchTEC = TextEditingController();

  bool _isFromEarning = false;
  late int earningId = 0;
  late String taskId = "";
  late String orderId = "";

  @override
  void initState() {
    super.initState();
    if (widget.arguments != null) {
      if (widget.arguments!.containsKey('taskId') &&
          widget.arguments!.containsKey('taskId')) {
        orderId = widget.arguments!['orderId'];
        taskId = widget.arguments!['taskId'];
      } else {
        _isFromEarning = true;
        _selectedDatesFormatted
            .putIfAbsent(Constants.DH_START_DATE,
                () => widget.arguments![Constants.DH_START_DATE])
            .reverse("-");
        _selectedDatesFormatted
            .putIfAbsent(Constants.DH_END_DATE,
                () => widget.arguments![Constants.DH_END_DATE])
            .reverse("-");
        earningId = widget.arguments!['earningId'];
      }
    }
    _getHistory();
  }

  DateTimeRange dateRange =
      DateTimeRange(start: DateTime.now(), end: DateTime.now());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: const FDAppBar(titleText: "Task History"),
      body: _buildBody(),
      // floatingActionButton: _isFromEarning ? null : _buildFilterButton(),
    );
  }
  // _isFromEarning ? "Earning details" :

  Widget _buildBody() {
    return Consumer(builder: (_, watch, __) {
      return watch(deliveryHistoryProvider)!.when(
        data: (DeliveryHistory deliveryHistory) =>
            _buildHistoryList(deliveryHistory),
        loading: () => const FDCircularLoader(),
        error: (_, __) => FDErrorWidget(
          onPressed: () => _getHistory(),
        ),
      );
    });
  }

  Widget _buildHistoryList(DeliveryHistory deliveryHistory) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ContainerDivider(),
          sizedBoxH8,
          Row(
            children: [
              _buildSearchItem(),
              sizedBoxW10,
              _onDateTap(),
              sizedBoxH10,
            ],
          ),
          Column(
            children: [
              Visibility(
                visible: _isFromEarning,
                child: Container(
                  height: 45,
                  padding: EdgeInsets.all(px_10),
                  margin: const EdgeInsets.only(top: px_12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          SvgPicture.asset(
                            'earning'.svgImageAsset,
                            fit: BoxFit.cover,
                          ),
                          Text("Total Earnings",
                              style: commonTextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ))
                        ],
                      ),
                      sizedBoxW15,
                      Container(
                        margin: const EdgeInsets.only(
                          left: 15,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: settledBorderColors),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        child: Text(
                          "Settled",
                          style: commonTextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Text("₹ ${deliveryHistory.stat!.codAmount}",
                          style: commonTextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          )),
                    ],
                  ),
                ),
              ),
              sizedBoxH15,
              Row(
                children: [
                  _buildEarningItem(
                      'lock',
                      '${deliveryHistory.stat!.orderCount!} Orders',
                      deliveryHistory.stat!.codAmount!),
                  sizedBoxW10,
                  _buildEarningItem(
                      'petrol',
                      '${deliveryHistory.stat!.distance!.toStringAsFixed(2)} kms',
                      deliveryHistory.stat!.distanceCost!),
                  sizedBoxW10,
                  _buildEarningItem(
                      'history_watch',
                      '${deliveryHistory.stat!.loginHours!.toStringAsFixed(2)} hrs',
                      deliveryHistory.stat!.loginIncentive!)
                ],
              ),
            ],
          ),

          //StatWidget(deliveryHistory.stat),
          sizedBoxH8,
          // if (_isFromEarning)
          //   _buildTabs(deliveryHistory)
          // else
          Expanded(child: _buildTaskWiseList(deliveryHistory))
        ],
      ),
    );
  }

  Widget _buildTabs(DeliveryHistory deliveryHistory) {
    return Expanded(
      child: DefaultTabController(
        length: 2,
        child: Column(
          children: [
            Container(
              height: 42,
              padding: const EdgeInsets.all(4.0),
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(6),
                  boxShadow: const [
                    BoxShadow(blurRadius: 3, color: Colors.grey)
                  ]),
              child: TabBar(
                indicatorSize: TabBarIndicatorSize.tab,
                indicator: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(6)),
                labelColor: Colors.white,
                unselectedLabelColor: Colors.black,
                tabs: const [
                  Tab(
                      child: Text(
                    "Task Wise",
                  )),
                  Tab(
                      child: Text(
                    "Day Wise",
                  )),
                ],
              ),
            ),
            sizedBoxH5,
            Expanded(
              child: TabBarView(children: [
                _buildTaskWiseList(deliveryHistory),
                DayWiseEarningListWidget(earningId)
              ]),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildTaskWiseList(DeliveryHistory deliveryHistory) {
    return (deliveryHistory.tasks!.isNotEmpty)
        ? ListView.separated(
            itemCount: deliveryHistory.tasks!.length,
            padding: const EdgeInsets.fromLTRB(4, 4, 4, 80),
            shrinkWrap: true,
            itemBuilder: (_, int index) {
              return HistoryItemWidget(
                deliveryHistory.tasks![index],
                isFromMenu: _isFromEarning,
              );
            },
            separatorBuilder: (_, __) => sizedBoxH15,
          )
        : const NoDataWidget(
            noDataText: "No history found!",
          );
  }

  Widget _buildFilterButton() {
    return FloatingActionButton(
      onPressed: _onFilterButtonTap,
      tooltip: "Select by date",
      backgroundColor: Colors.white,
      child: const Icon(Icons.date_range_rounded),
    );
  }

  void _onFilterButtonTap() {
    showDialog(
      context: context,
      builder: (_) => DateFilterDialog(
        selectedDatesFormatted: _selectedDatesFormatted,
        selectedDateTimes: _selectedDateTimes,
        onUpdate: _getHistory,
      ),
    );
  }

  final dateTimeFormatter = DateFormatter();

  void _getHistory({bool isFilter = false}) {
    String startDate = '';
    String endDate = '';
    if (!isFilter) {
      startDate = _selectedDatesFormatted[Constants.DH_START_DATE] ?? "";
      endDate = _selectedDatesFormatted[Constants.DH_END_DATE] ?? "";
      if (startDate.isEmpty) {
        startDate =
            dateTimeFormatter.parseDateTimeToDate(dateRange.start).reverse("-");
        endDate =
            dateTimeFormatter.parseDateTimeToDate(dateRange.start).reverse("-");
      }
    } else {
      startDate =
          dateTimeFormatter.parseDateTimeToDate(dateRange.start).reverse("-");
      endDate =
          dateTimeFormatter.parseDateTimeToDate(dateRange.end).reverse("-");
    }
    context.read(deliveryHistoryProvider.notifier).getTaskHistory(
        from: startDate, to: endDate, taskid: taskId, orderId: orderId);
  }

  Widget _buildSearchItem() {
    return Expanded(
      child: SizedBox(
        height: 45,
        child: TextField(
          // la: 'Search Task / Order ID...',
          style: commonTextStyle(color: Colors.white, fontSize: 11),
          cursorColor: Colors.white,
          textCapitalization: TextCapitalization.words,
          controller: _searchTEC,
          onChanged: onSearchTextChanged,
          decoration: InputDecoration(
              prefixIcon: SizedBox(
                height: px_16,
                width: px_16,
                child: Padding(
                  padding: const EdgeInsets.all(px_14),
                  child: SvgPicture.asset(
                    'ic_search'.svgImageAsset,
                  ),
                ),
              ),
              focusedBorder: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(px_8)),
                  borderSide: BorderSide(
                    color: dateBorderColor,
                  )),
              enabledBorder: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(px_8)),
                  borderSide: BorderSide(
                    color: dateBorderColor,
                  )),
              border: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(px_8)),
                  borderSide: BorderSide(
                    color: dateBorderColor,
                  )),
              label: TextView(
                  title: 'Search Task / Order ID...',
                  textStyle:
                      commonTextStyle(color: taskSearchColors, fontSize: 11))),
        ),
      ),
    );
  }

  Widget _buildEarningItem(String img, String earningLabel, num amount) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: px_20),
        decoration: BoxDecoration(
          color: containerBgColor,
          borderRadius: BorderRadius.circular(px_12),
          // border: Border.all(color: earningBorderColor),
        ),
        child: Column(
          children: [
            SvgPicture.asset(
              img.svgImageAsset,
              height: 25,
              width: 23,
              fit: BoxFit.cover,
            ),
            sizedBoxH5,
            Text(earningLabel,
                style: commonTextStyle(
                  color: textColor,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                )),
            sizedBoxH5,
            Visibility(
              visible: _isFromEarning,
              child: Text(
                "₹ ${amount.toStringAsFixed(0)}",
                style: commonTextStyle(
                  color: textColor,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _onDateTap() {
    final start = dateRange.start;
    final end = dateRange.end;
    return InkWell(
      onTap: () {
        pickDateRange();
      },
      child: Container(
        height: 45,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: dateBorderColor),
        ),
        child: Row(
          children: [
            Text(
              '${start.day}/${start.month}/${start.year} - ${end.day}/${end.month}/${end.year}',
              style: commonTextStyle(color: Colors.white, fontSize: 10),
            ),
          ],
        ),
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
    _getHistory(isFilter: true);
    print(dateRange);
  }

  void onSearchTextChanged(String text) async {
    context.read(deliveryHistoryProvider.notifier).getSearchItem(text);
  }
}
