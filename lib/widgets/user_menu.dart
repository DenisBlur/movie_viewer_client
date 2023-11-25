import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:movie_viewer/model/socket/socket_provider.dart';
import 'package:movie_viewer/model/ux_provider.dart';
import 'package:movie_viewer/widgets/items/user_item.dart';
import 'package:provider/provider.dart';

class UserMenu extends StatelessWidget {
  const UserMenu({super.key, required this.sp});

  final SocketProvider sp;

  @override
  Widget build(BuildContext context) {
    return Consumer<UxProvider>(
      builder: (context, ux, child) {
        return AnimatedPositioned(
          duration: const Duration(milliseconds: 650),
          curve: Curves.fastEaseInToSlowEaseOut,
          right: ux.showUserPanel ? 16 : -400,
          top: 64+16,
          bottom: 94,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: Theme.of(context).scaffoldBackgroundColor.withOpacity(.8), borderRadius: BorderRadius.circular(8)),
                width: 200,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      "Пользователи",
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height - 238,
                      width: 200,
                      child: ListView.builder(
                          itemBuilder: (context, index) {
                            return UserItem(user: sp.currentSession!.connectedUsers![index],);
                          },
                          itemCount: sp.currentSession!.connectedUsers!.length),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
