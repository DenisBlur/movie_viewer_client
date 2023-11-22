import 'dart:convert';

import 'package:movie_viewer/data/common.dart';
import 'package:movie_viewer/model/socket/socket_provider.dart';

class UserHandlers {

  SocketProvider? socketProvider;


  UserHandlers({required this.socketProvider});

  ///Создание пользователя на сервере и на клиенте
  void handleUserCreate(dynamic data) {
    socketProvider!.currentUser = User.fromJson(jsonDecode(data));
  }

  ///Смена username
  void handleUserChangeUsername(dynamic data) {
    //Смотрим не NULL ли наш пользователь
    if (socketProvider!.currentUser != null) {
      //Получаем данные пользователя с сервера
      User localUser = User.fromJson(jsonDecode(data));
      //Если это мы то меняем имя пользователя
      if (socketProvider!.currentUser!.id == localUser.id) {
        socketProvider!.currentUser!.username = localUser.username;
      }
      //Если мы находимся в сессии
      if (socketProvider!.currentSession != null) {
        //То ищем нужного нам пользователя по ID и заменяем
        for (var user in socketProvider!.currentSession!.connectedUsers!) {
          if(user.id == localUser.id) {
            var index = socketProvider!.currentSession!.connectedUsers!.indexOf(user);
            socketProvider!.currentSession!.connectedUsers![index] = localUser;
            socketProvider!.notifyListeners();
            return;
          }
        }
      }
    }
    socketProvider!.notifyListeners();
  }


}