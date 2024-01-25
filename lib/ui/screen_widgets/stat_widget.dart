import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fraazo_delivery/helpers/extensions/string_extension.dart';
import 'package:fraazo_delivery/helpers/route/route_helper.dart';
import 'package:fraazo_delivery/helpers/route/routes.dart';
import 'package:fraazo_delivery/models/home_page/earning_daily_order_model.dart';
import 'package:fraazo_delivery/ui/utils/textview.dart';
import 'package:fraazo_delivery/ui/utils/widgets_and_attributes.dart';
import 'package:fraazo_delivery/utils/utils.dart';
import 'package:fraazo_delivery/values/custom_colors.dart';

class StatWidget extends StatelessWidget {
  final EarningAndDailyOrderModel? earningAndDailyOrderModel;
  final bool isClickable;
  const StatWidget(this.earningAndDailyOrderModel, {this.isClickable = false});
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final double width = size.width;
    return IntrinsicHeight(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildStatWidget("Orders Today",
              "${earningAndDailyOrderModel?.orderCount}", "bag", width),
          sizedBoxW10,
          _buildStatWidget(
            "Cash in Hand",
            "₹ ${earningAndDailyOrderModel?.codAmount}",
            "money_new",
            width,
            onTap: () => RouteHelper.push(Routes.FLOATING_CASH,
                args: earningAndDailyOrderModel?.codAmount),
          ),
          // if (Globals.shouldShowBilling) ...[
          //   sizedBoxW10,
          //   _buildStatWidget(
          //       "Earnings", "₹${stat?.earningTruncated}", "money_new"),
          // ]
        ],
      ),
    );
  }

  Widget _buildStatWidget(
      String label, String value, String imageName, double width,
      {VoidCallback? onTap}) {
    return Expanded(
      child: InkWell(
        onTap: () => isClickable
            ? (onTap != null ? onTap() : RouteHelper.push(Routes.HISTORY))
            : null,
        child: Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: containerBgColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextView(
                      title: label,
                      textStyle: commonTextStyle(
                        color: const Color(0xffABABAB),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    TextView(
                      title: value,
                      textStyle: commonTextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              SvgPicture.asset(
                imageName.svgImageAsset,
                height: imageName == 'money_new' ? 40 : 30,
                fit: BoxFit.cover,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
