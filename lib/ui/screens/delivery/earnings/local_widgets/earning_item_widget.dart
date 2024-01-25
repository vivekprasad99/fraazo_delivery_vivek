import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fraazo_delivery/helpers/date/date_formatter.dart';
import 'package:fraazo_delivery/helpers/route/route_helper.dart';
import 'package:fraazo_delivery/helpers/route/routes.dart';
import 'package:fraazo_delivery/models/delivery/earning_model.dart';
import 'package:fraazo_delivery/ui/global_widgets/container_divider.dart';
import 'package:fraazo_delivery/ui/screen_widgets/shadow_card.dart';
import 'package:fraazo_delivery/ui/screens/delivery/earnings/local_widgets/pay_plan_dialog.dart';
import 'package:fraazo_delivery/ui/utils/widgets_and_attributes.dart';
import 'package:fraazo_delivery/utils/constants.dart';
import 'package:fraazo_delivery/utils/utils.dart';
import 'package:fraazo_delivery/values/custom_colors.dart';

class EarningItemWidget extends StatefulWidget {
  static const _ES_PAID = "PAID";
  static const _ES_REJECTED = "REJECTED";
  final Earning earning;
  const EarningItemWidget(this.earning);

  @override
  State<EarningItemWidget> createState() => _EarningItemWidgetState();
}

class _EarningItemWidgetState extends State<EarningItemWidget> {
  final dateTimeFormatter = DateFormatter();
  @override
  Widget build(BuildContext context) {
    return ShadowCard(
      child: InkWell(
        onTap: () {
          RouteHelper.push(Routes.HISTORY, args: {
            Constants.DH_START_DATE:
                widget.earning.startDateInDMY!.split('-').reversed.join('-'),
            Constants.DH_END_DATE:
                widget.earning.endDateInDMY!.split('-').reversed.join('-'),
            "earningId": widget.earning.id
          });
        },
        child: Container(
          decoration: BoxDecoration(
            color: containerBgColor,
            border: Border.all(color: earningBorderColor),
            borderRadius: BorderRadius.circular(2),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(px_10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${widget.earning.startDateFormatted} - ${widget.earning.endDateFormatted}',
                        style: commonTextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: textColor),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 5),
                        child: Text(
                          "Settled",
                          style: commonTextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  )),
              const ContainerDivider(),
              SizedBox(
                height: 270,
                child: ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: widget.earning.earningsRevamp!.length,
                  // padding: const EdgeInsets.all(16),
                  itemBuilder: (_, int index) =>
                      _buildEarningItem(widget.earning.earningsRevamp![index]),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEarningItem(EarningsRevamp earningsRevamp) {
    return Column(
      children: [
        if (earningsRevamp.title == 'Total Earnings')
          const ContainerDivider()
        else
          const SizedBox(),
        _buildEarningRow(earningsRevamp.title!, earningsRevamp.value,
            earningsRevamp.subValue ?? '', earningsRevamp.icon ?? ''),
      ],
    );
  }

  Widget _buildEarningRow(
      String label, num? value, String subText, String icon) {
    return InkWell(
      onTap: () {
        label == 'Total Earnings'
            ? _buildPayPlan()
            : RouteHelper.push(
                Routes.HISTORY,
                args: {
                  Constants.DH_START_DATE: widget.earning.startDateInDMY!
                      .split('-')
                      .reversed
                      .join('-'),
                  Constants.DH_END_DATE: widget.earning.endDateInDMY!
                      .split('-')
                      .reversed
                      .join('-'),
                  "earningId": widget.earning.id
                },
              );
      },
      child: ListTile(
        visualDensity: const VisualDensity(horizontal: -2, vertical: -2),
        dense: true,
        horizontalTitleGap: 0,
        leading: SvgPicture.network(
          icon,
          height: 20,
          width: 20,
          placeholderBuilder: (BuildContext context) => const Icon(
            Icons.error,
            color: textColor,
            size: 20,
          ),
          fit: BoxFit.cover,
        ),
        title: label == 'Total Earnings'
            ? Row(
                children: [
                  Text(
                    label,
                    style: commonTextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: textColor),
                  ),
                  sizedBoxW5,
                  const Icon(
                    Icons.info_outline,
                    color: textColor,
                    size: 24,
                  )
                ],
              )
            : Text(
                label,
                style: commonTextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: textColor),
              ),
        subtitle: Text(
          subText,
          style: commonTextStyle(fontSize: 10, color: subTextColor),
        ),
        trailing: Text(
          '₹ ${value ?? '0'}',
          style: commonTextStyle(
              fontSize: 13, fontWeight: FontWeight.w600, color: textColor),
        ),
      ),
    );
  }

  Widget _buildPaymentStatus() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
      margin: const EdgeInsets.only(right: 10),
      color: _getPaymentStatusBgColor(),
      child: Text(
        widget.earning.status!.replaceAll("_", " "),
        style: const TextStyle(
            color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700),
      ),
    );
  }

  Color _getPaymentStatusBgColor() {
    if (widget.earning.status == EarningItemWidget._ES_PAID) {
      return deliveredTextColors;
    } else if (widget.earning.status == EarningItemWidget._ES_REJECTED) {
      return cancelledTextColors;
    } else {
      return Colors.grey;
    }
  }

  void _buildPayPlan() {
    showDialog(
      barrierColor: Colors.transparent,
      context: context,
      builder: (_) => const PayPlanDialog(),
    );
  }
}
