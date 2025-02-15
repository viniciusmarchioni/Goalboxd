import 'dart:async';
import 'package:goalboxd/obj/error.dart';
import 'package:goalboxd/obj/games.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

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
  static Future<List<Comments>> getComments(int id, int page) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    try {
      final response = await http.get(
          Uri.parse('${dotenv.env['API_URL']}/games/comments/$id/$page'),
          headers: {
            'Authorization': prefs.getString('key')!
          }).timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        List<Comments> comments = [];
        for (var i in jsonDecode(response.body)) {
          comments.add(Comments.fromJson(i));
        }
        return comments;
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  static Future<bool> postComment(int gameid, String comment) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    try {
      final response = await http.post(
        Uri.parse('${dotenv.env['API_URL']}/games/comments'),
        body: jsonEncode({
          'gameid': gameid,
          'comment': comment,
          'userid': prefs.getInt('id')
        }),
        headers: {
          "Accept": "application/json",
          "content-type": "application/json",
          'Authorization': prefs.getString('key')!
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
    } on ExpiredToken {
      rethrow;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> deleteComment(int commentid) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    try {
      final response = await http.delete(
          Uri.parse('${dotenv.env['API_URL']}/users/comment/$commentid'),
          headers: {
            'Authorization': prefs.getString('key')!
          }).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        return true;
      } else if (response.statusCode == 401) {
        throw ExpiredToken('401');
      } else {
        return false;
      }
    } on TimeoutException {
      debugPrint('----------------TIMEOUT------------');
      return false;
    } catch (e) {
      return false;
    }
  }
}

class ProfileGameComment {
  late Games game;
  late int id;
  late String comment;

  ProfileGameComment.fromJson(Map<String, dynamic> json)
      : game = Games.fromJsonProfile(json),
        comment = json['comment'],
        id = json['commentid'];
}

class ProfileGameReview {
  late Games game;
  late int review;

  ProfileGameReview.fromJson(Map<String, dynamic> json)
      : game = Games.fromJsonProfile(json),
        review = json['nota'];
}

class ProfileRepository {
  List<ProfileGameComment> comments = [];
  List<ProfileGameReview> reviews = [];
  int _pageComments = 0;
  int _pageReviews = 0;
  bool endComments = false;
  bool endReview = false;

  Future<void> setProfileComment(int? userId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    try {
      if (!endComments) {
        userId ??= prefs.getInt('id');
        final response = await http.get(
            Uri.parse(
                '${dotenv.env['API_URL']}/users/comment/$userId/$_pageComments'),
            headers: {
              'Authorization': prefs.getString('key')!
            }).timeout(const Duration(seconds: 5));
        if (response.statusCode == 200) {
          List<ProfileGameComment> profileGameComment = [];
          for (var i in jsonDecode(response.body)) {
            profileGameComment.add(ProfileGameComment.fromJson(i));
          }
          _pageComments += 10;
          comments.addAll(profileGameComment);
          endComments = profileGameComment.length < 10;
        } else {
          return;
        }
      }
    } catch (e) {
      endComments = true;
      return;
    }
  }

  Future<void> setProfileReview(int? userId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (!endReview) {
      try {
        if (userId == null) {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          userId = prefs.getInt('id');
        }
        final response = await http.get(
            Uri.parse(
                '${dotenv.env['API_URL']}/users/review/$userId/$_pageReviews'),
            headers: {
              'Authorization': prefs.getString('key')!
            }).timeout(const Duration(seconds: 5));
        if (response.statusCode == 200) {
          List<ProfileGameReview> profileGameReview = [];
          for (var i in jsonDecode(response.body)) {
            profileGameReview.add(ProfileGameReview.fromJson(i));
          }
          endReview = profileGameReview.length < 10;
          _pageReviews += 10;
          reviews.addAll(profileGameReview);
        } else {
          return;
        }
      } catch (e) {
        endReview = true;
        return;
      }
    }
  }

  ProfileRepository();
}
