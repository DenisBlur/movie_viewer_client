import 'package:flutter/material.dart';
import 'package:movie_viewer/model/sites/movie_provider.dart';
import 'package:provider/provider.dart';

import '../data/common.dart';

class CustomMovieFinder extends StatefulWidget {
  const CustomMovieFinder({super.key});

  @override
  State<CustomMovieFinder> createState() => _CustomMovieFinderState();
}

class _CustomMovieFinderState extends State<CustomMovieFinder> {
  TextEditingController textEditingController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MovieProvider>(
      builder: (context, mp, child) {
        return SizedBox(
          width: MediaQuery.of(context).size.width / 2,
          height: MediaQuery.of(context).size.height / 2,
          child: Column(
            children: [
              TextField(
                controller: textEditingController,
                onSubmitted: (value) {
                  var movie = Movie(title: "Custom", coverUrl: "https://tvv.kinolord.click/uploads/posts/2023-11/temnye-vody.webp", imdb: "0", kp: "0", pageUrl: value,  year: "2077");
                  mp.getMovieStreamLink(movie: movie);
                },
              ),
              if (mp.loading) const LinearProgressIndicator(),
              if (mp.variants != null)
                for (var i in mp.variants!)
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      mp.setMovie(i.url.toString());
                    },
                    child: Text("${i.format.width}x${i.format.height}"),
                  ),
            ],
          ),
        );
      },
    );
  }
}
