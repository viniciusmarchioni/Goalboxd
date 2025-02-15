import 'package:flutter/material.dart';
import 'package:goalboxd/obj/comment.dart';
import 'package:goalboxd/obj/user.dart';
import 'package:goalboxd/widgets/displayname.dart';

class UserProfile extends StatefulWidget {
  final User user;
  const UserProfile({super.key, required this.user});

  @override
  State<StatefulWidget> createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile>
    with TickerProviderStateMixin {
  late final TabController _tabController;
  late User user;
  final ScrollController controllerComment = ScrollController();
  final ScrollController controllerReview = ScrollController();
  late ProfileRepository repositoryProfileGame;

  @override
  void initState() {
    super.initState();
    user = widget.user;
    _tabController = TabController(length: 2, vsync: this);
    repositoryProfileGame = ProfileRepository();

    updateComment(); //adiciona nas listas
    updateReview(); //valores padrões

    controllerComment.addListener(_scrollComment);
    controllerReview.addListener(_scrollReview);
  }

  void _scrollComment() {
    if (controllerComment.position.pixels ==
        controllerComment.position.maxScrollExtent) {
      updateComment();
    }
  }

  void _scrollReview() {
    if (controllerComment.position.pixels ==
        controllerComment.position.maxScrollExtent) {
      updateReview();
    }
  }

  Future updateComment() async {
    await repositoryProfileGame.setProfileComment(user.id);
    setState(() {
      repositoryProfileGame = repositoryProfileGame;
    });
  }

  Future updateReview() async {
    await repositoryProfileGame.setProfileReview(user.id);
    setState(() {
      repositoryProfileGame = repositoryProfileGame;
    });
  }

  @override
  void dispose() {
    super.dispose();
    _tabController.dispose();
    controllerComment.dispose();
    controllerReview.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Perfil"),
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
                    backgroundImage: user.urlimage != null
                        ? NetworkImage(user.urlimage!)
                        : const AssetImage('assets/userIcon.png')
                            as ImageProvider),
                Center(
                  child: DisplayName(username: user.username),
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
              ListView.builder(
                itemCount: repositoryProfileGame.reviews.length,
                itemBuilder: (context, index) {
                  return _buildReviewItem(repositoryProfileGame.reviews[index]);
                },
              ),
              ListView.builder(
                controller: controllerComment,
                itemCount: repositoryProfileGame.comments.length,
                itemBuilder: (context, index) {
                  return _buildCommentItem(
                      repositoryProfileGame.comments[index], index);
                },
              )
            ]),
          )
        ],
      ),
    );
  }

  Widget _buildReviewItem(ProfileGameReview review) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Container(
            margin: const EdgeInsets.all(5),
            child: CircleAvatar(
                backgroundImage: user.urlimage != null
                    ? NetworkImage(user.urlimage!)
                    : const AssetImage('assets/userIcon.png') as ImageProvider),
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

  Widget _buildCommentItem(ProfileGameComment comment, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                margin: const EdgeInsets.all(5),
                child: CircleAvatar(
                    backgroundImage: user.urlimage != null
                        ? NetworkImage(user.urlimage!)
                        : const AssetImage('assets/userIcon.png')
                            as ImageProvider),
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
          IconButton(
              onPressed: () async {
                bool deletado = await Comments.deleteComment(comment.id);
                if (deletado) {
                  setState(() {
                    user.qtdComentarios--;
                    repositoryProfileGame.comments.removeAt(index);
                  });
                }
              },
              icon: const Icon(
                Icons.delete,
                color: Colors.red,
              ))
        ],
      ),
    );
  }
}
