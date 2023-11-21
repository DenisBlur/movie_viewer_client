import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:movie_viewer/data/common.dart';
import 'package:movie_viewer/data/save_data.dart';
import 'package:movie_viewer/model/ux_provider.dart';
import 'package:socket_io_client/socket_io_client.dart';

class SocketProvider extends ChangeNotifier {
  UxProvider uxProvider;

  late final player = Player();
  late final controller = VideoController(player);

  SocketProvider({required this.uxProvider}) {
    connectToServer();

    player.stream.duration.listen((event) {
      maxSliderValue = event.inMilliseconds.toDouble();
    });
    player.stream.position.listen((event) {
      currentMSeconds = event.inMilliseconds;
    });
    player.stream.playing.listen((event) {
      isPlaying = event;
    });
  }

  String? username = "User";
  late Socket socket;

  User? currentUser;
  Session? _currentSession;

  Session? get currentSession => _currentSession;

  set currentSession(Session? value) {
    _currentSession = value;

    if (value == null) {
      uxProvider.animateWelcomePage(0);
    } else {
      uxProvider.animateWelcomePage(1);
      if (value.currentMovie != null) {
        uxProvider.animateWelcomePage(2);
      }
    }

    notifyListeners();
  }

  List<Session>? sessions;

  bool isPlaying = false;
  bool canSync = false;
  int currentMSeconds = 0;
  double maxSliderValue = 0;

  String currentMovie = "";

  bool connectToServer() {
    try {
      socket = io("http://95.105.56.9:3000", <String, dynamic>{
        'transports': ['websocket'],
        'autoConnect': false,
      });
      socket.connect();

      ///Пользователи
      socket.on('user_create', handleUserCreate);
      socket.on("user_change_username", handleUserChangeUsername);

      ///Сессия
      socket.on("session_user_connect", handleSessionUserConnect);
      socket.on("session_user_disconnect", handleSessionUserDisconnect);
      socket.on("session_update", handleSessionUpdate);
      socket.on("session_set_movie", handleSessionSetMovie);
      socket.on("session_sync_time", handleSessionSyncTime);
      socket.on("session_action", handleSessionAction);
      socket.on("session_change_owner", handleSessionChangeOwner);
      socket.on("session_duration_action", handleSessionDurationAction);
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

  void handleSocketData(dynamic data) {
    print(data);
  }

  ///Обработчики для пользователя
  void handleUserCreate(dynamic data) {
    currentUser = User.fromJson(jsonDecode(data));
    notifyListeners();
  }

  void handleUserChangeUsername(dynamic data) {
    if (currentUser != null) {
      User localUser = User.fromJson(jsonDecode(data));
      if (currentUser!.id == localUser.id) {
        currentUser!.username = localUser.username;
      }

      if (currentSession != null) {
        for (var i = 0; i < currentSession!.connectedUsers!.length; ++i) {
          if (currentSession!.connectedUsers![i].id == localUser.id) {
            currentSession!.connectedUsers![i] = localUser;
            notifyListeners();
            return;
          }
        }
      }
    }
    notifyListeners();
  }

  ///Обработчики для сессии

  void handleSessionChangeOwner(dynamic data) {
    if (currentSession != null) {
      List<dynamic> dataPack = data;

      String oldOwner = dataPack[0];

      if (currentSession!.ownerSessionID == oldOwner) {
        currentSession = Session.fromJson(jsonDecode(dataPack[1]));
        notifyListeners();
      }
    }
  }

  Future<void> handleSessionAction(dynamic data) async {
    List<dynamic> dataPack = data;

    String action = dataPack[0];
    String sessionId = dataPack[1];

    if (currentSession != null && currentSession!.sessionId == sessionId) {
      switch (action) {
        case "play":
          if (!isPlaying) {
            await player.play();
          }
          break;
        case "pause":
          if (isPlaying) {
            await player.pause();
          }
          break;
      }
    }
  }

  void handleSyncTime(dynamic data) {
    if (!checkLeader()) {
      currentUser = User.fromJson(jsonDecode(data));
    }
  }

  void handleSessionUpdate(dynamic data) {
    sessions = [];
    List<dynamic> jsonSessions = jsonDecode(data);
    if (jsonSessions.isNotEmpty) {
      for (var session in jsonSessions) {
        sessions!.add(Session.fromJson(session));
      }
    }
    notifyListeners();
  }

  ///Обработчики для сессии
  Future<void> handleSessionSetMovie(dynamic data) async {
    Session localSession = Session.fromJson(jsonDecode(data));
    if (currentSession!.sessionId == localSession.sessionId) {
      player.stop();
      currentSession = localSession;
      player.open(Media(currentSession!.streamLink!, httpHeaders: localSession.headers), play: false);
      if (localSession.audioLink != null) {
        player.setAudioTrack(AudioTrack.uri(localSession.audioLink!,
            title: "Audio", language: "all"));
      }
    }
    notifyListeners();
  }

  ///В таких датапаках USER идет всегда первым[0]!!!
  void handleSessionUserConnect(dynamic data) {
    List<dynamic> dataPack = jsonDecode(data);
    User localUser = User.fromJson(dataPack[0]);
    Session localSession = Session.fromJson(dataPack[1]);
    if (localUser.id == currentUser!.id!) {
      currentSession = localSession;
      if (checkLeader()) {
        Timer.periodic(const Duration(milliseconds: 200), (timer) {
          if (isPlaying) {
            sendPlayerTime();
          }
        });
      }
    } else {
      if (currentSession != null) {
        currentSession = localSession;
      }
    }
    if (sessions != null) {
      for (int i = 0; i < sessions!.length; i++) {
        if (sessions![i].ownerSessionID == localSession.ownerSessionID) {
          sessions![i] = localSession;
          break;
        }
      }
    }
    notifyListeners();
  }

  void handleSessionUserDisconnect(dynamic data) {
    List<dynamic> dataPack = jsonDecode(data);

    User localUser = User.fromJson(dataPack[0]);
    if (dataPack[1] != null) {
      Session localSession = Session.fromJson(dataPack[1]);

      if (localUser.id == currentUser!.id!) {
        currentSession = null;
        player.stop();
      }

      if (sessions != null) {
        for (int i = 0; i < sessions!.length; i++) {
          if (sessions![i].ownerSessionID == localSession.ownerSessionID) {
            sessions![i] = localSession;
          }
          if (currentSession != null &&
              currentSession!.ownerSessionID == localSession.ownerSessionID) {
            currentSession = localSession;
          }
        }
      }
    } else {
      currentSession = null;
      sessions = null;
    }
    notifyListeners();
  }

  void handleSessionDurationAction(dynamic data) async {
    if (currentSession != null) {
      int newDuration = int.parse(data[0].toString());
      String sessionId = data[1].toString();
      if (currentSession!.sessionId == sessionId) {
        await player.seek(Duration(milliseconds: newDuration));
      }
    }
  }

  Future<void> handleSessionSyncTime(dynamic data) async {
    if (!checkLeader() && currentSession != null) {
      int leaderMSecond = int.parse(data[0].toString());
      String sessionId = data[1].toString();
      if (currentSession!.sessionId == sessionId) {
        if (currentMSeconds > leaderMSecond + 500 ||
            currentMSeconds < leaderMSecond - 500) {
          await player.seek(Duration(milliseconds: leaderMSecond));
        }
      }
    }
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
    if (currentSession != null) {
      var dataPack = {"data": action, "sessionId": currentSession!.sessionId};
      socket.emit("session_action", jsonEncode(dataPack));
    }
  }

  void sendPlayerTime() {
    if (currentSession != null) {
      var dataPack = {
        "data": currentMSeconds,
        "sessionId": currentSession!.sessionId
      };

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
