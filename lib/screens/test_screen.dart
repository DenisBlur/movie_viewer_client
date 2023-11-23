import 'package:flutter/material.dart';
import 'package:movie_viewer/model/socket/socket_provider.dart';
import 'package:video_player/video_player.dart';
import 'package:fvp/fvp.dart' as fvp;

class TestScreen extends StatefulWidget {
  const TestScreen({super.key});

  @override
  State<TestScreen> createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {

  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();

    _controller = VideoPlayerController.networkUrl(
        Uri.parse('https://9bc-a3e-2200g0.v.plground.live:10402/hs/32/1700677185/K16zr76c2RaJz-EWigW5cg/976/566976/4/index-f2-v1-sa4-a1.m3u8'));

    _controller = VideoPlayerController.networkUrl(
        Uri.parse('https://9bc-a3e-2200g0.v.plground.live:10402/hs/32/1700677185/K16zr76c2RaJz-EWigW5cg/976/566976/4/index-f2-v1-sa4-a1.m3u8'));

    _controller.addListener(() {
      setState(() {});
    });
    _controller.setLooping(true);
    _controller.initialize().then((_) => setState(() {}));
    _controller.play();

  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: SingleChildScrollView(
      child: Column(
        children: <Widget>[
          const Text('With assets mp4'),
          Container(
            padding: const EdgeInsets.all(20),
            child: AspectRatio(
              aspectRatio: _controller.value.aspectRatio,
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: <Widget>[
                  VideoPlayer(_controller),
                  //ControlsOverlay(controller: _controller, socketProvider: null,),
                  VideoProgressIndicator(_controller, allowScrubbing: true),
                ],
              ),
            ),
          ),
        ],
      ),
    ),);
  }
}

