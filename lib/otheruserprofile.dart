import 'package:flutter/material.dart';
import 'package:goalboxd/obj/user.dart';
import 'package:goalboxd/userprofile.dart';

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
  late String username;
  late int userid;
  late final TabController _tabController;
  late User user;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    userid = widget.userid;
    username = widget.username;
    user = User();
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
      body: FutureBuilder(
        future: user.getProfile(userid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Column(children: [
              _buildUserInfo(),
              _buildTabBar(),
              TabView(tabController: _tabController, user: user)
            ]);
          }
          return const Center(
            child: CircularProgressIndicator(
              color: Colors.blue,
            ),
          );
        },
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
              user.urlimage ??
                  'https://upload.wikimedia.org/wikipedia/commons/thumb/5/59/User-avatar.svg/2048px-User-avatar.svg.png',
            ),
          ),
          Center(child: Text(user.username)),
          Center(child: Text("Avaliações: ${(user.qtdNota).toString()}")),
          Center(
              child: Text("Comentários: ${(user.qtdComentarios).toString()}")),
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
