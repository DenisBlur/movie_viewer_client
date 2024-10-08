import 'dart:convert';

import 'package:dart_vlc/dart_vlc.dart';
import 'package:flutter/foundation.dart';
import 'package:movie_viewer/data/common.dart';
import 'package:movie_viewer/data/save_data.dart';
import 'package:movie_viewer/model/socket/session_handlers.dart';
import 'package:movie_viewer/model/socket/user_handlers.dart';
import 'package:movie_viewer/model/ux_provider.dart';
import 'package:socket_io_client/socket_io_client.dart';
import 'package:window_manager/window_manager.dart';

class SocketProvider extends ChangeNotifier {
  ///Переменные
  UxProvider uxProvider;
  String? username = "User";
  User? _currentUser;
  Session? _currentSession;
  List<Session>? _sessions;
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
    } else {
      if (value.currentMovie != null) {
        uxProvider.animateWelcomePage(3);
      } else {
        uxProvider.animateWelcomePage(2);
        notifyListeners();
      }
    }
  }

  set sessions(List<Session>? value) {
    _sessions = value;
    notifyListeners();
  }

  ///Сокет
  late Socket socket;

  ///Плеер
  final player = Player(id: 13150);
  Player? audioPlayer;
  bool canSync = false;
  int currentMSeconds = 0;

  ///Конструктор
  SocketProvider({required this.uxProvider}) {
    userHandlers = UserHandlers(socketProvider: this);
    sessionHandlers = SessionHandlers(socketProvider: this);

    player.positionStream.listen((event) {
      currentMSeconds = event.position!.inMilliseconds;
    });

    connectToServer();
  }

  setMovie({required String video, String? audio}) async {
    player.open(Media.network(video), autoStart: false);
    if (audio != null) {
      audioPlayer = Player(id: 13155, commandlineArguments: ['--no-video']);
      audioPlayer!.open(Media.network(audio), autoStart: false);
      player.positionStream.listen((event) {
        print(currentMSeconds);
        if (audioPlayer != null) {
          int audioMS = audioPlayer!.position.position!.inMilliseconds;
          int videoMS = event.position!.inMilliseconds;

          var delta = videoMS - audioMS;

          if (delta.abs() > 300) {
            audioPlayer!.seek(event.position!);
            print(delta);
          }
        }
      });
    } else {
      if (audioPlayer != null) {
        audioPlayer!.dispose();
      }
    }
    notifyListeners();
  }

  pauseMovie() async {
    player.pause();
    if (audioPlayer != null) {
      audioPlayer!.pause();
    }
    notifyListeners();
  }

  playMovie() async {
    player.play();
    if (audioPlayer != null) {
      audioPlayer!.play();
    }
    notifyListeners();
  }

  seekMovie(int value) async {
    player.seek(Duration(milliseconds: value));
    notifyListeners();
  }

  stopMovie() async {
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

  bool connectToServer() {
    try {
      socket = io("http://95.105.56.9:3000", <String, dynamic>{
        'transports': ['websocket'],
        'autoConnect': false,
      });
      socket.connect();

      ///Пользователи
      socket.on('user_create', userHandlers!.handleUserCreate);
      socket.on("user_change_username", userHandlers!.handleUserChangeUsername);
      socket.on(
        "user_get_movie_link",
        (data) {},
      );

      ///Сессия
      socket.on("session_user_connect", sessionHandlers!.handleSessionUserConnect);
      socket.on("session_user_disconnect", sessionHandlers!.handleSessionUserDisconnect);
      socket.on("session_update", sessionHandlers!.handleSessionUpdate);
      socket.on("session_set_movie", sessionHandlers!.handleSessionSetMovie);
      socket.on("session_sync_time", sessionHandlers!.handleSessionSyncTime);
      socket.on("session_action", sessionHandlers!.handleSessionAction);
      socket.on("session_change_owner", sessionHandlers!.handleSessionChangeOwner);
      socket.on("session_duration_action", sessionHandlers!.handleSessionDurationAction);

      ///Тестовые
      socket.on("socket_data", handleSocketData);
      socket.on('fromServer', (_) => print(_));
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
    }

    createUser();
    return socket.connected;
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
      socket.emit("session_connect", jsonEncode(data));
    }
  }

  void disconnectFromSession() {
    setFullscreen(false);
    if (currentSession != null) {
      List<dynamic> data = [currentUser, currentSession];
      socket.emit("session_disconnect", jsonEncode(data));
    }
  }

  ///Отправка имени пользователя на сервер
  void changeUsername(String value) {
    ///если есть сохраненное имя, то подгружаем его
    SaveData().saveUsername(value);
    socket.emit(
      "user_change_username",
      value,
    );
  }

  void setSessionFilm(Movie movie, String streamLink, String? audioLink) {
    if (currentSession != null) {
      currentSession!.currentMovie = movie;
      currentSession!.streamLink = streamLink;
      currentSession!.audioLink = audioLink;

      socket.emit(
        "session_set_movie",
        currentSession,
      );
    }
  }

  ///Отправка позиции плеера
  sendSessionActionDuration(int ms) {
    if (currentSession != null) {
      var dataPack = {"data": ms, "sessionId": currentSession!.sessionId};

      socket.emit("session_duration_action", jsonEncode(dataPack));
    }
  }

  ///Отправка действий Player.pauseOrPlay
  sendSessionAction(String action) {
    if (currentSession != null) {
      var dataPack = {"data": action, "sessionId": currentSession!.sessionId};
      socket.emit("session_action", jsonEncode(dataPack));
    }
  }

  void sendPlayerTime() {
    if (currentSession != null) {
      var dataPack = {"data": currentMSeconds, "sessionId": currentSession!.sessionId};

      socket.emit("session_sync_time", jsonEncode(dataPack));
    }
  }

  ///Создание пользователя
  createUser() async {
    username = await SaveData().loadUsername();
    username = username ?? "User";
    socket.emit("user_create", username);
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

      socket.emit("session_create", jsonEncode(data));
    }
  }

  ///Проверка на лидера сессии
  bool checkLeader() {
    if (currentSession != null && currentUser != null) {
      return currentSession!.ownerSessionID == currentUser!.id;
    }
    return false;
  }

  String printDuration(Duration duration) {
    String negativeSign = duration.isNegative ? '-' : '';
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60).abs());
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60).abs());
    return "$negativeSign${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }
}
