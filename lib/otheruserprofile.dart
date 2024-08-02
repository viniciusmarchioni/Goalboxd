import 'package:flutter/material.dart';
import 'package:goalboxd/obj/comments.dart';
import 'package:goalboxd/obj/games.dart';
import 'package:goalboxd/obj/requests.dart';
import 'package:goalboxd/obj/user.dart';

class OtherUserProfile extends StatefulWidget {
  final int userid;
  final String username;
  const OtherUserProfile(
      {super.key, required this.userid, required this.username});

  @override
  State<StatefulWidget> createState() => _OtherUserProfileState();
}

class _OtherUserProfileState extends State<OtherUserProfile>
    with TickerProviderStateMixin {
  int atual = 0;
  late String username;
  late int userid;
  final ScrollController _controllerComment = ScrollController();
  final ScrollController _controllerReview = ScrollController();
  late final TabController _tabController;
  List<dynamic> comments = [];
  List<dynamic> reviews = [];
  UserView? user;
  bool endOfComments = false;
  bool endOfReview = false;
  int pageComment = 0;
  int pageReview = 0;

  @override
  void initState() {
    _tabController = TabController(length: 2, vsync: this);
    _controllerComment.addListener(_scrollListener);
    _controllerReview.addListener(_scrollListener2);
    userid = widget.userid;
    username = widget.username;
    super.initState();
    _fetchUserComments();
    _fetchUserReviews();
    _getUser(userid).then((value) {
      setState(() {
        user = value;
      });
    });
  }

  void _scrollListener() {
    if (_controllerComment.position.pixels ==
            _controllerComment.position.maxScrollExtent &&
        !endOfComments) {
      _fetchUserComments();
    }
  }

  void _scrollListener2() {
    if (_controllerReview.position.pixels ==
            _controllerReview.position.maxScrollExtent &&
        !endOfComments) {
      _fetchUserReviews();
    }
  }

  Future<void> _fetchUserComments() async {
    final newComments =
        await ProfileGameComment.getProfileComment(userid, pageComment);
    setState(() {
      comments.addAll(newComments);
      endOfComments = newComments.length < 10;
    });
    pageComment += 10;
  }

  Future<void> _fetchUserReviews() async {
    final newReview =
        await ProfileGameReview.getProfileReview(userid, pageReview);
    setState(() {
      reviews.addAll(newReview);
      endOfReview = newReview.length < 10;
    });
    pageReview += 10;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(username),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(colors: [Colors.blue, Colors.white]),
          ),
        ),
      ),
      body: Column(children: [
        _buildUserInfo(),
        _buildTabBar(),
        _buildTabBarView(),
      ]),
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
            itemCount: reviews.length,
            itemBuilder: (context, index) {
              return _buildReviewItem(index);
            },
          ),
          ListView.builder(
            controller: _controllerComment,
            itemCount: comments.length,
            itemBuilder: (context, index) {
              return _buildCommentItem(index);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCommentItem(int index) {
    final comment = comments[index];
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
    final review = reviews[index];
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

Future<UserView> _getUser(int userid) async {
  try {
    UserView user = await Requests.getProfile(userid);
    return user;
  } catch (e) {
    return UserView('Perfil Inexistente', null, 0, 0);
  }
}
