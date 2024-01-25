import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fraazo_delivery/helpers/error/error_reporter.dart';
import 'package:fraazo_delivery/helpers/extensions/string_extension.dart';
import 'package:fraazo_delivery/models/delivery/task_model.dart';
import 'package:fraazo_delivery/providers/delivery/latest_task_provider.dart';
import 'package:fraazo_delivery/providers/delivery/order/order_update_provider.dart';
import 'package:fraazo_delivery/ui/screen_widgets/dummy_location_switch.dart';
import 'package:fraazo_delivery/ui/screens/delivery/steps/local_widgets/cash_or_qr_code_widget.dart';
import 'package:fraazo_delivery/ui/screens/delivery/steps/local_widgets/issue_button.dart';
import 'package:fraazo_delivery/ui/screens/delivery/steps/local_widgets/new_slide_button.dart';
import 'package:fraazo_delivery/ui/screens/home/local_widgets/drawer_menu.dart';
import 'package:fraazo_delivery/ui/utils/textview.dart';
import 'package:fraazo_delivery/ui/utils/toast.dart';
import 'package:fraazo_delivery/ui/utils/widgets_and_attributes.dart';
import 'package:fraazo_delivery/utils/constants.dart';
import 'package:fraazo_delivery/utils/globals.dart';
import 'package:fraazo_delivery/utils/utils.dart';
import 'package:fraazo_delivery/values/custom_colors.dart';
import 'package:intl/intl.dart';

class DeliveryCompletedScreen extends StatefulWidget {
  final Task? task;
  const DeliveryCompletedScreen(this.task, {Key? key}) : super(key: key);

  @override
  State<DeliveryCompletedScreen> createState() =>
      _DeliveryCompletedScreenState();
}

class _DeliveryCompletedScreenState extends State<DeliveryCompletedScreen> {
  final _deliverTypeProvider =
      StateProvider<String>((ref) => _deliveredToTypes[0]);
  final cashTypeProvider = StateProvider<int>((ref) => 1);

  final List<int> _selectedCashType = [1, 2];
  int cashTypeId = -1;

  static const _deliveredToTypes = [
    "handed_to_customer",
    "handed_to_security",
    "left_on_society_gate"
  ];

  String? _selectedType = "handed_to_customer";
  late final int _taskID;

  OrderSeq? orderSeq;

  @override
  void initState() {
    super.initState();

    //WidgetsBinding.instance?.addPostFrameCallback((_) => _startOrderDelivery());
    _taskID = context.read(latestTaskProvider.notifier).currentTask!.id ?? 0;

    orderSeq = widget.task?.orderSeq?.single;
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarBrightness: Brightness.dark,
    ));
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0.0,
        actions: [IssueButton(task: widget.task)],
      ),
      drawer: const DrawerMenu(),
      body: Container(
        child: _buildBody(),
      ),
      bottomNavigationBar: orderSeq == null
          ? Container()
          : Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.only(
                      top: 25, bottom: 25, left: 16, right: 16),
                  width: MediaQuery.of(context).size.width,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(12.0),
                      topRight: Radius.circular(12.0),
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (orderSeq?.isCod ?? false) ...[
                        _buildCodFlowButton(orderSeq!),
                      ] else ...[
                        _prepaidFlowWidget(),
                      ],
                      sizedBoxH20,
                      _buildMarkDeliveredButton(),
                    ],
                  ),
                ),
                const DummyLocationSwitch()
              ],
            ),
    );
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      child: Column(
        children: [
          /**
           * Scroll within Stack issue
           * Expanded>SingleChildScrollView and bottom padding height/2.7 added
           ***/
          Padding(
            padding: const EdgeInsets.only(
              left: px_20,
              right: px_20,
              //bottom: MediaQuery.of(context).size.height / 3 /*px_50*/,
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextView(
                          title: "ORDER #${orderSeq?.orderNumber}",
                          textStyle: commonTextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        sizedBoxH10,
                        TextView(
                          title: "Task ID : ${orderSeq?.taskId}",
                          textStyle: commonTextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: TaskColor,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.only(
                          left: 10, right: 10, top: 8, bottom: 8),
                      decoration: BoxDecoration(
                        color: bgCodColor,
                        borderRadius: BorderRadius.circular(16.5),
                      ),
                      child: TextView(
                        title:
                            "${(orderSeq?.isCod ?? false) ? "COD ORDER: " : "PAID ORDER: "} ₹${orderSeq?.amount}",
                        textStyle: commonTextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                sizedBoxH5,
                const Divider(
                  thickness: 2,
                  color: borderLineColor,
                ),
                sizedBoxH20,
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          height: px_10,
                          width: px_10,
                          decoration: const BoxDecoration(
                              color: Colors.white, shape: BoxShape.circle),
                        ),
                        sizedBoxW10,
                        TextView(
                          title: "Pickup",
                          textStyle: commonTextStyle(
                            color: locationColor,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 20, top: 10),
                      child: Text(
                        widget.task!.storeInfo!.storeName ?? '',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                    )
                  ],
                ),
                sizedBoxH40,
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          height: px_10,
                          width: px_10,
                          decoration: const BoxDecoration(
                              color: buttonColor, shape: BoxShape.circle),
                        ),
                        sizedBoxW10,
                        TextView(
                          title: "Customer Location",
                          textStyle: commonTextStyle(
                            color: locationColor,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 20, top: 10),
                      child: TextView(
                        title: orderSeq?.address ?? '',
                        textStyle: commonTextStyle(
                          fontSize: 14,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                sizedBoxH20,
                const Divider(
                  thickness: 2,
                  color: borderLineColor,
                ),
                ListTile(
                  leading: SvgPicture.asset(
                    'customer'.svgImageAsset,
                  ),
                  title: TextView(
                    title: "Customer",
                    textStyle: commonTextStyle(
                      color: locationColor,
                      fontSize: 13,
                    ),
                  ),
                  subtitle: TextView(
                    title: orderSeq?.custName ?? '',
                    textStyle: commonTextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  trailing: InkWell(
                    onTap: () {
                      if (orderSeq?.callEnabled ?? false) {
                        _onCallButtonTap();
                      }
                    },
                    child: Container(
                      height: 30,
                      width: 65,
                      padding: const EdgeInsets.only(
                          left: 10, right: 10, top: 8, bottom: 8),
                      decoration: BoxDecoration(
                        color: (orderSeq?.callEnabled ?? false)
                            ? buttonColor
                            : disableCallColor,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.call,
                            size: 15,
                            color: Colors.white,
                          ),
                          sizedBoxW5,
                          TextView(
                            title: "Call",
                            textStyle: commonTextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Positioned(
          //   bottom: 0,
          //   child: Container(
          //     padding: const EdgeInsets.only(
          //         top: 25, bottom: 25, left: 16, right: 16),
          //     width: MediaQuery.of(context).size.width,
          //     decoration: const BoxDecoration(
          //       color: Colors.white,
          //       borderRadius: BorderRadius.only(
          //         topLeft: Radius.circular(12.0),
          //         topRight: Radius.circular(12.0),
          //       ),
          //     ),
          //     child: Column(
          //       children: [
          //         if (orderSeq?.isCod ?? false) ...[
          //           _buildCodFlowButton(orderSeq!),
          //         ] else ...[
          //           _prepaidFlowWidget(),
          //         ],
          //         sizedBoxH20,
          //         _buildMarkDeliveredButton(),
          //       ],
          //     ),
          //   ),
          // )
        ],
      ),
    );

    /*return SizedBox(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      child: Consumer(
        builder: (_, watch, __) {
          return watch(orderUpdateProvider).when(
            data: (value) {
              final OrderSeq orderSeq = value;
              return Stack(
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Expanded(
                        child: Padding(
                          padding:
                              const EdgeInsets.only(left: px_20, right: px_20),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      TextView(
                                        title: "ORDER #${orderSeq.orderNumber}",
                                        textStyle: commonTextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white,
                                        ),
                                      ),
                                      sizedBoxH10,
                                      TextView(
                                        title: "Task ID : ${orderSeq.taskId}",
                                        textStyle: commonTextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700,
                                          color: TaskColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Container(
                                    padding: const EdgeInsets.only(
                                        left: 10, right: 10, top: 8, bottom: 8),
                                    decoration: BoxDecoration(
                                      color: bgCodColor,
                                      borderRadius: BorderRadius.circular(16.5),
                                    ),
                                    child: TextView(
                                      title:
                                          "${orderSeq.isCod ? "COD ORDER: " : "PAID ORDER: "} ₹${orderSeq.amount}",
                                      textStyle: commonTextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              sizedBoxH5,
                              const Divider(
                                thickness: 2,
                                color: borderLineColor,
                              ),
                              sizedBoxH20,
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        height: px_10,
                                        width: px_10,
                                        decoration: const BoxDecoration(
                                            color: Colors.white,
                                            shape: BoxShape.circle),
                                      ),
                                      sizedBoxW10,
                                      TextView(
                                        title: "Pickup",
                                        textStyle: commonTextStyle(
                                          color: locationColor,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: 20, top: 10),
                                    child: Text(
                                      widget.task!.storeInfo!.storeName ?? '',
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.white,
                                      ),
                                    ),
                                  )
                                ],
                              ),
                              sizedBoxH40,
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        height: px_10,
                                        width: px_10,
                                        decoration: const BoxDecoration(
                                            color: buttonColor,
                                            shape: BoxShape.circle),
                                      ),
                                      sizedBoxW10,
                                      TextView(
                                        title: "Customer Location",
                                        textStyle: commonTextStyle(
                                          color: locationColor,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: 20, top: 10),
                                    child: TextView(
                                      title: orderSeq.address ?? '',
                                      textStyle: commonTextStyle(
                                        fontSize: 14,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              sizedBoxH20,
                              const Divider(
                                thickness: 2,
                                color: borderLineColor,
                              ),
                              ListTile(
                                leading: SvgPicture.asset(
                                  'customer'.svgImageAsset,
                                ),
                                title: TextView(
                                  title: "Customer",
                                  textStyle: commonTextStyle(
                                    color: locationColor,
                                    fontSize: 13,
                                  ),
                                ),
                                subtitle: TextView(
                                  title: orderSeq.custName ?? '',
                                  textStyle: commonTextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                trailing: InkWell(
                                  onTap: () {
                                    if (orderSeq.callEnabled!) {
                                      _onCallButtonTap();
                                    }
                                  },
                                  child: Container(
                                    height: 30,
                                    width: 65,
                                    padding: const EdgeInsets.only(
                                        left: 10, right: 10, top: 8, bottom: 8),
                                    decoration: BoxDecoration(
                                      color: orderSeq.callEnabled!
                                          ? buttonColor
                                          : disableCallColor,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(
                                          Icons.call,
                                          size: 15,
                                          color: Colors.white,
                                        ),
                                        sizedBoxW5,
                                        TextView(
                                          title: "Call",
                                          textStyle: commonTextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  Positioned(
                    bottom: 0,
                    child: Container(
                      padding: const EdgeInsets.only(
                          top: 25, bottom: 25, left: 16, right: 16),
                      width: MediaQuery.of(context).size.width,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(12.0),
                          topRight: Radius.circular(12.0),
                        ),
                      ),
                      child: Column(
                        children: [
                          if (orderSeq.isCod) ...[
                            _buildCodFlowButton(orderSeq),
                          ] else ...[
                            _prepaidFlowWidget(),
                          ],
                          sizedBoxH20,
                          _buildMarkDeliveredButton(),
                        ],
                      ),
                    ),
                  )
                ],
              );
            },
            loading: () => const FDCircularLoader(
              progressColor: Colors.white,
            ),
            error: (e, __) => FDErrorWidget(
              onPressed: _startOrderDelivery,
              errorType: e,
              textColor: Colors.white,
              shouldHideErrorToast: false,
            ),
          );
        },
      ),
    );*/
  }

  Widget _buildCodFlowButton(OrderSeq orderSeq) {
    return Consumer(
      builder: (_, watch, __) {
        final cashType = watch(cashTypeProvider);
        cashTypeId = cashType.state;
        return Column(
          children: [
            Material(
              // padding: const EdgeInsets.only(
              //     left: 20, right: 20, top: 10, bottom: 10),
              // decoration: BoxDecoration(
              //   color: bgCashColor,
              //   borderRadius: BorderRadius.circular(25.5),
              // ),

              borderRadius: BorderRadius.circular(25.5),
              elevation: 5,
              color: bgCashColor,
              child: Padding(
                padding: const EdgeInsets.only(
                    left: 20, right: 20, top: 10, bottom: 10),
                child: Text(
                  "Please Collect ₹${orderSeq.amount}",
                  style: commonTextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            sizedBoxH20,
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () {
                      context.read(cashTypeProvider).state =
                          _selectedCashType[0];
                      cashTypeId = _selectedCashType[0];
                      // _showDeliveryDialog();
                    },
                    child: Container(
                      padding: const EdgeInsets.only(
                          left: 8, right: 8, top: 15, bottom: 15),
                      decoration: BoxDecoration(
                          color: (cashTypeId == 1)
                              ? const Color.fromRGBO(38, 188, 38, 0.12)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: (cashTypeId == 1)
                                ? buttonColor
                                : unSelectedBtnColor,
                          )),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            SvgPicture.asset(
                              'new_cash'.svgImageAsset,
                              height: 18,
                              fit: BoxFit.cover,
                            ),
                            sizedBoxW5,
                            Expanded(
                              child: Text(
                                "Full Cash Collected",
                                overflow: TextOverflow.ellipsis,
                                style: commonTextStyle(
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ]),
                    ),
                  ),
                ),
                Visibility(
                  visible: Globals.user!.qrEnable,
                  child: Expanded(
                    child: Row(
                      children: [
                        sizedBoxW10,
                        InkWell(
                          onTap: () {
                            context.read(cashTypeProvider.notifier).state = 2;
                            cashTypeId = _selectedCashType[1];
                          },
                          child: Container(
                            padding: const EdgeInsets.only(
                                left: 10, right: 10, top: 12, bottom: 12),
                            decoration: BoxDecoration(
                              color: (cashTypeId == 2)
                                  ? const Color.fromRGBO(38, 188, 38, 0.12)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: (cashTypeId == 2)
                                    ? buttonColor
                                    : unSelectedBtnColor,
                              ),
                            ),
                            child: CashOrQrCodeWidget(
                              orderSeq,
                              onGenerateTap: () {
                                context
                                    .read(orderUpdateProvider.notifier)
                                    .endOrderDelivery(_taskID);
                              },
                              shouldShowQRIcon: true,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _prepaidFlowWidget() {
    return Column(
      children: [
        Text(
          "Please select how you delivered the order ",
          style: commonTextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        sizedBoxH20,
        _buildPrepaidFlowButton(),
      ],
    );
  }

  Widget _buildPrepaidFlowButton() {
    return Consumer(
      builder: (_, watch, __) {
        final cashType = watch(_deliverTypeProvider).state;
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            InkWell(
              onTap: () {
                context.read(_deliverTypeProvider).state = _deliveredToTypes[0];
                _selectedType = _deliveredToTypes[0];
              },
              child: Container(
                width: 100,
                padding: const EdgeInsets.only(
                    left: 8, right: 10, top: 12, bottom: 12),
                decoration: BoxDecoration(
                    color: (context.read(_deliverTypeProvider).state ==
                            _deliveredToTypes[0])
                        ? const Color.fromRGBO(38, 188, 38, 0.12)
                        : unSelectedBorderColor,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: (context.read(_deliverTypeProvider).state ==
                              _deliveredToTypes[0])
                          ? buttonColor
                          : unSelectedBtnColor,
                    )),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SvgPicture.asset(
                        'handed_to_customer'.svgImageAsset,
                        height: 35,
                      ),
                      Text(
                        toBeginningOfSentenceCase(
                            _deliveredToTypes[0].replaceAll("_", " "))!,
                        style: commonTextStyle(
                          fontSize: 11,
                        ),
                      ),
                    ]),
              ),
            ),
            InkWell(
              onTap: () {
                context.read(_deliverTypeProvider).state = _deliveredToTypes[1];
                _selectedType = _deliveredToTypes[1];
              },
              child: Container(
                width: 100,
                padding: const EdgeInsets.only(
                    left: 8, right: 10, top: 12, bottom: 12),
                decoration: BoxDecoration(
                    color: (context.read(_deliverTypeProvider).state ==
                            _deliveredToTypes[1])
                        ? const Color.fromRGBO(38, 188, 38, 0.12)
                        : unSelectedBorderColor,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: (context.read(_deliverTypeProvider).state ==
                              _deliveredToTypes[1])
                          ? buttonColor
                          : unSelectedBtnColor,
                    )),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SvgPicture.asset('handed_to_security'.svgImageAsset,
                          height: 35),
                      Text(
                        toBeginningOfSentenceCase(
                            _deliveredToTypes[1].replaceAll("_", " "))!,
                        style: commonTextStyle(
                          fontSize: 11,
                        ),
                      ),
                    ]),
              ),
            ),
            InkWell(
              onTap: () {
                context.read(_deliverTypeProvider).state = _deliveredToTypes[2];
                _selectedType = _deliveredToTypes[2];
              },
              child: Container(
                width: 100,
                padding: const EdgeInsets.only(
                    left: 8, right: 10, top: 12, bottom: 12),
                decoration: BoxDecoration(
                    color: (context.read(_deliverTypeProvider).state ==
                            _deliveredToTypes[2])
                        ? const Color.fromRGBO(38, 188, 38, 0.12)
                        : unSelectedBorderColor,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: (context.read(_deliverTypeProvider).state ==
                              _deliveredToTypes[2])
                          ? buttonColor
                          : unSelectedBtnColor,
                    )),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SvgPicture.asset('left_at_society_gate'.svgImageAsset,
                        height: 35),
                    Text(
                      toBeginningOfSentenceCase(
                        _deliveredToTypes[2].replaceAll("_", " "),
                      )!,
                      style: commonTextStyle(
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // void _showDeliveryDialog() {
  //   showModalBottomSheet(
  //     context: context,
  //     backgroundColor: Colors.white,
  //     shape: const RoundedRectangleBorder(
  //       borderRadius: BorderRadius.only(
  //           topRight: Radius.circular(px_16), topLeft: Radius.circular(px_16)),
  //     ),
  //     builder: (_) => SizedBox(
  //       height: MediaQuery.of(context).copyWith().size.height * 0.35,
  //       child: Padding(
  //         padding: const EdgeInsets.all(16.0),
  //         child: Column(
  //           children: [
  //             _prepaidFlowWidget(),
  //             sizedBoxH30,
  //             _buildMarkDeliveredButton(),
  //           ],
  //         ),
  //       ),
  //     ),
  //   );
  // }

  Widget _buildMarkDeliveredButton() {
    return NewSlideButton(
      action: () => _onOrderComplete(),
      backgroundColor: buttonColor,
      height: 54,
      radius: 10,
      dismissible: false,
      label: Text(
        "Mark Delivered",
        style: commonTextStyle(
          fontSize: 15,
          color: textColor,
        ),
      ),
      width: MediaQuery.of(context).size.width * 1,
      alignLabel: const Alignment(0.1, 0),
    );
  }

  void _startOrderDelivery() {
    context.read(orderUpdateProvider.notifier).updateOrderStatus(
          Constants.OS_REACHED_CUSTOMER,
          orderSeq: widget.task?.orderSeq?.single,
        );
  }

  Future _showWithPopupLoading(Future callback) async {
    final cancelFunc = Toast.popupLoading();
    try {
      await callback;
    } catch (e) {
      rethrow;
    } finally {
      cancelFunc();
    }
  }

  Future _onOrderComplete() async {
    if (_selectedType == null) {
      return;
    }
    await _showWithPopupLoading(_endOrderDelivery());
  }

  Future _endOrderDelivery() async {
    final order = widget.task!.orderSeq![0];
    await _updateOrderStatusToDelivered(order, deliveredTo: _selectedType);

    /*context
        .read(latestTaskProvider.notifier)
        .taskOrderComplete(taskId: widget.task?.id ?? 0);*/

    /* await context
        .read(taskUpdateProvider.notifier)
        .onTaskComplete(widget.task?.id);*/
  }

  Future _updateOrderStatusToDelivered(
    OrderSeq order, {
    String? deliveryOTP,
    String? deliveredTo,
  }) {
    context.read(orderUpdateProvider.notifier).updateOrderDetails(order);

    return context.read(orderUpdateProvider.notifier).endOrderDelivery(
          widget.task?.id ?? 0,
          orderSeq: order,
          deliveredTo: deliveredTo,
        );

    /*return context.read(orderUpdateProvider.notifier).updateOrderStatus(
          Constants.OS_DELIVERED,
          orderSeq: order,
          deliveredTo: deliveredTo,
        );*/
  }

  Future _onCallButtonTap() async {
    // if (context.read(orderUpdateProvider.notifier).clickCount == 0) {
    final order = widget.task!.orderSeq![0];
    final cancelFunc = Toast.popupLoading();
    try {
      await context
          .read(orderUpdateProvider.notifier)
          .callToCustomer(order.orderNumber);
      context.read(orderUpdateProvider.notifier).clickCount = 3;
      Toast.normal(
          "Call request is sent. Please wait and accept incoming call.");
    } catch (e, st) {
      ErrorReporter.error(
          e, st, "CurrentDeliveryDetailsWidget: _onCallButtonTap()");
    }
    cancelFunc();
    // } else {
    //   context.read(orderUpdateProvider.notifier).clickCallButton();
    // }
  }
}
