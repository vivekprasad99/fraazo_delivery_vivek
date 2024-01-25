import 'package:flutter/material.dart';
import 'package:fraazo_delivery/models/delivery/delivery_items_model.dart';
import 'package:fraazo_delivery/ui/global_widgets/flex_separated.dart';
import 'package:fraazo_delivery/ui/utils/widgets_and_attributes.dart';

class HorizontalProductCard extends StatelessWidget {
  final LineItem lineItem;
  final bool shouldShowAmount;
  const HorizontalProductCard(this.lineItem,
      {Key? key, this.shouldShowAmount = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ColoredBox(
          color: const Color(0xFFF6F6F6),
          child: Padding(
            padding: const EdgeInsets.all(3.0),
            child: Image.network(
              lineItem.imageUrl ?? "",
              height: 60,
              width: 60,
              fit: BoxFit.cover,
            ),
          ),
        ),
        sizedBoxW15,
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 3),
            child: FlexSeparated(
              spacing: 3.5,
              direction: Axis.vertical,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  lineItem.name ?? "",
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF333333),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Row(
                  children: [
                    Text(
                      "Unit: ${lineItem.packSize}",
                      style: const TextStyle(
                          color: Color(0xFF666666),
                          fontSize: 12,
                          fontWeight: FontWeight.w500),
                    ),
                    const Text(
                      "  |  ",
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 14,
                          fontWeight: FontWeight.w500),
                    ),
                    Text(
                      "Qty: ${lineItem.qty}",
                      style: const TextStyle(
                          color: Color(0xFF666666),
                          fontSize: 12,
                          fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
                if (shouldShowAmount)
                  Text(
                    "₹ ${lineItem.nettAmount}",
                    style: const TextStyle(
                      color: Colors.orange,
                    ),
                  )
              ],
            ),
          ),
        )
      ],
    );
  }
}
