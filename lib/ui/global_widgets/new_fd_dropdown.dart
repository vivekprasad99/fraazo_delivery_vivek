import 'package:flutter/material.dart';
import 'package:fraazo_delivery/utils/utils.dart';

import '../../values/custom_colors.dart';
import '../utils/textview.dart';
import '../utils/widgets_and_attributes.dart';

class NewFDDropDown extends StatefulWidget {
  final String? labelText;

  final Function(String)? onSelect;
  final bool shouldHideText;
  final double? height;
  final double? width;
  final double fontSize;
  final FontWeight fontWeight;
  final bool showDropDownIcon;
  String? defaultValue;
  final List<String>? dropDownValue;

  NewFDDropDown(
      {Key? key,
      this.labelText,
      this.onSelect,
      this.shouldHideText = false,
      this.height = 45,
      this.width,
      this.fontWeight = FontWeight.w500,
      this.fontSize = tx_16,
      this.showDropDownIcon = false,
      this.defaultValue = '',
      this.dropDownValue})
      : super(key: key);

  @override
  _NewFDDropDownState createState() => _NewFDDropDownState();
}

class _NewFDDropDownState extends State<NewFDDropDown> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextView(
            title: widget.labelText!,
            textStyle: commonTextStyle(
                fontSize: 12,
                color: lightBlackTxtColor,
                fontWeight: FontWeight.w400)),
        const SizedBox(
          height: 5,
        ),
        SizedBox(
            height: widget.height,
            width: widget.width,
            child: Container(
              decoration: BoxDecoration(
                  border: Border.all(color: borderLineColor),
                  borderRadius: BorderRadius.circular(px_4)),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: DropdownButton(
                  value: widget.defaultValue,
                  items: widget.dropDownValue!.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: TextView(
                        title: value,
                        textStyle: commonTextStyle(
                            fontSize: widget.fontSize, color: Colors.white),
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    widget.onSelect!(value.toString());
                    widget.defaultValue = value.toString();
                    setState(() {});
                  },
                  isExpanded: true,
                  //make true to take width of parent widget
                  underline: Container(),
                  //empty line
                  style: commonTextStyle(
                      fontSize: widget.fontSize, color: Colors.white),
                  dropdownColor: bgColor,
                  iconEnabledColor: Colors.white,
                  //Icon color
                  icon: const Icon(
                    Icons.arrow_drop_down_rounded,
                    color: inActiveTextColor,
                  ),
                ),
              ),
            )),
      ],
    );
  }
}
