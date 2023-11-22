import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:transparent_image/transparent_image.dart';

import '../model/sites/youtube_provider.dart';

class YoutubeWidget extends StatelessWidget {
  const YoutubeWidget({super.key, required this.urlController});

  final TextEditingController urlController;

  @override
  Widget build(BuildContext context) {
    return Consumer<YoutubeProvider>(
      builder: (context, yp, child) {
        return SizedBox(
          width: 650,
          height: MediaQuery.of(context).size.height / 2,
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 650,
                        child: TextField(
                          controller: urlController,
                          onSubmitted: (value) {
                            yp.getYouTubeVideoData(value);
                          },
                          decoration: const InputDecoration(
                            label: Text("ссылка на видео"),
                          ),
                        ),
                      ),
                      if (yp.title != "")
                        VideoPreview(
                          yp: yp,
                        ),
                      if (yp.title != "") const Padding(padding: EdgeInsets.only(left: 8), child: Text("Качество видео"),),
                      for (var info in yp.currentVideoQualityData) TextButton(onPressed: () {
                        Navigator.of(context).pop();
                        yp.sendCurrentMovie(info);
                      }, child: Text(info.videoQualityLabel))
                    ],
                  ),
                ),
              ),
              Row(
                children: [
                  const Expanded(child: SizedBox()),
                  TextButton(
                    child: const Text('Отмена'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  const SizedBox(
                    width: 16,
                  ),
                    TextButton(
                      child: const Text('Получить'),
                      onPressed: () {
                        yp.getYouTubeVideoData(urlController.text);
                      },
                    ),
                ],
              )
            ],
          ),
        );
      },
    );
  }
}

class VideoPreview extends StatelessWidget {
  const VideoPreview({super.key, required this.yp});

  final YoutubeProvider yp;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(24), color: Theme.of(context).colorScheme.primaryContainer),
      margin: const EdgeInsets.only(top: 16, bottom: 16),
      padding: const EdgeInsets.all(16),
      width: 650,
      height: 166,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: FadeInImage.memoryNetwork(placeholder: kTransparentImage, image: yp.thumbnail, height: 150, width: 250, fit: BoxFit.cover),
          ),
          const SizedBox(
            width: 16,
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(yp.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24), maxLines: 1, overflow: TextOverflow.ellipsis,),
                Text(yp.author, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 18)),
                const Expanded(child: SizedBox()),
                Text(
                  yp.date,
                  textAlign: TextAlign.end,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
