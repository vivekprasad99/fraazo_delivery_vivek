import 'package:flutter/material.dart';

/// This [ContainerDivider] exist because
/// - [Divider] widget has so many things going on when we just want a simple line to paint.
/// - This class just has container to handle it all and suitable at some places where performance is concern
/// - Also the power of "const"

class ContainerDivider extends StatelessWidget {
  final double thickness;
  final double startIndent;
  final double endIndent;
  final Color color;
  const ContainerDivider({
    Key? key,
    this.color = const Color.fromRGBO(153, 153, 153, 0.2),
    this.thickness = 1,
    this.startIndent = 0,
    this.endIndent = 0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(left: startIndent, right: endIndent),
      height: thickness,
      color: color,
    );
  }
}
