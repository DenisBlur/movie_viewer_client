import 'package:flutter/material.dart';
import 'package:movie_viewer/model/socket/socket_provider.dart';
import 'package:movie_viewer/screens/test_screen.dart';
import 'package:movie_viewer/widgets/admin_menu.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

import '../player.dart';
import '../user_menu.dart';

class TabMovieViewer extends StatelessWidget {
  const TabMovieViewer({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SocketProvider>(
      builder: (context, sp, child) {
        return Scaffold(
          body: Stack(
            children: [
              if (sp.videoController != null) VideoPlayer(sp.videoController!),
              if (sp.videoController != null)
                ControlsOverlay(
                  controller: sp.videoController!,
                ),
              if (sp.videoController != null)
                VideoProgressIndicator(sp.videoController!,
                    allowScrubbing: true),
              UserMenu(pr: sp),
              if (sp.checkLeader()) AdminPanel(pr: sp),
            ],
          ),
        );
      },
    );
  }
}
