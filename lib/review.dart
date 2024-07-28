import 'package:flutter/material.dart';
import 'package:goalboxd/obj/games.dart';
import 'package:goalboxd/obj/requests.dart';

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
    final grade = await Requests.getReview(game.id);
    setState(() {
      hate = grade;
    });
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
              await Requests.postReview(count, game.id);
              setState(() {
                hate = count;
              });
            },
          )
      ],
    );
  }
}
