import 'package:flutter/material.dart';

/// As [Container] is expensive than almost any other widget
/// This comes handy when we really need good performance
/// We can just have [SizedBox] with [ColoredBox]
/// This helps to reduce size of element and widget tree
/// - Also the power of "const"

class ColoredSizedBox extends StatelessWidget {
  final double? width;
  final double? height;
  final Color color;
  final Widget? child;
  const ColoredSizedBox({
    Key? key,
    required this.color,
    this.width,
    this.height,
    this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: color,
      child: SizedBox(width: width, height: height, child: child),
    );
  }
}
