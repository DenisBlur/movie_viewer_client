import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:fvp/fvp.dart';
import 'package:movie_viewer/model/hq_movie_provider.dart';
import 'package:movie_viewer/model/sites/movie_provider.dart';
import 'package:movie_viewer/model/sites/youtube_provider.dart';
import 'package:movie_viewer/model/ux_provider.dart';
import 'package:movie_viewer/screens/main_screen.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:window_manager/window_manager.dart';

import 'model/socket/socket_provider.dart';

final _defaultLightColorScheme = ColorScheme.fromSwatch(primarySwatch: Colors.blue);

final _defaultDarkColorScheme = ColorScheme.fromSwatch(primarySwatch: Colors.blue, brightness: Brightness.dark);

List<SingleChildWidget> _providers = [
  ChangeNotifierProvider(
    create: (context) => UxProvider(),
  ),
  ChangeNotifierProvider(
    create: (context) => SocketProvider(uxProvider: context.read()),
  ),
  ChangeNotifierProvider(
    create: (context) => MovieProvider(socketProvider: context.read()),
  ),
  ChangeNotifierProvider(
    create: (context) => YoutubeProvider(socketProvider: context.read()),
  ),
  ChangeNotifierProvider(
    create: (context) => HQMovieProvider(socketProvider: context.read()),
  ),
];

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();
  registerWith(options: {
    'video.decoders': ['D3D11', 'NVDEC', 'FFmpeg'],
    'lowLatency': 1,
  });
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: _providers,
      builder: (context, child) {
        return DynamicColorBuilder(
          builder: (lightColorScheme, darkColorScheme) {
            return MaterialApp(
              title: 'Movie viewer',
              theme: ThemeData(
                colorScheme: lightColorScheme ?? _defaultLightColorScheme,
                useMaterial3: true,
                platform: TargetPlatform.iOS,
              ),
              darkTheme: ThemeData(
                colorScheme: darkColorScheme ?? _defaultDarkColorScheme,
                useMaterial3: true,
                platform: TargetPlatform.iOS,
              ),
              home: const MainScreen(),
            );
          },
        );
      },
    );
  }
}
