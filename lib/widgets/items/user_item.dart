import 'package:flutter/material.dart';
import 'package:movie_viewer/model/socket/socket_provider.dart';
import 'package:provider/provider.dart';

import '../../data/common.dart';

class UserItem extends StatelessWidget {
  const UserItem({super.key, required this.user});

  final User user;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(color: Theme.of(context).colorScheme.primaryContainer, borderRadius: BorderRadius.circular(16)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            user.username!,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          Text("Время: ${context.read<SocketProvider>().durationToHMS(Duration(milliseconds: user.currentTime!))}",
              style: Theme.of(context).textTheme.labelSmall),
        ],
      ),
    );
  }
}
