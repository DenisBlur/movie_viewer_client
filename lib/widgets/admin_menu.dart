import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:movie_viewer/model/socket_provider.dart';
import 'package:movie_viewer/model/ux_provider.dart';
import 'package:provider/provider.dart';

class AdminPanel extends StatelessWidget {
  const AdminPanel({super.key, required this.pr});

  final SocketProvider pr;

  @override
  Widget build(BuildContext context) {
    return Consumer<UxProvider>(
      builder: (context, ux, child) {
        return AnimatedPositioned(
          duration: const Duration(milliseconds: 650),
          curve: Curves.fastEaseInToSlowEaseOut,
          left: ux.showAdminPanel ? 32 : -400,
          top: 32,
          bottom: 114,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: Theme.of(context).scaffoldBackgroundColor.withOpacity(.8), borderRadius: BorderRadius.circular(8)),
                width: 200,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      FilledButton(
                        onPressed: () {
                          //_showMyDialog(context);
                        },
                        child: Text("Поставить фильм"),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}