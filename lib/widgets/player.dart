import 'package:flutter/material.dart';
import 'package:movie_viewer/model/socket/socket_provider.dart';
import 'package:movie_viewer/model/ux_provider.dart';
import 'package:provider/provider.dart';

class Player extends StatelessWidget {
  const Player({super.key, required this.sp});

  final SocketProvider sp;

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: 1,
      duration: const Duration(milliseconds: 650),
      curve: Curves.fastEaseInToSlowEaseOut,
      child: SizedBox(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
      ),
    );
  }
}

// class Controls extends StatelessWidget {
//   const Controls({super.key, required this.pr, required this.state});
//
//   final SocketProvider pr;
//
//   @override
//   Widget build(BuildContext context) {
//     return Consumer<UxProvider>(
//       builder: (context, ux, child) {
//         return SizedBox(
//           width: MediaQuery.of(context).size.width,
//           height: MediaQuery.of(context).size.height,
//           child: Stack(
//             children: [
//               AnimatedPositioned(
//                 top: ux.showControls ? 32 : -100,
//                 right: 0,
//                 left: 0,
//                 duration: const Duration(milliseconds: 650),
//                 curve: Curves.fastEaseInToSlowEaseOut,
//                 child: Text(pr.currentSession!.currentMovie!.title!,style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 64
//                 ), textAlign: TextAlign.center, maxLines: 1,)
//               ),
//               AnimatedPositioned(
//                 top: ux.showControls ? 32 : -100,
//                 right: ux.showUserPanel ? 264 : 32,
//                 duration: const Duration(milliseconds: 650),
//                 curve: Curves.fastEaseInToSlowEaseOut,
//                 child: FilledButton(
//                   child: const Icon(Icons.supervised_user_circle_rounded),
//                   onPressed: () {
//                     ux.showUserPanel = !ux.showUserPanel;
//                   },
//                 ),
//               ),
//               AnimatedPositioned(
//                 duration: const Duration(milliseconds: 650),
//                 curve: Curves.fastEaseInToSlowEaseOut,
//                 bottom: ux.showControls ? 32 : -400,
//                 left: 32,
//                 right: 32,
//                 child: Container(
//                     padding: const EdgeInsets.all(8),
//                     decoration: BoxDecoration(
//                       color: Theme.of(context).colorScheme.background,
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                     child: Row(
//                       children: [
//                         IconButton(
//                           onPressed: () {
//                             if(pr.isPlaying) {
//                               pr.sendSessionAction("pause");
//                             } else {
//                               pr.sendSessionAction("play");
//                             }
//                           },
//                           icon: StreamBuilder(
//                             stream: state.widget.controller.player.stream.playing,
//                             builder: (context, playing) => Icon(
//                               playing.data == true ? Icons.pause : Icons.play_arrow,
//                             ),
//                           ),
//                         ),
//                         StreamBuilder(
//                           stream: state.widget.controller.player.stream.volume,
//                           builder: (context, value) {
//                             return SizedBox(
//                               width: 150,
//                               child: Slider(
//                                 value: value.data ?? 100,
//                                 max: 100,
//                                 min: 0,
//                                 onChanged: (double value) {
//                                   pr.player.setVolume(value);
//                                 },
//                               ),
//                             );
//                           },
//                         ),
//                         StreamBuilder(
//                           stream: state.widget.controller.player.stream.position,
//                           builder: (context, value) {
//                             if (value.data != null) {
//                               return Expanded(
//                                 child: Slider(
//                                   value: value.data!.inMilliseconds.toDouble(),
//                                   onChangeEnd: (value) async {
//                                     pr.sendSessionActionDuration(value.toInt());
//                                   },
//                                   max: pr.maxSliderValue == 0 ? 10 : pr.maxSliderValue,
//                                   min: 0, onChanged: (double value) {  },
//                                 ),
//                               );
//                             } else {
//                               return const SizedBox();
//                             }
//                           },
//                         ),
//                         IconButton(
//                           onPressed: () {
//                             toggleFullscreen(context);
//                           },
//                           icon: StreamBuilder(
//                             stream: state.widget.controller.player.stream.playing,
//                             builder: (context, playing) => const Icon(
//                               Icons.fullscreen_rounded,
//                             ),
//                           ),
//                         ),
//                       ],
//                     )),
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }
// }
