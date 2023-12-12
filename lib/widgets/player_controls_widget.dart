import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:movie_viewer/model/socket/socket_provider.dart';
import 'package:movie_viewer/model/ux_provider.dart';
import 'package:movie_viewer/widgets/user_menu.dart';
import 'package:provider/provider.dart';

// ignore: depend_on_referenced_packages
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart' as avp;

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
              GestureDetector(
                onTap: () {
                  if (sp.player.playback.isPlaying) {
                    sp.sendSessionAction("pause");
                  } else {
                    sp.sendSessionAction("play");
                  }
                },
              ),
              AnimatedScale(
                duration: const Duration(milliseconds: 250),
                curve: Curves.fastEaseInToSlowEaseOut,
                scale: up.showControls ? 1 : 0,
                child: Center(
                    child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      onPressed: () {
                        sp.sendSessionActionDuration(sp.currentMSeconds - 5000);
                      },
                      icon: const Icon(
                        Icons.replay_5_rounded,
                        color: Colors.white,
                        size: 42,
                        semanticLabel: 'Play',
                      ),
                    ),
                    const SizedBox(
                      width: 16,
                    ),
                    IconButton(
                      onPressed: () {
                        if (sp.player.playback.isPlaying) {
                          sp.sendSessionAction("pause");
                        } else {
                          sp.sendSessionAction("play");
                        }
                      },
                      icon: Icon(
                        sp.player.playback.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                        color: Colors.white,
                        size: 64,
                        semanticLabel: 'Play',
                      ),
                    ),
                    const SizedBox(
                      width: 16,
                    ),
                    IconButton(
                      onPressed: () {
                        sp.sendSessionActionDuration(sp.currentMSeconds + 5000);
                      },
                      icon: const Icon(
                        Icons.forward_5_rounded,
                        color: Colors.white,
                        size: 42,
                        semanticLabel: 'Play',
                      ),
                    )
                  ],
                )),
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
                          if (sp.checkLeader()) {
                            sp.sendSessionAction("goToSessionSetting");
                          } else {
                            sp.disconnectFromSession();
                          }
                        },
                      ),
                      if (sp.currentSession != null && sp.currentSession!.currentMovie != null)
                        Expanded(
                            child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              sp.currentSession!.currentMovie!.title!,
                              style: const TextStyle(fontSize: 34, fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,
                            ),
                            DropdownButton(
                              value: sp.resolutionVariants!.indexOf(sp.currentVariant!),
                              items: [
                                for (int i = 0; i < sp.resolutionVariants!.length; i++)
                                  DropdownMenuItem(
                                    value: i,
                                    child: Text("Качество: ${sp.resolutionVariants![i].format.width.toString() == "null" ? "Аудио" : sp.resolutionVariants![i].format.width.toString()}" ),
                                  )
                              ],
                              onChanged: (value) {
                                sp.changeResolution(value!);
                              },
                            ),
                          ],
                        )),
                      FilledButton(
                        focusNode: null,
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
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      padding: const EdgeInsets.only(left: 24, right: 8, bottom: 8, top: 8),
                      decoration:
                          BoxDecoration(color: Theme.of(context).colorScheme.background.withOpacity(.8), borderRadius: BorderRadius.circular(16)),
                      child: Row(
                        children: [
                          StreamBuilder(
                            stream: sp.player.positionStream,
                            builder: (context, snapshot) {
                              if (snapshot.data != null) {
                                return Expanded(
                                  child: avp.ProgressBar(
                                    progress: snapshot.data!.position!,
                                    total: snapshot.data!.duration!,
                                    timeLabelLocation: avp.TimeLabelLocation.sides,
                                    onDragStart: (details) {
                                      context.read<UxProvider>().seek = true;
                                    },
                                    onDragEnd: () {
                                      context.read<UxProvider>().seek = false;
                                    },
                                    onDragUpdate: (details) {
                                      sp.player.seek(details.timeStamp);
                                    },
                                    onSeek: (value) {
                                      sp.sendSessionActionDuration(value.inMilliseconds);
                                    },
                                  ),
                                );
                              } else {
                                return Expanded(
                                  child: Slider(
                                    focusNode: null,
                                    value: 0,
                                    min: 0,
                                    max: 1,
                                    onChanged: (value) {},
                                  ),
                                );
                              }
                            },
                          ),
                          const SizedBox(
                            width: 16,
                          ),
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
                                      focusNode: null,
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
                              focusNode: null,
                              onPressed: () async {
                                sp.setFullscreen(!sp.fullscreen);
                              },
                              icon: Icon(sp.fullscreen ? Icons.fullscreen_exit_rounded : Icons.fullscreen_rounded))
                        ],
                      ),
                    ),
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
