import 'package:dart_vlc/dart_vlc.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:movie_viewer/model/socket/socket_provider.dart';
import 'package:movie_viewer/widgets/tabs/tab_movie_viewer.dart';
import 'package:provider/provider.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:xml/xml.dart' as xml;


Future<void> getStreamLinks(String mpdUrl) async {
  try {
    // Fetch MPD file
    var response = await http.get(Uri.parse(mpdUrl));

    if (response.statusCode == 200) {
      // Parse MPD XML
      var document = xml.XmlDocument.parse(response.body);

      // Extract BaseURL
      var baseUrls = document.findAllElements('BaseURL');
      if (baseUrls.isNotEmpty) {
        var baseUrl = baseUrls.last.text;
        var baseUrl2 = baseUrls.first.text;

        // Iterate through AdaptationSets
        var adaptationSets = document.findAllElements('AdaptationSet');
        for (var adaptationSet in adaptationSets) {
          // Iterate through Representations
          var representations = adaptationSet.findAllElements('Representation');
          for (var representation in representations) {
            // Extract SegmentTemplate attributes
            var segmentTemplate = representation.findElements('SegmentTemplate').first;
            var initialization = segmentTemplate.getAttribute('initialization');
            var media = segmentTemplate.getAttribute('media');

            // Extract stream link
            var streamInitLink = '$baseUrl$initialization';
            var streamMediaLink = '$baseUrl$media';
          }
        }
      } else {
        print('BaseURL not found in MPD.');
      }
    } else {
      print('Failed to fetch MPD file. Status code: ${response.statusCode}');
    }
  } catch (e) {
    print('Error: $e');
  }
}


class TestScreen extends StatefulWidget {
  const TestScreen({super.key});

  @override
  State<TestScreen> createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Column(
      children: [
        FilledButton(onPressed: () async {

          getStreamLinks("https://hye1eaipby4w.takedwn.ws/x-en-x/khqakvA3Ya8xRy8aRa8xkn8xRC9BABzanExRnn8xRhL0RhL4Yr1cSD==");
          context.read<SocketProvider>().player.errorStream.listen((event) {
            print(event);
          });
          context.read<SocketProvider>().player.open(Media.network("https://hye1eaipby4w.takedwn.ws/x-en-x/khqakvA3Ya8xRy8aRa8xkn8xRC9BABzanExRnn8xRhL0RhL4Yr1cSD==", parse: true));

        }, child: const Text("Тестовая кнопка")),
        Expanded(child: PageView(children: [
          TabMovieViewer()
        ],))
      ],
    ));
  }
}

