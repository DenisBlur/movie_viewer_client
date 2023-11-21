import 'dart:convert';

class TagResponse {
  String? tag;
  dynamic data;

  TagResponse({required this.tag, this.data});

  Map toJson() {
    Map map = {};
    map["tag"] = tag;
    map["data"] = data;
    return map;
  }

  TagResponse.fromJson(Map<String, dynamic> json) {
    tag = json["tag"];
    data = json["data"];
  }
}

class User {
  String? id;
  String? username;

  User({required this.id, required this.username});

  String toJson() {
    Map map = {};
    map["id"] = id;
    map["username"] = username;
    return jsonEncode(map);
  }

  User.fromJson(Map<String, dynamic> json) {
    id = json["id"];
    username = json["username"];
  }
}

class Error {
  String? title;
  String? body;

  Error({required this.title, required this.body});

  String toJson() {
    Map map = {};
    map["title"] = title;
    map["body"] = body;
    return jsonEncode(map);
  }

  Error.fromJson(Map<String, dynamic> json) {
    title = json["title"];
    body = json["body"];
  }
}

class Session {
  String? sessionId;
  String? sessionName;
  int? maxUsers;
  String? ownerSessionID;
  List<User>? connectedUsers;

  Movie? currentMovie;
  String? audioLink;
  String? streamLink;
  Map<String, String>? headers;

  Session({required this.sessionId, required this.sessionName, required this.maxUsers, required this.ownerSessionID, required this.currentMovie, required this.streamLink, this.audioLink, this.headers});

  String toJson() {
    Map map = {};
    map["sessionId"] = sessionId;
    map["sessionName"] = sessionName;
    map["maxUser"] = maxUsers;
    map["ownerSessionID"] = ownerSessionID;
    map["connectedUsers"] = jsonEncode(connectedUsers);
    map["currentMovie"] = currentMovie == null ? "null" : currentMovie!.toJson();
    map["streamLink"] = streamLink;
    map["audioLink"] = audioLink;
    map["headers"] = jsonEncode(headers);
    return jsonEncode(map);
  }

  Session.fromJson(Map<String, dynamic> json) {
    sessionId = json["sessionId"];
    sessionName = json["sessionName"];
    maxUsers = json["maxUser"];
    ownerSessionID = json["ownerSessionID"];
    connectedUsers = [];
    if (json["connectedUsers"] != "null") {
      if (json["connectedUsers"] != null) {
        var list = json["connectedUsers"] ?? [];
        if (list.isNotEmpty) {
          for (var v in list) {
            connectedUsers!.add(User.fromJson(v));
          }
        }
      }
    }
    if(json["currentMovie"] != null && json["currentMovie"] != "null") {
      currentMovie = Movie.fromJson(jsonDecode(json["currentMovie"]));
    } else {
      currentMovie = null;
    }
    streamLink = json["streamLink"];
    audioLink = json["audioLink"];
    if(json["headers"] != null && json["headers"] != "null") {

      print(json["headers"]);

      headers = {};
      Map<String, dynamic> j = jsonDecode(json["headers"]);
      j.forEach((key, value) {
        headers![key] = value.toString();
      });

    }
  }
}

class Resolution {
  String? title;
  String? url;

  Resolution({required this.title, required this.url});
}

class Movie {
  String? pageUrl;
  String? coverUrl;
  String? kp;
  String? imdb;
  String? title;
  String? year;

  Movie({required this.pageUrl, required this.coverUrl, required this.kp, required this.imdb, required this.title, required this.year});

  Movie.fromJson(Map<String, dynamic> json) {
    pageUrl = json["pageUrl"];
    coverUrl = json["coverUrl"];
    kp = json["kp"];
    imdb = json["imdb"];
    title = json["title"];
    year = json["year"];
  }

  String toJson() {
    Map map = {};
    map["pageUrl"] = pageUrl;
    map["coverUrl"] = coverUrl;
    map["kp"] = kp;
    map["imdb"] = imdb;
    map["title"] = title;
    map["year"] = year;
    return jsonEncode(map);
  }

}
