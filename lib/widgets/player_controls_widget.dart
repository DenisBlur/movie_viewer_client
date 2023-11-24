import 'package:flutter/material.dart';
import 'package:movie_viewer/model/socket/socket_provider.dart';
import 'package:movie_viewer/model/ux_provider.dart';
import 'package:movie_viewer/screens/test_screen.dart';
import 'package:movie_viewer/widgets/user_menu.dart';
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
                    decoration: const BoxDecoration(
                        gradient: LinearGradient(colors: [
                      Color(0xCC000000),
                      Color(0x00000000),
                      Color(0x00000000),
                      Color(0x00000000),
                      Color(0xCC000000),
                    ], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
                  )),
              AnimatedScale(
                duration: const Duration(milliseconds: 250),
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
                  if(sp.player.playback.isPlaying) {
                    sp.sendSessionAction("pause");
                  } else {
                    sp.sendSessionAction("play");
                  }
                },
              ),
              AnimatedPositioned(
                  top: up.showControls ? 16 : -200,
                  left: 16,
                  right: 16,
                  curve: Curves.fastEaseInToSlowEaseOut,
                  duration: const Duration(milliseconds: 650),
                  child: Row(
                    children: [
                      FilledButton(
                        child: const Icon(Icons.navigate_before_rounded),
                        onPressed: () {
                          sp.disconnectFromSession();
                        },
                      ),
                      if(sp.currentSession != null)
                      Expanded(
                        child: Text(
                          sp.currentSession!.currentMovie!.title!,
                          style: const TextStyle(fontSize: 34, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      FilledButton(
                        child: const Icon(Icons.supervised_user_circle_rounded),
                        onPressed: () {
                          sp.uxProvider.showUserPanel = !sp.uxProvider.showUserPanel;
                        },
                      ),
                    ],
                  )),
              AnimatedPositioned(
                bottom: up.showControls ? 16 : -200,
                left: 16,
                right: 16,
                curve: Curves.fastEaseInToSlowEaseOut,
                duration: const Duration(milliseconds: 650),
                child: Container(
                  padding: const EdgeInsets.only(left: 24, right: 8, bottom: 8, top: 8),
                  decoration: BoxDecoration(color: Theme.of(context).colorScheme.background.withOpacity(.5), borderRadius: BorderRadius.circular(16)),
                  child: Row(
                    children: [
                      StreamBuilder(
                        stream: sp.player.positionStream,
                        builder: (context, snapshot) {
                          if (snapshot.data != null) {

                            return Text(sp.printDuration(snapshot.data!.position!));
                          } else {
                            return Text("00:00:00");
                          }
                        },
                      ),
                      StreamBuilder(
                        stream: sp.player.positionStream,
                        builder: (context, snapshot) {
                          if (snapshot.data != null) {
                            return Expanded(
                              child: Slider(
                                label: "Hello",
                                secondaryTrackValue: sp.player.bufferingProgress,
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
                            return Expanded(
                              child: Slider(
                                value: 0,
                                min: 0,
                                max: 1,
                                onChanged: (value) {},
                              ),
                            );
                          }
                        },
                      ),
                      StreamBuilder(
                        stream: sp.player.positionStream,
                        builder: (context, snapshot) {
                          if (snapshot.data != null) {

                            return Text(sp.printDuration(snapshot.data!.duration!));
                          } else {
                            return Text("00:00:00");
                          }
                        },
                      ),
                      SizedBox(width: 16,),
                      MouseRegion(
                        onEnter: (event) {
                          sp.uxProvider.showVolume = true;
                        },
                        onExit: (event) {
                          sp.uxProvider.showVolume = false;
                        },
                        child: Row(
                          children: [
                            const Icon(Icons.volume_up_rounded),
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 350),
                              curve: Curves.fastEaseInToSlowEaseOut,
                              width: sp.uxProvider.showVolume ? 150 : 0,
                              child: ClipRRect(
                                child: Slider(
                                  value: sp.player.general.volume,
                                  min: 0,
                                  max: 1,
                                  onChanged: (value) {
                                    sp.setVolume(value);
                                  },
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                      IconButton(
                          onPressed: () async {
                            sp.setFullscreen(!sp.fullscreen);
                          },
                          icon: Icon(sp.fullscreen ? Icons.fullscreen_exit_rounded : Icons.fullscreen_rounded))
                    ],
                  ),
                ),
              ),
              UserMenu(sp: sp),
            ],
          ),
        );
      },
    );
  }
}
