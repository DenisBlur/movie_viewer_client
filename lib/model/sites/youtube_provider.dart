import 'package:flutter/foundation.dart';
import 'package:movie_viewer/data/common.dart';
import 'package:movie_viewer/model/socket/socket_provider.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class YoutubeProvider extends ChangeNotifier {

  YoutubeProvider({required this.socketProvider});
  
  SocketProvider socketProvider;

  List<VideoOnlyStreamInfo> currentVideoQualityData = [];
  List<AudioOnlyStreamInfo> currentAudioQualityData = [];

  String title = "";
  String id = "";
  String author = "";
  String thumbnail = "";
  String date = "";
  String description = "";

  bool _loading = false;
  bool check = false;

  bool get loading => _loading;

  set loading(bool value) {
    _loading = value;
    notifyListeners();
  }

  var yt = YoutubeExplode();

  void getYouTubeVideoData(String link) async {

    String linkId = "";
    if(link.contains("&")) {
      linkId = link.substring(link.indexOf("?v=") + 3, link.indexOf("&"));
    } else {
      linkId = link.substring(link.indexOf("?v=") + 3, link.length);
    }

    loading = true;
    final video = await yt.videos.get(linkId);
    title = video.title;
    thumbnail = video.thumbnails.highResUrl;
    author = video.author;
    description = video.description;
    date = "${video.publishDate!.day}.${video.publishDate!.month}.${video.publishDate!.year}";


    final manifest = await yt.videos.streamsClient.getManifest(linkId);
    final getVideo = manifest.videoOnly;
    final getAudio = manifest.audioOnly;


    currentAudioQualityData = getAudio.toList();
    currentVideoQualityData = getVideo.toList();
    loading = false;

  }

  void sendCurrentMovie(VideoOnlyStreamInfo streamInfo) {

    socketProvider.setSessionFilm(Movie(pageUrl: null, coverUrl: thumbnail, kp: null, imdb: null, title: title, year: null), streamInfo.url.toString(), currentAudioQualityData.last.url.toString());

    currentVideoQualityData = [];
    currentAudioQualityData = [];

    title = "";
    id = "";
    author = "";
    thumbnail = "";
    date = "";
    description = "";
  }



}