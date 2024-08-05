import 'package:flutter/material.dart';
import 'package:goalboxd/gamepage.dart';
import 'package:goalboxd/main.dart';
import 'package:goalboxd/obj/games.dart';
import 'package:goalboxd/obj/user.dart';
import 'package:goalboxd/userprofile.dart';
import 'package:gradient_borders/gradient_borders.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Menu extends StatefulWidget {
  const Menu({super.key});

  @override
  State<StatefulWidget> createState() {
    return _MyHomePageState();
  }
}

class _MyHomePageState extends State<Menu> with TickerProviderStateMixin {
  late User user;
  late Future<List<Games>> _futureGames;
  late Future<List<Games>> _futureNowGames;
  late Future<List<Games>> _futureTodayGames;
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _futureGames = Games.getRiseGames();
    _futureNowGames = Games.getNowGames();
    _futureTodayGames = Games.getTodayGames();
  }

  @override
  void dispose() {
    super.dispose();
    _tabController.dispose();
  }

  Future<void> _refreshGames() async {
    setState(() {
      _futureGames = Games.getRiseGames();
    });
  }

  Future<void> _refreshNowGames() async {
    setState(() {
      _futureNowGames = Games.getNowGames();
    });
  }

  Future<void> _refreshTodayGames() async {
    setState(() {
      _futureTodayGames = Games.getTodayGames();
    });
  }

  @override
  Widget build(BuildContext context) {
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
                  future: userImage(),
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
        body: Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              FutureBuilder(
                future: _futureGames,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                        child: CircularProgressIndicator(
                      color: Colors.blue,
                    ));
                  } else if (snapshot.hasError) {
                    return const Center(child: Text('Falha de conexão'));
                  } else {
                    return RefreshIndicator(
                      color: Colors.blue,
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
              ),
              FutureBuilder(
                future: _futureNowGames,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                        child: CircularProgressIndicator(
                      color: Colors.blue,
                    ));
                  } else if (snapshot.hasError) {
                    return const Center(child: Text('Falha de conexão'));
                  } else {
                    return RefreshIndicator(
                      color: Colors.blue,
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
              ),
              FutureBuilder(
                future: _futureTodayGames,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                        child: CircularProgressIndicator(
                      color: Colors.blue,
                    ));
                  } else if (snapshot.hasError) {
                    return const Center(child: Text('Falha de conexão'));
                  } else {
                    return RefreshIndicator(
                      color: Colors.blue,
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
              )
            ],
          ),
        ));
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
  } else if (championship == 'Copa Do Brasil') {
    return const GradientBoxBorder(
        gradient: SweepGradient(colors: [
      Colors.green,
      Color.fromARGB(255, 192, 176, 35),
    ]));
  }
  return Border.all(color: Colors.red);
}

Future<Widget?> userImage() async {
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
