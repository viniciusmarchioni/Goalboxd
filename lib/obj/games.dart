import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class Complements {
  late String? urlImage;
  late String? colorTeam;

  Complements(this.urlImage, this.colorTeam);

  Complements.fromJson(Map<String, dynamic> json)
      : colorTeam = json['color'],
        urlImage = json['url_image'];

  static Future<Complements> getTeam(String name) async {
    try {
      final response =
          await http.get(Uri.parse('${dotenv.env['API_URL']}/teams/$name'));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return Complements.fromJson(data);
      } else {
        return Complements(null, null);
      }
    } catch (e) {
      return Complements(null, null);
    }
  }
}

GameType _toGameType(String type) {
  if (type == 'futebol') {
    return GameType.football;
  }
  return GameType.basquete;
}

enum GameType { football, basquete }

class Games {
  GameType? type;
  String? team1name;
  String? team2name;
  int? team1score;
  int? team2score;
  int? id;
  String? country1;
  String? country2;
  DateTime? date;
  String? championship;
  double? rate;

  Games.fromJsonAll(Map<String, dynamic> json)
      : id = json['id'],
        team1name = json['team1'],
        team2name = json['team2'],
        team1score = json['score1'],
        team2score = json['score2'],
        country1 = json['country1'],
        country2 = json['country2'],
        date = DateTime.parse(json['date']),
        championship = json['championship'],
        rate = double.parse(json['rate']),
        type = _toGameType(json['type']);

  Games.fromJsonProfile(Map<String, dynamic> json)
      : id = json['id'],
        team1name = json['team1'],
        team2name = json['team2'],
        team1score = json['score1'],
        team2score = json['score2'];

  String scorebord() {
    return "${team1score ?? ''} x ${team2score ?? ''}";
  }
}

class GamesRepository extends ChangeNotifier {
  List<Games> games = [];
  List<Games> now = [];
  List<Games> today = [];

  Future<void> updateRise() async {
    try {
      final response = await http
          .get(Uri.parse('${dotenv.env['API_URL']}/games/rise'))
          .timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        games = [];
        for (var i in jsonDecode(response.body)) {
          games.add(Games.fromJsonAll(i));
        }
      } else {
        debugPrint("Erro");
        games = [];
      }
    } catch (e) {
      debugPrint("Erro");
      games = [];
    } finally {
      notifyListeners();
    }
  }

  Future<void> updateNow() async {
    try {
      final response = await http
          .get(Uri.parse('${dotenv.env['API_URL']}/games/now'))
          .timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        now = [];
        for (var i in jsonDecode(response.body)) {
          now.add(Games.fromJsonAll(i));
        }
      } else {
        debugPrint("Erro");
        now = [];
      }
    } catch (e) {
      debugPrint("Erro");
      now = [];
    } finally {
      notifyListeners();
    }
  }

  Future<void> updateToday() async {
    try {
      final response = await http
          .get(Uri.parse('${dotenv.env['API_URL']}/games/today'))
          .timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        today = [];
        for (var i in jsonDecode(response.body)) {
          today.add(Games.fromJsonAll(i));
        }
      } else {
        debugPrint("Erro");
        today = [];
      }
    } catch (e) {
      debugPrint("Erro");
      today = [];
    } finally {
      notifyListeners();
    }
  }

  GamesRepository();
}
