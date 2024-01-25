import 'package:flutter/material.dart';
import 'package:fraazo_delivery/values/custom_colors.dart';

class ShadowCard extends StatelessWidget {
  final Widget? child;
  const ShadowCard({this.child});
  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
          color: containerBgColor,
          borderRadius: BorderRadius.circular(10),
          boxShadow: const [
            BoxShadow(
              blurRadius: 0,
              color: Color(0xff2B2A2A),
            ),
          ]),
      child: child,
    );
  }
}
