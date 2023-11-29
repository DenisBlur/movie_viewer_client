import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hls_parser/flutter_hls_parser.dart';
import 'package:html/parser.dart';
import 'package:http/http.dart' as http;
import 'package:movie_viewer/model/socket/socket_provider.dart';

import '../../data/common.dart';

class MovieProvider extends ChangeNotifier {
  MovieProvider({required this.socketProvider});

  SocketProvider socketProvider;
  String movieBaseDataLink = "https://kinoka.ru";
  List<Movie> _movies = [];
  bool _loading = false;
  PageController controller = PageController();
  List<Variant>? variants;

  Movie? selectedMovie;

  bool get loading => _loading;

  List<Movie> get movies => _movies;

  set loading(bool value) {
    _loading = value;
    notifyListeners();
  }

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

  Future<void> setMovie(String streamLink) async {
    socketProvider.setSessionFilm(selectedMovie!, streamLink, null);
  }

  void getMovieStreamLink({required Movie movie, bool scroll = true}) {
    loading = true;
    socketProvider.socket!.emit("user_get_movie_link", movie.pageUrl);
    socketProvider.socket!.once("user_get_movie_link", (data) async {

      if(scroll) {
        controller.animateToPage(1, duration: const Duration(milliseconds: 650), curve: Curves.fastEaseInToSlowEaseOut);
      }
      try {
        var playList = await HlsPlaylistParser.create().parseString(Uri.parse(data["url"]), data["responseBody"]) as HlsMasterPlaylist;
        variants = playList.variants;
        selectedMovie = movie;



        notifyListeners();
      } on ParserException catch (e) {
        print(e);
      }

      loading = false;
    });
  }

  void searchMovie(String value) {
    controller.animateToPage(0, duration: const Duration(milliseconds: 650), curve: Curves.fastEaseInToSlowEaseOut);
    loading = true;
    socketProvider.socket!.emit("user_search_movie", value);
    socketProvider.socket!.once("user_search_movie", (data) async {
      movies = await _getMoviesOnPage(data);
      loading = false;
    });
  }
}
