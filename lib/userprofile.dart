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
  bool fim = false;
  int teste = 0;
  int atual = 0;

  @override
  void initState() {
    super.initState();
    controller.addListener(() {
      if (controller.position.pixels == controller.position.maxScrollExtent &&
          !fim) {
        debugPrint("AQUII");
        featch();
      }
    });
  }

  Future featch() async {
    var novosComentarios = await Requests.getProfileComment(25, teste);
    setState(() {
      teste += 5;
      if (novosComentarios.length < 5) {
        fim = true;
      }
      comentarios.add(novosComentarios);
    });
    return true;
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
      body: Column(children: [
        Container(
          decoration: const BoxDecoration(
              gradient: LinearGradient(colors: [Colors.blue, Colors.white])),
          child: FutureBuilder(
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
        if (atual == 1)
          FutureBuilder(
            future: Requests.getProfileComment(25, teste),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                debugPrint('=============ERRO=============');
                return const Center(child: Text('Erro'));
              }
              if (snapshot.connectionState == ConnectionState.done) {
                comentarios += snapshot.data ?? [];
                debugPrint(
                    "===================${comentarios.length}========================");

                return Expanded(
                    child: ListView(
                  controller: controller,
                  children: [
                    for (var profileGame in comentarios)
                      if (profileGame is ProfileGame)
                        Container(
                          decoration: BoxDecoration(
                              border: Border.all(color: Colors.black12)),
                          margin: const EdgeInsets.only(bottom: 100),
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
              } else {
                return const CircularProgressIndicator();
              }
            },
          )
      ]),
    );
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
