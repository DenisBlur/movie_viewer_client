import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:movie_viewer/data/common.dart';
import 'package:movie_viewer/data/save_data.dart';
import 'package:movie_viewer/model/socket/session_handlers.dart';
import 'package:movie_viewer/model/socket/user_handlers.dart';
import 'package:movie_viewer/model/ux_provider.dart';
import 'package:socket_io_client/socket_io_client.dart';
import 'package:video_player/video_player.dart';

class SocketProvider extends ChangeNotifier {
  ///Переменные
  UxProvider uxProvider;
  String? username = "User";
  User? _currentUser;
  Session? _currentSession;
  List<Session>? _sessions;
  UserHandlers? userHandlers;
  SessionHandlers? sessionHandlers;

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
  VideoPlayerController? videoController;
  VideoPlayerController? audioController;
  bool canSync = false;
  int currentMSeconds = 0;

  ///Конструктор
  SocketProvider({required this.uxProvider}) {
    userHandlers = UserHandlers(socketProvider: this);
    sessionHandlers = SessionHandlers(socketProvider: this);

    connectToServer();
  }

  setMovie({required String video, String? audio}) async {
    videoController = VideoPlayerController.networkUrl(Uri.parse(video));
    if (audio != null) {
      audioController = VideoPlayerController.networkUrl(Uri.parse(audio));
    }
    await videoController!.initialize();
    videoController!.addListener(playerListener);
    if (audio != null) {
      await audioController!.initialize();
    }
    notifyListeners();
  }

  pauseMovie() async {
    if(videoController != null) {
      if (audioController != null) {
        Duration? localDuration = await videoController!.position;
        await audioController!.seekTo(localDuration!);
        await audioController!.pause();
        await videoController!.pause();
      } else {
        await videoController!.pause();
      }
    }
    notifyListeners();
  }

  playMovie() async {
    if(videoController != null) {
      if (audioController != null) {
        Duration? localDuration = await videoController!.position;
        await audioController!.seekTo(localDuration!);
        await audioController!.play();
        await videoController!.play();
      } else {
        await videoController!.play();
      }
    }
    notifyListeners();
  }

  seekMovie(int value) async {
    if(audioController != null) {
      await audioController!.seekTo(Duration(milliseconds: value));
      await videoController!.seekTo(Duration(milliseconds: value));
    } else {
      await videoController!.seekTo(Duration(milliseconds: value));
    }
    notifyListeners();
  }

  stopMovie() async {
    if (videoController != null) {
      videoController!.removeListener(playerListener);
      await videoController!.dispose();
      if (audioController != null) {
        await audioController!.dispose();
      }
    }
    notifyListeners();
  }

  playerListener() async {
    if(checkLeader()) {
      currentMSeconds = videoController!.value.position.inMilliseconds;
    }
    updateView();
  }

  goToSessionViewer() {
    uxProvider.animateWelcomePage(1);
  }

  goToMain() {
    uxProvider.animateWelcomePage(0);
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

    print(action);

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

  ///Тестовые функции
  get4KFilm(Movie movie) {
    if (currentUser != null && currentSession != null) {
      List<dynamic> dataPack = [currentSession!.sessionId, movie.pageUrl, movie.toJson()];
      socket.emit("get4kfilm", jsonEncode(dataPack));
    }
  }
}
