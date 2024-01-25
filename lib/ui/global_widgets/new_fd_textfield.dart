import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fraazo_delivery/utils/utils.dart';

import '../../values/custom_colors.dart';
import '../utils/textview.dart';
import '../utils/widgets_and_attributes.dart';

class NewFDTextField extends StatefulWidget {
  final String? labelText;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final bool isNumber;
  final int? maxLength;
  final TextInputType? keyboardType;
  final TextCapitalization textCapitalization;
  final int maxLines;
  final bool isAutoFocus;
  final bool isReadOnly;
  final VoidCallback? onTap;
  final bool shouldHideText;
  final double? height;
  final double? width;
  final double? spacing;
  final List<TextInputFormatter>? inputFormatters;
  final double fontSize;
  final FontWeight fontWeight;
  final bool showDropDownIcon;

  const NewFDTextField({
    Key? key,
    this.labelText,
    this.controller,
    this.focusNode,
    this.isNumber = false,
    this.maxLength,
    this.keyboardType,
    this.maxLines = 1,
    this.textCapitalization = TextCapitalization.none,
    this.isAutoFocus = false,
    this.isReadOnly = false,
    this.onTap,
    this.shouldHideText = false,
    this.height = 45,
    this.width,
    this.spacing,
    this.fontWeight = FontWeight.w500,
    this.fontSize = tx_16,
    this.inputFormatters,
    this.showDropDownIcon = false,
  }) : super(key: key);

  @override
  _NewFDTextFieldState createState() => _NewFDTextFieldState();
}

class _NewFDTextFieldState extends State<NewFDTextField> {
  bool _isHideTextVisible = false;

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
          child: TextField(
            controller: widget.controller,
            focusNode: widget.focusNode,
            autofocus: widget.isAutoFocus,
            cursorColor: Colors.white,
            cursorWidth: 1,
            style:
                commonTextStyle(fontSize: widget.fontSize, color: Colors.white),
            keyboardType:
                widget.isNumber ? TextInputType.number : widget.keyboardType,
            textCapitalization: widget.textCapitalization,
            readOnly: widget.isReadOnly,
            onTap: widget.onTap,
            obscureText: !_isHideTextVisible && widget.shouldHideText,
            inputFormatters: [
              if (widget.inputFormatters != null)
                ...?widget.inputFormatters
              else if (widget.isNumber)
                FilteringTextInputFormatter.digitsOnly
            ],
            maxLength: widget.maxLength,
            maxLines: widget.maxLines,
            scrollPadding: const EdgeInsets.only(bottom: 180),
            decoration: InputDecoration(
              focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(
                color: borderLineColor,
              )),
              enabledBorder: const OutlineInputBorder(
                  borderSide: BorderSide(
                color: borderLineColor,
              )),
              border: const OutlineInputBorder(
                  borderSide: BorderSide(
                color: borderLineColor,
              )),
              counterText: "",
              alignLabelWithHint: true,
              // hintStyle: commonTextStyle(
              //     fontSize: widget.fontSize, color: inActiveTextColor),
              // hintText: widget.labelText,
              contentPadding: EdgeInsets.symmetric(
                  horizontal: 12, vertical: widget.maxLines <= 1 ? 10 : 4),
              suffixIcon: widget.shouldHideText
                  ? IconButton(
                      onPressed: () {
                        setState(() {
                          _isHideTextVisible = !_isHideTextVisible;
                        });
                      },
                      icon: Icon(
                        _isHideTextVisible
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: inActiveTextColor,
                      ))
                  : widget.showDropDownIcon
                      ? const Icon(
                          Icons.arrow_drop_down_rounded,
                          color: inActiveTextColor,
                        )
                      : null,
            ),
          ),
        ),
      ],
    );
  }
}
