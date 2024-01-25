import 'package:flutter/material.dart';
import 'package:fraazo_delivery/utils/utils.dart';

class NoDataWidget extends StatelessWidget {
  final String noDataText;
  final EdgeInsets padding;
  final Color textColor;
  const NoDataWidget(
      {this.noDataText = "No data found!",
      this.padding = const EdgeInsets.all(20),
      this.textColor = Colors.white});
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: padding,
        child: Text(
          noDataText,
          style: commonTextStyle(color: textColor, fontSize: 18),
        ),
      ),
    );
  }
}
