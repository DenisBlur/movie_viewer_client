import 'package:flutter/material.dart';
import 'package:movie_viewer/data/update.dart';
import 'package:movie_viewer/model/socket/socket_provider.dart';
import 'package:movie_viewer/widgets/dialogs.dart';
import 'package:movie_viewer/widgets/items/update_item.dart';

class TabMain extends StatelessWidget {
  const TabMain({super.key, required this.socketProvider});

  final SocketProvider socketProvider;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
            child: Stack(
          children: [
            const Positioned(
              left: 0,
              right: 0,
              top: 86,
              child: Text(
                "Movie Viewer",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 36),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  BigButton(
                    onTap: () {
                      createSessionDialog(context);
                    },
                    title: 'Создать сессию',
                    icon: Icons.add_rounded,
                  ),
                  const SizedBox(
                    width: 32,
                  ),
                  BigButton(
                    onTap: () {
                      socketProvider.goToSessionViewer();
                    },
                    title: 'Подключиться',
                    icon: Icons.find_replace_rounded,
                  ),
                ],
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 16,
              child: Text(
                "список обновлений",
                style: TextStyle(fontSize: 18, color: Theme.of(context).textTheme.titleLarge!.color!.withOpacity(.6)),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        )),
        SliverList.builder(
          itemBuilder: (context, index) {
            return UpdateItem(update: updates[index]);
          },
          itemCount: updates.length,
        ),
      ],
    );
  }
}

class BigButton extends StatelessWidget {
  const BigButton({super.key, required this.onTap, required this.title, required this.icon});

  final VoidCallback onTap;
  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        width: 250,
        height: 250,
        decoration: BoxDecoration(color: Theme.of(context).colorScheme.primaryContainer.withOpacity(.1), borderRadius: BorderRadius.circular(16)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 36,
            ),
            Text(title)
          ],
        ),
      ),
    );
  }
}
