import 'package:flutter/material.dart';
import 'package:movie_viewer/model/socket/socket_provider.dart';
import 'package:movie_viewer/screens/test_screen.dart';
import 'package:movie_viewer/widgets/admin_menu.dart';
import 'package:movie_viewer/widgets/player_controls_widget.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

class TabMovieViewer extends StatelessWidget {
  const TabMovieViewer({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SocketProvider>(
      builder: (context, sp, child) {
        return Scaffold(
          body: Stack(
            children: [
              if (sp.videoController != null)
                Center(
                  child: AspectRatio(
                    aspectRatio: sp.videoController!.value.aspectRatio,
                    child: Stack(
                      alignment: Alignment.bottomCenter,
                      children: <Widget>[
                        VideoPlayer(sp.videoController!),
                        PlayerControls(
                          sp: sp,
                        ),
                      ],
                    ),
                  ),
                ),
              if (sp.checkLeader()) AdminPanel(pr: sp),
            ],
          ),
        );
      },
    );
  }
}
