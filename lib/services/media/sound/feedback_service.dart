import 'dart:typed_data';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';
import 'package:vibration/vibration.dart';

class FeedbackService {
  void triggerAlert() {
    Vibration.vibrate(pattern: [150, 150, 150, 150, 150, 150]);

    playAudio();
  }

  void vibrate() {
    Vibration.vibrate();
  }

  void playAudio() async {
    AudioPlayer player = AudioPlayer();
    String audioasset = "assets/audio/alert.mp3";
    ByteData bytes = await rootBundle.load(audioasset); //load sound from assets
    Uint8List soundbytes =
        bytes.buffer.asUint8List(bytes.offsetInBytes, bytes.lengthInBytes);
    int result = await player.playBytes(soundbytes);
    if (result == 1) {
      //play success
      print("Sound playing successful.");
    } else {
      print("Error while playing sound.");
    }
  }
}
