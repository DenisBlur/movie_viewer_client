import 'dart:convert';
import 'dart:math';

import 'package:dart_vlc/dart_vlc.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_hls_parser/flutter_hls_parser.dart';
import 'package:movie_viewer/data/common.dart';
import 'package:movie_viewer/data/save_data.dart';
import 'package:movie_viewer/model/socket/session_handlers.dart';
import 'package:movie_viewer/model/socket/user_handlers.dart';
import 'package:movie_viewer/model/ux_provider.dart';
import 'package:socket_io_client/socket_io_client.dart';
import 'package:window_manager/window_manager.dart';
import 'package:http/http.dart' as http;

class SocketProvider extends ChangeNotifier {
  ///Переменные
  UxProvider uxProvider;
  String? username = "User";
  User? _currentUser;
  Session? _currentSession;
  List<Session>? _sessions;
  List<Variant>? resolutionVariants;
  Variant? currentVariant;
  UserHandlers? userHandlers;
  SessionHandlers? sessionHandlers;
  bool fullscreen = false;

  ///Getters
  User? get currentUser => _currentUser;

  Session? get currentSession => _currentSession;

  List<Session>? get sessions => _sessions;

  ///Setters
  set currentUser(User? value) {
    _currentUser = value;
    notifyListeners();
  }

  set currentSession(Session? value) {
    _currentSession = value;

    if (value == null) {
      uxProvider.animateWelcomePage(0);
      notifyListeners();
    }
  }

  set sessions(List<Session>? value) {
    _sessions = value;
    notifyListeners();
  }

  ///Сокет
  Socket? socket;

  ///Плеер
  final player = Player(id: 13150 + Random().nextInt(5));
  Player? audioPlayer;
  int currentMSeconds = 0;

  ///Конструктор
  SocketProvider({required this.uxProvider}) {
    userHandlers = UserHandlers(socketProvider: this);
    sessionHandlers = SessionHandlers(socketProvider: this);

    player.positionStream.listen((event) {
      currentMSeconds = event.position!.inMilliseconds;
    });

    // ServicesBinding.instance.keyboard.addHandler((event) {
    //   final key = event.logicalKey.debugName;
    //
    //   if (event is KeyUpEvent && key == "Arrow Left") {
    //     seekMovie(player.position.position!.inMilliseconds - 5000);
    //     print("-5000");
    //   } else if(key == "Arrow Right") {
    //     seekMovie(player.position.position!.inMilliseconds + 5000);
    //     print("+5000");
    //   } else if(key == "Space") {
    //     if(player.playback.isPlaying) {
    //       pauseMovie();
    //     } else {
    //       playMovie();
    //     }
    //     print("PlayOrPause");
    //   }
    //
    //   print(key);
    //
    //   return false;
    // },);

    connectToServer();
  }

  changeResolution(int index) {
    if (resolutionVariants != null) {
      currentVariant = resolutionVariants![index];
      player.open(Media.network(currentVariant!.url.toString()), autoStart: true);
      sendSessionActionDuration(currentMSeconds);
    }
  }

  setMovie({required String video, String? audio}) async {
    if (audio == null) {
      var response = await http.get(Uri.parse(video));
      try {
        var playList = await HlsPlaylistParser.create().parseString(Uri.parse(video), response.body) as HlsMasterPlaylist;
        resolutionVariants = playList.variants;
        if (resolutionVariants != null) {
          for (int i = 0; i < resolutionVariants!.length; i++) {
            if (resolutionVariants![i].format.width == 1920) {
              currentVariant = resolutionVariants![i];
              break;
            } else if (resolutionVariants![i].format.width != null) {
              currentVariant = resolutionVariants![i];
            }
          }
        }
        if (currentVariant != null) {
          player.open(Media.network(currentVariant!.url.toString()), autoStart: false);
        }
      } on ParserException catch (e) {
        if (kDebugMode) {
          print(e);
        }
      }
    } else {
      resolutionVariants = null;
      currentVariant = null;

      if (audioPlayer != null) {
        audioPlayer!.dispose();
      }
      player.open(Media.network(video), autoStart: false);
      audioPlayer = Player(id: 13155, commandlineArguments: ['--no-video']);
      audioPlayer!.open(Media.network(audio), autoStart: false);
      player.positionStream.listen((event) {
        if (audioPlayer != null) {
          int audioMS = audioPlayer!.position.position!.inMilliseconds;
          int videoMS = event.position!.inMilliseconds;

          var delta = videoMS - audioMS;

          if (delta.abs() > 300) {
            audioPlayer!.seek(event.position!);
          }
        }
      });
    }
    notifyListeners();
  }

  pauseMovie() {
    player.pause();
    uxProvider.isPlay = false;
    if (audioPlayer != null) {
      audioPlayer!.pause();
    }
    notifyListeners();
  }

  playMovie() {
    player.play();
    uxProvider.isPlay = true;
    if (audioPlayer != null) {
      audioPlayer!.play();
    }
    notifyListeners();
  }

  seekMovie(int value) {
    player.seek(Duration(milliseconds: value));
    notifyListeners();
  }

  stopMovie() {
    player.stop();
    if (audioPlayer != null) {
      audioPlayer!.stop();
    }
    notifyListeners();
  }

  setVolume(double value) {
    player.setVolume(value);
    if (audioPlayer != null) {
      audioPlayer!.setVolume(value);
    }
    notifyListeners();
  }

  goToSessionViewer() {
    uxProvider.animateWelcomePage(1);
  }

  goToMain() {
    uxProvider.animateWelcomePage(0);
  }

  setFullscreen(bool value) async {
    await windowManager.setFullScreen(value);
    fullscreen = await windowManager.isFullScreen();
    notifyListeners();
  }

  bool connectToServer({String? ip = "95.105.56.9", String? port = "3000"}) {
    if (socket != null && socket!.connected) {
      socket!.dispose();
    }

    try {
      socket = io("http://$ip:$port", <String, dynamic>{
        'transports': ['websocket'],
        'autoConnect': false,
      });

      socket!.connect();

      ///Пользователи
      socket!.on('user_create', userHandlers!.handleUserCreate);
      socket!.on("user_change_username", userHandlers!.handleUserChangeUsername);
      socket!.on(
        "user_get_movie_link",
        (data) {},
      );

      ///Сессия
      socket!.on("session_user_connect", sessionHandlers!.handleSessionUserConnect);
      socket!.on("session_user_disconnect", sessionHandlers!.handleSessionUserDisconnect);
      socket!.on("session_update", sessionHandlers!.handleSessionUpdate);
      socket!.on("session_set_movie", sessionHandlers!.handleSessionSetMovie);
      socket!.on("session_sync_time", sessionHandlers!.handleSessionSyncTime);
      socket!.on("session_action", sessionHandlers!.handleSessionAction);
      socket!.on("session_change_owner", sessionHandlers!.handleSessionChangeOwner);
      socket!.on("session_duration_action", sessionHandlers!.handleSessionDurationAction);
      socket!.on("session_user_time_update", sessionHandlers!.handleSessionUserTimeUpdate);

      ///Тестовые
      socket!.on("socket_data", handleSocketData);
      socket!.on('fromServer', (_) => print(_));
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
    }
    createUser();
    return socket!.connected;
  }

  updateView() {
    notifyListeners();
  }

  ///Просто для теста
  void handleSocketData(dynamic data) {
    print(data);
  }

  ///Функции для отправки данных
  ///В таких датапаках USER идет всегда первым[0]!!!
  void connectToSession(Session session) {
    ///Отключение от текущей сессии
    if (currentSession != null) {
      disconnectFromSession();
    }

    if (currentUser != null) {
      List<dynamic> data = [currentUser, session];
      socket!.emit("session_connect", jsonEncode(data));
    }
  }

  void disconnectFromSession() {
    setFullscreen(false);
    if (currentSession != null) {
      List<dynamic> data = [currentUser, currentSession];
      socket!.emit("session_disconnect", jsonEncode(data));
    }
  }

  ///Отправка имени пользователя на сервер
  void changeUsername(String value) {
    ///если есть сохраненное имя, то подгружаем его
    SaveData().saveUsername(value);
    socket!.emit(
      "user_change_username",
      value,
    );
  }

  void setSessionFilm(Movie movie, String streamLink, String? audioLink) {
    if (currentSession != null) {
      currentSession!.currentMovie = movie;
      currentSession!.streamLink = streamLink;
      currentSession!.audioLink = audioLink;

      socket!.emit(
        "session_set_movie",
        currentSession,
      );
    }
  }

  ///Отправка позиции плеера
  sendSessionActionDuration(int ms) {
    currentMSeconds = ms;

    if (currentSession != null) {
      var dataPack = {"data": ms, "sessionId": currentSession!.sessionId};

      socket!.emit("session_duration_action", jsonEncode(dataPack));
    }
  }

  ///Отправка действий Player.pauseOrPlay
  sendSessionAction(String action) {
    if (currentSession != null) {
      var dataPack = {"data": action, "sessionId": currentSession!.sessionId};
      socket!.emit("session_action", jsonEncode(dataPack));
    }
  }

  ///Отправка данных плеера на сервер
  void sendPlayerTime() {
    if (currentSession != null && currentUser != null) {
      currentUser!.currentTime = currentMSeconds;
      var dataPack = {"user": currentUser!.toJson(), "sessionId": currentSession!.sessionId};
      socket!.emit("user_player_time", jsonEncode(dataPack));
    }
  }

  ///Создание пользователя
  createUser() async {
    username = await SaveData().loadUsername();
    username = username ?? "User";
    socket!.emit("user_create", username);
  }

  ///Создание сессии
  createSession(String sessionName, int maxUsers) {
    if (currentUser != null) {
      Session session = Session(
        sessionId: "null",
        sessionName: sessionName,
        maxUsers: maxUsers,
        ownerSessionID: currentUser!.id,
        streamLink: null,
        currentMovie: null,
        audioLink: null,
      );

      List<dynamic> data = [currentUser, session.toJson()];

      socket!.emit("session_create", jsonEncode(data));
    }
  }

  ///Проверка на лидера сессии
  bool checkLeader() {
    if (currentSession != null && currentUser != null) {
      return currentSession!.ownerSessionID == currentUser!.id;
    }
    return false;
  }

  String durationToHMS(Duration duration) {
    String negativeSign = duration.isNegative ? '-' : '';
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60).abs());
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60).abs());
    return "$negativeSign${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }
}
