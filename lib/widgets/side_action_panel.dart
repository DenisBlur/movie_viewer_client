import 'package:flutter/material.dart';
import 'package:movie_viewer/model/socket/socket_provider.dart';
import 'package:provider/provider.dart';

import '../model/ux_provider.dart';
import 'dialogs.dart';

class SideActionPanel extends StatelessWidget {
  const SideActionPanel({super.key, required this.socketProvider});

  final SocketProvider socketProvider;

  @override
  Widget build(BuildContext context) {
    return Consumer<UxProvider>(
      builder: (context, ux, child) {
        return Container(
          padding: const EdgeInsets.all(16),
          width: 250,
          decoration: BoxDecoration(
              color: Theme.of(context)
                  .colorScheme
                  .secondaryContainer
                  .withOpacity(.1)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (socketProvider.currentUser != null && socketProvider.currentSession == null)
                TextButton(
                  onPressed: () async {
                    createSessionDialog(context);
                  },
                  child: const Text("Создать сессию"),
                ),
              if (socketProvider.uxProvider.showButtonChangeFilm &&
                  socketProvider.currentSession != null)
                FilledButton(
                  onPressed: () async {
                    ux.animateWelcomePage(1);
                  },
                  child: const Text("Сменить фильм"),
                ),
              if (!socketProvider.uxProvider.showButtonChangeFilm &&
                  socketProvider.currentSession != null &&
                  socketProvider.currentSession!.currentMovie != null)
                FilledButton(
                  onPressed: () async {
                    ux.animateWelcomePage(2);
                  },
                  child: const Text("Вернуться"),
                ),
              if (socketProvider.currentSession != null)
                TextButton(
                  onPressed: () async {
                    socketProvider.disconnectFromSession();
                  },
                  child: const Text("Выйти из сессии"),
                ),
              const Expanded(child: SizedBox()),
              if (socketProvider.currentUser != null)
                Row(
                  children: [
                    IconButton(
                        onPressed: () {
                          changeNameDialog(context);
                        },
                        icon: const Icon(Icons.settings_rounded)),
                    const SizedBox(
                      width: 16,
                    ),
                    Text(socketProvider.currentUser!.username!),
                  ],
                )
            ],
          ),
        );
      },
    );
  }
}
