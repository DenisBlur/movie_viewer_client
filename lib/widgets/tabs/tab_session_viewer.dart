import 'package:flutter/material.dart';
import 'package:movie_viewer/model/socket/socket_provider.dart';
import 'package:movie_viewer/widgets/items/session_item.dart';

class TabSessionViewer extends StatelessWidget {
  const TabSessionViewer({super.key, required this.socketProvider});

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
          if (socketProvider.sessions != null && socketProvider.sessions!.isNotEmpty)
            SliverList.builder(
              itemBuilder: (context, index) {
                return SessionItem(session: socketProvider.sessions![index]);
              },
              itemCount: socketProvider.sessions!.length,
            )
        ],
      ),
    );
  }
}
