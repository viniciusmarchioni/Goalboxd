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
  final _controller = ScrollController();
  late final TabController _tabController;
  List<dynamic> comments = [];
  UserView? user;
  bool fim = false;
  int page = 0;
  int atual = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _controller.addListener(() {
      if (_controller.position.pixels == _controller.position.maxScrollExtent &&
          !fim) {
        debugPrint("AQUII");
        featch();
      }
    });
    featch();
    _getUser().then((value) {
      setState(() {
        user = value;
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  featch() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List x = await Requests.getProfileComment(prefs.getInt('id')!, page);
    comments.addAll(x);
    setState(() {
      if (x.length < 10) {
        fim = false;
      }
      comments = comments;
    });
    page += 10;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil'),
        flexibleSpace: Container(
            decoration: const BoxDecoration(
                gradient: LinearGradient(colors: [Colors.blue, Colors.white]))),
      ),
      body: user == null
          ? const Center(child: CircularProgressIndicator())
          : Column(children: [
              Container(
                  decoration: const BoxDecoration(
                      gradient:
                          LinearGradient(colors: [Colors.blue, Colors.white])),
                  child: Column(
                    children: [
                      CircleAvatar(
                          maxRadius: 50,
                          backgroundImage: NetworkImage(user?.urlImage ??
                              'https://upload.wikimedia.org/wikipedia/commons/thumb/5/59/User-avatar.svg/2048px-User-avatar.svg.png')),
                      Center(
                        child: Text(user?.username ?? ''),
                      ),
                      Center(
                        child: Text(
                            "Avaliações: ${(user?.qtdNota ?? 0).toString()}"),
                      ),
                      Center(
                        child: Text(
                            "Comentários: ${(user?.qtdComentarios ?? 0).toString()}"),
                      ),
                    ],
                  )),
              TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(
                    icon: Icon(Icons.star_border_rounded),
                    text: "Avaliações",
                  ),
                  Tab(
                    icon: Icon(Icons.comment),
                    text: "Comentários",
                  ),
                ],
                indicatorColor: Colors.blue,
                labelColor: Colors.blue,
                overlayColor: const MaterialStatePropertyAll(
                    Color.fromARGB(126, 61, 140, 206)),
              ),
              Expanded(
                  child: TabBarView(controller: _tabController, children: [
                Container(),
                ListView.builder(
                  controller: _controller,
                  itemCount: comments.length,
                  itemBuilder: (context, index) {
                    return Container(
                        margin: const EdgeInsets.only(bottom: 50),
                        child: Row(
                          children: [
                            Container(
                              margin: const EdgeInsets.all(5),
                              child: CircleAvatar(
                                  backgroundImage: NetworkImage(user
                                          ?.urlImage ??
                                      'https://upload.wikimedia.org/wikipedia/commons/thumb/5/59/User-avatar.svg/2048px-User-avatar.svg.png')),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(user?.username ?? ''),
                                Text(comments[index].comment),
                                Text(comments[index].game.team1name +
                                    " x " +
                                    comments[index].game.team2name)
                              ],
                            ),
                          ],
                        ));
                  },
                )
              ]))
            ]),
    );
  }
}

Future<UserView> _getUser() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  UserView user = await Requests.getProfile(prefs.getInt('id')!);
  return user;
}
