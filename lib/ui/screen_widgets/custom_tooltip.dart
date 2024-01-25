import 'dart:async';

import 'package:flutter/material.dart';

class CustomToolTip extends StatelessWidget {
  final Widget child;
  final String message;

  const CustomToolTip({required this.message, required this.child});

  @override
  Widget build(BuildContext context) {
    final key = GlobalKey<State<Tooltip>>();
    return Tooltip(
      key: key,
      message: message,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => _onTap(key),
        child: child,
      ),
    );
  }

  void _onTap(GlobalKey key) {
    final dynamic tooltip = key.currentState;
    tooltip?.ensureTooltipVisible();
    Timer(const Duration(milliseconds: 1500), () => tooltip?.deactivate());
  }
}
