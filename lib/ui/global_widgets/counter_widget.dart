import 'package:flutter/material.dart';

class Countdown extends AnimatedWidget {
  Countdown({Key? key, required this.animation, this.msg = ''})
      : super(key: key, listenable: animation);
  Animation<int> animation;
  String? msg;

  @override
  build(BuildContext context) {
    Duration clockTimer = Duration(seconds: animation.value);

    String timerText =
        '${clockTimer.inMinutes.remainder(60).toString()}:${(clockTimer.inSeconds.remainder(60) % 60).toString().padLeft(2, '0')}';

    return Text(
      "$msg $timerText",
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    );
  }
}
