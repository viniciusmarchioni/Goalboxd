import 'package:flutter/material.dart';
import 'package:goalboxd/gamepage.dart';
import 'package:goalboxd/main.dart';
import 'package:goalboxd/obj/games.dart';
import 'package:goalboxd/obj/user.dart';
import 'package:goalboxd/userprofile.dart';
import 'package:gradient_borders/gradient_borders.dart';
import 'package:marquee/marquee.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Menu extends StatefulWidget {
  const Menu({super.key});

  @override
  State<StatefulWidget> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<Menu> with TickerProviderStateMixin {
  late final TabController _tabController;
  bool iniciar = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    super.dispose();
    _tabController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gamesRepository = Provider.of<GamesRepository>(context);
    if (iniciar) {
      gamesRepository.updateRise();
      gamesRepository.updateNow();
      gamesRepository.updateToday();
      iniciar = false;
    }

    return Scaffold(
        appBar: AppBar(
          flexibleSpace: Container(
              decoration: const BoxDecoration(
                  gradient:
                      LinearGradient(colors: [Colors.blue, Colors.white]))),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Goalboxd", style: TextStyle(color: Colors.white)),
              Container(
                margin: const EdgeInsets.all(10),
                child: FutureBuilder(
                  future: _userImage(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      return snapshot.data ?? Container();
                    } else {
                      return Container();
                    }
                  },
                ),
              )
            ],
          ),
          bottom: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(
                icon: Icon(Icons.fireplace),
                text: "Em Alta",
              ),
              Tab(
                icon: Icon(Icons.timer),
                text: "Ao Vivo",
              ),
              Tab(
                icon: Icon(Icons.today),
                text: "De Hoje",
              )
            ],
            indicatorColor: Colors.blue,
            labelColor: Colors.white,
            overlayColor: const MaterialStatePropertyAll(
                Color.fromARGB(126, 61, 140, 206)),
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            RefreshIndicator(
              onRefresh: () async {
                gamesRepository.updateRise();
              },
              child: ListView.builder(
                itemCount: gamesRepository.games.length,
                itemBuilder: (context, index) {
                  return _listPlaceHolder2(gamesRepository.games[index]);
                },
              ),
            ),
            RefreshIndicator(
              onRefresh: () async {
                gamesRepository.updateNow();
              },
              child: ListView.builder(
                itemCount: gamesRepository.now.length,
                itemBuilder: (context, index) {
                  return _listPlaceHolder2(gamesRepository.now[index]);
                },
              ),
            ),
            RefreshIndicator(
              onRefresh: () async {
                gamesRepository.updateToday();
              },
              child: ListView.builder(
                itemCount: gamesRepository.today.length,
                itemBuilder: (context, index) {
                  return _listPlaceHolder2(gamesRepository.today[index]);
                },
              ),
            )
          ],
        ));
  }

  GestureDetector _listPlaceHolder2(Games game) {
    DateTime now = DateTime.now();
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => GamePage(game: game),
        ));
      },
      child: Container(
        height: 100,
        margin: const EdgeInsets.all(5),
        decoration: BoxDecoration(
            border: _borderDefine(game.championship!),
            borderRadius: const BorderRadius.all(Radius.circular(10))),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            game.type == GameType.football
                ? const Icon(Icons.sports_soccer)
                : const Icon(Icons.sports_basketball_outlined),
            _marqueeOrNot(game.team1name!),
            Text(game.scorebord()),
            _marqueeOrNot(game.team2name!),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (now.isBefore(game.date!)) ...[
                  const Icon(Icons.timer_sharp),
                  Text(
                      '${game.date!.hour.toString()}:${game.date!.minute.toString()}h')
                ] else ...[
                  const Icon(Icons.star_half_rounded),
                  Text(game.rate!.toStringAsFixed(1))
                ]
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _marqueeOrNot(String team) {
    if (team.length > 9) {
      return SizedBox(
        width: 80,
        height: 50,
        child: Marquee(
          text: team,
          style: const TextStyle(fontSize: 20),
          blankSpace: 5.0,
          pauseAfterRound: const Duration(seconds: 1),
        ),
      );
    }
    return Text(
      team,
      style: const TextStyle(fontSize: 20),
      overflow: TextOverflow.ellipsis,
    );
  }

  BoxBorder _borderDefine(String championship) {
    if (championship == 'Serie A') {
      return Border.all(color: Colors.blue);
    } else if (championship == 'Libertadores') {
      return const GradientBoxBorder(
          gradient: SweepGradient(colors: [
        Color.fromARGB(255, 218, 218, 52),
        Colors.black,
      ]));
    } else if (championship == 'Euro Championship') {
      return const GradientBoxBorder(
          gradient: LinearGradient(colors: [
        Colors.redAccent,
        Colors.greenAccent,
        Colors.yellowAccent,
        Colors.blueAccent
      ]));
    } else if (championship == 'Serie B') {
      return Border.all(color: Colors.green);
    } else if (championship == 'Copa Do Brasil') {
      return const GradientBoxBorder(
          gradient: SweepGradient(
              colors: [Colors.blue, Colors.green, Colors.yellow]));
    }
    return Border.all(color: Colors.black);
  }

  Future<Widget?> _userImage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getString('image') != null) {
      return Container(
        margin: const EdgeInsets.all(10),
        child: PopupMenuButton(
          tooltip: 'Mostrar opções',
          icon: CircleAvatar(
            backgroundImage: NetworkImage(prefs.getString('image')!),
            maxRadius: 20,
          ),
          itemBuilder: (context) => [
            PopupMenuItem(
              child: const Text('Perfil'),
              onTap: () async {
                User user = User();
                SharedPreferences prefs = await SharedPreferences.getInstance();
                await user.getProfile(prefs.getInt('id')!);
                if (context.mounted) {
                  Navigator.of(context).push(MaterialPageRoute(builder: (_) {
                    return UserProfile(
                      user: user,
                    );
                  }));
                }
              },
            ),
            PopupMenuItem(
              onTap: () {
                Navigator.of(context).pushNamed('/settings');
              },
              child: const Text('Configurações'),
            ),
            PopupMenuItem(
              onTap: () {
                prefs.clear();
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                    builder: (context) => const LoginPage(),
                  ),
                  (Route<dynamic> route) => false,
                );
              },
              child: const Text('Sair'),
            ),
          ],
        ),
      );
    }
    return Container(
      margin: const EdgeInsets.all(10),
      child: IconButton(
          iconSize: 20,
          icon: const CircleAvatar(
              backgroundImage: AssetImage('yuri.jpg'), maxRadius: 20),
          onPressed: () => PopupMenuButton(
                itemBuilder: (context) => [
                  PopupMenuItem(
                    onTap: () async {
                      User user = User();
                      SharedPreferences prefs =
                          await SharedPreferences.getInstance();
                      await user.getProfile(prefs.getInt('id')!);
                      if (context.mounted) {
                        Navigator.of(context)
                            .push(MaterialPageRoute(builder: (_) {
                          return UserProfile(
                            user: user,
                          );
                        }));
                      }
                    },
                    child: const Text('Perfil'),
                  ),
                  PopupMenuItem(
                    onTap: () {
                      Navigator.of(context).pushNamed('/settings');
                    },
                    child: const Text('Configurações'),
                  ),
                  PopupMenuItem(
                    onTap: () {
                      prefs.clear();
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(
                          builder: (context) => const LoginPage(),
                        ),
                        (Route<dynamic> route) => false,
                      );
                    },
                    child: const Text('Sair'),
                  ),
                ],
              )),
    );
  }
}
