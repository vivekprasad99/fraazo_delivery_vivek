import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fraazo_delivery/models/user/training_list_model.dart';
import 'package:fraazo_delivery/ui/utils/widgets_and_attributes.dart';
import 'package:video_player/video_player.dart';

class VideoItemWidget extends StatefulWidget {
  final Training training;
  const VideoItemWidget({Key? key, required this.training}) : super(key: key);

  @override
  _VideoItemWidgetState createState() => _VideoItemWidgetState();
}

class _VideoItemWidgetState extends State<VideoItemWidget> {
  VideoPlayerController? _controller;
  late Future<void> _video;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _controller = VideoPlayerController.network(widget.training.imageUrl!)
      ..addListener(() => setState(() {}))
      ..setLooping(true);
    _video = _controller!.initialize();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        FutureBuilder(
          future: _video,
          builder: (_, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return SizedBox(
                height: px_150,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(px_8),
                  child: VideoPlayer(_controller!),
                ),
              );
            } else {
              return Container();
            }
          },
        ),
        Positioned(
          right: 170,
          top: 30,
          child: IconButton(
            icon: Icon(
              _controller!.value.isPlaying ? Icons.pause : Icons.play_circle,
              color: Colors.white,
              size: 80,
            ),
            onPressed: () {
              _checkVideoPlay();
            },
          ),
        )
      ],
    );
  }

  void _checkVideoPlay() {
    if (_controller!.value.isPlaying) {
      _controller!.pause();
    } else {
      _controller!.play();
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _controller!.dispose();
  }
}
