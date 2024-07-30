import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:goalboxd/obj/comments.dart';
import 'package:goalboxd/obj/games.dart';
import 'package:goalboxd/obj/user.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Requests {
  static const String _baseUrl = 'http://10.0.2.2:5000';

  static Future<List<dynamic>> _fetchData(String endpoint) async {
    try {
      final response = await http
          .get(Uri.parse('$_baseUrl/$endpoint'))
          .timeout(const Duration(seconds: 3));
      if (response.statusCode == 200) {
        return json.decode(response.body) as List<dynamic>;
      } else {
        throw Exception('Failed to load objects');
      }
    } on TimeoutException {
      debugPrint('----------------TIMEOUT------------');
      return [];
    } on HttpException {
      debugPrint('----------------Failed to connect to API------------');
      return [];
    }
  }

  static Future<List<dynamic>> getRiseGames() async {
    final jsonResponse = await _fetchData('/games/rise');
    return jsonResponse.map((obj) => Games.fromJson(obj)).toList();
  }

  static Future<List<dynamic>> getTodayGames() async {
    final jsonResponse = await _fetchData('/games/today');
    return jsonResponse.map((obj) => Games.fromJson(obj)).toList();
  }

  static Future<List<dynamic>> getNowGames() async {
    final jsonResponse = await _fetchData('/games/now');
    return jsonResponse.map((obj) => Games.fromJson(obj)).toList();
  }

  static Future<List<dynamic>> getComments(int id) async {
    final jsonResponse = await _fetchData('/games/comments/$id');
    return jsonResponse.map((obj) => Comments.fromJson(obj)).toList();
  }

  static Future<bool> postReview(int grade, int gameid) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final response = await http.post(
        Uri.parse('$_baseUrl/games/review'),
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
      throw 'Timeout';
    }
  }

  static Future<bool> postComment(int gameid, String comment) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final response = await http.post(
        Uri.parse('$_baseUrl/games/comments'),
        body: jsonEncode({
          'gameid': gameid,
          'comment': comment,
          'userid': prefs.getInt('id')
        }),
        headers: {
          "Accept": "application/json",
          "content-type": "application/json"
        },
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } on TimeoutException {
      debugPrint('----------------TIMEOUT------------');
      return false;
    }
  }

  static Future<int> getReview(int gameid) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final response = await http
        .get(Uri.parse('$_baseUrl/games/review/$gameid/${prefs.getInt('id')}'));
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      return data['grade'];
    } else {
      return 0;
    }
  }

  static Future<Complements> getTeam(String name) async {
    final response = await http.get(Uri.parse('$_baseUrl/teams/$name'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      return Complements.fromJson(data);
    } else {
      return Complements(null, null);
    }
  }

  static Future<User> login(User user) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/users/login'),
        body: jsonEncode({
          'email': user.email,
          'username': user.name,
          'userid': 0,
          'image': user.image
        }),
        headers: {
          "Accept": "application/json",
          "content-type": "application/json"
        },
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        return User.fromJson(jsonResponse);
      } else {
        throw Exception('Failed to load objects');
      }
    } on TimeoutException {
      debugPrint('----------------TIMEOUT------------');
      return user;
    }
  }

  static Future<UserView> getProfile(int id) async {
    final response = await http.get(Uri.parse('$_baseUrl/users/$id'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      return UserView.fromJson(data);
    } else if (response.statusCode == 400) {
      throw 'Perfil inexistente';
    } else {
      throw 'Erro em buscar perfil';
    }
  }

  static Future<List<dynamic>> getProfileComment(int id, int offset) async {
    final jsonResponse = await _fetchData('/users/comment/$id/$offset');
    return jsonResponse.map((obj) => ProfileGameComment.fromJson(obj)).toList();
  }

  static Future<List<dynamic>> getProfileReview(int id, int offset) async {
    final jsonResponse = await _fetchData('/users/review/$id/$offset');
    return jsonResponse.map((obj) => ProfileGameReview.fromJson(obj)).toList();
  }
}
