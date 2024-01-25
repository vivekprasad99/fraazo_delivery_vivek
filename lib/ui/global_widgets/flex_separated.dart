import 'package:flutter/material.dart';

/*
This is used where we want separator in row or column but not for last widget
This saved adding extra column or row for every child
instead we just add them by looping it

*/
class FlexSeparated extends StatelessWidget {
  final Axis direction;
  final double spacing;
  final List<Widget> children;
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;
  final MainAxisSize mainAxisSize;
  final Widget? separator;
  const FlexSeparated({
    Key? key,
    this.direction = Axis.horizontal,
    this.children = const [],
    this.spacing = 10,
    this.mainAxisAlignment = MainAxisAlignment.spaceBetween,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.separator,
    this.mainAxisSize = MainAxisSize.max,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Flex(
      direction: direction,
      mainAxisAlignment: mainAxisAlignment,
      crossAxisAlignment: crossAxisAlignment,
      mainAxisSize: mainAxisSize,
      children: _buildChildrenWithSeparator(),
    );
  }

  List<Widget> _buildChildrenWithSeparator() {
    Widget separatorWidget;
    if (separator != null) {
      separatorWidget = separator ?? const SizedBox();
    } else if (direction == Axis.horizontal) {
      separatorWidget = SizedBox(width: spacing);
    } else {
      separatorWidget = SizedBox(height: spacing);
    }

    final List<Widget> childrenWithSeparatorList = [];
    final actualChildrenLength = children.length - 1;
    for (int i = 0; i <= actualChildrenLength; i++) {
      childrenWithSeparatorList.add(children[i]);
      if (i != actualChildrenLength) {
        childrenWithSeparatorList.add(separatorWidget);
      }
    }
    return childrenWithSeparatorList;
  }
}
