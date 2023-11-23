class Update {
  String titleUpdate;
  String imageUrl;
  List<String>? innovations;
  List<String>? deleted;
  List<String>? corrections;
  String version;

  Update({required this.titleUpdate, required this.imageUrl, required this.version, this.innovations, this.deleted, this.corrections});
}

List<Update> updates = [
  Update(
      titleUpdate: "Первый запуск",
      imageUrl: "https://cdn.dribbble.com/users/26059/screenshots/2471563/media/f4162cb1f11aaf4413ba50453b8c053e.jpg",
      version: '1.0.0',
      innovations: [
        "Поддержка YouTube видео",
        "Каталог фильмов",
        "Новый дизайн",
        "Новый плеер",
        "Сессии",
      ],
      deleted: [
        "Удален старый плеер",
      ],
      corrections: [
        "Исправление ошибок"
      ]),
];
