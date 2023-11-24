import 'package:dart_vlc/dart_vlc.dart';
import 'package:flutter/material.dart';
import 'package:movie_viewer/model/socket/socket_provider.dart';
import 'package:movie_viewer/widgets/items/user_item.dart';
import 'package:movie_viewer/widgets/player_controls_widget.dart';
import 'package:provider/provider.dart';

class TabMovieViewer extends StatelessWidget {
  const TabMovieViewer({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SocketProvider>(
      builder: (context, sp, child) {
        return Scaffold(
            body: SingleChildScrollView(
          child: Column(children: [
            Container(
              color: Colors.black,
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: <Widget>[
                  Video(width: MediaQuery.of(context).size.width, height: MediaQuery.of(context).size.height, player: sp.player, showControls: true, fit: BoxFit.fitWidth),
                  // PlayerControls(
                  //   sp: sp,
                  // ),
                ],
              ),
            ),
            Container(
              width: MediaQuery.of(context).size.width,
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondaryContainer.withOpacity(.2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      sp.currentSession!.currentMovie!.title!,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const Text(
                        "Пользователи",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
                      ),
                      for (var user in sp.currentSession!.connectedUsers!) UserItem(user: user)
                    ],
                  )
                ],
              ),
            ),
          ]),
        ));
      },
    );
  }
}
