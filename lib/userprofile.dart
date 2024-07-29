import 'package:flutter/material.dart';
import 'package:goalboxd/obj/requests.dart';
import 'package:goalboxd/obj/user.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserProfile extends StatefulWidget {
  const UserProfile({super.key});

  @override
  State<StatefulWidget> createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile>
    with TickerProviderStateMixin {
  final ScrollController _controller = ScrollController();
  late final TabController _tabController;
  List<dynamic> comments = [];
  UserView? user;
  bool endOfComments = false;
  int page = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _controller.addListener(_scrollListener);
    _fetchUserComments();
    _getUser().then((value) {
      setState(() {
        user = value;
      });
    });
  }

  void _scrollListener() {
    if (_controller.position.pixels == _controller.position.maxScrollExtent &&
        !endOfComments) {
      _fetchUserComments();
    }
  }

  Future<void> _fetchUserComments() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('id');
    if (userId == null) return;

    final newComments = await Requests.getProfileComment(userId, page);
    setState(() {
      comments.addAll(newComments);
      endOfComments = newComments.length < 10;
    });
    page += 10;
  }

  @override
  void dispose() {
    _controller.dispose();
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
          Container(),
          ListView.builder(
            controller: _controller,
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
}

Future<UserView> _getUser() async {
  final prefs = await SharedPreferences.getInstance();
  final userId = prefs.getInt('id');
  if (userId == null) throw Exception("User ID not found in SharedPreferences");
  return await Requests.getProfile(userId);
}
