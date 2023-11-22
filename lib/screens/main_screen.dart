import 'package:flutter/material.dart';
import 'package:movie_viewer/widgets/tabs/tab_movie_viewer.dart';
import 'package:movie_viewer/widgets/side_action_panel.dart';
import 'package:movie_viewer/widgets/tabs/tab_current_session_setting.dart';
import 'package:movie_viewer/widgets/tabs/tab_session_viewer.dart';
import 'package:provider/provider.dart';

import '../model/socket/socket_provider.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SocketProvider>(
      builder: (context, sp, child) {
        return Scaffold(
          body: Row(
            children: [
              SideActionPanel(
                socketProvider: sp,
              ),
              Expanded(
                  child: PageView(
                physics: const NeverScrollableScrollPhysics(),
                controller: sp.uxProvider.pageController,
                scrollDirection: Axis.horizontal,
                children: [
                  TabSessionViewer(socketProvider: sp),
                  if (sp.currentSession != null)
                    TabCurrentSessionSetting(
                      socketProvider: sp,
                    ),
                  const TabMovieViewer()
                ],
              )),
            ],
          ),
        );
      },
    );
  }
}
