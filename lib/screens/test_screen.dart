import 'package:dart_vlc/dart_vlc.dart';
import 'package:flutter/material.dart';
import 'package:movie_viewer/model/socket/socket_provider.dart';

final player = Player(id: 69420);

class TestScreen extends StatefulWidget {
  const TestScreen({super.key});

  @override
  State<TestScreen> createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {


  @override
  void initState() {
    player.open(Media.network("https://950-8ca-2500g0.v.plground.live:10402/hs/30/1700794593/S3g5CUEDbTJgonCiY1XX6g/973/10973/index-f4-v1-f5-a1.m3u8"));
    player.play();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: SingleChildScrollView(
      child: Video(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        player: player,
        showControls: true,
      )
    ),);
  }
}

