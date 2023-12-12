import 'package:flutter/material.dart';
import 'package:movie_viewer/model/sites/movie_provider.dart';
import 'package:movie_viewer/widgets/items/movie_item.dart';
import 'package:provider/provider.dart';

import '../data/common.dart';

double movieCardW = 170 * 1.25;
double movieCardH = 245 * 1.25;

class BaseMovieFinder extends StatefulWidget {
  const BaseMovieFinder({super.key});

  @override
  State<BaseMovieFinder> createState() => _BaseMovieFinderState();
}

class _BaseMovieFinderState extends State<BaseMovieFinder> {
  bool startup = true;

  TextEditingController textEditingController = TextEditingController();

  @override
  void initState() {
    loadContent();
    super.initState();
  }

  loadContent() async {
    MovieProvider mp = context.read();
    if (startup) {
      await mp.getMoviesPage(1, false);
      await mp.getMoviesPage(2, true);
      await mp.getMoviesPage(3, true);
      await mp.getMoviesPage(4, true);
      await mp.getMoviesPage(5, true);
      startup = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MovieProvider>(
      builder: (context, mp, child) {
        return Container(
          padding: const EdgeInsets.all(16),
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: Column(
            children: [
              TextField(
                controller: textEditingController,
                decoration: const InputDecoration(
                  label: Text("Поиск фильма"),
                  hintText: "...",
                ),
                onSubmitted: (value) {
                  mp.searchMovie(value);
                },
              ),
              if (mp.loading) const LinearProgressIndicator(),
              Expanded(child: ClipRRect(
                child: CustomScrollView(
                  slivers: [
                    if (mp.movies.isNotEmpty)
                      SliverPadding(
                        padding: const EdgeInsets.only(top: 16),
                        sliver: SliverGrid.builder(
                          itemBuilder: (context, index) {
                            Movie movie = mp.movies[index];
                            return MovieItem(
                              movie: movie,
                              callback: () {
                                mp.getMovieStreamLink(movie: movie);
                              },
                            );
                          },
                          itemCount: mp.movies.length,
                          gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                              maxCrossAxisExtent: movieCardW, crossAxisSpacing: 16, mainAxisSpacing: 16, mainAxisExtent: movieCardH),
                        ),
                      ),
                  ],
                ),
              ),),
            ],
          ),
        );
      },
    );
  }
}
