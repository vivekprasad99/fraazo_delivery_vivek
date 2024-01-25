import 'package:flutter/material.dart';
import 'package:fraazo_delivery/utils/utils.dart';
import 'package:fraazo_delivery/values/custom_colors.dart';

class AssetTitle extends StatelessWidget {
  const AssetTitle({Key? key, this.isAssetList = false}) : super(key: key);
  final bool isAssetList;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 7.0),
      padding: const EdgeInsets.symmetric(
        horizontal: 30,
        vertical: 9,
      ),
      decoration: BoxDecoration(
        color: dividerSetInCash.withOpacity(0.04),
        borderRadius: const BorderRadius.all(Radius.circular(4.0)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Asset',
            style: commonTextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
            textAlign: isAssetList ? TextAlign.center : TextAlign.left,
          ),
          Text(
            'Quantity',
            style: commonTextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
            textAlign: isAssetList ? TextAlign.center : TextAlign.left,
          ),
          if (isAssetList)
            Text(
              'Date',
              style: commonTextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
              textAlign: TextAlign.center,
            ),
        ],
      ),
    );
  }
}
