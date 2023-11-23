import 'package:flutter/material.dart';
import 'package:movie_viewer/data/update.dart';
import 'package:transparent_image/transparent_image.dart';

class UpdateItem extends StatelessWidget {
  const UpdateItem({super.key, required this.update});

  final Update update;

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Center(
            child: Container(
      padding: const EdgeInsets.all(16),
      width: 400,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), color: Theme.of(context).colorScheme.secondaryContainer.withOpacity(.1)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: FadeInImage.memoryNetwork(
              placeholder: kTransparentImage,
              image: update.imageUrl,
              height: 250,
              width: 400,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(
            height: 8,
          ),
          Text(
            update.titleUpdate,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(
            height: 16,
          ),
          if (update.innovations != null) const Text("Что нового:"),
          if (update.innovations != null)
            for (var i in update.innovations!)
              Text(
                "  -$i",
                style: TextStyle(color: Theme.of(context).textTheme.titleLarge!.color!.withOpacity(.6)),
              ),
          if (update.deleted != null)
            const SizedBox(
              height: 8,
            ),
          if (update.deleted != null) const Text("Что удалено:"),
          if (update.innovations != null)
            for (var i in update.deleted!)
              Text(
                "  -$i",
                style: TextStyle(color: Theme.of(context).textTheme.titleLarge!.color!.withOpacity(.6)),
              ),
          if (update.corrections != null)
            const SizedBox(
              height: 8,
            ),
          if (update.corrections != null) const Text("Исправления:"),
          if (update.corrections != null)
            for (var i in update.corrections!)
              Text(
                "  -$i",
                style: TextStyle(color: Theme.of(context).textTheme.titleLarge!.color!.withOpacity(.6)),
              ),
          const SizedBox(
            height: 8,
          ),
          Text("Версия: ${update.version}")
        ],
      ),
    )));
  }
}
