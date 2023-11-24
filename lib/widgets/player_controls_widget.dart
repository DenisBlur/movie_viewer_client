import 'package:flutter/material.dart';
import 'package:movie_viewer/model/socket/socket_provider.dart';
import 'package:movie_viewer/model/ux_provider.dart';
import 'package:movie_viewer/screens/test_screen.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';

class PlayerControls extends StatelessWidget {
  const PlayerControls({
    super.key,
    required this.sp,
  });

  final SocketProvider sp;

  @override
  Widget build(BuildContext context) {
    return Consumer<UxProvider>(
      builder: (context, up, child) {
        return MouseRegion(
          onHover: (event) {
            up.controlsBase();
          },
          child: Stack(
            children: <Widget>[
              AnimatedOpacity(
                  duration: const Duration(milliseconds: 650),
                  curve: Curves.fastEaseInToSlowEaseOut,
                  opacity: up.showControls ? 1 : 0,
                  child: Container(
                    color: Colors.black38,
                  )),
              AnimatedScale(
                duration: const Duration(milliseconds: 650),
                curve: Curves.fastEaseInToSlowEaseOut,
                scale: up.showControls ? 1 : 0,
                child: Center(
                  child: Icon(
                    sp.player.playback.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                    color: Colors.white,
                    size: 50,
                    semanticLabel: 'Play',
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  sp.player.playback.isPlaying ? sp.sendSessionAction("pause") : sp.sendSessionAction("play");
                },
              ),
              AnimatedPositioned(
                  bottom: up.showControls ? 16 : -200,
                  left: 16,
                  right: 16,
                  curve: Curves.fastEaseInToSlowEaseOut,
                  duration: const Duration(milliseconds: 650),
                  child: Row(
                    children: [
                  Slider(
                  value: player.general.volume,
                    min: 0,
                    max: 1,
                    onChanged: (value) {
                      sp.setVolume(value);
                    },
                  ),
                      StreamBuilder(
                        stream: sp.player.positionStream,
                        builder: (context, snapshot) {
                          if (snapshot.data != null) {
                            return Expanded(
                              child: Slider(
                                value: snapshot.data!.position!.inMilliseconds.toDouble(),
                                min: 0,
                                max: snapshot.data!.duration!.inMilliseconds.toDouble(),
                                onChanged: (value) {},
                                onChangeEnd: (value) {
                                  sp.sendSessionActionDuration(value.toInt());
                                },
                              ),
                            );
                          } else {
                            return const SizedBox();
                          }
                        },
                      ),
                      IconButton(
                          onPressed: () async {
                            sp.setFullscreen(!sp.fullscreen);
                          },
                          icon: Icon(sp.fullscreen ? Icons.fullscreen_exit_rounded : Icons.fullscreen_rounded))
                    ],
                  )),
            ],
          ),
        );
      },
    );
  }
}
