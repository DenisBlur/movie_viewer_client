import 'package:flutter/material.dart';
import 'package:movie_viewer/data/common.dart';

var movieCardW = 200.0;
var movieCardH = 350.0;

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
            if(widget.movie.coverUrl != null)
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
