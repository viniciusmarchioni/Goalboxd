import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:goalboxd/obj/games.dart';
import 'package:goalboxd/obj/user.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Requests {
  static const String _baseUrl = 'http://10.0.2.2:5000';

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
}
