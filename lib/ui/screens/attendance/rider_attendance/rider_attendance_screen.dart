import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fraazo_delivery/helpers/date/date_formatter.dart';
import 'package:fraazo_delivery/helpers/extensions/string_extension.dart';
import 'package:fraazo_delivery/models/misc/rider_login_hours_model.dart';
import 'package:fraazo_delivery/providers/misc/rider_login_hours_provider.dart';
import 'package:fraazo_delivery/ui/global_widgets/container_divider.dart';
import 'package:fraazo_delivery/ui/global_widgets/fd_app_bar.dart';
import 'package:fraazo_delivery/ui/global_widgets/fd_circular_loader.dart';
import 'package:fraazo_delivery/ui/global_widgets/fd_error_widget.dart';
import 'package:fraazo_delivery/ui/utils/app_colors.dart';
import 'package:fraazo_delivery/ui/utils/widgets_and_attributes.dart';
import 'package:fraazo_delivery/utils/utils.dart';
import 'package:fraazo_delivery/values/custom_colors.dart';
import 'package:table_calendar/table_calendar.dart';

class RiderAttendanceScreen extends StatefulWidget {
  const RiderAttendanceScreen({Key? key}) : super(key: key);

  @override
  _RiderAttendanceScreenState createState() => _RiderAttendanceScreenState();
}

class _RiderAttendanceScreenState extends State<RiderAttendanceScreen>
    with TickerProviderStateMixin {
  CalendarFormat format = CalendarFormat.week;
  String selectedDay = '';
  String endDate = '';
  String startEndDateRange = '';
  final dateTimeFormatter = DateFormatter();
  DateTime focusedDay = DateTime.now();
  static const TWO_PI = 3.14 * 2;
  final size = 200.0;

  final _riderLoginHoursProvider = StateNotifierProvider.autoDispose<
      RiderLoginHoursProvider, AsyncValue<RiderLoginHoursModel>>(
    (_) => RiderLoginHoursProvider(const AsyncLoading()),
  );

  late TabController _tabController;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    selectedDay = dateTimeFormatter.parseDateTimeToDate(focusedDay);
    endDate = dateTimeFormatter
        .parseDateTimeToDate(DateTime.now().add(const Duration(days: 6)));
    /*startEndDateRange =
        "${focusedDay.day}${dateTimeFormatter.getMonthName(focusedDay)}-${focusedDay.day}${dateTimeFormatter.getMonthName(focusedDay)}";*/
    startEndDateRange =
        "${focusedDay.day}${dateTimeFormatter.getMonthName(focusedDay)}-${DateFormatter().lastDateOfTheWeekInDateFormat(selectedDateTime: focusedDay)}";
    _getRiderLoginHours(selectedDay, selectedDay);
    _tabController = TabController(vsync: this, length: 2);
    _tabController.addListener(() {
      (_tabController.index == 0)
          ? _getRiderLoginHours(selectedDay, selectedDay)
          : _getRiderLoginHours(selectedDay, endDate);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: const FDAppBar(
        backgroundColor: bgColor,
        titleText: "Login Hours",
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    return Column(
      children: [
        sizedBoxH10,
        const ContainerDivider(),
        Expanded(
          child: DefaultTabController(
            length: 2,
            child: Column(
              children: [
                sizedBoxH5,
                Container(
                  height: 40,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    indicatorSize: TabBarIndicatorSize.tab,
                    labelPadding: EdgeInsets.zero,
                    indicator: const BoxDecoration(
                      color: btnLightGreen,
                    ),
                    tabs: [
                      Container(
                        alignment: Alignment.center,
                        color: bgColor,
                        child: Text(
                          "Daily",
                          style: commonTextStyle(
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      Container(
                        alignment: Alignment.center,
                        color: bgColor,
                        child: Text(
                          "Weekly",
                          style: commonTextStyle(
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                sizedBoxH20,
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [_buildWidget(true), _buildWidget(false)],
                  ),
                )
              ],
            ),
          ),
        )
      ],
    );
  }

  Widget _buildWidget(bool _isDailyOrWeekly) {
    return SingleChildScrollView(
      child: Consumer(builder: (_, watch, __) {
        return watch(_riderLoginHoursProvider).when(
          data: (RiderLoginHoursModel riderLoginHoursModel) {
            final _riderLoginTimeHours = riderLoginHoursModel.data.loginHours;
            final int timeHrs = _riderLoginTimeHours.toInt();
            final int timeMin = ((_riderLoginTimeHours - timeHrs) * 60).toInt();

            final _riderShiftTimeHours = riderLoginHoursModel.data.shiftHours;
            final int shiftHrs = _riderShiftTimeHours.toInt();
            final int shiftMin =
                ((_riderShiftTimeHours - shiftHrs) * 60).toInt();

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(child: _onDateTapWidget(_isDailyOrWeekly)),
                sizedBoxH30,
                Center(
                  child: TweenAnimationBuilder(
                    tween: Tween(begin: 0.0, end: 1.0),
                    duration: const Duration(seconds: 20),
                    builder: (context, double values, child) {
                      final int percentage = (values * 100).ceil();
                      return SizedBox(
                        width: size,
                        height: size,
                        child: Stack(
                          children: [
                            ShaderMask(
                              shaderCallback: (rect) {
                                return SweepGradient(endAngle: TWO_PI, stops: [
                                  values,
                                  values
                                ], colors: [
                                  const Color(0xff1DD1E3),
                                  Colors.grey.withAlpha(55)
                                ]).createShader(rect);
                              },
                              child: Container(
                                width: size,
                                height: size,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  image: DecorationImage(
                                    image: AssetImage(
                                        'assets/images/png/radial_scale.png'),
                                  ),
                                ),
                              ),
                            ),
                            Center(
                              child: Container(
                                width: size - 40,
                                height: size - 40,
                                decoration: const BoxDecoration(
                                    color: AppColors.bgColor,
                                    shape: BoxShape.circle),
                                child: Center(
                                  child: Text(
                                    "$timeHrs hrs\n$timeMin mn",
                                    //"$percentage",
                                    style: commonTextStyle(
                                        fontSize: 30,
                                        fontWeight: FontWeight.w700,
                                        color: const Color(0xff1DD1E3)),
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                      );
                    },
                  ),
                ),
                sizedBoxH30,
                Padding(
                  padding: const EdgeInsets.only(left: 16.0, right: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Container(
                        padding: const EdgeInsets.only(
                            left: 20, right: 20, bottom: 7.5, top: 7.5),
                        decoration: BoxDecoration(
                            color: const Color(0xff212121),
                            border: Border.all(
                                color: const Color(0xff3C3C3C), width: .5),
                            borderRadius: BorderRadius.circular(5)),
                        child: Text(
                          riderLoginHoursModel.data.shift.shift,
                          style: commonTextStyle(
                            color: const Color(0xffA8AAAF),
                            fontSize: 14,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.only(
                            left: 20, right: 20, bottom: 7.5, top: 7.5),
                        decoration: BoxDecoration(
                            color: const Color(0xff212121),
                            border: Border.all(
                                color: const Color(0xff3C3C3C), width: .5),
                            borderRadius: BorderRadius.circular(5)),
                        child: Text(
                          "Full Time",
                          style: commonTextStyle(
                            color: const Color(0xffA8AAAF),
                            fontSize: 14,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.only(
                            left: 20, right: 20, bottom: 7.5, top: 7.5),
                        decoration: BoxDecoration(
                            color: const Color(0xff212121),
                            border: Border.all(
                                color: const Color(0xff3C3C3C), width: .5),
                            borderRadius: BorderRadius.circular(5)),
                        child: Text(
                          riderLoginHoursModel.data.shift.shiftTiming,
                          style: commonTextStyle(
                            color: const Color(0xffA8AAAF),
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                sizedBoxH24,
                const ContainerDivider(),
                sizedBoxH5,
                ListTile(
                  title: Text(
                    "Login Time",
                    style: commonTextStyle(
                        color: AppColors.textColor, fontSize: 16.0),
                  ),
                  trailing: Text(
                    riderLoginHoursModel.data.startedAt.started,
                    style: commonHindStyle(
                        color: AppColors.textColor, fontSize: 16.0),
                  ),
                ),
                const ContainerDivider(),
                sizedBoxH5,
                ListTile(
                  title: Text(
                    "Delivered Order's ",
                    style: commonTextStyle(
                        color: AppColors.textColor, fontSize: 16.0),
                  ),
                  trailing: Text(
                    "${riderLoginHoursModel.data.totalOrders}",
                    style: commonHindStyle(
                        color: AppColors.textColor, fontSize: 17.0),
                  ),
                ),
                const ContainerDivider(),
                sizedBoxH10,
                //YOUR AVAILABILITY CODE
                // Container(
                //   padding: const EdgeInsets.only(
                //       top: 20, left: 16.0, bottom: 10.0, right: 16.0),
                //   child: Column(
                //     crossAxisAlignment: CrossAxisAlignment.start,
                //     children: [
                //       Text(
                //         "Your availability",
                //         style: commonTextStyle(
                //           color: AppColors.textColor,
                //           fontWeight: FontWeight.w600,
                //           fontSize: 15.0,
                //         ),
                //       ),
                //       sizedBoxH30,
                //       Column(
                //         crossAxisAlignment: CrossAxisAlignment.start,
                //         children: [
                //           SvgPicture.asset(
                //             'rider_scooter'.svgImageAsset,
                //           ),
                //           const ClipRRect(
                //             borderRadius: BorderRadius.all(Radius.circular(10)),
                //             child: LinearProgressIndicator(
                //               minHeight: 6,
                //               value: 0.5,
                //               backgroundColor: Colors.white,
                //               color: buttonColor,
                //             ),
                //           ),
                //         ],
                //       ),
                //       sizedBoxH10,
                //       Row(
                //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //         children: [
                //           Text(
                //             "Low",
                //             style: commonTextStyle(
                //               color: AppColors.textColor,
                //               fontSize: 13.0,
                //             ),
                //           ),
                //           Text(
                //             "Average",
                //             style: commonTextStyle(
                //               color: AppColors.textColor,
                //               fontSize: 13.0,
                //             ),
                //           ),
                //           Text(
                //             "Good",
                //             style: commonTextStyle(
                //               color: AppColors.textColor,
                //               fontSize: 13.0,
                //             ),
                //           ),
                //         ],
                //       )

                //       // Container(
                //       //   padding: const EdgeInsets.only(
                //       //       left: 15, right: 15, bottom: 5, top: 5),
                //       //   decoration: BoxDecoration(
                //       //       color: Colors.black54,
                //       //       border: Border.all(
                //       //           color: Colors.grey.shade300, width: .5),
                //       //       borderRadius: BorderRadius.circular(5)),
                //       //   child: Text(
                //       //     "$shiftHrs hrs $shiftMin mn",
                //       //     //"$percentage",
                //       //     style: const TextStyle(
                //       //         fontSize: 16, color: Colors.white),
                //       //   ),
                //       // )
                //     ],
                //   ),
                // ),
              ],
            );
          },
          loading: () => SizedBox(
            height: MediaQuery.of(context).size.height / 1.3,
            child: const FDCircularLoader(
              progressColor: Colors.white,
            ),
          ),
          error: (e, _) => SizedBox(
            height: MediaQuery.of(context).size.height / 1.3,
            child: FDErrorWidget(
                textColor: Colors.white,
                onPressed: () => _getRiderLoginHours(selectedDay, selectedDay)),
          ),
        );
      }),
    );
  }

  Widget _onDateTapWidget(bool _isDailyOrWeekly) {
    final size = MediaQuery.of(context).size;
    final double width = size.width;
    return InkWell(
      onTap: () => _onRiderLoginHoursDateTap(_isDailyOrWeekly),
      child: Container(
        margin: EdgeInsets.only(
          left: width * 0.061,
          right: width * 0.061,
          top: 10.0,
        ),
        width: 152,
        padding: const EdgeInsets.only(left: 14, top: 8, bottom: 8),
        decoration: BoxDecoration(
          color: const Color(0xff2D2D2D),
          borderRadius: BorderRadius.circular(19),
          border: Border.all(color: const Color(0xff505050)),
        ),
        child: Row(
          children: [
            Text(
              _isDailyOrWeekly ? selectedDay : startEndDateRange,
              style: commonTextStyle(
                color: Colors.white,
                fontSize: 14.0,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (_isDailyOrWeekly) sizedBoxW20 else sizedBoxW10,
            Padding(
              padding: EdgeInsets.only(right: _isDailyOrWeekly ? 0 : 10),
              child: SvgPicture.asset('ic_calender'.svgImageAsset),
            ),
          ],
        ),
      ),
    );
  }

  Future _onRiderLoginHoursDateTap(bool _isDailyOrWeekly) async {
    final DateTime? selectedDateTime = await showDatePicker(
      context: context,
      firstDate: DateTime(2021, 6),
      initialDate: DateTime.now(),
      lastDate: DateTime.now(),
    );
    setState(() {
      selectedDay = dateTimeFormatter.parseDateTimeToDate(selectedDateTime!);
      endDate = dateTimeFormatter
          .parseDateTimeToDate(selectedDateTime.add(const Duration(days: 6)));
      startEndDateRange =
          "${selectedDateTime.day}${dateTimeFormatter.getMonthName(selectedDateTime)}-${DateFormatter().lastDateOfTheWeekInDateFormat(selectedDateTime: selectedDateTime)}";
    });

    _isDailyOrWeekly
        ? _getRiderLoginHours(selectedDay, selectedDay)
        : _getRiderLoginHours(selectedDay, endDate);
  }

  Future _getRiderLoginHours(
    String startDate,
    String endDate,
  ) async {
    return context
        .read(_riderLoginHoursProvider.notifier)
        .getLoginHours(startDate, endDate);
  }
}
