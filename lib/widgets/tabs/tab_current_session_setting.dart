import 'package:flutter/material.dart';
import 'package:movie_viewer/model/socket/socket_provider.dart';
import 'package:movie_viewer/widgets/items/movie_item.dart';

import '../big_button.dart';
import '../dialogs.dart';
import '../items/user_item.dart';

class TabCurrentSessionSetting extends StatelessWidget {
  const TabCurrentSessionSetting({super.key, required this.socketProvider});

  final SocketProvider socketProvider;

  @override
  Widget build(BuildContext context) {
    if (socketProvider.currentSession != null) {
      return Padding(
        padding: const EdgeInsets.only(left: 16, right: 16),
        child: CustomScrollView(
          slivers: [
            const SliverToBoxAdapter(
              child: SizedBox(height: 16),
            ),
            SliverToBoxAdapter(
                child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                IconButton(
                    onPressed: () {
                      socketProvider.disconnectFromSession();
                    },
                    icon: const Icon(Icons.navigate_before_rounded)),
                Text(
                  socketProvider.currentSession!.sessionName!,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                const Expanded(child: SizedBox())
              ],
            )),
            const SliverToBoxAdapter(
              child: SizedBox(height: 16),
            ),
            if (socketProvider.checkLeader())
              SliverToBoxAdapter(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    if (socketProvider.currentSession!.currentMovie != null)
                      MovieItem(
                        movie: socketProvider.currentSession!.currentMovie!,
                        callback: () {
                          print("Hello!");
                          socketProvider.sendSessionAction("goToPlayer");
                        },
                      ),
                    if (socketProvider.currentSession!.currentMovie != null)
                      const SizedBox(
                        width: 16,
                      ),
                    BigButton(
                      enable: socketProvider.checkLeader(),
                      onTap: () {
                          showMyDialog(context);
                      },
                      w: 250,
                      h: 350,
                      iconSize: 24,
                      title: 'Добавить фильм',
                      icon: Icons.add_rounded,
                    ),
                    const SizedBox(
                      width: 16,
                    ),
                    BigButton(
                      enable: socketProvider.checkLeader(),
                      onTap: () {
                        findMovie(context);
                      },
                      w: 250,
                      h: 350,
                      iconSize: 24,
                      title: 'Найти фильм',
                      icon: Icons.find_in_page_rounded,
                    ),
                    const SizedBox(
                      width: 16,
                    ),
                    BigButton(
                      enable: socketProvider.checkLeader(),
                      onTap: () {
                        youtubeVideoDialog(context);
                      },
                      w: 250,
                      h: 350,
                      iconSize: 24,
                      title: 'YouTube',
                      icon: Icons.video_camera_back_rounded,
                    ),
                  ],
                ),
              ),
            if (socketProvider.checkLeader())
              const SliverToBoxAdapter(
                child: SizedBox(height: 16),
              ),
            SliverToBoxAdapter(
              child: Text(
                "Пользователи ${socketProvider.currentSession!.connectedUsers!.length.toString()}/${socketProvider.currentSession!.maxUsers!.toString()}",
                style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 18),
              ),
            ),
            const SliverToBoxAdapter(
              child: SizedBox(height: 8),
            ),
            SliverGrid.builder(
              itemBuilder: (context, index) {
                return UserItem(
                  user: socketProvider.currentSession!.connectedUsers![index],
                );
              },
              itemCount: socketProvider.currentSession!.connectedUsers!.length,
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 250, mainAxisExtent: 80, mainAxisSpacing: 16, crossAxisSpacing: 16),
            )
          ],
        ),
      );
    } else {
      return const Text("Ничего нет :(");
    }
  }
}
