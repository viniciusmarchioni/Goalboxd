import 'package:flutter/material.dart';
import 'package:goalboxd/obj/comments.dart';
import 'package:goalboxd/obj/user.dart';
import 'package:provider/provider.dart';

class OtherUserProfile extends StatefulWidget {
  final User user;
  const OtherUserProfile({super.key, required this.user});

  @override
  State<StatefulWidget> createState() => _OtherUserProfileState();
}

class _OtherUserProfileState extends State<OtherUserProfile>
    with TickerProviderStateMixin {
  late final TabController _tabController;
  late User user;
  final ScrollController controllerComment = ScrollController();
  final ScrollController controllerReview = ScrollController();
  late RepositoryProfileGame repositoryProfileGame;

  @override
  void initState() {
    super.initState();
    user = widget.user;
    _tabController = TabController(length: 2, vsync: this);
    repositoryProfileGame = Provider.of<RepositoryProfileGame>(context,
        listen: false); //inicia o provider

    repositoryProfileGame.setProfileComment(null); //adiciona nas listas
    repositoryProfileGame.setProfileReview(null); //valores padrões

    controllerComment.addListener(() {
      //adiciona ao terminar de scrollar
      if (controllerComment.position.pixels ==
          controllerComment.position.maxScrollExtent) {
        repositoryProfileGame.setProfileComment(null);
      }
    });
    controllerReview.addListener(() {
      //adiciona ao terminar de scrollar
      if (controllerComment.position.pixels ==
          controllerComment.position.maxScrollExtent) {
        repositoryProfileGame.setProfileReview(null);
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    controllerComment.dispose();
    controllerReview.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(user.username),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(colors: [Colors.blue, Colors.white]),
          ),
        ),
      ),
      body: Column(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(colors: [Colors.blue, Colors.white]),
            ),
            child: Column(
              children: [
                CircleAvatar(
                    maxRadius: 50,
                    backgroundImage: NetworkImage(user.urlimage ??
                        'https://upload.wikimedia.org/wikipedia/commons/thumb/5/59/User-avatar.svg/2048px-User-avatar.svg.png')),
                Center(
                  child: Text(user.username),
                ),
                Center(
                  child: Text("Comentários: ${user.qtdComentarios}"),
                ),
                Center(
                  child: Text("Avaliações: ${user.qtdNota}"),
                )
              ],
            ),
          ),
          TabBar(
            controller: _tabController,
            tabs: const [
              Tab(icon: Icon(Icons.star_border_rounded), text: "Avaliações"),
              Tab(icon: Icon(Icons.comment), text: "Comentários"),
            ],
            indicatorColor: Colors.blue,
            labelColor: Colors.blue,
            overlayColor: const MaterialStatePropertyAll(
                Color.fromARGB(126, 61, 140, 206)),
          ),
          Expanded(
            child: TabBarView(controller: _tabController, children: [
              Consumer<RepositoryProfileGame>(
                builder: (context, value, child) {
                  return ListView.builder(
                    itemCount: value.reviews.length,
                    itemBuilder: (context, index) {
                      return _buildReviewItem(value.reviews[index]);
                    },
                  );
                },
              ),
              Consumer<RepositoryProfileGame>(
                builder: (context, value, child) {
                  return ListView.builder(
                    controller: controllerComment,
                    itemCount: value.comments.length,
                    itemBuilder: (context, index) {
                      return _buildCommentItem(value.comments[index]);
                    },
                  );
                },
              ),
            ]),
          )
        ],
      ),
    );
  }

  Widget _buildReviewItem(ProfileGameReview review) {
    return Container(
      margin: const EdgeInsets.only(bottom: 50),
      child: Row(
        children: [
          Container(
            margin: const EdgeInsets.all(5),
            child: CircleAvatar(
              backgroundImage: NetworkImage(
                user.urlimage ??
                    'https://upload.wikimedia.org/wikipedia/commons/thumb/5/59/User-avatar.svg/2048px-User-avatar.svg.png',
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(user.username),
              Row(children: [
                for (int i = 0; i < review.review; i++) const Icon(Icons.star)
              ]),
              Text("${review.game.team1name} x ${review.game.team2name}"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCommentItem(ProfileGameComment comment) {
    return Container(
      margin: const EdgeInsets.only(bottom: 50),
      child: Row(
        children: [
          Container(
            margin: const EdgeInsets.all(5),
            child: CircleAvatar(
              backgroundImage: NetworkImage(
                user.urlimage ??
                    'https://upload.wikimedia.org/wikipedia/commons/thumb/5/59/User-avatar.svg/2048px-User-avatar.svg.png',
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(user.username),
              Text(comment.comment),
              Text("${comment.game.team1name} x ${comment.game.team2name}"),
            ],
          ),
        ],
      ),
    );
  }
}
