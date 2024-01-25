import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fraazo_delivery/helpers/date/date_formatter.dart';
import 'package:fraazo_delivery/helpers/extensions/string_extension.dart';
import 'package:fraazo_delivery/helpers/route/route_helper.dart';
import 'package:fraazo_delivery/helpers/route/routes.dart';
import 'package:fraazo_delivery/models/user/profile/performance_model.dart';
import 'package:fraazo_delivery/providers/user/performance/performance_provider.dart';
import 'package:fraazo_delivery/ui/global_widgets/container_divider.dart';
import 'package:fraazo_delivery/ui/global_widgets/fd_circular_loader.dart';
import 'package:fraazo_delivery/ui/global_widgets/fd_error_widget.dart';
import 'package:fraazo_delivery/ui/utils/app_colors.dart';
import 'package:fraazo_delivery/ui/utils/widgets_and_attributes.dart';
import 'package:fraazo_delivery/utils/utils.dart';
import 'package:fraazo_delivery/values/custom_colors.dart';
import 'package:intl/intl.dart';

class PerformanceScreen extends StatefulWidget {
  const PerformanceScreen({Key? key}) : super(key: key);

  @override
  _PerformanceScreenState createState() => _PerformanceScreenState();
}

class _PerformanceScreenState extends State<PerformanceScreen> {
  final _performanceProvider = StateNotifierProvider.autoDispose<
      PerformanceProvider, AsyncValue<PerformanceModel>>(
    (_) => PerformanceProvider(const AsyncLoading()),
  );

  final dateTimeFormatter = DateFormatter();
  final DateTime date = DateTime.now();
  String selectedDate = '';

  @override
  void initState() {
    super.initState();
    final String formattedDate = DateFormat('yyyy-MM-dd').format(date);
    selectedDate = dateTimeFormatter.parseDateTimeToDate(date);
    _getPerformance(formattedDate);
  }

  @override
  Widget build(BuildContext context) {
    return _buildBody();
  }

  Widget _buildBody() {
    final size = MediaQuery.of(context).size;
    final double height = size.height;
    final double width = size.width;
    return SingleChildScrollView(
      child: SizedBox(
        // height: height,
        width: width,
        child: Consumer(builder: (_, watch, __) {
          return watch(_performanceProvider).when(
              data: (PerformanceModel performanceModel) {
                final int issueCount =
                    performanceModel.data!.behaviorIssuesCount! +
                        performanceModel.data!.markedDelivered! +
                        performanceModel.data!.undelivered!;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _onDateTap(),
                    sizedBoxH10,
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 24),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Padding(
                              padding: EdgeInsets.only(
                                  left: width * 0.0254,
                                  top: issueCount > 0 ? 0.0 : 30.0),
                              child: (issueCount > 0)
                                  ? Column(
                                      children: [
                                        SvgPicture.asset(
                                          'performance_issue'.svgImageAsset,
                                          height: 64,
                                          width: 64,
                                        ),
                                        sizedBoxH10,
                                        Text(
                                          "$issueCount issue Reported",
                                          style: commonTextStyle(
                                            color: Colors.white,
                                            fontSize: 16.0,
                                          ),
                                        ),
                                      ],
                                    )
                                  : Column(
                                      children: [
                                        SvgPicture.asset(
                                          'ic_no_issue'.svgImageAsset,
                                          height: 64,
                                          width: 64,
                                        ),
                                        sizedBoxH10,
                                        Text(
                                          "No issues till now",
                                          style: commonTextStyle(
                                            color: Colors.white,
                                            fontSize: 16.0,
                                          ),
                                        ),
                                        Text(
                                          "Great Job !",
                                          style: commonTextStyle(
                                            color: Colors.white,
                                            fontSize: 20.0,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    )),
                          Hero(
                            tag: "rider_logo",
                            child: SvgPicture.asset(
                              (issueCount > 0)
                                  ? 'performance_issue_rider'.svgImageAsset
                                  : 'rider'.svgImageAsset,
                              width: 140,
                              height: 180,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.only(
                        left: width * 0.048,
                        right: width * 0.048,
                        top: height * 0.030,
                        bottom: height * 0.030,
                      ),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(24.0),
                          topRight: Radius.circular(24.0),
                        ),
                      ),
                      child: Column(
                        children: [
                          _buildPerformanceDetails(
                              "Behaviour Issues",
                              performanceModel.data!.behaviorIssuesCount!,
                              performanceModel,
                              "behaviourIssues"),
                          const ContainerDivider(),
                          _buildPerformanceDetails(
                              "Marked Delivered but Not Delivered",
                              performanceModel.data!.markedDelivered ?? 0,
                              performanceModel,
                              "markedDelivered"),
                          const ContainerDivider(),
                          _buildPerformanceDetails(
                              "Undelivered Orders",
                              performanceModel.data!.undelivered ?? 0,
                              performanceModel,
                              "undeliveredOrder"),
                          const ContainerDivider(),
                          sizedBoxH20,
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.white),
                            ),
                            child: Row(
                              children: [
                                SvgPicture.asset(
                                  'bulb'.svgImageAsset,
                                ),
                                sizedBoxW15,
                                Expanded(
                                  child: Text(
                                    "Always be nice to the Customers to avoid issues",
                                    style: commonTextStyle(
                                      color: bgColor,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                );
              },
              loading: () => SizedBox(
                  width: double.maxFinite,
                  height: MediaQuery.of(context).size.height / 2,
                  child: const FDCircularLoader()),
              error: (e, __) => SizedBox(
                    width: double.maxFinite,
                    height: MediaQuery.of(context).size.height / 2,
                    child: FDErrorWidget(
                      onPressed: () => _getPerformance(selectedDate),
                      errorType: e,
                      shouldHideErrorToast: false,
                    ),
                  ));
        }),
      ),
    );
  }

  Widget _buildPerformanceDetails(
      String label, int count, PerformanceModel performanceModel, String key) {
    return InkWell(
      onTap: () {
        List<int> task = [];
        List<String> orderId = [];
        if (key == 'undeliveredOrder' &&
            performanceModel.data!.undeliveredOrder!.isNotEmpty) {
          for (var i = 0;
              i < performanceModel.data!.undeliveredOrder!.length;
              i++) {
            task.add(performanceModel.data!.undeliveredOrder![i].taskId!);
            orderId
                .add(performanceModel.data!.undeliveredOrder![i].orderNumber!);
          }

          final String taskId = task.join(",");
          final String orderSeqId = orderId.join(",");
          RouteHelper.push(Routes.HISTORY,
              args: {"taskId": taskId, "orderId": orderSeqId});
        }
        // else if (key == 'markedDelivered' &&
        //     performanceModel.data!.markedDeliveredOrder!.isNotEmpty) {
        //   for (var i = 0;
        //       i < performanceModel.data!.markedDeliveredOrder!.length;
        //       i++) {
        //     task.add(performanceModel.data!.markedDeliveredOrder![i].taskId!);
        //     orderId.add(
        //         performanceModel.data!.markedDeliveredOrder![i].orderNumber!);
        //   }
        //   final String taskId = task.join(",");
        //   final String orderSeqId = orderId.join(",");
        //   RouteHelper.push(Routes.HISTORY,
        //       args: {"taskId": taskId, "orderId": orderSeqId});
        // }
      },
      child: ListTile(
        title: Text(
          label,
          style: commonTextStyle(
            color: performanceTextColor,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          "$count Times",
          style: commonTextStyle(
            color: count > 0
                ? performanceIssueSubTextColor
                : performanceSubTextColor,
            fontSize: 14,
          ),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 20,
          color: AppColors.secondary,
        ),
      ),
    );
  }

  Widget _onDateTap() {
    final size = MediaQuery.of(context).size;
    final double width = size.width;
    return Container(
      margin: EdgeInsets.only(
        left: width * 0.061,
      ),
      child: TextButton(
          style: ButtonStyle(
              fixedSize: MaterialStateProperty.all(const Size(130, 35)),
              shape: MaterialStateProperty.all(RoundedRectangleBorder(
                side: const BorderSide(color: Colors.white),
                borderRadius: BorderRadius.circular(4.0),
              ))),
          onPressed: () {
            _onPerformanceDateTap();
          },
          child: Row(
            children: [
              Text(
                selectedDate,
                style: commonTextStyle(
                  color: Colors.white,
                  fontSize: 14.0,
                  fontWeight: FontWeight.w600,
                ),
              ),
              sizedBoxW10,
              SvgPicture.asset('ic_calender'.svgImageAsset)
            ],
          )),
    );
  }

  Future _onPerformanceDateTap() async {
    final DateTime? selectedDateTime = await showDatePicker(
        context: context,
        firstDate: DateTime(2018, 6),
        initialDate: DateTime.now(),
        lastDate: DateTime.now(),
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: const ColorScheme.light(
                primary: bgColor, // <-- SEE HERE
                onPrimary: Colors.white, // <-- SEE HERE
                onSurface: bgColor, // <-- SEE HERE
              ),
              textTheme: TextTheme(
                  bodyText1: commonTextStyle(), headline1: commonTextStyle()),
              textButtonTheme: TextButtonThemeData(
                style: TextButton.styleFrom(
                    primary: bgColor,
                    textStyle: commonTextStyle() // button text color
                    ),
              ),
            ),
            child: child!,
          );
        });
    setState(() {
      selectedDate = dateTimeFormatter.parseDateTimeToDate(selectedDateTime!);
    });
    final DateFormat formatter = DateFormat('yyyy-MM-dd');
    final String date = formatter.format(selectedDateTime!);
    _getPerformance(date);
  }

  Future _getPerformance(String date) {
    return context
        .read(_performanceProvider.notifier)
        .getPerformanceApiFetch(date);
  }
}
