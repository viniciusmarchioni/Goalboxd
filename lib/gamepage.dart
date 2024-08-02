import 'package:flutter/material.dart';
import 'package:goalboxd/obj/Requests.dart';
import 'package:goalboxd/obj/comments.dart';
import 'package:goalboxd/obj/games.dart';
import 'package:goalboxd/otheruserprofile.dart';
import 'package:goalboxd/review.dart';
import 'package:marquee/marquee.dart';

class GamePage extends StatefulWidget {
  final Games game;
  const GamePage({super.key, required this.game});

  @override
  State<StatefulWidget> createState() {
    return _GamePageState();
  }
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
      body:
          Column(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Flexible(
          child: Container(
            alignment: Alignment.center,
            margin: const EdgeInsets.only(top: 100),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FutureBuilder(
                      future: Requests.getTeam(game.team1name),
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
                        _marqueeOrNot(game.team1name),
                        Container(
                          margin: const EdgeInsets.only(left: 10, right: 10),
                          child: Text(game.scorebord(),
                              style: const TextStyle(fontSize: 20)),
                        ),
                        _marqueeOrNot(game.team2name)
                      ],
                    ),
                    FutureBuilder(
                      future: Requests.getTeam(game.team2name),
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
                    Review(phate: 10, game: game),
                  ],
                )
              ],
            ),
          ),
        ),
        _CommentWidget(game: game),
      ]),
    );
  }
}

Widget _marqueeOrNot(String team) {
  if (team.length > 9) {
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

/*

CircleAvatar(
                radius: 20,
                backgroundImage: NetworkImage(comment.urlImage ??
                    'https://pbs.twimg.com/media/GGxpGBKXAAAkdwf?format=jpg&name=small'))


 */
class _ComentarioPlaceholder extends StatelessWidget {
  final Comments comment;
  const _ComentarioPlaceholder({
    required this.comment,
  });
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          RawMaterialButton(
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(builder: (_) {
                  return OtherUserProfile(
                    userid: comment.userid,
                    username: comment.username,
                  );
                }));
              },
              child: CircleAvatar(
                  radius: 20,
                  backgroundImage: NetworkImage(comment.urlImage ??
                      'https://pbs.twimg.com/media/GGxpGBKXAAAkdwf?format=jpg&name=small'))),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  comment.username,
                  overflow: TextOverflow.fade,
                ),
                Text(
                  comment.comment,
                  overflow: TextOverflow.ellipsis,
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}

class _CommentWidget extends StatefulWidget {
  final Games game;
  const _CommentWidget({required this.game});

  @override
  State<StatefulWidget> createState() {
    return _CommentWidgetState();
  }
}

class _CommentWidgetState extends State<_CommentWidget> {
  late Games game;
  final controller = TextEditingController();
  late Future<List<dynamic>> _futurecomments;

  Future<void> _refreshComments() async {
    setState(() {
      _futurecomments = Comments.getComments(game.id);
    });
  }

  @override
  void initState() {
    game = widget.game;
    _futurecomments = Comments.getComments(game.id);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          decoration: const BoxDecoration(
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20), topRight: Radius.circular(20)),
              color: Color.fromARGB(115, 12, 11, 10)),
          height: 400,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text("Comentarios:",
                  style: TextStyle(fontSize: 25, color: Colors.white)),
              FutureBuilder(
                future: _futurecomments,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  } else {
                    return SizedBox(
                      height: 275,
                      width: MediaQuery.of(context).size.width,
                      child: RefreshIndicator(
                        onRefresh: _refreshComments,
                        child: ListView(
                          children: [
                            for (Comments comment in snapshot.data ?? [])
                              _ComentarioPlaceholder(comment: comment)
                          ],
                        ),
                      ),
                    );
                  }
                },
              ),
              Row(
                children: [
                  Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      height: 75,
                      width: 270,
                      child: TextField(
                        controller: controller,
                        maxLines: 10,
                        decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: "Comentario"),
                      )),
                  ElevatedButton(
                      onPressed: () async {
                        if (controller.text.isNotEmpty) {
                          await Comments.postComment(
                              game.id, controller.text.toString());
                          controller.clear();
                          _refreshComments();
                        }
                      },
                      child: const Text("Enviar"))
                ],
              )
            ],
          ),
        ),
      ],
    );
  }
}
