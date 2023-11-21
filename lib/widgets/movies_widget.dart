import 'package:flutter/material.dart';
import 'package:movie_viewer/model/movie_provider.dart';
import 'package:provider/provider.dart';

import '../data/common.dart';

double movieCardW = 170 * 1.25;
double movieCardH = 245 * 1.25;

class MoviesSelectWidget extends StatefulWidget {
  const MoviesSelectWidget({super.key, required this.callback});

  final VoidCallback callback;

  @override
  State<MoviesSelectWidget> createState() => _MoviesSelectWidgetState();
}

class _MoviesSelectWidgetState extends State<MoviesSelectWidget> {

  bool startup = true;

  @override
  void initState() {
    loadContent();
    super.initState();
  }

  loadContent() async {
    MovieProvider mp = context.read();
    if(startup) {
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

        return SizedBox(
          width: MediaQuery.of(context).size.width/2,
          height: MediaQuery.of(context).size.height/2,
          child: Column(
            children: [
              TextField(
                decoration: const InputDecoration(
                  label: Text("Поиск"),
                  hintText: "введите название",
                ),
                onSubmitted: (value) {

                },
              ),
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
                                movie: movie, callback: widget.callback,
                              );
                            },
                            itemCount: mp.movies.length,
                            gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                                maxCrossAxisExtent: movieCardW, crossAxisSpacing: 16, mainAxisSpacing: 16, mainAxisExtent: movieCardH),
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

class MovieItem extends StatefulWidget {
  const MovieItem({super.key, required this.movie, required this.callback});

  final VoidCallback callback;
  final Movie movie;

  @override
  State<MovieItem> createState() => _MovieItemState();
}

class _MovieItemState extends State<MovieItem> {
  bool isHover = false;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      hoverColor: Colors.transparent,
      onTap: () async {
        widget.callback();
      },
      onHover: (value) {
        isHover = value;
        setState(() {});
      },
      child: SizedBox(
        width: movieCardW,
        height: movieCardH,
        child: Stack(
          children: [
            ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  widget.movie.coverUrl!,
                  fit: BoxFit.cover,
                  width: movieCardW,
                  height: movieCardH,
                )),
            AnimatedContainer(
              duration: const Duration(milliseconds: 650),
              curve: Curves.fastEaseInToSlowEaseOut,
              width: movieCardW,
              height: movieCardH,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  gradient: LinearGradient(
                      colors: [Colors.black.withOpacity(isHover ? .8 : .5), Colors.black.withOpacity(isHover ? .8 : 0)],
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter)),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.end,
                mainAxisSize: MainAxisSize.max,
                children: [
                  Text(
                    widget.movie.title!,
                    style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                    textAlign: TextAlign.center,
                  ),
                  if(widget.movie.year != null)
                  Text(
                    widget.movie.year!,
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                  Row(
                    children: [
                      if (widget.movie.kp != null && widget.movie.kp != "")
                        const Text(
                          "KP ",
                          style: TextStyle(color: Colors.orange, fontSize: 16, fontWeight: FontWeight.w600),
                          textAlign: TextAlign.center,
                        ),
                      if(widget.movie.kp != null)
                      Text(
                        widget.movie.kp!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      if (widget.movie.imdb != "" && widget.movie.kp != "") const Expanded(child: SizedBox()),
                      if (widget.movie.imdb != "")
                        const Text(
                          "IMDB ",
                          style: TextStyle(color: Colors.yellow, fontSize: 16, fontWeight: FontWeight.w600),
                          textAlign: TextAlign.center,
                        ),
                      if(widget.movie.imdb != null)
                      Text(
                        widget.movie.imdb!,
                        style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
