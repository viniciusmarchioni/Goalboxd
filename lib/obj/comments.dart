import 'dart:async';
import 'package:goalboxd/obj/games.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Comments {
  String? urlImage;
  final String username;
  final int userid;
  final String comment;

  Comments(
      {required this.userid,
      required this.username,
      required this.comment,
      this.urlImage});

  factory Comments.fromJson(Map<String, dynamic> json) {
    return Comments(
        userid: json['userid'],
        comment: json['comment'],
        username: json['name'],
        urlImage: json['image']);
  }
  static Future<List<Comments>> getComments(int id) async {
    final response = await http
        .get(Uri.parse('http://10.0.2.2:5000/games/comments/$id'))
        .timeout(const Duration(seconds: 5));
    if (response.statusCode == 200) {
      List<Comments> comments = [];
      for (var i in jsonDecode(response.body)) {
        comments.add(Comments.fromJson(i));
      }
      debugPrint(comments.toString());
      return comments;
    } else {
      return [];
    }
  }

  static Future<bool> postComment(int gameid, String comment) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final response = await http.post(
        Uri.parse('http://10.0.2.2:5000/games/comments'),
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
}

class ProfileGameComment {
  late Games game;
  late String comment;

  ProfileGameComment.fromJson(Map<String, dynamic> json)
      : game = Games.forProfile(json),
        comment = json['comment'];

  static Future<List<ProfileGameComment>> getProfileComment(
      int id, int offset) async {
    final response = await http
        .get(Uri.parse('http://10.0.2.2:5000/users/comment/$id/$offset'))
        .timeout(const Duration(seconds: 5));
    if (response.statusCode == 200) {
      List<ProfileGameComment> profileGameComment = [];
      for (var i in jsonDecode(response.body)) {
        profileGameComment.add(ProfileGameComment.fromJson(i));
      }
      debugPrint(profileGameComment.toString());
      return profileGameComment;
    } else {
      return [];
    }
  }
}
