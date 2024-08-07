import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Games {
  late GameType type;
  late String team1name;
  late String team2name;
  late int? team1score;
  late int? team2score;
  late int id;
  late String? country1;
  late String? country2;
  late DateTime date;
  late String championship;
  late double rate;

  Games(
      this.type,
      this.id,
      this.team1name,
      this.team2name,
      this.team1score,
      this.team2score,
      this.country1,
      this.country2,
      this.date,
      this.championship,
      this.rate);

  String scorebord() {
    return "${team1score ?? ''} x ${team2score ?? ''}";
  }

  Games.fromJson(Map<String, dynamic> json)
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

  Games.forProfile(Map<String, dynamic> json)
      : id = json['id'],
        team1name = json['team1'],
        team2name = json['team2'],
        team1score = json['score1'],
        team2score = json['score2'];

  static Future<List<Games>> getRiseGames() async {
    try {
      final response = await http
          .get(Uri.parse('${dotenv.env['API_URL']}/games/rise'))
          .timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        List<Games> games = [];
        for (var i in jsonDecode(response.body)) {
          games.add(Games.fromJson(i));
        }
        return games;
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  static Future<List<Games>> getNowGames() async {
    try {
      final response = await http
          .get(Uri.parse('${dotenv.env['API_URL']}/games/now'))
          .timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        List<Games> games = [];
        for (var i in jsonDecode(response.body)) {
          games.add(Games.fromJson(i));
        }
        return games;
      } else {
        return [];
      }
    } on TimeoutException {
      return [];
    } catch (e) {
      return [];
    }
  }

  static Future<List<Games>> getTodayGames() async {
    try {
      final response = await http
          .get(Uri.parse('${dotenv.env['API_URL']}/games/today'))
          .timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        List<Games> games = [];
        for (var i in jsonDecode(response.body)) {
          games.add(Games.fromJson(i));
        }
        return games;
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  static Future<bool> postReview(int grade, int gameid) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final response = await http.post(
        Uri.parse('${dotenv.env['API_URL']}/games/review'),
        body: jsonEncode(
            {'userid': prefs.getInt('id'), 'gameid': gameid, 'grade': grade}),
        headers: {
          "Accept": "application/json",
          "content-type": "application/json"
        },
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        return true;
      } else {
        debugPrint('----------------ERRO------------');
        return false;
      }
    } on TimeoutException {
      debugPrint('----------------TIMEOUT------------');
      return false;
    } catch (e) {
      return false;
    }
  }

  static Future<int> getReview(int gameid) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final response = await http.get(Uri.parse(
          '${dotenv.env['API_URL']}/games/review/$gameid/${prefs.getInt('id')}'));
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return data['grade'];
      } else {
        return 0;
      }
    } catch (e) {
      return 0;
    }
  }
}

class GamesRepository {
  List<Games> games = [];

  Future<void> init(String endpoint) async {
    try {
      final response = await http
          .get(Uri.parse('${dotenv.env['API_URL']}$endpoint'))
          .timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        games = [];
        for (var i in jsonDecode(response.body)) {
          games.add(Games.fromJson(i));
        }
      } else {
        debugPrint("Erro");
        games = [];
      }
    } catch (e) {
      debugPrint("Erro");
      games = [];
    }
  }

  GamesRepository();
}

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
