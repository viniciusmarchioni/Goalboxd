import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:goalboxd/obj/games.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Review extends StatefulWidget {
  final int? phate;
  final Games game;
  const Review({super.key, required this.phate, required this.game});

  @override
  State<StatefulWidget> createState() {
    return _ReviewState();
  }
}

class _ReviewState extends State<Review> {
  late int hate;
  late Games game;

  @override
  void initState() {
    super.initState();
    hate = 0;
    game = widget.game;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadGrade();
    });
  }

  Future<void> _loadGrade() async {
    final grade = await getReview();
    setState(() {
      hate = grade;
    });
  }

  Future postReview(int grade) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final response = await http.post(
      Uri.parse('${dotenv.env['API_URL']}/games/review'),
      body: jsonEncode(
          {'userid': prefs.getInt('id'), 'gameid': game.id, 'grade': grade}),
      headers: {
        "Accept": "application/json",
        "content-type": "application/json"
      },
    ).timeout(const Duration(seconds: 5));
    if (response.statusCode == 200) {
      return;
    } else {
      debugPrint("Erro");
      return;
    }
  }

  Future<int> getReview() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final response = await http.get(Uri.parse(
        '${dotenv.env['API_URL']}/games/review/${game.id}/${prefs.getInt('id')}'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['grade'];
    } else {
      return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (int count = 1; count < 6; count++)
          GestureDetector(
            child: hate >= count
                ? const Icon(Icons.star)
                : const Icon(Icons.star_border),
            onTap: () async {
              await postReview(count);
              setState(() {
                hate = count;
              });
            },
          )
      ],
    );
  }
}
