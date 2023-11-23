import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:html/parser.dart';
import 'package:http/http.dart' as http;
import 'package:movie_viewer/model/socket/socket_provider.dart';

import '../../data/common.dart';

class MovieProvider extends ChangeNotifier {
  MovieProvider({required this.socketProvider});

  SocketProvider socketProvider;
  String movieBaseDataLink = "https://kinoka.ru";
  List<Movie> _movies = [];
  List<Movie> get movies => _movies;

  set movies(List<Movie> value) {
    _movies = value;
    notifyListeners();
  }

  Future<void> getMoviesPage(int pageIndex, bool addMore) async {
    List<Movie> localMovies = [];

    if (addMore) {
      localMovies = movies;
    } else {
      movies.clear();
    }

    var response = await http.get(Uri.parse("$movieBaseDataLink/films/page/$pageIndex/"));

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
        coverUrl = "$movieBaseDataLink${element.querySelector("img")!.attributes["src"].toString()}";
      }

      localMovies.add(Movie(pageUrl: pageUrl, coverUrl: coverUrl, kp: kp, imdb: imdb, title: title, year: year));
    }

    return localMovies;
  }

  void getMovieStreamLink(Movie movie) {
    socketProvider.socket.emit("user_get_movie_link", movie.pageUrl);
  }
}
