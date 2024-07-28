import 'package:flutter/material.dart';
import 'package:goalboxd/gamepage.dart';
import 'package:goalboxd/main.dart';
import 'package:goalboxd/obj/games.dart';
import 'package:goalboxd/obj/requests.dart';
import 'package:goalboxd/userprofile.dart';
import 'package:gradient_borders/gradient_borders.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Menu extends StatelessWidget {
  const Menu({super.key});

  @override
  Widget build(BuildContext context) {
    return const MenuPage();
  }
}

class MenuPage extends StatefulWidget {
  const MenuPage({super.key});

  @override
  State<StatefulWidget> createState() {
    return _MyHomePageState();
  }
}

class _MyHomePageState extends State<MenuPage> {
  int atual = 0;
  late Future<List<dynamic>> _futureGames;
  late Future<List<dynamic>> _futureNowGames;
  late Future<List<dynamic>> _futureTodayGames;

  @override
  void initState() {
    super.initState();
    _futureGames = Requests.getRiseGames();
    _futureNowGames = Requests.getNowGames();
    _futureTodayGames = Requests.getTodayGames();
  }

  Future<void> _refreshGames() async {
    setState(() {
      _futureGames = Requests.getRiseGames();
    });
  }

  Future<void> _refreshNowGames() async {
    setState(() {
      _futureNowGames = Requests.getNowGames();
    });
  }

  Future<void> _refreshTodayGames() async {
    setState(() {
      _futureTodayGames = Requests.getTodayGames();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
            decoration: const BoxDecoration(
                gradient: LinearGradient(colors: [Colors.blue, Colors.white]))),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("Goalboxd", style: TextStyle(color: Colors.black)),
            Container(
              margin: const EdgeInsets.all(10),
              child: FutureBuilder(
                future: image(),
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
      ),
      body: Column(
        children: [
          NavigationBar(
            backgroundColor: Colors.white,
            selectedIndex: atual,
            destinations: const [
              NavigationDestination(
                  icon: Icon(Icons.fireplace), label: 'Em alta'),
              NavigationDestination(icon: Icon(Icons.timer), label: 'Ao vivo'),
              NavigationDestination(icon: Icon(Icons.today), label: 'De hoje'),
            ],
            labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
            onDestinationSelected: (value) {
              setState(() {
                atual = value;
              });
            },
          ),
          Expanded(child: _conteudo(atual)),
        ],
      ),
    );
  }

  Widget _conteudo(int index) {
    if (index == 0) {
      return FutureBuilder(
        future: _futureGames,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            return RefreshIndicator(
              onRefresh: _refreshGames,
              child: ListView(
                children: [
                  for (Games game in snapshot.data ?? [])
                    _listPlaceHolder(game),
                ],
              ),
            );
          }
        },
      );
    } else if (index == 1) {
      return FutureBuilder(
        future: _futureNowGames,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            return RefreshIndicator(
              onRefresh: _refreshNowGames,
              child: ListView(
                children: [
                  for (Games game in snapshot.data ?? [])
                    _listPlaceHolder(game),
                ],
              ),
            );
          }
        },
      );
    } else {
      return FutureBuilder(
        future: _futureTodayGames,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            return RefreshIndicator(
              onRefresh: _refreshTodayGames,
              child: ListView(
                children: [
                  for (Games game in snapshot.data ?? [])
                    _listPlaceHolder(game),
                ],
              ),
            );
          }
        },
      );
    }
  }

  GestureDetector _listPlaceHolder(Games game) {
    DateTime now = DateTime.now();
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(builder: (_) {
          return GamePage(
            game: game,
          );
        }));
      },
      child: Container(
        height: 100,
        margin: const EdgeInsets.all(5),
        decoration: BoxDecoration(
            border: _borderDefine(game.championship),
            borderRadius: const BorderRadius.all(Radius.circular(10))),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            game.type == GameType.football
                ? const Icon(Icons.sports_soccer)
                : const Icon(Icons.sports_basketball_outlined),
            Text("${game.team1name} ${game.scorebord()} ${game.team2name}"),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (now.isBefore(game.date)) ...[
                  const Icon(Icons.timer_sharp),
                  Text(
                      '${game.date.hour.toString()}:${game.date.minute.toString()}h')
                ] else ...[
                  const Icon(Icons.star_half_rounded),
                  Text(game.rate.toStringAsFixed(1))
                ]
              ],
            )
          ],
        ),
      ),
    );
  }
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
  }
  return Border.all(color: Colors.red);
}

Future<Widget?> image() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  if (prefs.getString('image') != null) {
    return Container(
      margin: const EdgeInsets.all(10),
      child: PopupMenuButton(
        icon: CircleAvatar(
          backgroundImage: NetworkImage(prefs.getString('image')!),
          maxRadius: 20,
        ),
        itemBuilder: (context) => [
          PopupMenuItem(
            child: const Text('Perfil'),
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (_) {
                return const UserProfile();
              }));
            },
          ),
          const PopupMenuItem(
            child: Text('Configurações'),
          ),
          PopupMenuItem(
            onTap: () {
              prefs.clear();
              Navigator.of(context)
                  .pushReplacement(MaterialPageRoute(builder: (_) {
                return const MyApp();
              }));
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
                const PopupMenuItem(
                  onTap: null,
                  child: Text('Perfil'),
                ),
                const PopupMenuItem(
                  onTap: null,
                  child: Text('Configurações'),
                ),
                PopupMenuItem(
                  onTap: () {
                    prefs.clear();
                    Navigator.of(context).pushReplacementNamed('/home');
                  },
                  child: const Text('Sair'),
                ),
              ],
            )),
  );
}
