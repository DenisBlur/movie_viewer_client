import 'dart:async';
import 'dart:convert';

import 'package:movie_viewer/model/socket/socket_provider.dart';

import '../../data/common.dart';

class SessionHandlers {
  SocketProvider? socketProvider;

  SessionHandlers({required this.socketProvider});

  ///Пользователь подключается к сессии
  void handleSessionUserConnect(dynamic data) {
    //Получаем данные
    List<dynamic> dataPack = jsonDecode(data);
    User localUser = User.fromJson(dataPack[0]);
    Session localSession = Session.fromJson(dataPack[1]);

    //Если это мы то устанавливаем currentSession
    if (localUser.id == socketProvider!.currentUser!.id!) {
      socketProvider!.currentSession = localSession;
      //Если мы лидер то, запускаем таймер на передачу данных
      if (socketProvider!.checkLeader()) {
        Timer.periodic(const Duration(milliseconds: 200), (timer) {
          if (socketProvider!.videoController != null && socketProvider!.videoController!.value.isPlaying) {
            socketProvider!.sendPlayerTime();
          }
        });
      }
    } else {
      //Устанавливаем сессии
      if (socketProvider!.currentSession != null) {
        socketProvider!.currentSession = localSession;
      }
    }
    //Изменяем кол-во человек в сессии
    if (socketProvider!.sessions != null) {
      for (int i = 0; i < socketProvider!.sessions!.length; i++) {
        if (socketProvider!.sessions![i].ownerSessionID == localSession.ownerSessionID) {
          socketProvider!.sessions![i] = localSession;
          break;
        }
      }
    }
    socketProvider!.updateView();
  }

  ///Пользователь покинул сессию
  void handleSessionUserDisconnect(dynamic data) {
    List<dynamic> dataPack = jsonDecode(data);
    User localUser = User.fromJson(dataPack[0]);
    //Есди дата о сессии не null
    if (dataPack[1] != null) {
      Session localSession = Session.fromJson(dataPack[1]);

      //Если это мы
      if (localUser.id == socketProvider!.currentUser!.id!) {
        //Выставляем сессию в null и стопаем плеер
        socketProvider!.currentSession = null;
        socketProvider!.stopMovie();
      }

      //Обновление в списке сессий
      if (socketProvider!.sessions != null) {
        for (int i = 0; i < socketProvider!.sessions!.length; i++) {
          if (socketProvider!.sessions![i].ownerSessionID == localSession.ownerSessionID) {
            socketProvider!.sessions![i] = localSession;
          }
          if (socketProvider!.currentSession != null && socketProvider!.currentSession!.ownerSessionID == localSession.ownerSessionID) {
            socketProvider!.currentSession = localSession;
          }
        }
      }
    } else {
      socketProvider!.currentSession = null;
      socketProvider!.sessions = null;
    }
    socketProvider!.updateView();
  }

  ///Смена лидера сессии
  void handleSessionChangeOwner(dynamic data) {
    if (socketProvider!.currentSession != null) {
      List<dynamic> dataPack = data;

      String oldOwner = dataPack[0];

      if (socketProvider!.currentSession!.ownerSessionID == oldOwner) {
        socketProvider!.currentSession = Session.fromJson(jsonDecode(dataPack[1]));
        socketProvider!.updateView();
      }
    }
  }

  ///Действия в сессии
  Future<void> handleSessionAction(dynamic data) async {
    List<dynamic> dataPack = data;

    String action = dataPack[0];
    String sessionId = dataPack[1];

    if (socketProvider!.currentSession != null && socketProvider!.currentSession!.sessionId == sessionId) {
      switch (action) {
        case "play":
          await socketProvider!.playMovie();
          break;
        case "pause":
          await socketProvider!.pauseMovie();
          break;
      }
    }
  }

  ///Обновление списка сессий
  void handleSessionUpdate(dynamic data) {
    socketProvider!.sessions = [];
    List<dynamic> jsonSessions = jsonDecode(data);
    if (jsonSessions.isNotEmpty) {
      for (var session in jsonSessions) {
        socketProvider!.sessions!.add(Session.fromJson(session));
      }
    }
    socketProvider!.updateView();
  }

  ///Установка фильма
  Future<void> handleSessionSetMovie(dynamic data) async {
    Session localSession = Session.fromJson(jsonDecode(data));
    if (socketProvider!.currentSession != null) {
      if (socketProvider!.currentSession!.sessionId == localSession.sessionId) {
        socketProvider!.stopMovie();
        socketProvider!.currentSession = localSession;
        socketProvider!.setMovie(video: localSession.streamLink!, audio: localSession.audioLink);
      }
    }
  }

  ///Смена позиции плеера
  void handleSessionDurationAction(dynamic data) async {
    if (socketProvider!.currentSession != null) {
      int newDuration = int.parse(data[0].toString());
      String sessionId = data[1].toString();
      if (socketProvider!.currentSession!.sessionId == sessionId) {
        await socketProvider!.seekMovie(newDuration);
        await socketProvider!.pauseMovie();
      }
    }
  }

  ///Синхронизация времени +-500ms
  Future<void> handleSessionSyncTime(dynamic data) async {
    if (!socketProvider!.checkLeader() && socketProvider!.currentSession != null) {
      int leaderMSecond = int.parse(data[0].toString());
      String sessionId = data[1].toString();
      if (socketProvider!.currentSession!.sessionId == sessionId) {
        if (socketProvider!.currentMSeconds > leaderMSecond + 500 || socketProvider!.currentMSeconds < leaderMSecond - 500) {
          //await socketProvider!.player.seek(Duration(milliseconds: leaderMSecond));
        }
      }
    }
  }
}
