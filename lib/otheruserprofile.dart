import 'package:flutter/material.dart';
import 'package:goalboxd/obj/requests.dart';
import 'package:goalboxd/obj/user.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OtherUserProfile extends StatefulWidget {
  final int userid;
  final String username;
  const OtherUserProfile(
      {super.key, required this.userid, required this.username});

  @override
  State<StatefulWidget> createState() => _OtherUserProfileState();
}

class _OtherUserProfileState extends State<OtherUserProfile> {
  int atual = 0;
  late String username;
  late int userid;

  @override
  void initState() {
    userid = widget.userid;
    username = widget.username;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(username)),
      body: Column(children: [
        FutureBuilder(
          future: _getUser(userid),
          builder: (context, snapshot) {
            return Column(
              children: [
                CircleAvatar(
                    maxRadius: 50,
                    backgroundImage: NetworkImage(snapshot.data?.urlImage ??
                        'https://upload.wikimedia.org/wikipedia/commons/thumb/5/59/User-avatar.svg/2048px-User-avatar.svg.png')),
                Center(
                  child: Text(snapshot.data?.username ?? 'Null'),
                ),
                Center(
                  child: Text(
                      "Avaliações: ${(snapshot.data?.qtdNota ?? 0).toString()}"),
                ),
                Center(
                  child: Text(
                      "Comentários: ${(snapshot.data?.qtdComentarios ?? 0).toString()}"),
                ),
              ],
            );
          },
        ),
        NavigationBar(
          selectedIndex: atual,
          destinations: const [
            NavigationDestination(icon: Icon(Icons.star), label: 'Avaliações'),
            NavigationDestination(
                icon: Icon(Icons.comment_rounded), label: 'Comentários')
          ],
          labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
          onDestinationSelected: (value) {
            setState(() {
              atual = value;
            });
          },
        )
      ]),
    );
  }
}

Future<UserView> _getUser(int userid) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();

  try {
    UserView user = await Requests.getProfile(prefs.getInt('id')!);
    return user;
  } catch (e) {
    return UserView('Perfil Inexistente', null, 0, 0);
  }
}
