import 'package:flutter/cupertino.dart';
import 'package:html/parser.dart';
import 'package:http/http.dart' as http;
import 'package:movie_viewer/model/socket/socket_provider.dart';
import '../data/common.dart';

class HQMovieProvider extends ChangeNotifier {

  HQMovieProvider({required this.socketProvider});

  SocketProvider socketProvider;
  String movieLink = "https://hds.4kfilm.click";
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

    var response = await http.get(Uri.parse("$movieLink/filmi-4k/page/$pageIndex/"));

    localMovies.addAll(await _getMoviesOnPage(response.body));
    movies = localMovies;
  }

  Future<List<Movie>> _getMoviesOnPage(String body) async {
    List<Movie> localMovies = [];

    var document = parse(body);
    var movieItems = document.getElementsByClassName("krat123");

    for (var element in movieItems) {
      String title = "", pageUrl = "", coverUrl = "";

      if (element.querySelector(".krat123-title") != null) {
        title = element.querySelector(".krat123-title")!.text;
      }
      if (element.querySelector(".with-mask") != null) {
        pageUrl = element.querySelector(".with-mask")!.attributes["href"].toString();
      }
      if (element.querySelector("img") != null) {
        coverUrl = "$movieLink${element.querySelector("img")!.attributes["src"].toString()}";
      }

      localMovies.add(Movie(pageUrl: pageUrl, coverUrl: coverUrl, kp: null, imdb: null, title: title, year: null));
    }

    return localMovies;
  }


}
