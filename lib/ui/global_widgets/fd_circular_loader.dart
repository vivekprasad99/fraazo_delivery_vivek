import 'package:flutter/material.dart';

class FDCircularLoader extends StatelessWidget {
  final double size;
  final Color progressColor;
  const FDCircularLoader({
    Key? key,
    this.size = 100,
    this.progressColor = Colors.white,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        height: size,
        width: double.infinity,
        child: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation(progressColor),
          ),
        ),
      ),
    );
  }
}
