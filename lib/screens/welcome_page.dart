import 'package:flutter/material.dart';
import 'package:movie_viewer/model/sites/youtube_provider.dart';
import 'package:movie_viewer/model/ux_provider.dart';
import 'package:movie_viewer/screens/movie_page.dart';
import 'package:movie_viewer/widgets/user_item.dart';
import 'package:provider/provider.dart';

import '../model/socket_provider.dart';
import '../widgets/dialogs.dart';
import '../widgets/session_item.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SocketProvider>(
      builder: (context, sp, child) {
        return Scaffold(
          body: Row(
            children: [
              Consumer<UxProvider>(
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
                        if (sp.currentUser != null && sp.currentSession == null)
                          TextButton(
                            onPressed: () async {
                              createSessionDialog(context);
                            },
                            child: const Text("Создать сессию"),
                          ),
                        if (sp.uxProvider.showButtonChangeFilm &&
                            sp.currentSession != null)
                          FilledButton(
                            onPressed: () async {
                              ux.animateWelcomePage(1);
                            },
                            child: const Text("Сменить фильм"),
                          ),
                        if (!sp.uxProvider.showButtonChangeFilm &&
                            sp.currentSession != null &&
                            sp.currentSession!.currentMovie != null)
                          FilledButton(
                            onPressed: () async {
                              ux.animateWelcomePage(2);
                            },
                            child: const Text("Вернуться"),
                          ),
                        if (sp.currentSession != null)
                          TextButton(
                            onPressed: () async {
                              sp.disconnectFromSession();
                            },
                            child: const Text("Выйти из сессии"),
                          ),
                        const Expanded(child: SizedBox()),
                        if (sp.currentUser != null)
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
                              Text(sp.currentUser!.username!),
                            ],
                          )
                      ],
                    ),
                  );
                },
              ),
              Expanded(
                  child: PageView(
                physics: const NeverScrollableScrollPhysics(),
                controller: sp.uxProvider.pageController,
                scrollDirection: Axis.horizontal,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 16, right: 16),
                    child: CustomScrollView(
                      slivers: [
                        const SliverToBoxAdapter(
                          child: SizedBox(height: 16),
                        ),
                        const SliverToBoxAdapter(
                          child: Text(
                            "Доступные сессии",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 24),
                          ),
                        ),
                        const SliverToBoxAdapter(
                          child: SizedBox(height: 16),
                        ),
                        if (sp.sessions != null && sp.sessions!.isNotEmpty)
                          SliverList.builder(
                            itemBuilder: (context, index) {
                              return SessionItem(session: sp.sessions![index]);
                            },
                            itemCount: sp.sessions!.length,
                          )
                      ],
                    ),
                  ),
                  if (sp.currentSession != null)
                    Padding(
                      padding: const EdgeInsets.only(left: 16, right: 16),
                      child: CustomScrollView(
                        slivers: [
                          const SliverToBoxAdapter(
                            child: SizedBox(height: 16),
                          ),
                          SliverToBoxAdapter(
                            child: Text(
                              sp.currentSession!.sessionName!,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 24),
                            ),
                          ),
                          if (sp.checkLeader())
                            const SliverToBoxAdapter(
                              child: SizedBox(height: 16),
                            ),
                          if (sp.checkLeader())
                            SliverToBoxAdapter(
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: FilledButton(
                                      onPressed: () {
                                        createFilmDialog(context);
                                      },
                                      child: const Text("Добавить фильм"),
                                    ),
                                  ),
                                  Expanded(
                                    child: TextButton(
                                      onPressed: () async {
                                        findMovie(context);
                                        // sp.get4KFilm(
                                        //     "https://hds.4kfilm.click/1709-dzhon-uik-4-2023-smotret-onlajn-v-4k.html");
                                      },
                                      child: const Text("4К Фильм"),
                                    ),
                                  ),
                                  Expanded(
                                    child: FilledButton(
                                      onPressed: () {
                                        findMovie(context);
                                      },
                                      child: const Text("Выбрать фильм"),
                                    ),
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
                          if (sp.checkLeader())
                            const SliverToBoxAdapter(
                              child: SizedBox(height: 16),
                            ),
                          if (sp.currentSession!.currentMovie != null)
                            const SliverToBoxAdapter(child: Text("Hellllo!!!")),
                          SliverToBoxAdapter(
                            child: Text(
                              "Пользователи ${sp.currentSession!.connectedUsers!.length.toString()}/${sp.currentSession!.maxUsers!.toString()}",
                              style: const TextStyle(
                                  fontWeight: FontWeight.w500, fontSize: 18),
                            ),
                          ),
                          const SliverToBoxAdapter(
                            child: SizedBox(height: 8),
                          ),
                          SliverList.builder(
                            itemBuilder: (context, index) {
                              return UserItem(
                                user: sp.currentSession!.connectedUsers![index],
                              );
                            },
                            itemCount:
                                sp.currentSession!.connectedUsers!.length,
                          )
                        ],
                      ),
                    ),
                  if (sp.currentSession != null &&
                      sp.currentSession!.currentMovie != null)
                    const MoviePage()
                ],
              )),
            ],
          ),
        );
      },
    );
  }
}
