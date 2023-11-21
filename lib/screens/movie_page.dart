import 'package:flutter/material.dart';
import 'package:movie_viewer/model/socket_provider.dart';
import 'package:movie_viewer/widgets/admin_menu.dart';
import 'package:provider/provider.dart';

import '../widgets/player.dart';
import '../widgets/user_menu.dart';

class MoviePage extends StatelessWidget {
  const MoviePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SocketProvider>(
      builder: (context, sp, child) {
        return Scaffold(
          body: Stack(
            children: [
              Player(sp: sp),
              UserMenu(pr: sp),
              if(sp.checkLeader()) AdminPanel(pr: sp),
            ],
          ),
        );
      },
    );
  }
}
