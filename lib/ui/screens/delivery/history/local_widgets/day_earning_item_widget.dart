import 'package:flutter/material.dart';
import 'package:fraazo_delivery/models/delivery/day_wise_earning_model.dart';
import 'package:fraazo_delivery/ui/global_widgets/flex_separated.dart';
import 'package:fraazo_delivery/ui/screen_widgets/shadow_card.dart';
import 'package:fraazo_delivery/ui/utils/app_colors.dart';
import 'package:fraazo_delivery/ui/utils/widgets_and_attributes.dart';

class DayEarningItemWidget extends StatelessWidget {
  final DayEarning dayEarning;
  const DayEarningItemWidget(this.dayEarning);

  @override
  Widget build(BuildContext context) {
    return ShadowCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.f6,
              border: Border.all(color: Colors.black26, width: 0.5),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Date: ${dayEarning.createdAtParsed!}",
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                sizedBoxH2,
                Row(
                  children: [
                    const Text(
                      "Total Orders: ",
                      style: TextStyle(
                        color: Colors.black54,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      dayEarning.totalOrders!.toString(),
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: FlexSeparated(
              direction: Axis.vertical,
              spacing: 5,
              children: [
                _buildEarningRow("Total Fixed Cost", dayEarning.totalFixedCost),
                _buildEarningRow(
                    "Total Distance: ${dayEarning.totalDistance}Km",
                    dayEarning.totalDistanceEarning),
                _buildEarningRow("Total Incentives", dayEarning.totalIncentive),
                _buildEarningRow(
                    "Total LoggedIn Hours: ${dayEarning.loggedInHours}Hrs",
                    dayEarning.mgBonus),
                const Divider(
                  color: AppColors.secondary,
                  height: 8,
                ),
                DefaultTextStyle(
                  style: const TextStyle(fontSize: 15, color: Colors.black),
                  child: _buildEarningRow(
                    "Total Amount",
                    dayEarning.totalAmount,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildEarningRow(String label, num? value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.black54,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        sizedBoxW10,
        Text(
          "₹$value",
          style: const TextStyle(
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
