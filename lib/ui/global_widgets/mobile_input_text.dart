import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fraazo_delivery/ui/utils/textview.dart';
import 'package:fraazo_delivery/ui/utils/widgets_and_attributes.dart';
import 'package:fraazo_delivery/utils/utils.dart';
import 'package:get/get.dart';

import '../../values/custom_colors.dart';

class MobileInputText extends GetView {
  final TextEditingController textEditingController;
  final Function onChangeValue;
  MobileInputText(
      {required this.textEditingController, required this.onChangeValue});

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Container(
      margin: const EdgeInsets.only(top: px_18),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(px_8),
          border: Border.all(color: borderLineColor)),
      child: Row(
        children: [
          TextView(
              padding: const EdgeInsets.all(px_12),
              title: '+91',
              textStyle: commonTextStyle(
                  color: Colors.white,
                  fontSize: tx_16,
                  fontWeight: FontWeight.w600)),
          Container(
            color: borderLineColor,
            width: 1,
            height: px_50,
          ),
          Expanded(
            child: TextField(
              controller: textEditingController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.all(px_12),
              ),
              cursorColor: Colors.white,
              cursorWidth: 1,
              style: commonTextStyle(
                  color: Colors.white,
                  fontSize: tx_16,
                  fontWeight: FontWeight.w600),
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(10),
              ],
              onChanged: (value) {
                onChangeValue(value);
              },
            ),
          )
        ],
      ),
    );
  }
}
