import 'package:flutter/material.dart';
import 'package:movie_viewer/widgets/tabs/tab_movie_viewer.dart';
import 'package:movie_viewer/widgets/tabs/tab_current_session_setting.dart';
import 'package:movie_viewer/widgets/tabs/tab_session_viewer.dart';
import 'package:provider/provider.dart';

import '../model/socket/socket_provider.dart';
import '../widgets/tabs/tab_main.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SocketProvider>(
      builder: (context, sp, child) {
        return Scaffold(
            body: PageView(
          physics: const NeverScrollableScrollPhysics(),
          controller: sp.uxProvider.pageController,
          scrollDirection: Axis.horizontal,
          children: [
            TabMain(socketProvider: sp),
            TabSessionViewer(socketProvider: sp),
            TabCurrentSessionSetting(socketProvider: sp,),
            const TabMovieViewer()
          ],
        ));
      },
    );
  }
}
