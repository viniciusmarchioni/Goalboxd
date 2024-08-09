import 'package:flutter/material.dart';
import 'package:goalboxd/obj/comments.dart';
import 'package:goalboxd/obj/user.dart';

class UserProfile extends StatefulWidget {
  const UserProfile({super.key});

  @override
  State<StatefulWidget> createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile>
    with TickerProviderStateMixin {
  late final TabController _tabController;
  RepositoryProfileGame repositoryProfileGame = RepositoryProfileGame();
  User? user;

  /*
  Isso não está feito da melhor maneira, 
  não pode atualizar o estado com hot reload mas é oq funciona,
  futuramente atualizar com provider ou algo do tipo
  */

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    user = User();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Perfil'),
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(colors: [Colors.blue, Colors.white]),
            ),
          ),
        ),
        body: FutureBuilder(
          future: user?.getProfile(null),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return Column(
                children: [
                  _buildUserInfo(),
                  _buildTabBar(),
                  TabView(tabController: _tabController, user: user!),
                ],
              );
            } else if (snapshot.hasError) {
              return Text(snapshot.error.toString());
            }
            return const Center(
              child: CircularProgressIndicator(
                color: Colors.blue,
              ),
            );
          },
        ));
  }

  Widget _buildUserInfo() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(colors: [Colors.blue, Colors.white]),
      ),
      child: Column(
        children: [
          CircleAvatar(
            maxRadius: 50,
            backgroundImage: NetworkImage(
              user?.urlimage ??
                  'https://upload.wikimedia.org/wikipedia/commons/thumb/5/59/User-avatar.svg/2048px-User-avatar.svg.png',
            ),
          ),
          Center(child: Text(user?.username ?? '')),
          Center(child: Text("Avaliações: ${(user?.qtdNota ?? 0).toString()}")),
          Center(
              child: Text(
                  "Comentários: ${(user?.qtdComentarios ?? 0).toString()}")),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return TabBar(
      controller: _tabController,
      tabs: const [
        Tab(icon: Icon(Icons.star_border_rounded), text: "Avaliações"),
        Tab(icon: Icon(Icons.comment), text: "Comentários"),
      ],
      indicatorColor: Colors.blue,
      labelColor: Colors.blue,
      overlayColor:
          const MaterialStatePropertyAll(Color.fromARGB(126, 61, 140, 206)),
    );
  }
}

class TabView extends StatefulWidget {
  final TabController tabController;
  final User user;

  const TabView({super.key, required this.tabController, required this.user});

  @override
  State<StatefulWidget> createState() => TabViewState();
}

class TabViewState extends State<TabView> {
  late final TabController tabController;
  RepositoryProfileGame repositoryProfileGame = RepositoryProfileGame();
  final ScrollController _controllerComment = ScrollController();
  final ScrollController _controllerReview = ScrollController();
  late User user;

  void _scrollComment() {
    if (_controllerComment.position.pixels ==
        _controllerComment.position.maxScrollExtent) {
      setState(() {
        repositoryProfileGame.setProfileComment(null);
      });
    }
  }

  void _scrollListener2() {
    if (_controllerReview.position.pixels ==
        _controllerReview.position.maxScrollExtent) {
      setState(() {
        repositoryProfileGame.setProfileReview(null);
      });
    }
  }

  @override
  void dispose() {
    _controllerComment.dispose();
    _controllerReview.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    user = widget.user;
    _controllerComment.addListener(_scrollComment);
    _controllerReview.addListener(_scrollListener2);
    tabController = widget.tabController;
  }

  Future<void> chama2() async {
    await repositoryProfileGame.setProfileComment(null);
    await repositoryProfileGame.setProfileReview(null);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: chama2(),
      builder: (context, snapshot) {
        return Expanded(
          child: TabBarView(
            controller: tabController,
            children: [
              ListView.builder(
                controller: _controllerReview,
                itemCount: repositoryProfileGame.reviews.length,
                itemBuilder: (context, index) {
                  return _buildReviewItem(index);
                },
              ),
              ListView.builder(
                controller: _controllerComment,
                itemCount: repositoryProfileGame.comments.length,
                itemBuilder: (context, index) {
                  return _buildCommentItem(index);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCommentItem(int index) {
    final comment = repositoryProfileGame.comments[index];
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

  Widget _buildReviewItem(int index) {
    final review = repositoryProfileGame.reviews[index];
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
}
