import 'package:flutter/material.dart';
import 'package:goalboxd/obj/comments.dart';
import 'package:goalboxd/obj/user.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserProfile extends StatefulWidget {
  const UserProfile({super.key});

  @override
  State<StatefulWidget> createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile>
    with TickerProviderStateMixin {
  final ScrollController _controllerComment = ScrollController();
  final ScrollController _controllerReview = ScrollController();
  late final TabController _tabController;
  RepositoryProfileGame repositoryProfileGame = RepositoryProfileGame();
  UserView? user;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _controllerComment.addListener(_scrollComments);
    _controllerReview.addListener(_scrollReviews);
    repositoryProfileGame.setProfileComment();
    repositoryProfileGame.setProfileReview();
    _getUser().then((value) {
      setState(() {
        user = value;
      });
    });
  }

  void _scrollComments() {
    if (_controllerComment.position.pixels ==
            _controllerComment.position.maxScrollExtent &&
        !repositoryProfileGame.endComments) {
      setState(() {
        repositoryProfileGame.setProfileComment();
      });
    }
  }

  void _scrollReviews() {
    if (_controllerReview.position.pixels ==
            _controllerReview.position.maxScrollExtent &&
        !repositoryProfileGame.endReview) {
      setState(() {
        repositoryProfileGame.setProfileReview();
      });
    }
  }

  @override
  void dispose() {
    _controllerComment.dispose();
    _controllerReview.dispose();
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
      body: user == null
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _buildUserInfo(),
                _buildTabBar(),
                _buildTabBarView(),
              ],
            ),
    );
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
              user?.urlImage ??
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

  Widget _buildTabBarView() {
    return Expanded(
      child: TabBarView(
        controller: _tabController,
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
                user?.urlImage ??
                    'https://upload.wikimedia.org/wikipedia/commons/thumb/5/59/User-avatar.svg/2048px-User-avatar.svg.png',
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(user?.username ?? ''),
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
                user?.urlImage ??
                    'https://upload.wikimedia.org/wikipedia/commons/thumb/5/59/User-avatar.svg/2048px-User-avatar.svg.png',
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(user?.username ?? ''),
              Text(review.review.toString()),
              Text("${review.game.team1name} x ${review.game.team2name}"),
            ],
          ),
        ],
      ),
    );
  }
}

Future<UserView> _getUser() async {
  final prefs = await SharedPreferences.getInstance();
  final userId = prefs.getInt('id');
  if (userId == null) throw Exception("User ID not found in SharedPreferences");
  return await UserView.getProfile(userId);
}
