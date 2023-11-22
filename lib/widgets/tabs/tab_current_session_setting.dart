import 'package:flutter/material.dart';
import 'package:movie_viewer/model/socket/socket_provider.dart';
import 'package:movie_viewer/widgets/items/movie_item.dart';

import '../dialogs.dart';
import '../items/user_item.dart';

class TabCurrentSessionSetting extends StatelessWidget {
  const TabCurrentSessionSetting({super.key, required this.socketProvider});

  final SocketProvider socketProvider;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16),
      child: CustomScrollView(
        slivers: [
          const SliverToBoxAdapter(
            child: SizedBox(height: 16),
          ),
          SliverToBoxAdapter(
            child: Text(
              socketProvider.currentSession!.sessionName!,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
            ),
          ),
          if (socketProvider.checkLeader())
            const SliverToBoxAdapter(
              child: SizedBox(height: 16),
            ),
          if (socketProvider.checkLeader())
            SliverToBoxAdapter(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: FilledButton(
                      onPressed: () {
                        createFilmDialog(context);
                      },
                      child: const Text("Добавить фильм"),
                    ),
                  ),
                  const SizedBox(
                    width: 16,
                  ),
                  Expanded(
                    child: FilledButton(
                      onPressed: () {
                        findMovie(context);
                      },
                      child: const Text("Выбрать фильм"),
                    ),
                  ),
                  const SizedBox(
                    width: 16,
                  ),
                  Expanded(
                    child: FilledButton(
                      onPressed: () {
                        youtubeVideoDialog(context);
                      },
                      child: const Text("YouTube"),
                    ),
                  ),
                ],
              ),
            ),
          if (socketProvider.checkLeader())
            const SliverToBoxAdapter(
              child: SizedBox(height: 16),
            ),
          if (socketProvider.currentSession!.currentMovie != null)
            SliverToBoxAdapter(
                child: MovieItem(
              movie: socketProvider.currentSession!.currentMovie!,
              callback: () {},
            )),
          SliverToBoxAdapter(
            child: Text(
              "Пользователи ${socketProvider.currentSession!.connectedUsers!.length.toString()}/${socketProvider.currentSession!.maxUsers!.toString()}",
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 18),
            ),
          ),
          const SliverToBoxAdapter(
            child: SizedBox(height: 8),
          ),
          SliverList.builder(
            itemBuilder: (context, index) {
              return UserItem(
                user: socketProvider.currentSession!.connectedUsers![index],
              );
            },
            itemCount: socketProvider.currentSession!.connectedUsers!.length,
          )
        ],
      ),
    );
  }
}
