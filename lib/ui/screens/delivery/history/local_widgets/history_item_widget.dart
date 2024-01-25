import 'package:flutter/material.dart';
import 'package:fraazo_delivery/helpers/date/date_formatter.dart';
import 'package:fraazo_delivery/models/delivery/task_model.dart';
import 'package:fraazo_delivery/ui/global_widgets/container_divider.dart';
import 'package:fraazo_delivery/ui/utils/widgets_and_attributes.dart';
import 'package:fraazo_delivery/utils/constants.dart';
import 'package:fraazo_delivery/utils/globals.dart';
import 'package:fraazo_delivery/utils/utils.dart';
import 'package:fraazo_delivery/values/custom_colors.dart';
import 'package:timelines/timelines.dart';

import '../../../../utils/textview.dart';

class HistoryItemWidget extends StatefulWidget {
  final Task task;
  final bool isFromMenu;

  const HistoryItemWidget(this.task, {Key? key, this.isFromMenu = false})
      : super(key: key);

  @override
  State<HistoryItemWidget> createState() => _HistoryItemWidgetState();
}

class _HistoryItemWidgetState extends State<HistoryItemWidget> {
  @override
  Widget build(BuildContext context) {
    return _buildExpandedCard(widget.task);
  }

  bool _customTileExpanded = false;

  Widget _buildExpandedCard(Task task) {
    final dateTimeFormatter = DateFormatter();
    return DecoratedBox(
      decoration: BoxDecoration(
        color: containerBgColor,
        border: Border.all(color: earningBorderColor),
        borderRadius: BorderRadius.circular(4),
        boxShadow: const [BoxShadow()],
      ),
      child: ListTileTheme(
        contentPadding: EdgeInsets.zero,
        dense: true,
        horizontalTitleGap: 0.0,
        minLeadingWidth: 0,
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: px_8),
          expandedCrossAxisAlignment: CrossAxisAlignment.start,
          maintainState: true,
          title: IntrinsicHeight(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      "Task ID: ${task.id}",
                      style: commonTextStyle(
                        fontSize: 13,
                        color: textColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    sizedBoxW2,
                    const VerticalDivider(
                      color: verticalDividerColor,
                      thickness: 1,
                    ),
                    sizedBoxW2,
                    Text(
                      dateTimeFormatter.parseDateToDMY(task.createdAt!),
                      style: commonTextStyle(
                          color: historySubTextColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 10),
                    ),
                    sizedBoxW2,
                    const VerticalDivider(
                      color: verticalDividerColor,
                      thickness: 1,
                    ),
                    sizedBoxW2,
                    if (!_customTileExpanded)
                      CircleAvatar(
                        radius: 10,
                        backgroundColor: orderSeqColor,
                        child: Text(
                          task.orderSeq!.length.toString(),
                          style: commonTextStyle(
                              color: textColor,
                              fontWeight: FontWeight.w600,
                              fontSize: 10),
                        ),
                      )
                    else
                      Text(
                        dateTimeFormatter.dateStringToTime(task.createdAt!),
                        style: commonTextStyle(
                            color: historySubTextColor, fontSize: 10),
                      ),
                  ],
                ),
                Row(
                  children: [
                    CircleAvatar(
                      radius: 3,
                      backgroundColor: widget.task.statusColorCode == 0
                          ? cancelledTextColors
                          : widget.task.statusColorCode == 1
                              ? partilyTextColors
                              : deliveredTextColors,
                    ),
                    Visibility(
                      visible: widget.isFromMenu && !_customTileExpanded,
                      child: Container(
                        height: 26,
                        margin: const EdgeInsets.only(left: 5),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        padding: const EdgeInsets.only(
                            left: 8, right: 8, top: 4, bottom: 4),
                        child: Text(
                          "₹ ${task.earning?.total?.toStringAsFixed(0)}",
                          style: commonTextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
          trailing: Icon(
            _customTileExpanded ? Icons.arrow_drop_up : Icons.arrow_drop_down,
            color: textColor,
            size: 16,
          ),
          onExpansionChanged: (bool expanded) {
            setState(() {
              _customTileExpanded = expanded;
            });
          },
          // childrenPadding:
          //     const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          children: [
            // Visibility(
            //   visible: widget.isFromMenu,
            //   child: Container(
            //     width: double.infinity,
            //     margin: const EdgeInsets.only(left: 9, right: 9, bottom: px_16),
            //     padding: const EdgeInsets.symmetric(vertical: 4),
            //     decoration: BoxDecoration(
            //       color: Colors.white,
            //       borderRadius: BorderRadius.circular(4),
            //     ),
            //     child: Center(
            //       child: Row(
            //         mainAxisAlignment: MainAxisAlignment.center,
            //         children: [
            //           SvgPicture.asset(
            //             'payment_settled_note'.svgImageAsset,
            //             height: 25,
            //             width: 23,
            //             fit: BoxFit.cover,
            //           ),
            //           sizedBoxW5,
            //           Text(
            //             "Payments Settled",
            //             style: commonTextStyle(
            //               fontSize: 12,
            //               fontWeight: FontWeight.w600,
            //             ),
            //           ),
            //         ],
            //       ),
            //     ),
            //   ),
            // ),
            const ContainerDivider(),

            // sizedBoxH20,
            // ...List.generate(task.orderSeq?.length ?? 0, (index) {
            //   final order = task.orderSeq![index];
            //   // print('perKmPrice ${task.earning!.}');
            //   return
            Padding(
              padding: const EdgeInsets.all(px_10),
              child: FixedTimeline.tileBuilder(
                theme: TimelineThemeData(
                  nodePosition: 0,
                  color: const Color(0xff989898),
                  indicatorTheme: const IndicatorThemeData(
                    position: 0,
                    size: 20.0,
                  ),
                  connectorTheme: const ConnectorThemeData(
                      thickness: 1, color: Color(0xff555555)),
                ),
                builder: TimelineTileBuilder.connected(
                  connectionDirection: ConnectionDirection.before,
                  itemCount: task.orderSeq!.length + 2,
                  contentsBuilder: (_, index) {
                    final order =
                        index == 0 || index == task.orderSeq!.length + 1
                            ? null
                            : task.orderSeq![index - 1];

                    return index == 0 || index == task.orderSeq!.length + 1
                        ? Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Darkstore",
                                  style: commonTextStyle(
                                      color: historySubTextColor,
                                      fontSize: 10.0),
                                ),
                                sizedBoxH5,
                                Visibility(
                                  visible: index != task.orderSeq!.length + 1,
                                  child: TextView(
                                      title:
                                          'Dist : ${index == 0 ? task.dkToFirstOrder?.toStringAsFixed(2) : task.lastOrderToDk?.toStringAsFixed(2)} kms ',
                                      textStyle: commonTextStyle(
                                          fontSize: 9, color: Colors.white)),
                                ),
                                if (index == 0) sizedBoxH30 else sizedBoxH10
                              ],
                            ),
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 10),
                                width: double.infinity,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        IntrinsicHeight(
                                          child: Row(
                                            children: [
                                              Row(
                                                children: [
                                                  Text(
                                                    'Order ID: ${order?.orderNumber}',
                                                    style: commonTextStyle(
                                                        color:
                                                            HistoryIdTextColor,
                                                        fontSize: 11),
                                                  ),
                                                  sizedBoxW2,
                                                  const VerticalDivider(
                                                    color: verticalDividerColor,
                                                    thickness: 1,
                                                  ),
                                                  sizedBoxW2,
                                                  Text(
                                                    order?.orderStatus
                                                            ?.replaceAll(
                                                                '_', ' ') ??
                                                        "",
                                                    style: commonTextStyle(
                                                      color: order?.orderStatus ==
                                                              'DELIVERED'
                                                          ? deliveredTextColors
                                                          : cancelledTextColors,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      fontSize: 8,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                        // Text(
                                        //   "₹ ${task.orderSeq![0].amount!.toStringAsFixed(0)}",
                                        //   style: commonTextStyle(
                                        //     color: textColor,
                                        //     fontWeight: FontWeight.w600,
                                        //     fontSize: 12,
                                        //   ),
                                        // ),
                                      ],
                                    ),
                                    sizedBoxH5,
                                    IntrinsicHeight(
                                      child: Row(
                                        children: [
                                          Text(
                                            dateTimeFormatter.dateStringToTime(
                                                order!.updatedAt!),
                                            style: commonTextStyle(
                                                color: historySubTextColor,
                                                fontSize: 9),
                                          ),
                                          sizedBoxW2,
                                          const VerticalDivider(
                                            color: verticalDividerColor,
                                            thickness: 1,
                                          ),
                                          sizedBoxW2,
                                          Text(
                                            order.isCod
                                                ? "COD Order"
                                                : "Prepaid Order",
                                            style: commonTextStyle(
                                                color: historySubTextColor,
                                                fontSize: 9),
                                          ),
                                        ],
                                      ),
                                    ),
                                    sizedBoxH10,
                                    Text(
                                      "Customer Location",
                                      style: commonTextStyle(
                                          color: historySubTextColor,
                                          fontSize: 10.0),
                                    ),
                                    sizedBoxH2,
                                    Text(
                                      order.address!,
                                      style: commonTextStyle(
                                          color: textColor, fontSize: 10.0),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          top: px_16, bottom: px_16),
                                      child: TextView(
                                          title:
                                              'Dist : ${order.darkstoreDistance} kms ',
                                          textStyle: commonTextStyle(
                                              fontSize: 9,
                                              color: historySubTextColor)),
                                    )
                                  ],
                                ),
                              )

                              //   ),
                            ],
                          );
                  },
                  indicatorBuilder: (_, index) {
                    return DotIndicator(
                        color: const Color(0xff555555),
                        size: 15,
                        child: Center(
                          child: TextView(
                              alignment: Alignment.center,
                              title: index == 0 ||
                                      index == task.orderSeq!.length + 1
                                  ? ''
                                  : '$index',
                              textStyle: commonTextStyle(
                                color: Colors.white,
                                fontSize: 8,
                              )),
                        ));
                  },
                  connectorBuilder: (_, index, ___) =>
                      const SolidLineConnector(color: Color(0xff555555)),
                ),
              ),
            ),

            const ContainerDivider(),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Total Distance",
                        style: commonTextStyle(
                            color: historySubTextColor, fontSize: 10.0),
                      ),
                      // Text(
                      //   "₹ ${task.orderSeq![0].amount!.toStringAsFixed(0)}",
                      //   style: commonTextStyle(
                      //       color: textColor, fontWeight: FontWeight.w600),
                      // ),
                    ],
                  ),
                  sizedBoxH5,
                  Text(
                    'Dist: ${task.totalTripDistance?.toStringAsFixed(2)} kms',
                    style: commonTextStyle(
                      color: textColor,
                      fontSize: 9,
                    ),
                  ),
                ],
              ),
            ),

            Visibility(
              visible: Globals.user!.billingEnabled!,
              child: Column(
                children: [
                  const ContainerDivider(),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 15),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Total Amount",
                          style: commonTextStyle(
                              color: historySubTextColor, fontSize: 10.0),
                        ),
                        Text(
                          "₹ ${task.earning?.total?.toStringAsFixed(2)}",
                          style: commonTextStyle(
                            color: textColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
