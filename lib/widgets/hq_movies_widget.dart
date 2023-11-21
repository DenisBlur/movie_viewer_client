import 'package:flutter/material.dart';
import 'package:movie_viewer/model/hq_movie_provider.dart';
import 'package:movie_viewer/model/movie_provider.dart';
import 'package:provider/provider.dart';

import '../data/common.dart';
import 'movies_widget.dart';

double movieCardW = 170 * 1.25;
double movieCardH = 245 * 1.25;

class HQSelectWidget extends StatefulWidget {
  const HQSelectWidget({super.key});

  @override
  State<HQSelectWidget> createState() => _HQSelectWidgetState();
}

class _HQSelectWidgetState extends State<HQSelectWidget> {
  bool startup = true;

  @override
  void initState() {
    loadContent();
    super.initState();
  }

  loadContent() async {
    HQMovieProvider mp = context.read();
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
    return Consumer<HQMovieProvider>(
      builder: (context, mp, child) {
        return SizedBox(
          width: MediaQuery.of(context).size.width / 2,
          height: MediaQuery.of(context).size.height / 2,
          child: Column(
            children: [
              Expanded(
                child: ClipRRect(
                  child: CustomScrollView(
                    slivers: [
                      if (mp.movies.isNotEmpty)
                        SliverPadding(
                          padding: const EdgeInsets.all(16),
                          sliver: SliverGrid.builder(
                            itemBuilder: (context, index) {
                              Movie movie = mp.movies[index];
                              return MovieItem(
                                movie: movie,
                                callback: () {
                                  mp.setMovie(movie);
                                  Navigator.pop(context);
                                },
                              );
                            },
                            itemCount: mp.movies.length,
                            gridDelegate:
                                SliverGridDelegateWithMaxCrossAxisExtent(
                                    maxCrossAxisExtent: movieCardW,
                                    crossAxisSpacing: 16,
                                    mainAxisSpacing: 16,
                                    mainAxisExtent: movieCardH),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
