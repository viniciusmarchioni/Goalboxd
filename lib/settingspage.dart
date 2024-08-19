import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<StatefulWidget> createState() => SettingsState();
}

class SettingsState extends State {
  late bool song;
  late bool vibration;
  late bool notification;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Configurações"),
        flexibleSpace: Container(
            decoration: const BoxDecoration(
                gradient: LinearGradient(colors: [Colors.blue, Colors.white]))),
      ),
      body: Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(),
          Column(children: [
            FutureBuilder(
              future: _getSettings(0),
              builder: (context, snapshot) {
                song = snapshot.data ?? true;
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.music_note,
                      color: Colors.blue,
                    ),
                    Switch(
                      activeColor: Colors.blue,
                      value: song,
                      onChanged: (value) async {
                        await _setSettings(value, 0);
                        setState(() {
                          song = value;
                        });
                      },
                    ),
                  ],
                );
              },
            ),
            FutureBuilder(
              future: _getSettings(1),
              builder: (context, snapshot) {
                vibration = snapshot.data ?? true;
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.vibration,
                      color: Colors.blue,
                    ),
                    Switch(
                      activeColor: Colors.blue,
                      value: vibration,
                      onChanged: (value) async {
                        await _setSettings(value, 1);
                        setState(() {
                          vibration = value;
                        });
                      },
                    ),
                  ],
                );
              },
            ),
            FutureBuilder(
              future: _getSettings(2),
              builder: (context, snapshot) {
                notification = snapshot.data ?? true;
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.notifications,
                      color: Colors.blue,
                    ),
                    Switch(
                      activeColor: Colors.blue,
                      value: notification,
                      onChanged: (value) async {
                        await _setSettings(value, 2);
                        setState(() {
                          notification = value;
                        });
                      },
                    ),
                  ],
                );
              },
            ),
          ]),
          Column(
            children: [
              TextButton(
                  style: const ButtonStyle(
                      foregroundColor: MaterialStatePropertyAll(Colors.blue)),
                  onPressed: () {
                    Navigator.of(context).pushNamed('/about');
                  },
                  child: const Text("--Sobre--")),
              ElevatedButton(
                  //Deletar conta
                  onPressed: () {
                    Navigator.of(context).pushNamed('/delete');
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  child: const Text(
                    "Deletar conta",
                    style: TextStyle(color: Colors.white),
                  ))
            ],
          ),
        ],
      )),
    );
  }

  Future<void> _setSettings(bool value, int config) async {
    /*
    0 to set songs
    1 to set vibration
    ... to set notifications
    */
    SharedPreferences prefs = await SharedPreferences.getInstance();
    switch (config) {
      case (0):
        prefs.setBool('song', value);
      case (1):
        prefs.setBool('vibration', value);
      default:
        prefs.setBool('notification', value);
    }
  }

  Future<bool> _getSettings(int config) async {
    /*
    0 to get songs
    1 to get vibration
    ... to get notification
    */
    SharedPreferences prefs = await SharedPreferences.getInstance();
    switch (config) {
      case (0):
        return prefs.getBool('song') ?? true;
      case (1):
        return prefs.getBool('vibration') ?? true;
      default:
        return prefs.getBool('notification') ?? true;
    }
  }
}
