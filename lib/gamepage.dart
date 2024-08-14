import 'package:flutter/material.dart';
import 'package:goalboxd/obj/games.dart';
import 'package:goalboxd/widgets/comments.dart';
import 'package:goalboxd/widgets/geralreview.dart';
import 'package:goalboxd/widgets/review.dart';
import 'package:marquee/marquee.dart';

class GamePage extends StatefulWidget {
  final Games game;
  const GamePage({super.key, required this.game});

  @override
  State<StatefulWidget> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  late Games game;
  final controller = TextEditingController();

  @override
  void initState() {
    game = widget.game;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("${game.team1name} x ${game.team2name}"),
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(colors: [Colors.blue, Colors.white]),
            ),
          ),
        ),
        body: Stack(
          children: [
            Container(
              alignment: Alignment.center,
              margin: const EdgeInsets.only(top: 100),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      FutureBuilder(
                        future: Complements.getTeam(game.team1name ?? ""),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return ClipRRect(
                              borderRadius: const BorderRadius.only(
                                  bottomLeft: Radius.circular(10),
                                  topLeft: Radius.circular(10)),
                              child: Container(
                                  height: 60,
                                  color: _teamcolor(null),
                                  padding: const EdgeInsets.all(5),
                                  child: Image.asset('assets/escudo.png')),
                            );
                          } else {
                            return ClipRRect(
                              borderRadius: const BorderRadius.only(
                                  bottomLeft: Radius.circular(10),
                                  topLeft: Radius.circular(10)),
                              child: Container(
                                height: 60,
                                color: _teamcolor(snapshot.data?.colorTeam),
                                padding: const EdgeInsets.all(5),
                                child: snapshot.data?.urlImage == null
                                    ? Image.asset('assets/escudo.png')
                                    : Image.network(snapshot.data!.urlImage!),
                              ),
                            );
                          }
                        },
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _marqueeOrNot(game.team1name ?? ""),
                          Text(game.scorebord(),
                              style: const TextStyle(fontSize: 20)),
                          _marqueeOrNot(game.team2name ?? "")
                        ],
                      ),
                      FutureBuilder(
                        future: Complements.getTeam(game.team2name ?? ""),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return ClipRRect(
                              borderRadius: const BorderRadius.only(
                                  bottomRight: Radius.circular(10),
                                  topRight: Radius.circular(10)),
                              child: Container(
                                  height: 60,
                                  color: _teamcolor(null),
                                  padding: const EdgeInsets.all(5),
                                  child: Image.asset('assets/escudo.png')),
                            );
                          } else {
                            return ClipRRect(
                              borderRadius: const BorderRadius.only(
                                  bottomRight: Radius.circular(10),
                                  topRight: Radius.circular(10)),
                              child: Container(
                                height: 60,
                                color: _teamcolor(snapshot.data?.colorTeam),
                                padding: const EdgeInsets.all(5),
                                child: snapshot.data?.urlImage == null
                                    ? Image.asset('assets/escudo.png')
                                    : Image.network(snapshot.data!.urlImage!),
                              ),
                            );
                          }
                        },
                      )
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Review(game: game),
                    ],
                  ),
                  GeralReview(valor: game.rate ?? 0)
                ],
              ),
            ),
            CommentWidget(game: game),
          ],
        ));
  }

  Widget _marqueeOrNot(String team) {
    if (MediaQuery.sizeOf(context).width >= 800) {
      return Container(
        margin: const EdgeInsets.only(left: 5, right: 5),
        child: Text(
          team,
          style: const TextStyle(fontSize: 20),
          overflow: TextOverflow.ellipsis,
        ),
      );
    }
    if (team.length > 5) {
      return Container(
        width: 80,
        height: 50,
        margin: const EdgeInsets.only(left: 5, right: 5),
        child: Marquee(
          text: team,
          style: const TextStyle(fontSize: 20),
          blankSpace: 5.0,
          pauseAfterRound: const Duration(seconds: 1),
        ),
      );
    }
    return Container(
      margin: const EdgeInsets.only(left: 5, right: 5),
      child: Text(
        team,
        style: const TextStyle(fontSize: 20),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Color _teamcolor(String? color) {
    switch (color) {
      case 'black':
        return Colors.black;
      case 'white':
        return const Color.fromARGB(255, 223, 223, 223);
      case 'red':
        return Colors.red;
      case 'green':
        return Colors.green;
      case 'yellow':
        return Colors.yellow;
      case 'blue':
        return Colors.blue;
      default:
        return Colors.white;
    }
  }
}
