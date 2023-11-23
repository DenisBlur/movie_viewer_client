import 'package:flutter/material.dart';
import 'package:movie_viewer/model/socket/socket_provider.dart';

class PlayerControls extends StatelessWidget {
  const PlayerControls({
    super.key,
    required this.sp,
  });

  final SocketProvider sp;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 50),
          reverseDuration: const Duration(milliseconds: 200),
          child: sp.videoController!.value.isPlaying
              ? const SizedBox.shrink()
              : Container(
                  color: Colors.black26,
                  child: const Center(
                    child: Icon(
                      Icons.play_arrow,
                      color: Colors.white,
                      size: 100.0,
                      semanticLabel: 'Play',
                    ),
                  ),
                ),
        ),
        GestureDetector(
          onTap: () {
            sp.videoController!.value.isPlaying ? sp.sendSessionAction("pause") : sp.sendSessionAction("play");
          },
        ),
        Positioned(
          bottom: 16,
          left: 16,
          right: 16,
          child: Slider(
            value: sp.videoController!.value.position.inMilliseconds.toDouble(),
            min: 0,
            max: sp.videoController!.value.duration.inMilliseconds.toDouble(),
            onChanged: (value) {
            },
            onChangeEnd: (value) {
              sp.sendSessionActionDuration(value.toInt());
            },
          ),
        )
      ],
    );
  }
}
