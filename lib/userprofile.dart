import 'package:flutter/material.dart';
import 'package:goalboxd/obj/games.dart';
import 'package:goalboxd/obj/requests.dart';
import 'package:goalboxd/obj/user.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserProfile extends StatefulWidget {
  const UserProfile({super.key});

  @override
  State<StatefulWidget> createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  final controller = ScrollController();
  var comentarios = [];
  int atual = 0;

  @override
  void initState() {
    super.initState();
    controller.addListener(() {
      if (controller.position.maxScrollExtent == controller.offset) {
        featch();
      }
    });
  }

  Future featch() async {
    setState(() {
      comentarios.add(Requests.getProfileComment(25, 0));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Perfil')),
      body: Column(children: [
        FutureBuilder(
          future: _getUser(),
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
              NavigationDestination(
                  icon: Icon(Icons.star), label: 'Avaliações'),
              NavigationDestination(
                  icon: Icon(Icons.comment_rounded), label: 'Comentários')
            ],
            labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
            onDestinationSelected: (value) {
              setState(() {
                atual = value;
              });
            }),
        _conteudo(atual, controller)
      ]),
    );
  }
}

Widget _conteudo(int index, ScrollController controller) {
  var comentarios = [];
  if (index == 1) {
    return FutureBuilder(
      future: Requests.getProfileComment(25, 0),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          debugPrint('=============ERRO=============');
          return const Center(child: Text('Erro'));
        }
        comentarios += snapshot.data ?? [];
        return Expanded(
            child: ListView(
          children: [
            for (var profileGame in comentarios)
              if (profileGame is ProfileGame)
                Container(
                  decoration:
                      BoxDecoration(border: Border.all(color: Colors.black12)),
                  margin: const EdgeInsets.only(bottom: 50),
                  height: 50,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(profileGame.comment),
                      Text(
                          '${profileGame.game.team1name}x${profileGame.game.team2name}')
                    ],
                  ),
                )
          ],
        ));
      },
    );
  } else {
    return Container();
  }
}

Future<UserView> _getUser() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();

  try {
    UserView user = await Requests.getProfile(prefs.getInt('id')!);
    return user;
  } catch (e) {
    throw 'Erro: $e';
  }
}
