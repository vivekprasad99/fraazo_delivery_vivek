import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class FDTextField extends StatefulWidget {
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
  final String imagePath;
  final TextStyle? textStyle;
  final EdgeInsets? contentPadding;

  const FDTextField({
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
    this.imagePath = '',
    this.inputFormatters,
    this.textStyle,
    this.contentPadding,
  }) : super(key: key);

  @override
  _FDTextFieldState createState() => _FDTextFieldState();
}

class _FDTextFieldState extends State<FDTextField> {
  bool _isHideTextVisible = false;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      width: widget.width,
      child: TextField(
        controller: widget.controller,
        focusNode: widget.focusNode,
        autofocus: widget.isAutoFocus,
        style: widget.textStyle ??
            TextStyle(fontSize: 15, letterSpacing: widget.spacing),
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
            FilteringTextInputFormatter.digitsOnly,
        ],
        maxLength: widget.maxLength,
        maxLines: widget.maxLines,
        scrollPadding: const EdgeInsets.only(bottom: 180),
        decoration: InputDecoration(
          border: const OutlineInputBorder(),
          counterText: "",
          alignLabelWithHint: true,
          labelStyle: const TextStyle(fontWeight: FontWeight.w300),
          labelText: widget.labelText,
          contentPadding: widget.contentPadding ??
              EdgeInsets.symmetric(
                horizontal: 12,
                vertical: widget.maxLines <= 1 ? 10 : 4,
              ),
          suffixIcon:
              widget.imagePath.isNotEmpty && widget.imagePath.startsWith('http')
                  ? Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: Image.network(
                        widget.imagePath,
                        width: 70,
                      ),
                    )
                  : widget.shouldHideText
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
                          ),
                        )
                      : null,
        ),
      ),
    );
  }
}
