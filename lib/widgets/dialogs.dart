import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:movie_viewer/model/socket/socket_provider.dart';
import 'package:movie_viewer/widgets/youtube_widget.dart';
import 'package:provider/provider.dart';

import '../data/common.dart';
import 'hq_movies_widget.dart';

Future<void> showMyDialog(BuildContext context) async {
  TextEditingController controller = TextEditingController(text: "");

  return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.movie_creation_rounded, size: 36),
              SizedBox(
                width: 16,
              ),
              Text(
                "Фильм",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: SizedBox(
            width: 450,
            child: TextField(
              controller: controller,
              decoration: const InputDecoration(
                label: Text("Ссылка"),
                hintText: "http://.....",
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Отмена'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Отправить'),
              onPressed: () {
                Navigator.of(context).pop();
                //context.read<SocketProvider>().sendMovie(controller.text);
              },
            ),
          ],
        );
      });
}

Future<void> findMovie(BuildContext context) async {
  return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.movie_creation_rounded, size: 36),
              SizedBox(
                width: 16,
              ),
              Text(
                "Имя",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: const BaseMovieFinder(),
          actions: <Widget>[
            TextButton(
              child: const Text('Отмена'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      });
}

Future<void> changeNameDialog(BuildContext context) async {
  TextEditingController controller = TextEditingController(text: "");



  return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.movie_creation_rounded, size: 36),
              SizedBox(
                width: 16,
              ),
              Text(
                "Имя",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: SizedBox(
            width: 450,
            child: TextField(
              controller: controller,
              decoration: const InputDecoration(
                label: Text("Имя пользователя"),
                hintText: "user...",
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Отмена'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Отправить'),
              onPressed: () {
                Navigator.of(context).pop();
                context.read<SocketProvider>().changeUsername(controller.text);
              },
            ),
          ],
        );
      });
}

Future<void> youtubeVideoDialog(BuildContext context) async {
  TextEditingController urlController = TextEditingController(text: "");

  return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.movie_creation_rounded, size: 36),
              SizedBox(
                width: 16,
              ),
              Text(
                "YouTube",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: YoutubeWidget(urlController: urlController,),
        );
      });
}

Future<void> createFilmDialog(BuildContext context) async {
  TextEditingController movieNameController = TextEditingController(text: "");
  TextEditingController movieYearController= TextEditingController(text: "");
  TextEditingController movieLinkController = TextEditingController(text: "");

  return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.movie_creation_rounded, size: 36),
              SizedBox(
                width: 16,
              ),
              Text(
                "Создание сессии",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: Column(
            children: [
              SizedBox(
                width: 450,
                child: TextField(
                  controller: movieNameController,
                  decoration: const InputDecoration(
                    label: Text("Название фильма"),
                  ),
                ),
              ),
              SizedBox(
                width: 450,
                child: TextField(
                  controller: movieYearController,
                  decoration: const InputDecoration(
                    label: Text("Год выпуска"),
                  ),
                ),
              ),
              SizedBox(
                width: 450,
                child: TextField(
                  controller: movieLinkController,
                  decoration: const InputDecoration(
                    label: Text("ссылка на фильм"),
                  ),
                ),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Отмена'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Отправить'),
              onPressed: () {
                Navigator.of(context).pop();
                context.read<SocketProvider>().setSessionFilm(Movie(pageUrl: null, coverUrl: null, kp: null, imdb: null, title: movieNameController.text, year: movieYearController.text), movieLinkController.text, null);
              },
            ),
          ],
        );
      });
}

Future<void> createSessionDialog(BuildContext context) async {
  TextEditingController sessionNameController = TextEditingController(text: "Сессия");
  TextEditingController userMaxController = TextEditingController(text: "8");

  return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.movie_creation_rounded, size: 36),
              SizedBox(
                width: 16,
              ),
              Text(
                "Создание сессии",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: SizedBox(
            height: 150,
            child: Column(
              children: [
                SizedBox(
                  width: 450,
                  child: TextField(
                    controller: sessionNameController,
                    decoration: const InputDecoration(
                      label: Text("Название сессии"),
                    ),
                  ),
                ),
                SizedBox(
                  width: 450,
                  child: TextField(
                    controller: userMaxController,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: const InputDecoration(
                      label: Text("Максимальное кол-во пользователей"),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Отмена'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Отправить'),
              onPressed: () {
                Navigator.of(context).pop();
                context.read<SocketProvider>().createSession(sessionNameController.text, int.parse(userMaxController.text));
              },
            ),
          ],
        );
      });
}
