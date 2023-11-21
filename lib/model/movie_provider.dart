import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:html/parser.dart';
import 'package:http/http.dart' as http;
import 'package:movie_viewer/model/socket_provider.dart';

import '../data/common.dart';

class MovieProvider extends ChangeNotifier {
  MovieProvider({required this.socketProvider});

  SocketProvider socketProvider;

  String movieLink = "https://kino.lordfilm24.site";

  Movie? selectMovie;

  List<Movie> _movies = [];

  List<String> blockLinks = [
    "aj1907.online",
    "cdn3.vb17123filippaaniketos.pw",
    "mc.yandex.ru",
    "pc.playjusting.com",
    "mc.webvisor.org",
    "stats.getaim.org",
    "4251.tech",
    "vast.playmatic.video",
  ];


  bool isInitAlready = false;

  List<Movie> get movies => _movies;

  set movies(List<Movie> value) {
    _movies = value;
    notifyListeners();
  }

  List<Resolution> _resolutionLinks = [];

  List<Resolution> get resolutionLinks => _resolutionLinks;

  set resolutionLinks(List<Resolution> value) {
    _resolutionLinks = value;
    notifyListeners();
  }

  Future<void> getMoviesPage(int pageIndex, bool addMore) async {
    List<Movie> localMovies = [];

    if (addMore) {
      localMovies = movies;
    } else {
      movies.clear();
    }

    var response = await http.get(Uri.parse("$movieLink/filmi/page/$pageIndex/"));

    localMovies.addAll(await _getMoviesOnPage(response.body));
    movies = localMovies;
  }

  Future<List<Movie>> _getMoviesOnPage(String body) async {
    List<Movie> localMovies = [];

    var document = parse(body);
    var movieItems = document.getElementsByClassName("th-item");

    for (var element in movieItems) {
      String title = "", year = "", kp = "", imdb = "", pageUrl = "", coverUrl = "";

      if (element.querySelector(".th-title") != null) {
        title = element.querySelector(".th-title")!.text;
      }
      if (element.querySelector(".th-year") != null) {
        year = element.querySelector(".th-year")!.text;
      }
      if (element.querySelector(".th-rate-kp") != null) {
        kp = element.querySelector(".th-rate-kp")!.text;
      }
      if (element.querySelector(".th-rate-imdb") != null) {
        imdb = element.querySelector(".th-rate-imdb")!.text;
      }
      if (element.querySelector(".with-mask") != null) {
        pageUrl = element.querySelector(".with-mask")!.attributes["href"].toString();
      }
      if (element.querySelector("img") != null) {
        coverUrl = "$movieLink${element.querySelector("img")!.attributes["data-src"].toString()}";
      }

      localMovies.add(Movie(pageUrl: pageUrl, coverUrl: coverUrl, kp: kp, imdb: imdb, title: title, year: year));
    }

    return localMovies;
  }

  Future<List<Resolution>> getResolution(String link) async {
    ///Получение всех возможных разрешений

    List<Resolution> resolutions = [];

    if (link != "") {
      var response = await http.get(Uri.parse(link));
      var resSplits = response.body.split("#");

      for (var element in resSplits) {
        if (!element.contains("hls")) {
          if (element.contains("/")) {
            var resName = element.substring(element.indexOf("/"), element.length);
            resolutions.add(Resolution(title: resName, url: link.replaceAll("/index.m3u8", resName)));
          }
        } else {
          var resName = element.substring(element.indexOf("hls"), element.length);
          resolutions.add(Resolution(title: '/$resName', url: link.replaceAll("/index.m3u8", "/$resName")));
        }
      }
    }

    if (selectMovie != null) {
      socketProvider.setSessionFilm(selectMovie!, resolutions[resolutions.length - 1].url!, null);
      selectMovie = null;
    }

    return resolutions;
  }

  Future<String?> getMovieLink(String link) async {
    ///Получение HTML страницы фильмы, для получения ссылки на плеер
    var response = await http.get(Uri.parse(link));
    var document = parse(response.body);
    var videoBox = document.querySelector(".tabs-b");
    return videoBox!.attributes["data-src"];
  }
}
